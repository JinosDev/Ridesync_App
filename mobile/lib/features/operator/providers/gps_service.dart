import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// GPS Broadcasting service for Bus Operators.
/// Writes location to Firebase RTDB /busLocations/{busId} every 3–10s.
class GpsService {
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();
  Timer? _locationTimer;

  static const int _fastIntervalSec = 3;    // when speed > 5 km/h
  static const int _slowIntervalSec = 10;   // when stationary
  static const double _movingThresholdMps = 1.4; // 5 km/h

  /// Call when operator taps "Start Trip"
  Future<void> startBroadcasting(String busId) async {
    await _requestPermissions();
    _scheduleUpdate(busId, _fastIntervalSec);
  }

  void _scheduleUpdate(String busId, int intervalSec) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(Duration(seconds: intervalSec), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        final bool isMoving = pos.speed >= _movingThresholdMps;
        final int nextInterval = isMoving ? _fastIntervalSec : _slowIntervalSec;

        // Adaptive: reschedule if speed mode changed
        if (nextInterval != intervalSec) {
          _scheduleUpdate(busId, nextInterval);
          return;
        }

        await _rtdb.child('busLocations/$busId').set({
          'lat':       pos.latitude,
          'lng':       pos.longitude,
          'speed':     double.parse((pos.speed * 3.6).toStringAsFixed(1)), // m/s → km/h
          'heading':   pos.heading,
          'timestamp': ServerValue.timestamp,
        });
      } on TimeoutException {
        debugPrint('[GPS] Timeout — skipping RTDB write');
      } catch (e) {
        debugPrint('[GPS] Write error: $e');
      }
    });
  }

  /// Call when operator taps "End Trip"
  void stopBroadcasting() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Please enable in settings.');
    }
  }
}
