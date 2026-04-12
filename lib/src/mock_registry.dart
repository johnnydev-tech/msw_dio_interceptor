import 'mock_matcher.dart';
import 'mock_request.dart';
import 'mock_rule.dart';

/// A global registry for storing and retrieving [MockRule]s.
class MockRegistry {
  // A private constructor to prevent instantiation.
  MockRegistry._();

  static final List<MockRule> _rules = [];
  static final MockMatcher _matcher = const MockMatcher();

  /// Registers a [MockRule].
  static void register(MockRule rule) {
    _rules.add(rule);
  }

  /// Finds the last [MockRule] that matches the given [MockRequest].
  /// This ensures that newer handlers override previous ones.
  static MockRule? find(MockRequest request) {
    for (int i = _rules.length - 1; i >= 0; i--) {
      final rule = _rules[i];
      if (_matcher.matches(rule, request)) {
        return rule;
      }
    }
    return null;
  }

  /// Clears all registered rules.
  static void clear() {
    _rules.clear();
  }
}
