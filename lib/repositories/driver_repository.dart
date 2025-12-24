import 'dart:convert';
import '../services/api_client.dart';
import '../core/utils/result.dart';
import '../models/delivery_order.dart';
import '../models/driver.dart';
import '../models/driver_distance.dart';

/// Repository for driver operations
class DriverRepository {
  final ApiClient _apiClient;

  DriverRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get driver tasks (delivery orders)
  Future<Result<List<DeliveryOrder>>> getDriverTasks() async {
    try {
      final response = await _apiClient.get('/driver/delivery-orders');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final tasks = data.map((json) => DeliveryOrder.fromJson(json)).toList();
        return Success(tasks);
      } else {
        return Failure(
          message: 'Gagal memuat daftar tugas',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Get driver distance (driver to destination)
  Future<Result<DriverDistance>> getDriverDistance(int deliveryOrderId) async {
    try {
      final response = await _apiClient.getDriverDistance(deliveryOrderId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final distance = DriverDistance.fromJson(data);
        return Success(distance);
      } else {
        return Failure(
          message: 'Gagal memuat jarak driver',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Update task status
  Future<Result<void>> updateTaskStatus(
    int deliveryOrderId,
    String status,
  ) async {
    try {
      final response = await _apiClient.put(
        '/driver/delivery-orders/$deliveryOrderId/status',
        {'status': status},
      );

      if (response.statusCode == 200) {
        return const Success(null);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal mengupdate status',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Send driver location
  Future<Result<void>> sendLocation(
    int deliveryOrderId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _apiClient.post(
        '/driver/delivery-orders/$deliveryOrderId/location',
        {'latitude': latitude, 'longitude': longitude},
      );

      if (response.statusCode == 200) {
        return const Success(null);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal mengirim lokasi',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Get list of drivers (for admin)
  Future<Result<List<Driver>>> getDrivers() async {
    try {
      final response = await _apiClient.getDrivers();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final drivers = data.map((json) => Driver.fromJson(json)).toList();
        return Success(drivers);
      } else {
        return Failure(
          message: 'Gagal memuat daftar driver',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Assign driver to order (for admin)
  Future<Result<void>> assignDriver(int orderId, int driverId) async {
    try {
      final response = await _apiClient.assignDriver(orderId, driverId);

      if (response.statusCode == 200) {
        return const Success(null);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal menugaskan driver',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }
}
