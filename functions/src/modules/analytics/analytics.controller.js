const express = require('express');
const router  = express.Router();
const rbac    = require('../../middleware/rbac.middleware');
const { db }  = require('../../config/firebase.config');

// GET /api/analytics/bookings — Admin: booking stats aggregated
router.get('/bookings', rbac('admin'), async (req, res, next) => {
  try {
    const snap = await db.collection('bookings').get();
    const bookings = snap.docs.map(d => d.data());

    const total     = bookings.length;
    const confirmed = bookings.filter(b => b.status === 'confirmed').length;
    const cancelled = bookings.filter(b => b.status === 'cancelled').length;
    const revenue   = bookings
        .filter(b => b.status === 'confirmed')
        .reduce((sum, b) => sum + (b.fare || 0), 0);

    res.json({ data: { total, confirmed, cancelled, revenue } });
  } catch (err) { next(err); }
});

// GET /api/analytics/routes — Admin: most popular routes
router.get('/routes', rbac('admin'), async (req, res, next) => {
  try {
    const snap   = await db.collection('bookings').where('status', '==', 'confirmed').get();
    const counts = {};
    snap.docs.forEach(d => {
      const { scheduleId } = d.data();
      counts[scheduleId] = (counts[scheduleId] || 0) + 1;
    });
    const sorted = Object.entries(counts)
        .sort(([, a], [, b]) => b - a)
        .slice(0, 10)
        .map(([scheduleId, count]) => ({ scheduleId, count }));
    res.json({ data: sorted });
  } catch (err) { next(err); }
});

module.exports = router;
