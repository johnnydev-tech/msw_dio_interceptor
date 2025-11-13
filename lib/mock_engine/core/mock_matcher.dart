import 'mock_request.dart';
import 'mock_rule.dart';

/// A utility class to match a [MockRequest] against a [MockRule].
class MockMatcher {
  const MockMatcher();

  bool matches(MockRule rule, MockRequest request) {
    if (rule.method.toUpperCase() != request.method.toUpperCase()) {
      return false;
    }

    // Match query parameters
    if (rule.queryParams != null) {
      if (!rule.queryParams!.entries.every((entry) {
        return request.query[entry.key] == entry.value.toString();
      })) {
        return false;
      }
    }

    // Match by URL
    if (rule.url != null) {
      return request.url == rule.url;
    }

    // Match by Regex
    if (rule.regex != null) {
      return rule.regex!.hasMatch(request.url);
    }

    // Match by Path
    if (rule.path != null) {
      return request.path == rule.path;
    }

    // If a rule has no path/url/regex, it should not match anything.
    return false;
  }
}
