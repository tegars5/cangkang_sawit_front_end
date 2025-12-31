/// Order Item model representing individual products in an order
class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final double quantity;
  final double pricePerUnit;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product']?['name'] as String? ?? 'Unknown Product',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Formatted price per unit for display
  String get formattedPricePerUnit {
    return 'Rp ${pricePerUnit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Formatted subtotal for display
  String get formattedSubtotal {
    return 'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
