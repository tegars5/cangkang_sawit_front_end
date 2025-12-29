import 'dart:convert';
import '../services/api_client.dart';
import '../core/utils/result.dart';
import '../models/waybill.dart';

/// Repository for waybill operations
class WaybillRepository {
  final ApiClient _apiClient;

  WaybillRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all waybills (admin only)
  Future<Result<List<Waybill>>> getWaybills() async {
    try {
      final response = await _apiClient.getWaybills();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final waybills = data.map((json) => Waybill.fromJson(json)).toList();
        return Success(waybills);
      } else {
        return Failure(
          message: 'Gagal memuat daftar surat jalan',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Get waybill detail by ID
  Future<Result<Waybill>> getWaybillDetail(int id) async {
    try {
      final response = await _apiClient.getWaybillDetail(id);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final waybill = Waybill.fromJson(data);
        return Success(waybill);
      } else {
        return Failure(
          message: 'Gagal memuat detail surat jalan',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Create waybill for an order
  Future<Result<Waybill>> createWaybill(int orderId) async {
    try {
      final response = await _apiClient.createWaybill(orderId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final waybill = Waybill.fromJson(data);
        return Success(waybill);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal membuat surat jalan',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }
}
