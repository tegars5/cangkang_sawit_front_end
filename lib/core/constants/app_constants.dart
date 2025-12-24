/// Application-wide constants
class AppConstants {
  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Validation
  static const int minPasswordLength = 6;
  static const int minAddressLength = 10;
  static const int maxNotesLength = 500;

  // Pagination
  static const int defaultPageSize = 20;

  // Date
  static const int maxFutureDays = 365;
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'dd MMMM yyyy';
  static const String locale = 'id_ID';

  // Weight
  static const String weightUnit = 'ton';
  static const double minWeight = 0.1;
  static const double maxWeight = 100.0;

  // Price
  static const String currencySymbol = 'Rp';
  static const String currencyCode = 'IDR';
}
