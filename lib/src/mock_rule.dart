import 'dart:async';

import 'mock_request.dart';
import 'mock_response.dart';

typedef MockResponseHandler = FutureOr<MockResponse> Function(
    MockRequest request);

/// Defines a rule for mocking a request.
class MockRule {
  final String method;
  final String? path;
  final RegExp? regex;
  final String? url;
  final Map<String, dynamic>? queryParams;
  final MockResponseHandler handler;
  final Duration delay;

  /// Creates a [MockRule] that matches a request by its [path] and [method].
  MockRule({
    required this.path,
    required this.method,
    required this.handler,
    this.queryParams,
    int delayMs = 0,
  })  : delay = Duration(milliseconds: delayMs),
        regex = null,
        url = null;

  /// Creates a [MockRule] that matches a request by a [RegExp] pattern.
  MockRule.regex({
    required String pattern,
    required this.method,
    required this.handler,
    this.queryParams,
    int delayMs = 0,
  })  : delay = Duration(milliseconds: delayMs),
        regex = RegExp(pattern),
        path = null,
        url = null;

  /// Creates a [MockRule] that matches a request by its full [url].
  MockRule.url({
    required this.url,
    required this.method,
    required this.handler,
    this.queryParams,
    int delayMs = 0,
  })  : delay = Duration(milliseconds: delayMs),
        regex = null,
        path = null;
}
