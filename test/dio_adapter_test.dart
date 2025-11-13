import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  late Dio dio;
  late MockHttpEngine engine;

  setUp(() {
    dio = Dio();
    engine = MockHttpEngine(enabled: true);
    dio.interceptors.add(MockInterceptor(engine: engine));
    MockRegistry.clear();
  });

  group('Dio Adapter Tests', () {
    test('should mock response with path', () async {
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

    test('should mock response with regex', () async {
      MockRegistry.register(
        MockRule.regex(
          pattern: r'\/users\/\d+',
          method: 'GET',
          handler: (_) => MockResponse.json({'id': 123}),
        ),
      );

      final response = await dio.get('http://example.com/users/123');
      expect(response.statusCode, 200);
      expect(response.data, '{"id":123}');
    });

    test('should mock response with url', () async {
      const url = 'https://api.example.com/v1/me';
      MockRegistry.register(
        MockRule.url(
          url: url,
          method: 'GET',
          handler: (_) => MockResponse.json({'name': 'John Doe'}),
        ),
      );

      final response = await dio.get(url);
      expect(response.statusCode, 200);
      expect(response.data, '{"name":"John Doe"}');
    });

    test('should mock response with query params', () async {
      MockRegistry.register(
        MockRule(
          path: '/search',
          method: 'GET',
          queryParams: {'q': 'test'},
          handler: (_) => MockResponse.json({'result': 'ok'}),
        ),
      );

      final response =
          await dio.get('http://example.com/search', queryParameters: {'q': 'test'});
      expect(response.statusCode, 200);
      expect(response.data, '{"result":"ok"}');
    });

    test('should handle delay correctly', () {
      fakeAsync((async) {
        MockRegistry.register(
          MockRule(
            path: '/delayed',
            method: 'GET',
            delayMs: 500,
            handler: (_) => MockResponse.text('delayed'),
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

    test('should pass through when no rule matches', () {
      // No rules registered
      expect(
        () => dio.get('http://unreachable.example.com/test'),
        throwsA(isA<DioException>()),
      );
    });
  });
}