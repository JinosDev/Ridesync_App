const express  = require('express');
const router   = express.Router();
const fareService = require('./fare.service');

// GET /api/fare?scheduleId=X&fromStop=Y&toStop=Z&class=AC
router.get('/', async (req, res, next) => {
  try {
    const { scheduleId, fromStop, toStop, class: busClass } = req.query;
    if (!scheduleId || !fromStop || !toStop) {
      return res.status(400).json({ error: 'scheduleId, fromStop, toStop are required' });
    }
    const breakdown = await fareService.calculateFare({ scheduleId, fromStop, toStop, busClass: busClass || 'NonAC' });
    res.json({ data: breakdown });
  } catch (err) { next(err); }
});

// GET /api/fares/:routeId — Fare table for a route
router.get('/:routeId', async (req, res, next) => {
  try {
    const fares = await fareService.getFaresByRoute(req.params.routeId);
    res.json({ data: fares });
  } catch (err) { next(err); }
});

module.exports = router;
