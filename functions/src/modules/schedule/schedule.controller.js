const express  = require('express');
const router   = express.Router();
const Joi      = require('joi');
const rbac     = require('../../middleware/rbac.middleware');
const validate = require('../../middleware/validate.middleware');
const scheduleService = require('./schedule.service');

// GET /api/schedules — Search by from/to/date
router.get('/', async (req, res, next) => {
  try {
    const { from, to, date, operatorId, busId } = req.query;
    const schedules = await scheduleService.searchSchedules({ from, to, date, operatorId, busId });
    res.json({ data: schedules });
  } catch (err) { next(err); }
});

// GET /api/schedules/:id — Schedule detail with seat map
router.get('/:id', async (req, res, next) => {
  try {
    const schedule = await scheduleService.getScheduleById(req.params.id);
    if (!schedule) return res.status(404).json({ error: 'Schedule not found' });
    res.json({ data: schedule });
  } catch (err) { next(err); }
});

// POST /api/schedules — Admin creates schedule
const scheduleSchema = Joi.object({
  routeId:       Joi.string().required(),
  busId:         Joi.string().required(),
  operatorId:    Joi.string().required(),
  departureTime: Joi.string().isoDate().required(),
  capacity:      Joi.number().integer().min(1).max(60).required(),
  busClass:      Joi.string().valid('AC', 'NonAC').required(),
});

router.post('/', rbac('admin'), validate(scheduleSchema), async (req, res, next) => {
  try {
    const schedule = await scheduleService.createSchedule(req.body);
    res.status(201).json({ data: schedule });
  } catch (err) { next(err); }
});

// PUT /api/schedules/:id — Operator or admin updates status
router.put('/:id', rbac('admin', 'operator'), async (req, res, next) => {
  try {
    const { role, busId: operBusId } = req.user;
    if (role === 'operator') {
      const sc = await scheduleService.getScheduleById(req.params.id);
      if (!sc || sc.busId !== operBusId)
        return res.status(403).json({ error: 'Not your schedule' });
    }
    await scheduleService.updateSchedule(req.params.id, req.body);
    res.json({ message: 'Schedule updated' });
  } catch (err) { next(err); }
});

module.exports = router;
