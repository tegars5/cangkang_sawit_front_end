import 'dart:convert';
import '../services/api_client.dart';
import '../core/utils/result.dart';
import '../models/product.dart';

/// Repository for product operations
class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all products
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

  /// Get product by ID
  Future<Result<Product>> getProductById(int id) async {
    try {
      final response = await _apiClient.get('/products/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = Product.fromJson(data);
        return Success(product);
      } else {
        return Failure(
          message: 'Gagal memuat detail produk',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Create new product
  Future<Result<Product>> createProduct(
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await _apiClient.createProduct(productData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final product = Product.fromJson(data);
        return Success(product);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal membuat produk',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Update existing product
  Future<Result<Product>> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await _apiClient.updateProduct(id, productData);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = Product.fromJson(data);
        return Success(product);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal mengupdate produk',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }

  /// Delete product
  Future<Result<void>> deleteProduct(int id) async {
    try {
      final response = await _apiClient.deleteProduct(id);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Success(null);
      } else {
        final errorData = jsonDecode(response.body);
        return Failure(
          message: errorData['message'] ?? 'Gagal menghapus produk',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return Failure(message: 'Terjadi kesalahan: $e', cause: e);
    }
  }
}
