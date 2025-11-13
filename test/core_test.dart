import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('Core Components', () {
    setUp(() {
      MockRegistry.clear();
    });

    test('MockRegistry registers and finds a rule', () {
      final rule = MockRule(
        path: '/test',
        method: 'GET',
        handler: (_) => MockResponse.text('test'),
      );
      MockRegistry.register(rule);

      final request = MockRequest(
        url: 'http://example.com/test',
        path: '/test',
        method: 'GET',
        query: {},
        headers: {},
      );

      final foundRule = MockRegistry.find(request);
      expect(foundRule, equals(rule));
    });

    test('MockRegistry.find correctly matches rules', () {
      final rule = MockRule(
        path: '/test',
        method: 'GET',
        queryParams: {'id': '1'},
        handler: (_) => MockResponse.text('test'),
      );
      MockRegistry.register(rule);

      final matchingRequest = MockRequest(
        url: 'http://example.com/test?id=1',
        path: '/test',
        method: 'GET',
        query: {'id': '1'},
        headers: {},
      );

      final nonMatchingRequest = MockRequest(
        url: 'http://example.com/test',
        path: '/test',
        method: 'GET',
        query: {},
        headers: {},
      );

      expect(MockRegistry.find(matchingRequest), equals(rule));
      expect(MockRegistry.find(nonMatchingRequest), isNull);
    });

    test('MockHttpEngine handles request when enabled', () async {
      final engine = MockHttpEngine(enabled: true);
      MockRegistry.register(
        MockRule(
          path: '/test',
          method: 'GET',
          handler: (_) => MockResponse.text('success'),
        ),
      );

      final request = MockRequest(
        url: 'http://example.com/test',
        path: '/test',
        method: 'GET',
        query: {},
        headers: {},
      );

      final response = await engine.handle(request);
      expect(response, isNotNull);
      expect(response?.data, 'success');
    });

    test('MockHttpEngine returns null when disabled', () async {
      final engine = MockHttpEngine(enabled: false);
      MockRegistry.register(
        MockRule(
          path: '/test',
          method: 'GET',
          handler: (_) => MockResponse.text('success'),
        ),
      );

      final request = MockRequest(
        url: 'http://example.com/test',
        path: '/test',
        method: 'GET',
        query: {},
        headers: {},
      );

      final response = await engine.handle(request);
      expect(response, isNull);
    });
  });
}
