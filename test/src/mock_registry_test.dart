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
  });
}
