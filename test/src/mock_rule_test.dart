import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('MockRule.matches', () {
    final baseRequest = RequestOptions(path: 'http://example.com');

    test('should match method correctly', () {
      final rule = MockRule(
        path: '/test',
        method: 'GET',
        handler: (_) => MockResponse.text(''),
      );
      final options = baseRequest.copyWith(path: '/test', method: 'GET');
      final nonMatchingOptions =
          baseRequest.copyWith(path: '/test', method: 'POST');

      final mockRequest = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );
      final nonMatchingMockRequest = MockRequest(
        url: nonMatchingOptions.uri.toString(),
        path: nonMatchingOptions.uri.path,
        method: nonMatchingOptions.method,
        query: nonMatchingOptions.queryParameters,
        headers: nonMatchingOptions.headers.map((k, v) => MapEntry(k, v.toString())),
        body: nonMatchingOptions.data,
      );

      final matcher = MockMatcher();
      expect(matcher.matches(rule, mockRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingMockRequest), isFalse);
    });

    test('should match path correctly', () {
      final rule = MockRule(
        path: '/test',
        method: 'GET',
        handler: (_) => MockResponse.text(''),
      );
      final options = baseRequest.copyWith(path: '/test', method: 'GET');
      final nonMatchingOptions =
          baseRequest.copyWith(path: '/other', method: 'GET');

      final mockRequest = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );
      final nonMatchingMockRequest = MockRequest(
        url: nonMatchingOptions.uri.toString(),
        path: nonMatchingOptions.uri.path,
        method: nonMatchingOptions.method,
        query: nonMatchingOptions.queryParameters,
        headers: nonMatchingOptions.headers.map((k, v) => MapEntry(k, v.toString())),
        body: nonMatchingOptions.data,
      );

      final matcher = MockMatcher();
      expect(matcher.matches(rule, mockRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingMockRequest), isFalse);
    });

    test('should match full url correctly', () {
      const url = 'https://api.example.com/v1/data';
      final rule = MockRule.url(
        url: url,
        method: 'GET',
        handler: (_) => MockResponse.text(''),
      );
      final options = RequestOptions(path: url, method: 'GET');
      final nonMatchingOptions =
          RequestOptions(path: 'https://api.example.com/v2/data', method: 'GET');

      final mockRequest = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );
      final nonMatchingMockRequest = MockRequest(
        url: nonMatchingOptions.uri.toString(),
        path: nonMatchingOptions.uri.path,
        method: nonMatchingOptions.method,
        query: nonMatchingOptions.queryParameters,
        headers: nonMatchingOptions.headers.map((k, v) => MapEntry(k, v.toString())),
        body: nonMatchingOptions.data,
      );

      final matcher = MockMatcher();
      expect(matcher.matches(rule, mockRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingMockRequest), isFalse);
    });

    test('should match regex correctly', () {
      final rule = MockRule.regex(
        pattern: r'\/items\/\d+',
        method: 'GET',
        handler: (_) => MockResponse.text(''),
      );
      final options =
          RequestOptions(path: 'http://example.com/items/123', method: 'GET');
      final nonMatchingOptions =
          RequestOptions(path: 'http://example.com/items/abc', method: 'GET');

      final mockRequest = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );
      final nonMatchingMockRequest = MockRequest(
        url: nonMatchingOptions.uri.toString(),
        path: nonMatchingOptions.uri.path,
        method: nonMatchingOptions.method,
        query: nonMatchingOptions.queryParameters,
        headers: nonMatchingOptions.headers.map((k, v) => MapEntry(k, v.toString())),
        body: nonMatchingOptions.data,
      );

      final matcher = MockMatcher();
      expect(matcher.matches(rule, mockRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingMockRequest), isFalse);
    });

    test('should match query parameters correctly', () {
      final rule = MockRule(
        path: '/search',
        method: 'GET',
        queryParams: {'q': 'test', 'page': '1'},
        handler: (_) => MockResponse.text(''),
      );
      final options = RequestOptions(
        path: 'http://example.com/search',
        method: 'GET',
        queryParameters: {'q': 'test', 'page': '1'},
      );
      final nonMatchingOptions = RequestOptions(
        path: 'http://example.com/search',
        method: 'GET',
        queryParameters: {'q': 'test'},
      );

      final mockRequest = MockRequest(
        url: options.uri.toString(),
        path: options.uri.path,
        method: options.method,
        query: options.queryParameters,
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data,
      );
      final nonMatchingMockRequest = MockRequest(
        url: nonMatchingOptions.uri.toString(),
        path: nonMatchingOptions.uri.path,
        method: nonMatchingOptions.method,
        query: nonMatchingOptions.queryParameters,
        headers: nonMatchingOptions.headers.map((k, v) => MapEntry(k, v.toString())),
        body: nonMatchingOptions.data,
      );

      final matcher = MockMatcher();
      expect(matcher.matches(rule, mockRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingMockRequest), isFalse);
    });
  });
}
