import 'dart:async';

import 'mock_registry.dart';
import 'mock_request.dart';
import 'mock_response.dart';

/// The central engine that handles request mocking.
class MockHttpEngine {
  final bool enabled;

  const MockHttpEngine({this.enabled = false});

  /// Handles an incoming [MockRequest], finds a matching rule,
  /// and returns a [MockResponse] if a match is found.
  ///
  /// Returns `null` if no matching rule is found or if the engine is disabled.
  Future<MockResponse?> handle(MockRequest request) async {
    if (!enabled) {
      return null;
    }

    final rule = MockRegistry.find(request);

    if (rule == null) {
      return null;
    }

    return await rule.handler(request);
  }
}
