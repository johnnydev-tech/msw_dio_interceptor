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
        method: 'GET',
        handler: (_) => MockResponse.text('test'),
      );
      MockRegistry.register(rule);

      final options = RequestOptions(path: '/test', method: 'GET');
      final request = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );

      final foundRule = MockRegistry.find(request);
      expect(foundRule, equals(rule));
    });

    test('find should return null when no rule matches', () {
      final rule = MockRule(
        path: '/test',
        method: 'GET',
        handler: (_) => MockResponse.text('test'),
      );
      MockRegistry.register(rule);

      final options = RequestOptions(path: '/other', method: 'GET');
      final request = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );

      final foundRule = MockRegistry.find(request);
      expect(foundRule, isNull);
    });

    test('clear should remove all rules', () {
      MockRegistry.register(
        MockRule(
          path: '/test',
          method: 'GET',
          handler: (_) => MockResponse.text('test'),
        ),
      );

      MockRegistry.clear();

      final options = RequestOptions(path: '/test', method: 'GET');
      final request = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );

      final foundRule = MockRegistry.find(request);
      expect(foundRule, isNull);
    });

    test('newer handlers should override previous ones', () {
      final firstRule = MockRule(
        path: '/test',
        method: 'GET',
        handler: (_) => MockResponse.text('first'),
      );

      final secondRule = MockRule(
        path: '/test',
        method: 'GET',
        handler: (_) => MockResponse.text('second'),
      );

      MockRegistry.register(firstRule);
      MockRegistry.register(secondRule);

      final options = RequestOptions(path: '/test', method: 'GET');
      final request = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );

      final foundRule = MockRegistry.find(request);
      expect(foundRule, equals(secondRule));
    });

    test('should allow overriding a rule at different points in the test', () {
      final catchAllRule = MockRule(
        path: '/api/data',
        method: 'GET',
        handler: (_) => MockResponse.json({'data': 'default'}),
      );

      MockRegistry.register(catchAllRule);

      // Initial request should return default response
      var options = RequestOptions(path: '/api/data', method: 'GET');
      var request = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );

      var foundRule = MockRegistry.find(request);
      expect(foundRule, equals(catchAllRule));

      // Later in the test, override with a different response
      final overrideRule = MockRule(
        path: '/api/data',
        method: 'GET',
        handler: (_) => MockResponse.json({'data': 'overridden'}),
      );
      MockRegistry.register(overrideRule);

      // Now the new rule should be found instead
      options = RequestOptions(path: '/api/data', method: 'GET');
      request = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );

      foundRule = MockRegistry.find(request);
      expect(foundRule, equals(overrideRule));
    });
  });
}
