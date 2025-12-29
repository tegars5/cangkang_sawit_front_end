/// Model for Waybill/Surat Jalan
class Waybill {
  final int id;
  final String waybillNumber;
  final int orderId;
  final String orderCode;
  final String? driverName;
  final String? vehiclePlate;
  final String destination;
  final double totalWeight;
  final String status;
  final String? createdAt;

  Waybill({
    required this.id,
    required this.waybillNumber,
    required this.orderId,
    required this.orderCode,
    this.driverName,
    this.vehiclePlate,
    required this.destination,
    required this.totalWeight,
    required this.status,
    this.createdAt,
  });

  factory Waybill.fromJson(Map<String, dynamic> json) {
    return Waybill(
      id: json['id'] as int,
      waybillNumber: json['waybill_number'] as String? ?? 'N/A',
      orderId: json['order_id'] as int,
      orderCode: json['order_code'] as String? ?? 'N/A',
      driverName: json['driver_name'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      destination: json['destination'] as String? ?? 'Unknown',
      totalWeight: (json['total_weight'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'waybill_number': waybillNumber,
      'order_id': orderId,
      'order_code': orderCode,
      'driver_name': driverName,
      'vehicle_plate': vehiclePlate,
      'destination': destination,
      'total_weight': totalWeight,
      'status': status,
      'created_at': createdAt,
    };
  }

  /// Display status in Indonesian
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_transit':
        return 'Dalam Perjalanan';
      case 'delivered':
        return 'Terkirim';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Format created date for display
  String get formattedDate {
    if (createdAt == null) return 'N/A';
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt!;
    }
  }
}
