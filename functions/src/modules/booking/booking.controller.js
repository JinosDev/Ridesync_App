const express  = require('express');
const router   = express.Router();
const Joi      = require('joi');
const validate = require('../../middleware/validate.middleware');
const bookingService = require('./booking.service');

const bookingSchema = Joi.object({
  scheduleId: Joi.string().required(),
  seatNo:     Joi.string().required(),
  fromStop:   Joi.string().required(),
  toStop:     Joi.string().required(),
});

// POST /api/bookings — Passenger creates booking (atomic seat lock)
router.post('/', validate(bookingSchema), async (req, res, next) => {
  try {
    const uid     = req.user.uid;
    const booking = await bookingService.createBooking({ ...req.body, passengerId: uid });
    res.status(201).json({ data: booking });
  } catch (err) { next(err); }
});

// GET /api/bookings/my — Passenger get own bookings
router.get('/my', async (req, res, next) => {
  try {
    const bookings = await bookingService.getBookingsByPassenger(req.user.uid);
    res.json({ data: bookings });
  } catch (err) { next(err); }
});

// GET /api/bookings/:id — Get single booking
router.get('/:id', async (req, res, next) => {
  try {
    const booking = await bookingService.getBookingById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Booking not found' });
    if (req.user.uid !== booking.passengerId && !['admin', 'operator'].includes(req.user.role))
      return res.status(403).json({ error: 'Access denied' });
    res.json({ data: booking });
  } catch (err) { next(err); }
});

// PUT /api/bookings/:id/cancel — Passenger cancels own booking
router.put('/:id/cancel', async (req, res, next) => {
  try {
    const booking = await bookingService.getBookingById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Booking not found' });
    if (req.user.uid !== booking.passengerId && req.user.role !== 'admin')
      return res.status(403).json({ error: 'Not your booking' });
    await bookingService.cancelBooking(req.params.id, booking);
    res.json({ message: 'Booking cancelled' });
  } catch (err) { next(err); }
});

// GET /api/bookings/schedule/:scheduleId — Operator gets manifest
router.get('/schedule/:scheduleId', async (req, res, next) => {
  try {
    if (!['operator', 'admin'].includes(req.user.role))
      return res.status(403).json({ error: 'Operator or admin only' });
    const bookings = await bookingService.getBookingsBySchedule(req.params.scheduleId);
    res.json({ data: bookings });
  } catch (err) { next(err); }
});

module.exports = router;
