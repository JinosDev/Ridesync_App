import 'package:hive_flutter/hive_flutter.dart';

/// Hive local key-value cache service for offline access
class HiveService {
  HiveService._();

  static const _bookingsBox = 'cached_bookings';
  static const _routesBox   = 'cached_routes';
  static const _userBox     = 'cached_user';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_bookingsBox);
    await Hive.openBox(_routesBox);
    await Hive.openBox(_userBox);
  }

  // ── Bookings ────────────────────────────────────────────────────────────

  /// Cache a confirmed booking for offline e-ticket access
  static Future<void> cacheBooking(Map<String, dynamic> booking) async {
    final box = Hive.box(_bookingsBox);
    await box.put(booking['bookingId'], booking);
  }

  static Map<String, dynamic>? getCachedBooking(String bookingId) {
    return Hive.box(_bookingsBox).get(bookingId) as Map<String, dynamic>?;
  }

  static List<Map<String, dynamic>> getAllCachedBookings() {
    return Hive.box(_bookingsBox).values.cast<Map<String, dynamic>>().toList();
  }

  // ── Routes ──────────────────────────────────────────────────────────────

  static Future<void> cacheRoutes(List<Map<String, dynamic>> routes) async {
    await Hive.box(_routesBox).put('routes', routes);
  }

  static List<Map<String, dynamic>> getCachedRoutes() {
    final data = Hive.box(_routesBox).get('routes');
    return data != null ? List<Map<String, dynamic>>.from(data) : [];
  }

  // ── User ─────────────────────────────────────────────────────────────────

  static Future<void> cacheUser(Map<String, dynamic> user) async {
    await Hive.box(_userBox).put('user', user);
  }

  static Map<String, dynamic>? getCachedUser() {
    return Hive.box(_userBox).get('user') as Map<String, dynamic>?;
  }

  static Future<void> clearUser() async {
    await Hive.box(_userBox).clear();
  }

  /// Clear all boxes on logout
  static Future<void> clearAll() async {
    await Hive.box(_bookingsBox).clear();
    await Hive.box(_routesBox).clear();
    await Hive.box(_userBox).clear();
  }
}
