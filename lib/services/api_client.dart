import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Base URL untuk backend Laravel
  static const String baseUrl = 'http://192.168.1.2:8000/api';

  // ========== Token & User Data Management ==========

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
  }

  Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ========== Private Helper Methods ==========

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Handle GET request
  Future<http.Response> _handleGet(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http.get(uri, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Handle POST request
  Future<http.Response> _handlePost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http.post(uri, headers: headers, body: jsonEncode(body));
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Handle PUT request
  Future<http.Response> _handlePut(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http.put(uri, headers: headers, body: jsonEncode(body));
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Handle DELETE request
  Future<http.Response> _handleDelete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http.delete(uri, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ========== Public API Methods (Generic) ==========

  Future<http.Response> get(String path) => _handleGet(path);
  Future<http.Response> post(String path, Map<String, dynamic> body) =>
      _handlePost(path, body);
  Future<http.Response> put(String path, Map<String, dynamic> body) =>
      _handlePut(path, body);
  Future<http.Response> delete(String path) => _handleDelete(path);

  // ========== Specific API Endpoints ==========

  // Distance
  Future<http.Response> getOrderDistance(int orderId) =>
      _handleGet('/orders/$orderId/distance');

  Future<http.Response> getDriverDistance(int deliveryOrderId) =>
      _handleGet('/driver/delivery-orders/$deliveryOrderId/distance');

  // Drivers
  Future<http.Response> getDrivers() => _handleGet('/admin/drivers');

  Future<http.Response> assignDriver(int orderId, int driverId) => _handlePost(
    '/admin/orders/$orderId/assign-driver',
    {'driver_id': driverId},
  );

  // Products
  Future<http.Response> getProducts() => _handleGet('/products');

  // Orders
  Future<http.Response> createOrder(Map<String, dynamic> orderData) =>
      _handlePost('/orders', orderData);

  Future<http.Response> payOrder(int orderId) =>
      _handlePost('/orders/$orderId/pay', {});

  Future<http.Response> cancelOrder(int orderId) =>
      _handlePost('/orders/$orderId/cancel', {});
}
