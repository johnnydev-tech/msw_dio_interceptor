/// A universal, client-agnostic representation of an HTTP request.
class MockRequest {
  final String url;
  final String path;
  final String method;
  final Map<String, dynamic> query;
  final Map<String, String> headers;
  final dynamic body;

  const MockRequest({
    required this.url,
    required this.path,
    required this.method,
    required this.query,
    required this.headers,
    this.body,
  });
}
