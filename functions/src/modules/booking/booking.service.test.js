const bookingService = require('../booking.service');

describe('Booking Service', () => {
  test('exports createBooking function', () => {
    expect(typeof bookingService.createBooking).toBe('function');
  });
  test('exports cancelBooking function', () => {
    expect(typeof bookingService.cancelBooking).toBe('function');
  });
  test('exports getBookingsByPassenger function', () => {
    expect(typeof bookingService.getBookingsByPassenger).toBe('function');
  });
});
