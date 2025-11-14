import 'package:fake_async/fake_async.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('MockHttpEngine', () {
    setUp(() {
      MockRegistry.clear();
    });

    test('handles request when a rule matches', () async {
      final engine = MockHttpEngine();
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

    test('returns null when no rule matches', () async {
      final engine = MockHttpEngine();
      // No rule registered

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

    test('applies delay from rule', () {
      fakeAsync((async) {
        final engine = MockHttpEngine();
        MockRegistry.register(
          MockRule(
            path: '/delayed',
            method: 'GET',
            delayMs: 500,
            handler: (_) => MockResponse.text('delayed'),
          ),
        );

        final request = MockRequest(
          url: 'http://example.com/delayed',
          path: '/delayed',
          method: 'GET',
          query: {},
          headers: {},
        );

        bool completed = false;
        engine.handle(request).then((response) {
          expect(response?.data, 'delayed');
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
