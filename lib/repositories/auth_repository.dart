import 'dart:convert';
import '../services/api_client.dart';
import '../core/utils/result.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Login with email and password
  /// Returns Success with user data and token, or Failure with error message
  Future<Result<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _apiClient.post('/login', {
        'email': email,
        'password': password,
      });

      // Debug logging (uncomment if needed)
      // print('Login response status: ${response.statusCode}');
      // print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode JSON response
        final decodedBody = jsonDecode(response.body);

        // Ensure it's a Map
        if (decodedBody is Map<String, dynamic>) {
          // Response structure: { "user": {...}, "token": "..." }
          return Success(decodedBody);
        } else {
          return const Failure(
            message: 'Format response tidak valid',
            code: 200,
          );
        }
      } else {
        // Try to extract error message from response
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? 'Login gagal';
          return Failure(message: errorMessage, code: response.statusCode);
        } catch (_) {
          // If JSON decode fails, return generic error
          return Failure(message: 'Login gagal', code: response.statusCode);
        }
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Register new user (Mitra)
  Future<Result<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post('/register', {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = jsonDecode(response.body);

        if (decodedBody is Map<String, dynamic>) {
          return Success(decodedBody);
        } else {
          return const Failure(
            message: 'Format response tidak valid',
            code: 200,
          );
        }
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? 'Registrasi gagal';
          return Failure(message: errorMessage, code: response.statusCode);
        } catch (_) {
          return Failure(
            message: 'Registrasi gagal',
            code: response.statusCode,
          );
        }
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Logout and clear all data
  Future<Result<void>> logout() async {
    try {
      await _apiClient.clearAllData();
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Gagal logout: $e', cause: e);
    }
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _apiClient.setToken(token);
  }

  /// Save user role
  Future<void> saveRole(String role) async {
    await _apiClient.setRole(role);
  }

  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _apiClient.setUserData(userData);
  }

  /// Get current token
  Future<String?> getToken() async {
    return await _apiClient.getToken();
  }

  /// Get current role
  Future<String?> getRole() async {
    return await _apiClient.getRole();
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    return await _apiClient.getUserData();
  }
}
