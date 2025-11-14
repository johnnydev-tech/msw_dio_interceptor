import 'dart:convert';
import 'dart:typed_data';

import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('MockResponse', () {
    test('should be created with default properties', () {
      final response = MockResponse(data: 'test');
      expect(response.data, 'test');
      expect(response.statusCode, 200);
      expect(response.headers, isNull);
    });

    test('should be created with custom status code and headers', () {
      final headers = {'X-Custom': 'value'};
      final response = MockResponse(
        data: 'test',
        statusCode: 201,
        headers: headers,
      );
      expect(response.statusCode, 201);
      expect(response.headers, headers);
    });

    test('MockResponse.json should create a JSON response', () {
      final json = {'key': 'value'};
      final response = MockResponse.json(json, statusCode: 200);
      expect(response.data, jsonEncode(json));
      expect(response.statusCode, 200);
      expect(
          response.headers?['content-type'], 'application/json; charset=utf-8');
    });

    test('MockResponse.text should create a text response', () {
      const text = 'plain text';
      final response = MockResponse.text(text, statusCode: 200);
      expect(response.data, text);
      expect(response.statusCode, 200);
      expect(response.headers?['content-type'], 'text/plain; charset=utf-8');
    });

    test('MockResponse.bytes should create a bytes response', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final response = MockResponse.bytes(bytes, statusCode: 200);
      expect(response.data, bytes);
      expect(response.statusCode, 200);
      expect(response.headers, isNull); // No default content-type for bytes
    });
  });
}
