/// Simple DeliveryOrder model for Driver screen
class DeliveryOrder {
  final int id;
  final String orderCode;
  final String status;
  final String destination;
  final double totalWeight;
  final String? pickupLocation;

  DeliveryOrder({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.destination,
    required this.totalWeight,
    this.pickupLocation,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as int,
      orderCode: json['order']?['order_code'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'pending',
      destination: json['order']?['destination'] as String? ?? 'Unknown',
      totalWeight: (json['order']?['total_weight'] as num?)?.toDouble() ?? 0.0,
      pickupLocation: json['order']?['pickup_location'] as String?,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'assigned':
        return 'Ditugaskan';
      case 'on_the_way':
        return 'Dalam Perjalanan';
      case 'arrived':
        return 'Tiba';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }
}
