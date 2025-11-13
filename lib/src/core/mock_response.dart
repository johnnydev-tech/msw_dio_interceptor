import 'dart:convert';
import 'dart:typed_data';

/// Represents a mock response to be returned by the interceptor.
class MockResponse {
  /// The data to be returned in the response body.
  final dynamic data;

  /// Creates a [MockResponse] with the given data.
  const MockResponse(this.data);

  /// Factory constructor for creating a response with JSON data.
  ///
  /// The [json] object will be encoded to a UTF-8 string.
  factory MockResponse.json(Map<String, dynamic> json) {
    return MockResponse(jsonEncode(json));
  }

  /// Factory constructor for creating a response with plain text data.
  factory MockResponse.text(String text) {
    return MockResponse(text);
  }

  /// Factory constructor for creating a response with byte data.
  factory MockResponse.bytes(Uint8List bytes) {
    return MockResponse(bytes);
  }
}
