/// Model untuk response jarak driver ke tujuan order
class DriverDistance {
  final int deliveryOrderId;
  final double distanceKm;
  final int durationMinutes;
  final String driverLocation;
  final String destination;

  DriverDistance({
    required this.deliveryOrderId,
    required this.distanceKm,
    required this.durationMinutes,
    required this.driverLocation,
    required this.destination,
  });

  factory DriverDistance.fromJson(Map<String, dynamic> json) {
    return DriverDistance(
      deliveryOrderId: json['delivery_order_id'] as int,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      driverLocation: json['driver_location'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery_order_id': deliveryOrderId,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'driver_location': driverLocation,
      'destination': destination,
    };
  }

  /// Format jarak untuk ditampilkan
  String get formattedDistance {
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Format durasi untuk ditampilkan
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '±$durationMinutes menit';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      return '±$hours jam ${minutes > 0 ? "$minutes menit" : ""}';
    }
  }

  /// Format lengkap untuk ditampilkan
  String get displayText {
    return 'Driver → tujuan: $formattedDistance ($formattedDuration)';
  }
}
