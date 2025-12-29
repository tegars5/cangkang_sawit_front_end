/// Product model matching backend schema
class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? category;
  final List<String>? images;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.category,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper to parse price (can be string or number)
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper to parse stock (can be string or number)
    int parseStock(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String?,
      price: parsePrice(json['price']),
      stock: parseStock(json['stock']),
      category: json['category'] as String?,
      images: json['images'] != null
          ? (json['images'] is List
                ? List<String>.from(json['images'] as List)
                : [json['images'] as String])
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'images': images,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Format price for display
  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Check if product is low stock (less than 10)
  bool get isLowStock => stock < 10;

  /// Check if product is out of stock
  bool get isOutOfStock => stock <= 0;

  /// Get stock status text
  String get stockStatus {
    if (isOutOfStock) return 'Habis';
    if (isLowStock) return 'Stok Rendah';
    return 'Tersedia';
  }

  /// Get first image URL or null
  String? get primaryImage {
    if (images == null || images!.isEmpty) return null;
    return images!.first;
  }

  /// Check if product is available (for backward compatibility)
  bool get isAvailable => !isOutOfStock;

  /// Price per ton (for backward compatibility with create_order_screen)
  double get pricePerTon => price;
}
