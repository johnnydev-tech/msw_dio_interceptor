import 'package:dio/dio.dart';

import 'mock_rule.dart';

/// A global registry for storing and retrieving [MockRule]s.
class MockRegistry {
  // A private constructor to prevent instantiation.
  MockRegistry._();

  static final List<MockRule> _rules = [];
  static final Map<String, List<MockRule>> _namespacedRules = {};

  /// Registers a [MockRule].
  static void register(MockRule rule) {
    _rules.add(rule);
  }

  /// Returns a [MockRegistryNamespace] to register rules under a specific scope.
  static MockRegistryNamespace namespace(String name) {
    _namespacedRules.putIfAbsent(name, () => []);
    return MockRegistryNamespace._(name);
  }

  /// Finds the first [MockRule] that matches the given [RequestOptions].
  static MockRule? find(RequestOptions options) {
    for (final rule in _rules) {
      if (rule.matches(options)) {
        return rule;
      }
    }
    for (final namespace in _namespacedRules.values) {
      for (final rule in namespace) {
        if (rule.matches(options)) {
          return rule;
        }
      }
    }
    return null;
  }

  /// Clears all registered rules (global and namespaced).
  static void clear() {
    _rules.clear();
    _namespacedRules.clear();
  }
}

/// A wrapper for registering rules under a specific namespace.
class MockRegistryNamespace {
  final String _name;

  MockRegistryNamespace._(this._name);

  /// Registers a [MockRule] within this namespace.
  void register(MockRule rule) {
    MockRegistry._namespacedRules[_name]?.add(rule);
  }
}
