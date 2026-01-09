import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Base URL untuk backend Laravel
  static const String baseUrl = 'http://192.168.1.7:8000/api';

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

  // ========== Auth ==========
  /// Login dengan email dan password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _handlePost('/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save token dan user data
        if (data['token'] != null) {
          await setToken(data['token']);
        }
        if (data['user'] != null) {
          await setUserData(data['user']);
          if (data['user']['role'] != null) {
            await setRole(data['user']['role']);
          }
        }
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login gagal');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // ========== Orders ==========
  /// Get orders milik user yang sedang login
  Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await _handleGet('/orders');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array directly
        return data is List ? data : [];
      } else {
        throw Exception('Gagal mengambil orders');
      }
    } catch (e) {
      throw Exception('Get orders error: $e');
    }
  }

  /// Get product detail by ID
  Future<Map<String, dynamic>> getProductDetail(int id) async {
    try {
      final response = await _handleGet('/products/$id');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns product object directly
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception('Gagal mengambil detail produk');
      }
    } catch (e) {
      throw Exception('Get product detail error: $e');
    }
  }

  // ========== Driver ==========
  /// Get delivery orders untuk driver
  Future<List<dynamic>> getDriverOrders() async {
    try {
      final response = await _handleGet('/driver/orders');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns {"delivery_orders": [...]}
        return data['delivery_orders'] ?? [];
      } else {
        throw Exception('Gagal mengambil delivery orders');
      }
    } catch (e) {
      throw Exception('Get driver orders error: $e');
    }
  }

  /// Update lokasi driver saat pengiriman
  Future<Map<String, dynamic>> trackDriverDelivery(
    int deliveryOrderId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _handlePost(
        '/driver/delivery-orders/$deliveryOrderId/track',
        {
          'lat': latitude, // Backend expects 'lat' not 'latitude'
          'lng': longitude, // Backend expects 'lng' not 'longitude'
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal update tracking');
      }
    } catch (e) {
      throw Exception('Track delivery error: $e');
    }
  }

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

  // ========== PHOTO UPLOAD (Multipart) ==========
  Future<Map<String, dynamic>> uploadProduct({
    required String name,
    required double price,
    required int stock,
    required File imageFile,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Biar multipart auto-boundary

      final uri = Uri.parse('$baseUrl/products');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields.addAll({
        'name': name,
        'price': price.toString(),
        'stock': stock.toString(),
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'image_file', // Backend expect nama ini!
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Upload gagal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Products
  Future<http.Response> getProducts() => _handleGet('/products');

  // Orders
  Future<http.Response> createOrder(Map<String, dynamic> orderData) =>
      _handlePost('/orders', orderData);

  Future<http.Response> payOrder(int orderId) =>
      _handlePost('/orders/$orderId/pay', {});

  Future<http.Response> cancelOrder(int orderId) =>
      _handlePost('/orders/$orderId/cancel', {});

  /// Approve order (admin only)
  Future<http.Response> approveOrder(int orderId) =>
      _handlePost('/admin/orders/$orderId/approve', {});

  /// Get admin dashboard summary (total orders, in delivery, completed)
  Future<http.Response> getAdminDashboardSummary() =>
      _handleGet('/admin/dashboard-summary');

  // Waybills
  Future<http.Response> getWaybills() => _handleGet('/admin/waybills');

  Future<http.Response> getWaybillDetail(int id) =>
      _handleGet('/admin/waybills/$id');

  Future<http.Response> createWaybill(int orderId) =>
      _handlePost('/admin/waybills', {'order_id': orderId});

  // Tracking
  Future<http.Response> getOrderTracking(int orderId) =>
      _handleGet('/orders/$orderId/tracking');

  // Products (Admin)
  Future<http.Response> createProduct(Map<String, dynamic> data) =>
      _handlePost('/products', data);

  Future<http.Response> updateProduct(int id, Map<String, dynamic> data) =>
      _handlePut('/products/$id', data);

  Future<http.Response> deleteProduct(int id) => _handleDelete('/products/$id');
}
