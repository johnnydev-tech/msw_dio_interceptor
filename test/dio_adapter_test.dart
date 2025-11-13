import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  late Dio dio;
  late MockHttpEngine engine;

  setUp(() {
    dio = Dio();
    MockRegistry.clear();
  });

  group('Dio Adapter (MockInterceptor)', () {
    test('should return mocked response when enabled', () async {
      engine = MockHttpEngine(enabled: true);
      dio.interceptors.add(MockInterceptor(engine: engine));

      MockRegistry.register(
        MockRule(
          path: '/test',
          method: 'GET',
          handler: (_) => MockResponse.json({'message': 'success'}),
        ),
      );

      final response = await dio.get('http://example.com/test');
      expect(response.statusCode, 200);
      expect(response.data, '{"message":"success"}');
    });

    test('should pass through request when disabled', () async {
      engine = MockHttpEngine(enabled: false);
      dio.interceptors.add(MockInterceptor(engine: engine));

      MockRegistry.register(
        MockRule(
          path: '/test',
          method: 'GET',
          handler: (_) => MockResponse.json({'message': 'fail'}),
        ),
      );

      expect(
        () => dio.get('http://unreachable.example.com/test'),
        throwsA(isA<DioException>()),
      );
    });

    test('should return error response', () async {
      engine = MockHttpEngine(enabled: true);
      dio.interceptors.add(MockInterceptor(engine: engine));

      MockRegistry.register(
        MockRule(
          path: '/error',
          method: 'GET',
          handler: (_) => MockResponse.json(
            {'error': 'not found'},
            statusCode: 404,
          ),
        ),
      );

      try {
        await dio.get('http://example.com/error');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 404);
        expect(e.response?.data, '{"error":"not found"}');
      }
    });
  });
}
