import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:cangkang_sawit_mobile/core/utils/api_helper.dart';
import 'package:cangkang_sawit_mobile/core/utils/result.dart';

void main() {
  group('ApiHelper', () {
    group('handleResponse', () {
      test('should return Success with data for 200 response', () {
        final response = http.Response(
          json.encode({'id': 1, 'name': 'Test'}),
          200,
        );

        final result = ApiHelper.handleResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Success<Map<String, dynamic>>>());
        result.onSuccess((data) {
          expect(data['id'], 1);
          expect(data['name'], 'Test');
        });
      });

      test('should return Success with data for 201 response', () {
        final response = http.Response(
          json.encode({'id': 2, 'status': 'created'}),
          201,
        );

        final result = ApiHelper.handleResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Success<Map<String, dynamic>>>());
        result.onSuccess((data) {
          expect(data['id'], 2);
          expect(data['status'], 'created');
        });
      });

      test('should return Failure for 400 response', () {
        final response = http.Response(
          json.encode({'message': 'Bad request'}),
          400,
        );

        final result = ApiHelper.handleResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<Map<String, dynamic>>>());
        result.onFailure((failure) {
          expect(failure.message, contains('Bad request'));
        });
      });

      test('should return Failure for 401 response', () {
        final response = http.Response(
          json.encode({'message': 'Unauthorized'}),
          401,
        );

        final result = ApiHelper.handleResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<Map<String, dynamic>>>());
        result.onFailure((failure) {
          expect(failure.message, contains('Unauthorized'));
        });
      });

      test('should return Failure for 404 response', () {
        final response = http.Response(
          json.encode({'message': 'Not found'}),
          404,
        );

        final result = ApiHelper.handleResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<Map<String, dynamic>>>());
        result.onFailure((failure) {
          expect(failure.message, contains('Not found'));
        });
      });

      test('should return Failure for 500 response', () {
        final response = http.Response(
          json.encode({'message': 'Server error'}),
          500,
        );

        final result = ApiHelper.handleResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<Map<String, dynamic>>>());
        result.onFailure((failure) {
          expect(failure.message, contains('Server error'));
        });
      });

      test(
        'should return Failure with default message if no message in response',
        () {
          final response = http.Response(json.encode({}), 400);

          final result = ApiHelper.handleResponse<Map<String, dynamic>>(
            response,
            (json) => json as Map<String, dynamic>,
          );

          expect(result, isA<Failure<Map<String, dynamic>>>());
          result.onFailure((failure) {
            expect(failure.message, isNotEmpty);
          });
        },
      );

      test('should handle JSON parsing errors', () {
        final response = http.Response('invalid json', 200);

        final result = ApiHelper.handleResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<Map<String, dynamic>>>());
      });
    });

    group('handleListResponse', () {
      test('should return Success with list for 200 response', () {
        final response = http.Response(
          json.encode([
            {'id': 1, 'name': 'Item 1'},
            {'id': 2, 'name': 'Item 2'},
          ]),
          200,
        );

        final result = ApiHelper.handleListResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Success<List<Map<String, dynamic>>>>());
        result.onSuccess((list) {
          expect(list.length, 2);
          expect(list[0]['id'], 1);
          expect(list[1]['id'], 2);
        });
      });

      test('should return Success with empty list for empty array', () {
        final response = http.Response(json.encode([]), 200);

        final result = ApiHelper.handleListResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Success<List<Map<String, dynamic>>>>());
        result.onSuccess((list) {
          expect(list.length, 0);
        });
      });

      test('should return Failure for 400 response', () {
        final response = http.Response(
          json.encode({'message': 'Bad request'}),
          400,
        );

        final result = ApiHelper.handleListResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<List<Map<String, dynamic>>>>());
      });

      test('should return Failure for 500 response', () {
        final response = http.Response(
          json.encode({'message': 'Server error'}),
          500,
        );

        final result = ApiHelper.handleListResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<List<Map<String, dynamic>>>>());
      });

      test('should handle JSON parsing errors', () {
        final response = http.Response('invalid json', 200);

        final result = ApiHelper.handleListResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<List<Map<String, dynamic>>>>());
      });

      test('should handle non-array JSON', () {
        final response = http.Response(json.encode({'not': 'an array'}), 200);

        final result = ApiHelper.handleListResponse<Map<String, dynamic>>(
          response,
          (json) => json as Map<String, dynamic>,
        );

        expect(result, isA<Failure<List<Map<String, dynamic>>>>());
      });
    });
  });
}
