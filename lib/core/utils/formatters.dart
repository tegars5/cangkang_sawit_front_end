import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for formatting values
class Formatters {
  /// Format currency in Indonesian Rupiah
  /// Example: formatCurrency(15000) => "Rp 15.000"
  static String formatCurrency(double amount) {
    return '${AppConstants.currencySymbol} ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Format date in Indonesian format
  /// Example: formatDate(DateTime(2024, 1, 15)) => "15 Januari 2024"
  static String formatDate(DateTime date) {
    return DateFormat(
      AppConstants.displayDateFormat,
      AppConstants.locale,
    ).format(date);
  }

  /// Format date for API (ISO format)
  /// Example: formatDateForApi(DateTime(2024, 1, 15)) => "2024-01-15"
  static String formatDateForApi(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format weight with unit
  /// Example: formatWeight(5.5) => "5.5 ton"
  static String formatWeight(double weight) {
    return '$weight ${AppConstants.weightUnit}';
  }

  /// Format distance in kilometers
  /// Example: formatDistance(5.3) => "5.3 km"
  static String formatDistance(double distanceKm) {
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Format duration in minutes to readable format
  /// Example: formatDuration(75) => "1 jam 15 menit"
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes menit';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours jam';
    }
    return '$hours jam $remainingMinutes menit';
  }

  /// Format phone number (Indonesian format)
  /// Example: formatPhone("081234567890") => "0812-3456-7890"
  static String formatPhone(String phone) {
    if (phone.length < 10) return phone;
    return '${phone.substring(0, 4)}-${phone.substring(4, 8)}-${phone.substring(8)}';
  }

  /// Parse currency string to double
  /// Example: parseCurrency("Rp 15.000") => 15000.0
  static double parseCurrency(String currencyString) {
    final cleaned = currencyString
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
