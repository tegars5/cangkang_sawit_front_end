/// Model for Driver data
class Driver {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? vehicleType;
  final String? vehicleNumber;
  final bool isAvailable;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.vehicleType,
    this.vehicleNumber,
    required this.isAvailable,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'is_available': isAvailable,
    };
  }

  /// Display text for driver info
  String get displayInfo {
    final parts = <String>[name];
    if (vehicleType != null) {
      parts.add(vehicleType!);
    }
    if (vehicleNumber != null) {
      parts.add(vehicleNumber!);
    }
    return parts.join(' • ');
  }
}
