import 'dart:convert';
import 'dart:typed_data';

/// A universal, client-agnostic representation of an HTTP response.
class MockResponse {
  final dynamic data;
  final int statusCode;
  final Map<String, String>? headers;

  const MockResponse({
    this.data,
    this.statusCode = 200,
    this.headers,
  });

  /// Factory for creating a JSON response.
  factory MockResponse.json(
    Map<String, dynamic> data, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return MockResponse(
      data: jsonEncode(data),
      statusCode: statusCode,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        ...?headers,
      },
    );
  }

  /// Factory for creating a text response.
  factory MockResponse.text(
    String data, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return MockResponse(
      data: data,
      statusCode: statusCode,
      headers: {
        'content-type': 'text/plain; charset=utf-8',
        ...?headers,
      },
    );
  }

  /// Factory for creating a bytes response.
  factory MockResponse.bytes(
    Uint8List data, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return MockResponse(
      data: data,
      statusCode: statusCode,
      headers: headers,
    );
  }
}
