import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/operator_repository.dart';
import 'gps_service.dart';

// ── Repository providers ────────────────────────────────────────────────────

final operatorRepositoryProvider = Provider((ref) => OperatorRepository());
final gpsServiceProvider         = Provider((ref) => GpsService());

// ── Trip State ────────────────────────────────────────────────────────────────

enum TripStatus { idle, active, ended }

class TripState {
  final TripStatus status;
  final String? activeScheduleId;
  final bool isGpsBroadcasting;
  final int? delayMinutes;
  final String? currentStop;

  const TripState({
    this.status              = TripStatus.idle,
    this.activeScheduleId,
    this.isGpsBroadcasting   = false,
    this.delayMinutes,
    this.currentStop,
  });

  TripState copyWith({
    TripStatus? status, String? activeScheduleId,
    bool? isGpsBroadcasting, int? delayMinutes, String? currentStop,
  }) => TripState(
    status:              status              ?? this.status,
    activeScheduleId:    activeScheduleId    ?? this.activeScheduleId,
    isGpsBroadcasting:   isGpsBroadcasting  ?? this.isGpsBroadcasting,
    delayMinutes:        delayMinutes        ?? this.delayMinutes,
    currentStop:         currentStop         ?? this.currentStop,
  );
}

class TripNotifier extends StateNotifier<TripState> {
  final OperatorRepository _repo;
  final GpsService _gps;

  TripNotifier(this._repo, this._gps) : super(const TripState());

  Future<void> startTrip(String scheduleId, String busId) async {
    await _repo.updateScheduleStatus(scheduleId, 'active');
    await _gps.startBroadcasting(busId);
    state = state.copyWith(
      status: TripStatus.active,
      activeScheduleId: scheduleId,
      isGpsBroadcasting: true,
    );
  }

  Future<void> endTrip(String scheduleId) async {
    _gps.stopBroadcasting();
    await _repo.updateScheduleStatus(scheduleId, 'completed');
    state = state.copyWith(status: TripStatus.ended, isGpsBroadcasting: false);
  }

  Future<void> reportDelay(String scheduleId, int minutes) async {
    await _repo.updateDelay(scheduleId, minutes);
    state = state.copyWith(delayMinutes: minutes);
  }

  Future<void> updateCurrentStop(String scheduleId, String stopName) async {
    await _repo.updateCurrentStop(scheduleId, stopName);
    state = state.copyWith(currentStop: stopName);
  }
}

final tripProvider = StateNotifierProvider<TripNotifier, TripState>((ref) {
  return TripNotifier(
    ref.watch(operatorRepositoryProvider),
    ref.watch(gpsServiceProvider),
  );
});

// ── Operator schedule list ────────────────────────────────────────────────────

final operatorScheduleProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(operatorRepositoryProvider).getMySchedules();
});
