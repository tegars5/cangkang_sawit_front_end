/// Model for Product data
class Product {
  final int id;
  final String name;
  final String? description;
  final double pricePerTon;
  final String unit;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.pricePerTon,
    required this.unit,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Product',
      description: json['description'] as String?,
      pricePerTon: (json['price_per_ton'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'ton',
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_per_ton': pricePerTon,
      'unit': unit,
      'is_available': isAvailable,
    };
  }

  /// Formatted price for display
  String get formattedPrice {
    return 'Rp ${pricePerTon.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/$unit';
  }
}
