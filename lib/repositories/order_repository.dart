import 'dart:convert';
import '../services/api_client.dart';
import '../core/utils/result.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/order_distance.dart';

/// Repository for order operations
class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get orders by role
  Future<Result<List<Order>>> getOrders() async {
    try {
      final response = await _apiClient.get('/orders');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final orders = data.map((json) => Order.fromJson(json)).toList();
        return Success(orders);
      } else {
        return Failure(
          message: 'Gagal memuat daftar pesanan',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Get order detail by ID
  Future<Result<Order>> getOrderDetail(int id) async {
    try {
      final response = await _apiClient.get('/orders/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final order = Order.fromJson(data);
        return Success(order);
      } else {
        return Failure(
          message: 'Gagal memuat detail pesanan',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Get order distance (warehouse to destination)
  Future<Result<OrderDistance>> getOrderDistance(int orderId) async {
    try {
      final response = await _apiClient.getOrderDistance(orderId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final distance = OrderDistance.fromJson(data);
        return Success(distance);
      } else {
        return Failure(
          message: 'Gagal memuat jarak pesanan',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Get list of products
  Future<Result<List<Product>>> getProducts() async {
    try {
      final response = await _apiClient.getProducts();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final products = data.map((json) => Product.fromJson(json)).toList();
        return Success(products);
      } else {
        return Failure(
          message: 'Gagal memuat daftar produk',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Create new order
  Future<Result<Order>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _apiClient.createOrder(orderData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final order = Order.fromJson(data);
        return Success(order);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal membuat pesanan',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Pay for an order
  Future<Result<Map<String, dynamic>>> payOrder(int orderId) async {
    try {
      final response = await _apiClient.payOrder(orderId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Success(data);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal memproses pembayaran',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Cancel an order
  Future<Result<void>> cancelOrder(int orderId) async {
    try {
      final response = await _apiClient.cancelOrder(orderId);

      if (response.statusCode == 200) {
        return const Success(null);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal membatalkan pesanan',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }
}
