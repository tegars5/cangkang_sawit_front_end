import 'dart:convert';
import 'package:http/http.dart' as http;
import 'result.dart';

/// Helper class for API operations
class ApiHelper {
  /// Handle API response and extract data
  static Result<T> handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Success(fromJson(data));
      } else {
        return Failure(
          message: getErrorMessage(response),
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Failed to parse response: $e', cause: e);
    }
  }

  /// Handle API response for list data
  static Result<List<T>> handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data
            .map((json) => fromJson(json as Map<String, dynamic>))
            .toList();
        return Success(list);
      } else {
        return Failure(
          message: getErrorMessage(response),
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Failed to parse list response: $e', cause: e);
    }
  }

  /// Extract error message from response
  static String getErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? 'Terjadi kesalahan';
      }
    } catch (e) {
      // If JSON parsing fails, return generic error
    }
    return 'Terjadi kesalahan (${response.statusCode})';
  }

  /// Check if response is successful
  static bool isSuccessful(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  factory ApiException.fromResponse(http.Response response) {
    return ApiException(
      response.statusCode,
      ApiHelper.getErrorMessage(response),
    );
  }

  @override
  String toString() => message;
}
