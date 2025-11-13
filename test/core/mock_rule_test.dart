import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('MockRule.matches', () {
    final baseRequest = RequestOptions(path: 'http://example.com');

    test('should match method correctly', () {
      final rule = MockRule(
        path: '/test',
        method: HttpMethod.get,
        response: MockResponse.text(''),
      );
      final options = baseRequest.copyWith(path: '/test', method: 'GET');
      final nonMatchingOptions =
          baseRequest.copyWith(path: '/test', method: 'POST');

      expect(rule.matches(options), isTrue);
      expect(rule.matches(nonMatchingOptions), isFalse);
    });

    test('should match path correctly', () {
      final rule = MockRule(
        path: '/test',
        method: HttpMethod.get,
        response: MockResponse.text(''),
      );
      final options = baseRequest.copyWith(path: '/test', method: 'GET');
      final nonMatchingOptions =
          baseRequest.copyWith(path: '/other', method: 'GET');

      expect(rule.matches(options), isTrue);
      expect(rule.matches(nonMatchingOptions), isFalse);
    });

    test('should match full url correctly', () {
      const url = 'https://api.example.com/v1/data';
      final rule = MockRule.url(
        url: url,
        method: HttpMethod.get,
        response: MockResponse.text(''),
      );
      final options = RequestOptions(path: url, method: 'GET');
      final nonMatchingOptions =
          RequestOptions(path: 'https://api.example.com/v2/data', method: 'GET');

      expect(rule.matches(options), isTrue);
      expect(rule.matches(nonMatchingOptions), isFalse);
    });

    test('should match regex correctly', () {
      final rule = MockRule.regex(
        pattern: r'\/items\/\d+',
        method: HttpMethod.get,
        response: MockResponse.text(''),
      );
      final options =
          RequestOptions(path: 'http://example.com/items/123', method: 'GET');
      final nonMatchingOptions =
          RequestOptions(path: 'http://example.com/items/abc', method: 'GET');

      expect(rule.matches(options), isTrue);
      expect(rule.matches(nonMatchingOptions), isFalse);
    });

    test('should match query parameters correctly', () {
      final rule = MockRule(
        path: '/search',
        method: HttpMethod.get,
        queryParams: {'q': 'test', 'page': '1'},
        response: MockResponse.text(''),
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

      expect(rule.matches(options), isTrue);
      expect(rule.matches(nonMatchingOptions), isFalse);
    });
  });
}
