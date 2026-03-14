import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import 'fare_model.dart';

class FareRepository {
  final _auth = FirebaseAuth.instance;

  Future<FareBreakdownModel> getFareEstimate({
    required String scheduleId,
    required String fromStop,
    required String toStop,
    required String busClass,
  }) async {
    final token = await _auth.currentUser!.getIdToken();
    final json = await ApiClient.get(
      endpoint: ApiEndpoints.fare,
      token: token!,
      queryParams: {
        'scheduleId': scheduleId,
        'fromStop':   fromStop,
        'toStop':     toStop,
        'class':      busClass,
      },
    );
    return FareBreakdownModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
