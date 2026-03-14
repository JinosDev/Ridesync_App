import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_client.dart';
import '../../../services/hive_service.dart';
import '../../../core/constants/api_endpoints.dart';
import 'booking_model.dart';
import 'schedule_model.dart';

class BookingRepository {
  final _auth = FirebaseAuth.instance;

  /// GET /api/schedules?from=X&to=Y&date=YYYY-MM-DD
  Future<List<ScheduleModel>> searchSchedules({
    required String from,
    required String to,
    required String date,
  }) async {
    final token = await _auth.currentUser!.getIdToken();
    final json = await ApiClient.get(
      endpoint: ApiEndpoints.schedules,
      token: token!,
      queryParams: {'from': from, 'to': to, 'date': date},
    );
    return (json['data'] as List)
        .map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/schedules/:id
  Future<ScheduleModel> getScheduleDetail(String scheduleId) async {
    final token = await _auth.currentUser!.getIdToken();
    final json = await ApiClient.get(
      endpoint: ApiEndpoints.scheduleById(scheduleId),
      token: token!,
    );
    return ScheduleModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// POST /api/bookings — Firestore transaction on server for atomic seat lock
  Future<BookingModel> createBooking({
    required String scheduleId,
    required String seatNo,
    required String fromStop,
    required String toStop,
  }) async {
    final token = await _auth.currentUser!.getIdToken();
    final json = await ApiClient.post(
      endpoint: ApiEndpoints.createBooking,
      token: token!,
      body: {
        'scheduleId': scheduleId,
        'seatNo':     seatNo,
        'fromStop':   fromStop,
        'toStop':     toStop,
      },
    );
    final booking = BookingModel.fromJson(json['data'] as Map<String, dynamic>);
    await HiveService.cacheBooking(booking.toJson());
    return booking;
  }

  /// GET /api/bookings/my
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final token = await _auth.currentUser!.getIdToken();
      final json = await ApiClient.get(
        endpoint: ApiEndpoints.myBookings,
        token: token!,
      );
      final bookings = (json['data'] as List)
          .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
          .toList();
      for (final b in bookings) {
        await HiveService.cacheBooking(b.toJson());
      }
      return bookings;
    } catch (_) {
      // Fallback to Hive cache when offline
      final cached = HiveService.getAllCachedBookings();
      if (cached.isEmpty) rethrow;
      return cached.map((b) => BookingModel.fromJson(b)).toList();
    }
  }

  /// PUT /api/bookings/:id/cancel
  Future<void> cancelBooking(String bookingId) async {
    final token = await _auth.currentUser!.getIdToken();
    await ApiClient.put(
      endpoint: ApiEndpoints.cancelBooking(bookingId),
      token: token!,
      body: {},
    );
  }
}
