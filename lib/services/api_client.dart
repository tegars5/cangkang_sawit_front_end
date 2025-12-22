import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Base URL untuk backend Laravel
  // Ganti dengan IP komputer Anda saat testing di HP fisik
  // Contoh: http://192.168.1.100:8000/api
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Simpan token ke SharedPreferences
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Ambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Hapus token (untuk logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Simpan role user
  Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  // Ambil role user
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Simpan data user
  Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Ambil data user
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Clear semua data (untuk logout)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Method untuk GET request
  Future<http.Response> get(String path) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$path');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Tambahkan Authorization header jika token ada
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(uri, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Gagal melakukan GET request: $e');
    }
  }

  // Method untuk POST request
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$path');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Tambahkan Authorization header jika token ada
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Gagal melakukan POST request: $e');
    }
  }

  // Method untuk PUT request
  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$path');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Gagal melakukan PUT request: $e');
    }
  }

  // Method untuk DELETE request
  Future<http.Response> delete(String path) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$path');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.delete(uri, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Gagal melakukan DELETE request: $e');
    }
  }
}
