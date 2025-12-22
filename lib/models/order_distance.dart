/// Model untuk response jarak order dari gudang ke tujuan
class OrderDistance {
  final int orderId;
  final double distanceKm;
  final int durationMinutes;
  final String origin;
  final String destination;

  OrderDistance({
    required this.orderId,
    required this.distanceKm,
    required this.durationMinutes,
    required this.origin,
    required this.destination,
  });

  factory OrderDistance.fromJson(Map<String, dynamic> json) {
    return OrderDistance(
      orderId: json['order_id'] as int,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      origin: json['origin'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'origin': origin,
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
    return 'Dari gudang: $formattedDistance ($formattedDuration)';
  }
}
