import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

/// Utility class for form validation
class Validators {
  /// Validate required field
  /// Returns error message if field is empty, null otherwise
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${AppStrings.fieldRequired}';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${AppStrings.fieldRequired}';
    }
    if (value.length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, String fieldName) {
    if (value != null && value.length > max) {
      return '$fieldName maksimal $max karakter';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '${AppStrings.email} ${AppStrings.fieldRequired}';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '${AppStrings.password} ${AppStrings.fieldRequired}';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  /// Validate number (positive)
  static String? number(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${AppStrings.fieldRequired}';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName harus berupa angka positif';
    }
    return null;
  }

  /// Validate weight
  static String? weight(String? value) {
    if (value == null || value.isEmpty) {
      return '${AppStrings.weight} ${AppStrings.fieldRequired}';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return AppStrings.weightInvalid;
    }
    if (weight < AppConstants.minWeight) {
      return '${AppStrings.weight} minimal ${AppConstants.minWeight} ${AppConstants.weightUnit}';
    }
    if (weight > AppConstants.maxWeight) {
      return '${AppStrings.weight} maksimal ${AppConstants.maxWeight} ${AppConstants.weightUnit}';
    }
    return null;
  }

  /// Validate address
  static String? address(String? value) {
    if (value == null || value.isEmpty) {
      return '${AppStrings.destination} ${AppStrings.fieldRequired}';
    }
    if (value.length < AppConstants.minAddressLength) {
      return AppStrings.addressTooShort;
    }
    return null;
  }

  /// Validate phone number (Indonesian format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  /// Combine multiple validators
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
