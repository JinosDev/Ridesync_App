const { db } = require('../../config/firebase.config');

const COLLECTION = 'routes';

async function getAllRoutes() {
  const snap = await db.collection(COLLECTION).orderBy('name').get();
  return snap.docs.map(d => ({ routeId: d.id, ...d.data() }));
}

async function getRouteById(routeId) {
  const doc = await db.collection(COLLECTION).doc(routeId).get();
  if (!doc.exists) return null;
  return { routeId: doc.id, ...doc.data() };
}

async function createRoute(data) {
  const ref = await db.collection(COLLECTION).add({ ...data, createdAt: new Date() });
  return { routeId: ref.id, ...data };
}

async function updateRoute(routeId, data) {
  await db.collection(COLLECTION).doc(routeId).update({ ...data, updatedAt: new Date() });
}

module.exports = { getAllRoutes, getRouteById, createRoute, updateRoute };
