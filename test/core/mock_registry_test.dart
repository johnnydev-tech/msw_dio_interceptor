import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('MockRegistry', () {
    setUp(() {
      MockRegistry.clear();
    });

    test('register and find should work for a basic rule', () {
      final rule = MockRule(
        path: '/test',
        method: HttpMethod.get,
        response: MockResponse.text('test'),
      );
      MockRegistry.register(rule);

      final options = RequestOptions(path: '/test', method: 'GET');
      final foundRule = MockRegistry.find(options);
      expect(foundRule, equals(rule));
    });

    test('find should return null when no rule matches', () {
      final rule = MockRule(
        path: '/test',
        method: HttpMethod.get,
        response: MockResponse.text('test'),
      );
      MockRegistry.register(rule);

      final options = RequestOptions(path: '/other', method: 'GET');
      final foundRule = MockRegistry.find(options);
      expect(foundRule, isNull);
    });

    test('find should respect namespaces', () {
      final globalRule = MockRule(
        path: '/test',
        method: HttpMethod.get,
        response: MockResponse.text('global'),
      );
      MockRegistry.register(globalRule);

      final auth = MockRegistry.namespace('auth');
      final authRule = MockRule(
        path: '/test',
        method: HttpMethod.post,
        response: MockResponse.text('auth'),
      );
      auth.register(authRule);

      final getOptions = RequestOptions(path: '/test', method: 'GET');
      final postOptions = RequestOptions(path: '/test', method: 'POST');

      expect(MockRegistry.find(getOptions), equals(globalRule));
      expect(MockRegistry.find(postOptions), equals(authRule));
    });

    test('clear should remove all rules, including namespaced ones', () {
      MockRegistry.register(
        MockRule(
          path: '/test',
          method: HttpMethod.get,
          response: MockResponse.text('test'),
        ),
      );
      final auth = MockRegistry.namespace('auth');
      auth.register(
        MockRule(
          path: '/login',
          method: HttpMethod.post,
          response: MockResponse.text('login'),
        ),
      );

      MockRegistry.clear();

      final options1 = RequestOptions(path: '/test', method: 'GET');
      final options2 = RequestOptions(path: '/login', method: 'POST');

      expect(MockRegistry.find(options1), isNull);
      expect(MockRegistry.find(options2), isNull);
    });
  });
}
