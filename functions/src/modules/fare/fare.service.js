const { db } = require('../../config/firebase.config');

// Class multipliers from architecture doc
const CLASS_MULTIPLIERS = { NonAC: 1.0, AC: 1.4 };
const BASE_FARE_LKR = 20;
const RATE_PER_KM   = 5;

async function calculateFare({ scheduleId, fromStop, toStop, busClass }) {
  // Get schedule → routeId
  const scheduleDoc = await db.collection('schedules').doc(scheduleId).get();
  if (!scheduleDoc.exists) throw Object.assign(new Error('Schedule not found'), { status: 404 });

  const { routeId } = scheduleDoc.data();
  const routeDoc    = await db.collection('routes').doc(routeId).get();
  if (!routeDoc.exists) throw Object.assign(new Error('Route not found'), { status: 404 });

  const route  = routeDoc.data();
  const fromSt = route.stops.find(s => s.name === fromStop);
  const toSt   = route.stops.find(s => s.name === toStop);

  if (!fromSt || !toSt) throw Object.assign(new Error('Invalid stops'), { status: 400 });

  const segmentKm       = Math.abs(toSt.distFromStartKm - fromSt.distFromStartKm);
  const classMultiplier = CLASS_MULTIPLIERS[busClass] || 1.0;
  const total           = Math.round(BASE_FARE_LKR + segmentKm * RATE_PER_KM * classMultiplier);

  return {
    total,
    baseFare:        BASE_FARE_LKR,
    segmentKm:       parseFloat(segmentKm.toFixed(2)),
    ratePerKm:       RATE_PER_KM,
    classMultiplier,
    busClass:        busClass || 'NonAC',
  };
}

async function getFaresByRoute(routeId) {
  const snap = await db.collection('fares').where('routeId', '==', routeId).get();
  return snap.docs.map(d => ({ fareId: d.id, ...d.data() }));
}

module.exports = { calculateFare, getFaresByRoute };
