import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('MockRequest', () {
    test('should be created with correct properties', () {
      const url = 'http://example.com/path?query=value';
      const path = '/path';
      const method = 'GET';
      final query = {'query': 'value'};
      final headers = {'Content-Type': 'application/json'};
      const body = 'request body';

      final request = MockRequest(
        url: url,
        path: path,
        method: method,
        query: query,
        headers: headers,
        body: body,
      );

      expect(request.url, url);
      expect(request.path, path);
      expect(request.method, method);
      expect(request.query, query);
      expect(request.headers, headers);
      expect(request.body, body);
    });
  });
}
