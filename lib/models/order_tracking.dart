/// Model for real-time order tracking data
class OrderTracking {
  final int orderId;
  final String orderCode;
  final String status;

  // Driver information
  final String? driverName;
  final String? driverPhone;
  final double? driverLatitude;
  final double? driverLongitude;

  // Destination information
  final String destinationAddress;
  final double? destinationLatitude;
  final double? destinationLongitude;

  // Distance and time
  final double? distanceKm;
  final int? estimatedTimeMinutes;

  OrderTracking({
    required this.orderId,
    required this.orderCode,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.driverLatitude,
    this.driverLongitude,
    required this.destinationAddress,
    this.destinationLatitude,
    this.destinationLongitude,
    this.distanceKm,
    this.estimatedTimeMinutes,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    final driverLocation = json['driver_location'] as Map<String, dynamic>?;
    final destination = json['destination'] as Map<String, dynamic>?;

    return OrderTracking(
      orderId: json['order_id'] as int,
      orderCode: json['order_code'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'unknown',
      driverName: json['driver']?['name'] as String?,
      driverPhone: json['driver']?['phone'] as String?,
      driverLatitude: driverLocation?['latitude'] as double?,
      driverLongitude: driverLocation?['longitude'] as double?,
      destinationAddress: json['destination_address'] as String? ?? 'Unknown',
      destinationLatitude: destination?['latitude'] as double?,
      destinationLongitude: destination?['longitude'] as double?,
      distanceKm: (json['distance'] as num?)?.toDouble(),
      estimatedTimeMinutes: json['estimated_time'] as int?,
    );
  }

  /// Check if driver location is available
  bool get hasDriverLocation =>
      driverLatitude != null && driverLongitude != null;

  /// Check if destination location is available
  bool get hasDestinationLocation =>
      destinationLatitude != null && destinationLongitude != null;

  /// Format distance for display
  String get formattedDistance {
    if (distanceKm == null) return 'N/A';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  /// Format estimated time for display
  String get formattedEstimatedTime {
    if (estimatedTimeMinutes == null) return 'N/A';
    if (estimatedTimeMinutes! < 60) {
      return '±${estimatedTimeMinutes} menit';
    } else {
      final hours = estimatedTimeMinutes! ~/ 60;
      final minutes = estimatedTimeMinutes! % 60;
      return '±$hours jam ${minutes > 0 ? "$minutes menit" : ""}';
    }
  }

  /// Display status in Indonesian
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'on_delivery':
        return 'Dalam Pengiriman';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
