import 'package:flutter_test/flutter_test.dart';
import 'package:cangkang_sawit_mobile/core/utils/formatters.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    // Initialize Indonesian locale for date formatting
    await initializeDateFormatting('id_ID', null);
  });
  group('Formatters', () {
    group('formatCurrency', () {
      test('should format zero correctly', () {
        expect(Formatters.formatCurrency(0), 'Rp 0');
      });

      test('should format small amounts correctly', () {
        expect(Formatters.formatCurrency(500), 'Rp 500');
      });

      test('should format thousands with dot separator', () {
        expect(Formatters.formatCurrency(15000), 'Rp 15.000');
      });

      test('should format millions correctly', () {
        expect(Formatters.formatCurrency(1500000), 'Rp 1.500.000');
      });

      test('should format billions correctly', () {
        expect(Formatters.formatCurrency(1500000000), 'Rp 1.500.000.000');
      });

      test('should handle decimal amounts (round down)', () {
        expect(Formatters.formatCurrency(15000.99), 'Rp 15.000');
      });
    });

    group('formatDate', () {
      test('should format date in Indonesian format', () {
        final date = DateTime(2024, 1, 15);
        final result = Formatters.formatDate(date);
        expect(result, contains('15'));
        expect(result, contains('Januari'));
        expect(result, contains('2024'));
      });

      test('should handle different months', () {
        final date = DateTime(2024, 12, 25);
        final result = Formatters.formatDate(date);
        expect(result, contains('25'));
        expect(result, contains('Desember'));
        expect(result, contains('2024'));
      });
    });

    group('formatDateForApi', () {
      test('should format date in ISO format', () {
        final date = DateTime(2024, 1, 15);
        expect(Formatters.formatDateForApi(date), '2024-01-15');
      });

      test('should handle single digit months and days', () {
        final date = DateTime(2024, 3, 5);
        expect(Formatters.formatDateForApi(date), '2024-03-05');
      });

      test('should handle double digit months and days', () {
        final date = DateTime(2024, 12, 25);
        expect(Formatters.formatDateForApi(date), '2024-12-25');
      });
    });

    group('formatWeight', () {
      test('should format integer weight', () {
        expect(Formatters.formatWeight(5), '5.0 ton');
      });

      test('should format decimal weight', () {
        expect(Formatters.formatWeight(5.5), '5.5 ton');
      });

      test('should format zero weight', () {
        expect(Formatters.formatWeight(0), '0.0 ton');
      });
    });

    group('formatDistance', () {
      test('should format distance with one decimal place', () {
        expect(Formatters.formatDistance(5.3), '5.3 km');
      });

      test('should round to one decimal place', () {
        expect(Formatters.formatDistance(5.678), '5.7 km');
      });

      test('should format zero distance', () {
        expect(Formatters.formatDistance(0), '0.0 km');
      });

      test('should format large distances', () {
        expect(Formatters.formatDistance(123.456), '123.5 km');
      });
    });

    group('formatDuration', () {
      test('should format minutes less than 60', () {
        expect(Formatters.formatDuration(30), '30 menit');
        expect(Formatters.formatDuration(59), '59 menit');
      });

      test('should format exactly 60 minutes as 1 hour', () {
        expect(Formatters.formatDuration(60), '1 jam');
      });

      test('should format hours without remaining minutes', () {
        expect(Formatters.formatDuration(120), '2 jam');
        expect(Formatters.formatDuration(180), '3 jam');
      });

      test('should format hours with remaining minutes', () {
        expect(Formatters.formatDuration(75), '1 jam 15 menit');
        expect(Formatters.formatDuration(150), '2 jam 30 menit');
      });

      test('should handle zero minutes', () {
        expect(Formatters.formatDuration(0), '0 menit');
      });
    });

    group('formatPhone', () {
      test('should format 12-digit phone number', () {
        expect(Formatters.formatPhone('081234567890'), '0812-3456-7890');
      });

      test('should format 11-digit phone number', () {
        expect(Formatters.formatPhone('08123456789'), '0812-3456-789');
      });

      test('should return original if less than 10 digits', () {
        expect(Formatters.formatPhone('0812345'), '0812345');
      });

      test('should handle exactly 10 digits', () {
        expect(Formatters.formatPhone('0812345678'), '0812-3456-78');
      });
    });

    group('parseCurrency', () {
      test('should parse formatted currency string', () {
        expect(Formatters.parseCurrency('Rp 15.000'), 15000.0);
      });

      test('should parse currency with millions', () {
        expect(Formatters.parseCurrency('Rp 1.500.000'), 1500000.0);
      });

      test('should parse currency with decimals (comma)', () {
        expect(Formatters.parseCurrency('Rp 15.000,50'), 15000.50);
      });

      test('should handle currency without Rp symbol', () {
        expect(Formatters.parseCurrency('15.000'), 15000.0);
      });

      test('should handle plain numbers', () {
        expect(Formatters.parseCurrency('15000'), 15000.0);
      });

      test('should return 0 for invalid input', () {
        expect(Formatters.parseCurrency('invalid'), 0.0);
        expect(Formatters.parseCurrency(''), 0.0);
      });

      test('should handle currency with extra spaces', () {
        expect(Formatters.parseCurrency('  Rp 15.000  '), 15000.0);
      });
    });
  });
}
