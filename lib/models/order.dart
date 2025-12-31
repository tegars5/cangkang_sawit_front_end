import 'order_item.dart';

/// Simple Order model for Mitra and Admin screens
class Order {
  final int id;
  final String orderCode;
  final String status;
  final double totalWeight;
  final String destination;
  final String? mitraName;
  final String? createdAt;
  final String? paymentStatus;
  final double? totalPrice;
  final String? paymentMethod;
  final List<OrderItem>? orderItems;
  final String? driverName;
  final int? driverId;

  Order({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.totalWeight,
    required this.destination,
    this.mitraName,
    this.createdAt,
    this.paymentStatus,
    this.totalPrice,
    this.paymentMethod,
    this.orderItems,
    this.driverName,
    this.driverId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse order items if available
    List<OrderItem>? items;
    if (json['order_items'] != null) {
      items = (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Order(
      id: json['id'] as int,
      orderCode: json['order_code'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'pending',
      totalWeight: (json['total_weight'] as num?)?.toDouble() ?? 0.0,
      destination: json['destination'] as String? ?? 'Unknown',
      mitraName: json['mitra']?['name'] as String?,
      createdAt: json['created_at'] as String?,
      paymentStatus: json['payment_status'] as String?,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String?,
      orderItems: items,
      driverName: json['driver']?['name'] as String?,
      driverId: json['driver_id'] as int?,
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

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'Belum Dibayar';
      case 'paid':
        return 'Sudah Dibayar';
      case 'failed':
        return 'Gagal';
      case 'expired':
        return 'Kadaluarsa';
      default:
        return paymentStatus ?? 'Unknown';
    }
  }

  /// Formatted total price for display
  String get formattedTotalPrice {
    if (totalPrice == null) return 'N/A';
    return 'Rp ${totalPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
