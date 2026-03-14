/// All UI text strings — centralised for easy localisation later
class AppStrings {
  AppStrings._();

  // App
  static const String appName         = 'RideSync';
  static const String appTagline      = 'Your Smart Bus Companion';

  // Auth
  static const String login           = 'Login';
  static const String register        = 'Register';
  static const String logout          = 'Logout';
  static const String email           = 'Email';
  static const String password        = 'Password';
  static const String name            = 'Full Name';
  static const String phone           = 'Phone Number';
  static const String forgotPassword  = 'Forgot Password?';
  static const String noAccount       = "Don't have an account? ";
  static const String hasAccount      = 'Already have an account? ';

  // Home / Search
  static const String searchRoute     = 'Search Route';
  static const String from            = 'From';
  static const String to              = 'To';
  static const String selectDate      = 'Select Date';
  static const String searchBuses     = 'Search Buses';

  // Booking
  static const String availableRoutes = 'Available Schedules';
  static const String selectSeat      = 'Select Seat';
  static const String confirmBooking  = 'Confirm Booking';
  static const String payAndBook      = 'Pay & Book';
  static const String bookingSuccess  = 'Booking Confirmed!';
  static const String myBookings      = 'My Bookings';
  static const String cancelBooking   = 'Cancel Booking';

  // Fare
  static const String fareEstimate    = 'Fare Estimate';
  static const String fareBreakdown   = 'Fare Breakdown';
  static const String baseFare        = 'Base Fare';
  static const String totalFare       = 'Total Fare';

  // Tracking
  static const String liveTracking    = 'Live Tracking';
  static const String signalLost      = 'Location signal lost';
  static const String eta             = 'ETA';
  static const String currentStop     = 'Current Stop';

  // Operator
  static const String startTrip       = 'Start Trip';
  static const String endTrip         = 'End Trip';
  static const String gpsBroadcasting = 'GPS Broadcasting';
  static const String gpsInactive     = 'GPS Inactive';
  static const String reportDelay     = 'Report Delay';
  static const String passengers      = 'Passengers';

  // Errors
  static const String genericError    = 'Something went wrong. Please try again.';
  static const String networkError    = 'No internet connection.';
  static const String sessionExpired  = 'Session expired. Please log in again.';
  static const String seatTaken       = 'This seat has already been booked.';

  // Empty states
  static const String noBookings      = 'No bookings yet';
  static const String noSchedules     = 'No schedules available for this route';
  static const String noNotifications = 'No notifications';
}
