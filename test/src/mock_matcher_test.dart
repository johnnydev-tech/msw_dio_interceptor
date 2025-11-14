import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('MockMatcher', () {
    final matcher = MockMatcher();

    test('should match method correctly', () {
      final rule = MockRule(
        path: '/test',
        method: 'GET',
        handler: (_) => MockResponse.text(''),
      );
      final matchingRequest = MockRequest(
        url: 'http://example.com/test',
        path: '/test',
        method: 'GET',
        query: {},
        headers: {},
      );
      final nonMatchingRequest = MockRequest(
        url: 'http://example.com/test',
        path: '/test',
        method: 'POST',
        query: {},
        headers: {},
      );

      expect(matcher.matches(rule, matchingRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingRequest), isFalse);
    });

    test('should match path correctly', () {
      final rule = MockRule(
        path: '/test',
        method: 'GET',
        handler: (_) => MockResponse.text(''),
      );
      final matchingRequest = MockRequest(
        url: 'http://example.com/test',
        path: '/test',
        method: 'GET',
        query: {},
        headers: {},
      );
      final nonMatchingRequest = MockRequest(
        url: 'http://example.com/other',
        path: '/other',
        method: 'GET',
        query: {},
        headers: {},
      );

      expect(matcher.matches(rule, matchingRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingRequest), isFalse);
    });

    test('should match full url correctly', () {
      const url = 'https://api.example.com/v1/data';
      final rule = MockRule.url(
        url: url,
        method: 'GET',
        handler: (_) => MockResponse.text(''),
      );
      final matchingRequest = MockRequest(
        url: url,
        path: '/v1/data',
        method: 'GET',
        query: {},
        headers: {},
      );
      final nonMatchingRequest = MockRequest(
        url: 'https://api.example.com/v2/data',
        path: '/v2/data',
        method: 'GET',
        query: {},
        headers: {},
      );

      expect(matcher.matches(rule, matchingRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingRequest), isFalse);
    });

    test('should match regex correctly', () {
      final rule = MockRule.regex(
        pattern: r'\/items\/\d+',
        method: 'GET',
        handler: (_) => MockResponse.text(''),
      );
      final matchingRequest = MockRequest(
        url: 'http://example.com/items/123',
        path: '/items/123',
        method: 'GET',
        query: {},
        headers: {},
      );
      final nonMatchingRequest = MockRequest(
        url: 'http://example.com/items/abc',
        path: '/items/abc',
        method: 'GET',
        query: {},
        headers: {},
      );

      expect(matcher.matches(rule, matchingRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingRequest), isFalse);
    });

    test('should match query parameters correctly', () {
      final rule = MockRule(
        path: '/search',
        method: 'GET',
        queryParams: {'q': 'test', 'page': '1'},
        handler: (_) => MockResponse.text(''),
      );
      final matchingRequest = MockRequest(
        url: 'http://example.com/search?q=test&page=1',
        path: '/search',
        method: 'GET',
        query: {'q': 'test', 'page': '1'},
        headers: {},
      );
      final nonMatchingRequest = MockRequest(
        url: 'http://example.com/search?q=test',
        path: '/search',
        method: 'GET',
        query: {'q': 'test'},
        headers: {},
      );

      expect(matcher.matches(rule, matchingRequest), isTrue);
      expect(matcher.matches(rule, nonMatchingRequest), isFalse);
    });
  });
}
