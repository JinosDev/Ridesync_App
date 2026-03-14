import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../data/booking_model.dart';
import '../data/schedule_model.dart';

// ── Repositories ─────────────────────────────────────────────────────────────

final bookingRepositoryProvider = Provider((ref) => BookingRepository());

// ── Schedule Search ───────────────────────────────────────────────────────────

class ScheduleSearchParams {
  final String from, to, date;
  const ScheduleSearchParams({required this.from, required this.to, required this.date});
  @override bool operator ==(Object o) => o is ScheduleSearchParams && from == o.from && to == o.to && date == o.date;
  @override int get hashCode => Object.hash(from, to, date);
}

final scheduleProvider = FutureProvider.family<List<ScheduleModel>, ScheduleSearchParams>((ref, params) {
  return ref.watch(bookingRepositoryProvider).searchSchedules(
    from: params.from, to: params.to, date: params.date,
  );
});

final scheduleDetailProvider = FutureProvider.family<ScheduleModel, String>((ref, scheduleId) {
  return ref.watch(bookingRepositoryProvider).getScheduleDetail(scheduleId);
});

// ── Booking Flow StateNotifier ────────────────────────────────────────────────

enum BookingStatus { idle, loading, success, error }

class BookingState {
  final BookingStatus status;
  final String? selectedScheduleId;
  final String? selectedSeatNo;
  final String? fromStop;
  final String? toStop;
  final double? estimatedFare;
  final BookingModel? confirmedBooking;
  final String? errorMessage;

  const BookingState({
    this.status           = BookingStatus.idle,
    this.selectedScheduleId,
    this.selectedSeatNo,
    this.fromStop,
    this.toStop,
    this.estimatedFare,
    this.confirmedBooking,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status, String? selectedScheduleId, String? selectedSeatNo,
    String? fromStop, String? toStop, double? estimatedFare,
    BookingModel? confirmedBooking, String? errorMessage,
  }) => BookingState(
    status:              status             ?? this.status,
    selectedScheduleId:  selectedScheduleId ?? this.selectedScheduleId,
    selectedSeatNo:      selectedSeatNo     ?? this.selectedSeatNo,
    fromStop:            fromStop           ?? this.fromStop,
    toStop:              toStop             ?? this.toStop,
    estimatedFare:       estimatedFare      ?? this.estimatedFare,
    confirmedBooking:    confirmedBooking   ?? this.confirmedBooking,
    errorMessage:        errorMessage       ?? this.errorMessage,
  );
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repo;
  BookingNotifier(this._repo) : super(const BookingState());

  void selectSchedule(String id) => state = state.copyWith(selectedScheduleId: id);
  void selectSeat(String seatNo) => state = state.copyWith(selectedSeatNo: seatNo);
  void selectStops(String from, String to) => state = state.copyWith(fromStop: from, toStop: to);
  void setFare(double fare) => state = state.copyWith(estimatedFare: fare);

  Future<void> confirmBooking() async {
    if (state.selectedScheduleId == null || state.selectedSeatNo == null ||
        state.fromStop == null || state.toStop == null) return;
    state = state.copyWith(status: BookingStatus.loading);
    try {
      final booking = await _repo.createBooking(
        scheduleId: state.selectedScheduleId!,
        seatNo:     state.selectedSeatNo!,
        fromStop:   state.fromStop!,
        toStop:     state.toStop!,
      );
      state = state.copyWith(status: BookingStatus.success, confirmedBooking: booking);
    } catch (e) {
      state = state.copyWith(status: BookingStatus.error, errorMessage: e.toString());
    }
  }

  void reset() => state = const BookingState();
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref.watch(bookingRepositoryProvider));
});

// ── Booking History ───────────────────────────────────────────────────────────

final bookingHistoryProvider = FutureProvider<List<BookingModel>>((ref) {
  return ref.watch(bookingRepositoryProvider).getMyBookings();
});
