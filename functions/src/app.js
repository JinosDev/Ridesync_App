require('dotenv').config();
const express    = require('express');
const helmet     = require('helmet');
const cors       = require('cors');
const rateLimit  = require('express-rate-limit');

const authMiddleware      = require('./middleware/auth.middleware');
const { errorHandler }    = require('./middleware/errorHandler.middleware');
const bookingRoutes       = require('./modules/booking/booking.controller');
const routeRoutes         = require('./modules/route/route.controller');
const fareRoutes          = require('./modules/fare/fare.controller');
const scheduleRoutes      = require('./modules/schedule/schedule.controller');
const notificationRoutes  = require('./modules/notification/notification.controller');
const analyticsRoutes     = require('./modules/analytics/analytics.controller');
const chatbotRoutes       = require('./modules/chatbot/chatbot.proxy');

const app = express();

// ── Security headers ─────────────────────────────────────────────────────
app.use(helmet());
app.use(cors({ origin: true }));

// ── Body parser ───────────────────────────────────────────────────────────
app.use(express.json({ limit: '10kb' }));

// ── Global rate limit ─────────────────────────────────────────────────────
app.use('/api/', rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000,
  max:      parseInt(process.env.RATE_LIMIT_MAX) || 100,
  standardHeaders: true,
  legacyHeaders:   false,
  message: { error: 'Too many requests, please try again later.' },
}));

// ── Stricter rate limit on booking ────────────────────────────────────────
app.use('/api/bookings', rateLimit({
  windowMs: 60 * 1000,
  max:      parseInt(process.env.BOOKING_RATE_LIMIT_MAX) || 10,
  message:  { error: 'Booking rate limit exceeded.' },
}));

// ── Health check (no auth) ────────────────────────────────────────────────
app.get('/api/health', (_, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

// ── Protected routes ──────────────────────────────────────────────────────
app.use('/api', authMiddleware);
app.use('/api/routes',        routeRoutes);
app.use('/api/schedules',     scheduleRoutes);
app.use('/api/fare',          fareRoutes);
app.use('/api/bookings',      bookingRoutes);
app.use('/api/notify',        notificationRoutes);
app.use('/api/analytics',     analyticsRoutes);
app.use('/api/chatbot',       chatbotRoutes);

// ── Auth routes ───────────────────────────────────────────────────────────
const authController = require('./modules/auth/auth.controller');
app.use('/api/auth', authController);

// ── 404 ───────────────────────────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ error: `Route not found: ${req.method} ${req.path}` }));

// ── Error handler ─────────────────────────────────────────────────────────
app.use(errorHandler);

module.exports = app;
