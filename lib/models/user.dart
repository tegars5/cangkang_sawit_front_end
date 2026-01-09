/// User model untuk authentication dan user data
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? address;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.address,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone_number': phoneNumber,
      'address': address,
      'created_at': createdAt,
    };
  }

  /// Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Check if user is driver
  bool get isDriver => role.toLowerCase() == 'driver';

  /// Check if user is mitra/customer
  bool get isMitra =>
      role.toLowerCase() == 'mitra' || role.toLowerCase() == 'user';

  /// Get role display name
  String get roleDisplay {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'driver':
        return 'Driver';
      case 'mitra':
      case 'user':
        return 'Mitra';
      default:
        return role;
    }
  }
}
