import 'package:dio/dio.dart';

import 'http_method.dart';
import 'mock_response.dart';

/// Defines a rule for mocking a request.
class MockRule {
  final HttpMethod method;
  final String? path;
  final RegExp? regex;
  final String? url;
  final Map<String, dynamic>? queryParams;
  final MockResponse response;
  final int statusCode;
  final Duration delay;

  /// Creates a [MockRule] that matches a request by its [path] and [method].
  MockRule({
    required this.path,
    required this.method,
    required this.response,
    this.statusCode = 200,
    this.queryParams,
    int delayMs = 0,
  })  : delay = Duration(milliseconds: delayMs),
        regex = null,
        url = null;

  /// Creates a [MockRule] that matches a request by a [RegExp] pattern.
  MockRule.regex({
    required String pattern,
    required this.method,
    required this.response,
    this.statusCode = 200,
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
    required this.response,
    this.statusCode = 200,
    this.queryParams,
    int delayMs = 0,
  })  : delay = Duration(milliseconds: delayMs),
        regex = null,
        path = null;

  /// Determines if this rule matches the given [RequestOptions].
  bool matches(RequestOptions options) {
    if (method.name.toUpperCase() != options.method.toUpperCase()) {
      return false;
    }

    final requestUri = options.uri;

    if (queryParams != null) {
      if (!queryParams!.entries.every((entry) {
        return requestUri.queryParameters[entry.key] == entry.value.toString();
      })) {
        return false;
      }
    }

    if (url != null) {
      return requestUri.toString() == url;
    }

    if (regex != null) {
      return regex!.hasMatch(requestUri.toString());
    }

    if (path != null) {
      return requestUri.path == path;
    }

    return false;
  }
}
