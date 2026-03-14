const { db, admin } = require('../../config/firebase.config');
const COLLECTION = 'schedules';

// Generate seat map object: { "A1": null, "A2": null, ... }
function generateSeatMap(capacity) {
  const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  const cols = 4;
  const seatMap = {};
  let count = 0;
  for (const row of rows) {
    for (let col = 1; col <= cols; col++) {
      if (count >= capacity) break;
      seatMap[`${row}${col}`] = null;
      count++;
    }
    if (count >= capacity) break;
  }
  return seatMap;
}

async function searchSchedules({ from, to, date, operatorId, busId }) {
  let query = db.collection(COLLECTION);

  if (operatorId) query = query.where('operatorId', '==', operatorId);
  if (busId)      query = query.where('busId', '==', busId);

  const snap = await query.get();
  let results = snap.docs.map(d => ({ scheduleId: d.id, ...d.data() }));

  // Client-side filter for date, from, to (until full-text search is implemented)
  if (date) {
    const targetDate = new Date(date);
    results = results.filter(s => {
      const depDate = new Date(s.departureTime);
      return depDate.toDateString() === targetDate.toDateString();
    });
  }

  // Enrich with route info
  const routeIds = [...new Set(results.map(s => s.routeId))];
  const routeDocs = await Promise.all(routeIds.map(id => db.collection('routes').doc(id).get()));
  const routeMap = {};
  routeDocs.forEach(d => { if (d.exists) routeMap[d.id] = d.data(); });

  return results.map(s => ({
    ...s,
    routeName:  routeMap[s.routeId]?.name,
    startPoint: routeMap[s.routeId]?.startPoint,
    endPoint:   routeMap[s.routeId]?.endPoint,
  }));
}

async function getScheduleById(scheduleId) {
  const doc = await db.collection(COLLECTION).doc(scheduleId).get();
  if (!doc.exists) return null;
  const data = doc.data();

  // Enrich with route info
  const routeDoc = await db.collection('routes').doc(data.routeId).get();
  const route = routeDoc.data() || {};

  // Enrich with bus info
  const busDoc = await db.collection('buses').doc(data.busId).get();
  const bus    = busDoc.data() || {};

  return {
    scheduleId: doc.id,
    ...data,
    routeName:  route.name,
    startPoint: route.startPoint,
    endPoint:   route.endPoint,
    capacity:   bus.capacity || Object.keys(data.seatMap || {}).length,
    busClass:   bus.busClass || data.busClass,
  };
}

async function createSchedule(data) {
  const seatMap = generateSeatMap(data.capacity);
  const ref = await db.collection(COLLECTION).add({
    ...data,
    seatMap,
    status:        'scheduled',
    delayMinutes:  0,
    currentStop:   null,
    createdAt:     new Date(),
  });
  return { scheduleId: ref.id, ...data, seatMap };
}

async function updateSchedule(scheduleId, data) {
  const allowed = ['status', 'delayMinutes', 'currentStop', 'eta'];
  const update = {};
  allowed.forEach(k => { if (data[k] !== undefined) update[k] = data[k]; });
  update.updatedAt = new Date();
  await db.collection(COLLECTION).doc(scheduleId).update(update);
}

module.exports = { searchSchedules, getScheduleById, createSchedule, updateSchedule };
