import 'dart:async';

import 'mock_registry.dart';
import 'mock_request.dart';
import 'mock_response.dart';

/// The central engine that handles request mocking.
class MockHttpEngine {
  const MockHttpEngine();

  /// Handles an incoming [MockRequest], finds a matching rule,
  /// and returns a [MockResponse] if a match is found.
  ///
  /// Returns `null` if no matching rule is found.
  Future<MockResponse?> handle(MockRequest request) async {
    final rule = MockRegistry.find(request);

    if (rule == null) {
      return null;
    }

    // Apply delay if specified
    if (rule.delay > Duration.zero) {
      await Future.delayed(rule.delay);
    }

    return await rule.handler(request);
  }
}
