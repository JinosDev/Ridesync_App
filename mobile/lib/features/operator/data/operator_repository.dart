import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class OperatorRepository {
  final _auth = FirebaseAuth.instance;

  Future<String> _token() async => (await _auth.currentUser!.getIdToken())!;

  Future<List<dynamic>> getMySchedules() async {
    final json = await ApiClient.get(
      endpoint: ApiEndpoints.schedules,
      token: await _token(),
      queryParams: {'operatorId': _auth.currentUser!.uid},
    );
    return json['data'] as List;
  }

  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await ApiClient.put(
      endpoint: ApiEndpoints.scheduleById(scheduleId),
      token: await _token(),
      body: {'status': status},
    );
  }

  Future<void> updateDelay(String scheduleId, int minutes) async {
    await ApiClient.put(
      endpoint: ApiEndpoints.scheduleById(scheduleId),
      token: await _token(),
      body: {'delayMinutes': minutes},
    );
  }

  Future<void> updateCurrentStop(String scheduleId, String stopName) async {
    await ApiClient.put(
      endpoint: ApiEndpoints.scheduleById(scheduleId),
      token: await _token(),
      body: {'currentStop': stopName},
    );
  }

  Future<List<dynamic>> getPassengerManifest(String scheduleId) async {
    final json = await ApiClient.get(
      endpoint: ApiEndpoints.scheduleBookings(scheduleId),
      token: await _token(),
    );
    return json['data'] as List;
  }
}
