const express    = require('express');
const router     = express.Router();
const rbac       = require('../../middleware/rbac.middleware');
const { db, messaging } = require('../../config/firebase.config');

// POST /api/notify/broadcast — Admin sends notification to a route's passengers
router.post('/broadcast', rbac('admin'), async (req, res, next) => {
  try {
    const { routeId, title, body, type = 'alert' } = req.body;
    if (!title || !body) return res.status(400).json({ error: 'title and body required' });

    // Find all passengers with active bookings on this route's schedules
    const schedulesSnap = await db.collection('schedules')
        .where('routeId', '==', routeId)
        .where('status', '==', 'active')
        .get();
    const scheduleIds = schedulesSnap.docs.map(d => d.id);

    const bookingsSnap = await db.collection('bookings')
        .where('scheduleId', 'in', scheduleIds.slice(0, 10))
        .where('status', '==', 'confirmed')
        .get();

    const passengerIds = [...new Set(bookingsSnap.docs.map(d => d.data().passengerId))];

    // Get FCM tokens
    const userDocs = await Promise.all(
      passengerIds.map(uid => db.collection('users').doc(uid).get())
    );
    const tokens = userDocs
        .map(d => d.data()?.fcmToken)
        .filter(Boolean);

    if (tokens.length > 0) {
      await messaging.sendEachForMulticast({ tokens, notification: { title, body } });
    }

    // Write notifications to Firestore for in-app display
    const batch = db.batch();
    for (const uid of passengerIds) {
      const ref = db.collection('notifications').doc(uid).collection('items').doc();
      batch.set(ref, { title, body, type, isRead: false, createdAt: new Date() });
    }
    await batch.commit();

    res.json({ message: `Notification sent to ${passengerIds.length} passengers`, tokensSent: tokens.length });
  } catch (err) { next(err); }
});

// POST /api/notify/user/:uid — Admin sends notification to specific user
router.post('/user/:uid', rbac('admin', 'operator'), async (req, res, next) => {
  try {
    const { title, body, type = 'alert' } = req.body;
    const { uid } = req.params;

    const userDoc = await db.collection('users').doc(uid).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (fcmToken) {
      await messaging.send({ token: fcmToken, notification: { title, body } });
    }

    const ref = db.collection('notifications').doc(uid).collection('items').doc();
    await ref.set({ title, body, type, isRead: false, createdAt: new Date() });

    res.json({ message: 'Notification sent' });
  } catch (err) { next(err); }
});

module.exports = router;
