import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusLocation {
  final double lat;
  final double lng;
  final double speed;
  final double heading;
  final int timestamp;

  const BusLocation({
    required this.lat,
    required this.lng,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  /// True if last update was more than 30 seconds ago
  bool get isStale =>
      DateTime.now().millisecondsSinceEpoch - timestamp > 30000;

  factory BusLocation.fromSnapshot(DataSnapshot snapshot) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return BusLocation(
      lat:       (data['lat'] as num).toDouble(),
      lng:       (data['lng'] as num).toDouble(),
      speed:     (data['speed'] as num).toDouble(),
      heading:   (data['heading'] as num).toDouble(),
      timestamp: data['timestamp'] as int,
    );
  }
}

/// Passenger: real-time bus location stream from RTDB
final trackingProvider =
    StreamProvider.family<BusLocation, String>((ref, busId) {
  return FirebaseDatabase.instance
      .ref('busLocations/$busId')
      .onValue
      .map((event) => BusLocation.fromSnapshot(event.snapshot));
});

/// ETA and current stop from tripStatus RTDB node
final tripStatusProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, scheduleId) {
  return FirebaseDatabase.instance
      .ref('tripStatus/$scheduleId')
      .onValue
      .map((event) {
        final data = event.snapshot.value as Map?;
        return data != null ? Map<String, dynamic>.from(data) : {};
      });
});
