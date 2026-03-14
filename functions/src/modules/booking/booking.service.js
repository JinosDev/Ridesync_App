const { db, admin } = require('../../config/firebase.config');
const fareService   = require('../fare/fare.service');

const BOOKINGS   = 'bookings';
const SCHEDULES  = 'schedules';

async function createBooking({ scheduleId, seatNo, fromStop, toStop, passengerId }) {
  const scheduleRef = db.collection(SCHEDULES).doc(scheduleId);

  // Run inside Firestore transaction to prevent double-booking
  const booking = await db.runTransaction(async (tx) => {
    const scheduleSnap = await tx.get(scheduleRef);
    if (!scheduleSnap.exists) throw Object.assign(new Error('Schedule not found'), { status: 404 });

    const schedule = scheduleSnap.data();
    if (schedule.seatMap[seatNo] !== null && schedule.seatMap[seatNo] !== undefined) {
      throw Object.assign(new Error('Seat already booked. Please choose another.'), { status: 409 });
    }
    if (!Object.prototype.hasOwnProperty.call(schedule.seatMap, seatNo)) {
      throw Object.assign(new Error('Invalid seat number'), { status: 400 });
    }

    // Calculate fare
    const fareBreakdown = await fareService.calculateFare({
      scheduleId,
      fromStop,
      toStop,
      busClass: schedule.busClass || 'NonAC',
    });

    const bookingRef = db.collection(BOOKINGS).doc();
    const bookingData = {
      bookingId:    bookingRef.id,
      passengerId,
      scheduleId,
      seatNo,
      fromStop,
      toStop,
      fare:         fareBreakdown.total,
      fareBreakdown,
      status:       'confirmed',
      bookedAt:     new Date().toISOString(),
      createdAt:    admin.firestore.FieldValue.serverTimestamp(),
    };

    // Atomically mark seat as taken
    tx.set(bookingRef, bookingData);
    tx.update(scheduleRef, { [`seatMap.${seatNo}`]: passengerId });

    return bookingData;
  });

  return booking;
}

async function getBookingsByPassenger(passengerId) {
  const snap = await db.collection(BOOKINGS)
      .where('passengerId', '==', passengerId)
      .orderBy('bookedAt', 'desc')
      .get();
  return snap.docs.map(d => d.data());
}

async function getBookingById(bookingId) {
  const doc = await db.collection(BOOKINGS).doc(bookingId).get();
  return doc.exists ? doc.data() : null;
}

async function cancelBooking(bookingId, booking) {
  const scheduleRef = db.collection(SCHEDULES).doc(booking.scheduleId);
  await db.runTransaction(async (tx) => {
    tx.update(db.collection(BOOKINGS).doc(bookingId), { status: 'cancelled' });
    tx.update(scheduleRef, { [`seatMap.${booking.seatNo}`]: null });
  });
}

async function getBookingsBySchedule(scheduleId) {
  const snap = await db.collection(BOOKINGS)
      .where('scheduleId', '==', scheduleId)
      .where('status', '==', 'confirmed')
      .get();
  return snap.docs.map(d => d.data());
}

module.exports = { createBooking, getBookingsByPassenger, getBookingById, cancelBooking, getBookingsBySchedule };
