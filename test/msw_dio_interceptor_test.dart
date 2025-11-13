import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio();
    dio.interceptors.add(MswDioInterceptor(enabled: true));
    MockRegistry.clear();
  });

  group('MswDioInterceptor', () {
    test('should return mocked JSON response', () async {
      MockRegistry.register(
        MockRule(
          path: '/json',
          method: HttpMethod.get,
          response: MockResponse.json({'message': 'success'}),
        ),
      );

      final response = await dio.get('http://example.com/json');
      expect(response.statusCode, 200);
      expect(response.data, '{"message":"success"}');
    });

    test('should return mocked text response', () async {
      MockRegistry.register(
        MockRule(
          path: '/text',
          method: HttpMethod.get,
          response: MockResponse.text('plain text'),
        ),
      );

      final response = await dio.get('http://example.com/text');
      expect(response.statusCode, 200);
      expect(response.data, 'plain text');
    });

    test('should return mocked bytes response', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      MockRegistry.register(
        MockRule(
          path: '/bytes',
          method: HttpMethod.get,
          response: MockResponse.bytes(bytes),
        ),
      );

      final response = await dio.get(
        'http://example.com/bytes',
        options: Options(responseType: ResponseType.bytes),
      );
      expect(response.statusCode, 200);
      expect(response.data, equals(bytes));
    });

    test('should return mocked error', () async {
      MockRegistry.register(
        MockRule(
          path: '/error',
          method: HttpMethod.post,
          response: MockResponse.json({'error': 'not found'}),
          statusCode: 404,
        ),
      );

      try {
        await dio.post('http://example.com/error');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 404);
        expect(e.response?.data, '{"error":"not found"}');
      }
    });

    test('should respect delay using fake_async', () {
      fakeAsync((async) {
        MockRegistry.register(
          MockRule(
            path: '/delayed',
            method: HttpMethod.get,
            response: MockResponse.text('delayed'),
            delayMs: 500,
          ),
        );

        bool completed = false;
        dio.get('http://example.com/delayed').then((response) {
          expect(response.data, 'delayed');
          completed = true;
        });

        expect(completed, isFalse);
        async.elapse(const Duration(milliseconds: 499));
        expect(completed, isFalse);
        async.elapse(const Duration(milliseconds: 1));
        expect(completed, isTrue);
      });
    });
  });
}