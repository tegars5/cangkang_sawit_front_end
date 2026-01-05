import 'dart:convert';
import '../services/api_client.dart';
import '../core/utils/result.dart';

/// Repository for payment operations
class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get payment URL for an order (Tripay checkout)
  Future<Result<String>> getPaymentUrl(int orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId/payment-url');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentUrl = data['payment_url'] as String;
        return Success(paymentUrl);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal mendapatkan URL pembayaran',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Check payment status
  Future<Result<Map<String, dynamic>>> checkPaymentStatus(int orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId/payment-status');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Success(data);
      } else {
        return Failure(
          message: 'Gagal memeriksa status pembayaran',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }
}
