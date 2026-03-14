/// All backend REST API endpoint paths
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register    = '/api/auth/register';
  static const String setRole     = '/api/auth/set-role';

  // Routes
  static const String routes      = '/api/routes';
  static String routeById(String id) => '/api/routes/$id';

  // Schedules
  static const String schedules   = '/api/schedules';
  static String scheduleById(String id)         => '/api/schedules/$id';
  static String scheduleSeats(String id)        => '/api/schedules/$id/seats';

  // Fare
  static const String fare        = '/api/fare';
  static String faresByRoute(String routeId)    => '/api/fares/$routeId';

  // Bookings
  static const String createBooking = '/api/bookings';
  static const String myBookings    = '/api/bookings/my';
  static String bookingById(String id)          => '/api/bookings/$id';
  static String cancelBooking(String id)        => '/api/bookings/$id/cancel';
  static String scheduleBookings(String id)     => '/api/bookings/schedule/$id';

  // Notifications
  static const String notifyBroadcast = '/api/notify/broadcast';
  static String notifyUser(String uid)          => '/api/notify/user/$uid';

  // Chatbot
  static const String chatbot     = '/api/chatbot/message';

  // Health
  static const String health      = '/api/health';
}
