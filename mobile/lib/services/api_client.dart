import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/env.dart';
import '../core/errors/app_failure.dart';
import '../core/utils/logger.dart';

/// Centralised HTTP client for all backend REST API calls.
/// All calls require a valid Firebase ID Token.
class ApiClient {
  ApiClient._();

  static final _client  = http.Client();
  static final _baseUrl = Env.apiBaseUrl;

  static Future<Map<String, dynamic>> get({
    required String endpoint,
    required String token,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );
    AppLogger.info('GET $uri');
    final response = await _client
        .get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    AppLogger.info('POST $uri');
    final response = await _client
        .post(uri, headers: _headers(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    AppLogger.info('PUT $uri');
    final response = await _client
        .put(uri, headers: _headers(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Map<String, String> _headers(String token) => {
    'Content-Type':  'application/json',
    'Authorization': 'Bearer $token',
  };

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = response.statusCode;

    if (status >= 200 && status < 300) return body;

    AppLogger.error('API Error $status', body);
    switch (status) {
      case 401:
      case 403:
        throw AuthFailure(body['error'] as String? ?? 'Unauthorized');
      case 409:
      case 422:
        throw ServerFailure(body['error'] as String? ?? 'Request failed');
      default:
        throw NetworkFailure(body['error'] as String? ?? 'Server error');
    }
  }
}
