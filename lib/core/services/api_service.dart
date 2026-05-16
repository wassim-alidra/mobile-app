import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiService {
  final String? _token;

  ApiService({String? token}) : _token = token;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer ${_token!.trim()}';
    }
    return headers;
  }

  // ─── Auth ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$kApiUrl$kLoginEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$kApiUrl$kRefreshEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$kApiUrl$kCurrentUserEndpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─── Deliveries ──────────────────────────────────────────────────

  Future<List<dynamic>> getMyDeliveries() async {
    final response = await http.get(
      Uri.parse('$kApiUrl$kDeliveriesEndpoint'),
      headers: _headers,
    );
    final data = _handleResponse(response);
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List<dynamic>;
    }
    return data as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> getAvailableOrders() async {
    final response = await http.get(
      Uri.parse('$kApiUrl$kAvailableOrdersEndpoint'),
      headers: _headers,
    );
    final data = _handleResponse(response);
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List<dynamic>;
    }
    return data as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> acceptDelivery(int orderId) async {
    final response = await http.post(
      Uri.parse('$kApiUrl$kDeliveriesEndpoint'),
      headers: _headers,
      body: jsonEncode({'order': orderId}),
    );
    return _handleResponse(response);
  }


  Future<Map<String, dynamic>> getDelivery(int id) async {
    final response = await http.get(
      Uri.parse('$kApiUrl$kDeliveriesEndpoint$id/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateDeliveryStatus(
      int id, String status) async {
    final response = await http.patch(
      Uri.parse('$kApiUrl$kDeliveriesEndpoint$id/'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    return _handleResponse(response);
  }

  // ─── Orders ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getOrder(int id) async {
    final response = await http.get(
      Uri.parse('$kApiUrl$kOrdersEndpoint$id/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─── Routing ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> calculateRoute(
      String farmerWilaya, String buyerWilaya) async {
    final response = await http.get(
      Uri.parse(
          '$kApiUrl$kRoutingEndpoint?farmer_wilaya=$farmerWilaya&buyer_wilaya=$buyerWilaya'),
      headers: _headers,
    );
    return _handleResponse(response);
  }


  // ─── Notifications ───────────────────────────────────────────────

  Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$kApiUrl$kNotificationsEndpoint'),
      headers: _headers,
    );
    final data = _handleResponse(response);
    if (data.containsKey('results')) {
      return data['results'] as List<dynamic>;
    }
    return data as List<dynamic>? ?? [];
  }

  Future<void> markNotificationRead(int id) async {
    await http.patch(
      Uri.parse('$kApiUrl$kNotificationsEndpoint$id/'),
      headers: _headers,
      body: jsonEncode({'is_read': true}),
    );
  }

  Future<void> markAllNotificationsRead() async {
    // Get all unread notifications and mark them read
    final notifs = await getNotifications();
    for (final n in notifs) {
      if (n['is_read'] == false) {
        await markNotificationRead(n['id'] as int);
      }
    }
  }

  // ─── Profile ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$kApiUrl$kCurrentUserEndpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // ─── Generic Methods ─────────────────────────────────────────────

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$kApiUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$kApiUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$kApiUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$kApiUrl$endpoint'),
      headers: _headers,
    );
    if (response.statusCode == 204) return null;
    return _handleResponse(response);
  }

  // ─── Helper ──────────────────────────────────────────────────────

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);
      return decoded;
    } else {
      String errorMsg = 'Request failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('detail')) {
          errorMsg = body['detail'];
        } else if (body is Map && body.containsKey('error')) {
          errorMsg = body['error'];
        } else if (body is Map) {
          final firstKey = body.keys.first;
          final firstVal = body[firstKey];
          if (firstVal is List) {
            errorMsg = firstVal.first.toString();
          } else {
            errorMsg = firstVal.toString();
          }
        }
      } catch (_) {}
      throw ApiException(errorMsg, statusCode: response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
