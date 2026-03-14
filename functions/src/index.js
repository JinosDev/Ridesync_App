const functions = require('firebase-functions');
const app = require('./app');

// ── HTTP entry point for Firebase Cloud Functions ──────────────────────────
exports.api = functions
  .region('asia-southeast1')
  .https.onRequest(app);

// ── RTDB-triggered ETA recalculation ──────────────────────────────────────
const { admin } = require('./config/firebase.config');

exports.recalculateETA = functions
  .region('asia-southeast1')
  .database.ref('/busLocations/{busId}')
  .onWrite(async (change, context) => {
    if (!change.after.exists()) return null;
    const { busId } = context.params;
    const location  = change.after.val();

    try {
      const schedulesSnap = await admin.firestore()
        .collection('schedules')
        .where('busId', '==', busId)
        .where('status', '==', 'active')
        .limit(1)
        .get();

      if (schedulesSnap.empty) return null;

      const scheduleDoc  = schedulesSnap.docs[0];
      const { routeId }  = scheduleDoc.data();

      const routeDoc = await admin.firestore().collection('routes').doc(routeId).get();
      const route    = routeDoc.data();
      if (!route) return null;

      const currentStop    = scheduleDoc.data().currentStop;
      const currentStopIdx = route.stops.findIndex(s => s.name === currentStop);
      if (currentStopIdx === -1) return null;

      const endStop      = route.stops[route.stops.length - 1];
      const remainingKm  = endStop.distFromStartKm - route.stops[currentStopIdx].distFromStartKm;
      const avgSpeedKmh  = Math.max(location.speed || 30, 10);
      const etaMs        = Date.now() + (remainingKm / avgSpeedKmh) * 3600 * 1000;

      await admin.database()
        .ref(`/tripStatus/${scheduleDoc.id}`)
        .update({ eta: etaMs, lastUpdatedAt: Date.now() });

      return null;
    } catch (err) {
      console.error('ETA calculation failed:', err);
      return null;
    }
  });
