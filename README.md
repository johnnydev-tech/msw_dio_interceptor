# MSW Dio Interceptor

[![Build Status](https://github.com/johnnydev-tech/msw_dio_interceptor/actions/workflows/ci.yaml/badge.svg)](https://github.com/johnnydev-tech/msw_dio_interceptor/actions/workflows/ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/msw_dio_interceptor)](https://pub.dev/packages/msw_dio_interceptor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible mock interceptor for `dio`, inspired by [Mock Service Worker (MSW)](https://mswjs.io/).

This package provides a clean, universal mocking engine and a dedicated `dio` interceptor to mock API responses, making it perfect for testing, development, and UI prototyping.

## Features

-   ✅ **Clean Architecture**: A universal core engine with a dedicated adapter for Dio.
-   ✅ **Easy to Use**: Simple and intuitive API for registering mock rules.
-   ✅ **Environment-Controlled**: Enable or disable mocks globally with an environment flag.
-   ✅ **Flexible Matching**: Match requests by path, full URL, RegExp, and query parameters.
-   ✅ **Realistic Simulations**: Simulate status codes, errors, and custom headers.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  dio: <latest_version>
  
dev_dependencies:
  msw_dio_interceptor: <latest_version>
```

Then, run `dart pub get` or `flutter pub get`.

## How to Use

### 1. Enable Mocks via Environment Flag

To run your application with mocks enabled, use the `--define` flag:

```sh
# For pure Dart apps
dart --define=ENABLE_API_MOCK=true run your_app.dart

# For Flutter apps
flutter run --dart-define=ENABLE_API_MOCK=true
```

### 2. Register Mock Rules

Use the `MockRegistry` to define the rules for your mock responses.

```dart
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';

void setupMocks() {
  MockRegistry.register(
    MockRule(
      path: '/products',
      method: 'GET',
      handler: (request) {
        return MockResponse.json({
          'items': [{'id': 1, 'name': 'Product A'}]
        });
      },
    ),
  );
}
```

### 3. Add the Interceptor to Dio

Create an instance of the `MockHttpEngine` and pass it to the `MockInterceptor`.

```dart
import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';

const bool kEnableApiMock = bool.fromEnvironment('ENABLE_API_MOCK');

// 1. Create the engine
final mockEngine = MockHttpEngine(enabled: kEnableApiMock);

// 2. Create a Dio instance and add the interceptor
final dio = Dio();
dio.interceptors.add(MockInterceptor(engine: mockEngine));

// Now you can use dio as usual
await dio.get('/products');
```

## Testing

This package is ideal for writing clean and reliable tests for your data layer.

In your test `setUp`, create the engine and interceptor, and use `MockRegistry.clear()` to ensure test isolation.

```dart
import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';

void main() {
  late Dio dio;
  late MockHttpEngine mockEngine;

  setUp(() {
    // Enable the engine for all tests
    mockEngine = MockHttpEngine(enabled: true);
    
    // Create a Dio instance with the interceptor
    dio = Dio();
    dio.interceptors.add(MockInterceptor(engine: mockEngine));

    // Clear all mocks before each test
    MockRegistry.clear();
  });

  test('fetchProducts returns a list of products on success', () async {
    // Arrange: Define the mock response
    MockRegistry.register(
      MockRule(
        path: '/products',
        method: 'GET',
        handler: (request) => MockResponse.json({
          'items': [{'id': 1, 'name': 'Mock Product'}]
        }),
      ),
    );

    // Act
    final response = await dio.get('/products');

    // Assert
    expect(response.statusCode, 200);
    expect(response.data, isA<String>());
  });
}
```