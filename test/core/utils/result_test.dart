import 'package:flutter_test/flutter_test.dart';
import 'package:cangkang_sawit_mobile/core/utils/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create Success with data', () {
        const result = Success<int>(42);
        expect(result.data, 42);
      });

      test('should be of type Success', () {
        const result = Success<String>('test');
        expect(result, isA<Success<String>>());
      });
    });

    group('Failure', () {
      test('should create Failure with message', () {
        const result = Failure<int>(message: 'Error message');
        expect(result.message, 'Error message');
      });

      test('should be of type Failure', () {
        const result = Failure<String>(message: 'Error');
        expect(result, isA<Failure<String>>());
      });
    });

    group('onSuccess', () {
      test('should execute callback for Success', () {
        const result = Success<int>(42);
        var executed = false;
        var receivedValue = 0;

        result.onSuccess((value) {
          executed = true;
          receivedValue = value;
        });

        expect(executed, true);
        expect(receivedValue, 42);
      });

      test('should not execute callback for Failure', () {
        const result = Failure<int>(message: 'Error');
        var executed = false;

        result.onSuccess((value) {
          executed = true;
        });

        expect(executed, false);
      });

      test('should return the same Result for chaining', () {
        const result = Success<int>(42);
        final returned = result.onSuccess((value) {});
        expect(returned, result);
      });
    });

    group('onFailure', () {
      test('should execute callback for Failure', () {
        const result = Failure<int>(message: 'Error message');
        var executed = false;
        var receivedMessage = '';

        result.onFailure((failure) {
          executed = true;
          receivedMessage = failure.message;
        });

        expect(executed, true);
        expect(receivedMessage, 'Error message');
      });

      test('should not execute callback for Success', () {
        const result = Success<int>(42);
        var executed = false;

        result.onFailure((failure) {
          executed = true;
        });

        expect(executed, false);
      });

      test('should return the same Result for chaining', () {
        const result = Failure<int>(message: 'Error');
        final returned = result.onFailure((failure) {});
        expect(returned, result);
      });
    });

    group('chaining onSuccess and onFailure', () {
      test('should execute only onSuccess for Success', () {
        const result = Success<int>(42);
        var successExecuted = false;
        var failureExecuted = false;

        result
            .onSuccess((value) {
              successExecuted = true;
            })
            .onFailure((failure) {
              failureExecuted = true;
            });

        expect(successExecuted, true);
        expect(failureExecuted, false);
      });

      test('should execute only onFailure for Failure', () {
        const result = Failure<int>(message: 'Error');
        var successExecuted = false;
        var failureExecuted = false;

        result
            .onSuccess((value) {
              successExecuted = true;
            })
            .onFailure((failure) {
              failureExecuted = true;
            });

        expect(successExecuted, false);
        expect(failureExecuted, true);
      });
    });

    group('map', () {
      test('should transform Success data', () {
        const result = Success<int>(42);
        final mapped = result.map((value) => value * 2);

        expect(mapped, isA<Success<int>>());
        mapped.onSuccess((value) {
          expect(value, 84);
        });
      });

      test('should preserve Failure', () {
        const result = Failure<int>(message: 'Error');
        final mapped = result.map((value) => value * 2);

        expect(mapped, isA<Failure<int>>());
        mapped.onFailure((failure) {
          expect(failure.message, 'Error');
        });
      });
    });

    group('isSuccess', () {
      test('should return true for Success', () {
        const result = Success<int>(42);
        expect(result.isSuccess, true);
      });

      test('should return false for Failure', () {
        const result = Failure<int>(message: 'Error');
        expect(result.isSuccess, false);
      });
    });

    group('isFailure', () {
      test('should return true for Failure', () {
        const result = Failure<int>(message: 'Error');
        expect(result.isFailure, true);
      });

      test('should return false for Success', () {
        const result = Success<int>(42);
        expect(result.isFailure, false);
      });
    });
  });
}
