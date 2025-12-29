import 'dart:convert';
import '../services/api_client.dart';
import '../core/utils/result.dart';
import '../models/order_tracking.dart';

/// Repository for order tracking operations
class TrackingRepository {
  final ApiClient _apiClient;

  TrackingRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get real-time tracking data for an order
  Future<Result<OrderTracking>> getOrderTracking(int orderId) async {
    try {
      final response = await _apiClient.getOrderTracking(orderId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tracking = OrderTracking.fromJson(data);
        return Success(tracking);
      } else {
        return Failure(
          message: 'Gagal memuat data tracking',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }
}
