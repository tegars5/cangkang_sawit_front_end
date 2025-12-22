/// Simple Order model for Mitra and Admin screens
class Order {
  final int id;
  final String orderCode;
  final String status;
  final double totalWeight;
  final String destination;
  final String? mitraName;
  final String? createdAt;

  Order({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.totalWeight,
    required this.destination,
    this.mitraName,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderCode: json['order_code'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'pending',
      totalWeight: (json['total_weight'] as num?)?.toDouble() ?? 0.0,
      destination: json['destination'] as String? ?? 'Unknown',
      mitraName: json['mitra']?['name'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'on_delivery':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
