# MSW Dio Interceptor

[![Build Status](https://github.com/johnnydev-tech/msw_dio_interceptor/actions/workflows/ci.yaml/badge.svg)](https://github.com/johnnydev-tech/msw_dio_interceptor/actions/workflows/ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/msw_dio_interceptor)](https://pub.dev/packages/msw_dio_interceptor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible mock interceptor for `dio`, inspired by [Mock Service Worker (MSW)](https://mswjs.io/).

This package provides a clean, universal mocking engine and a dedicated `dio` interceptor to mock API responses, making it perfect for testing, development, and UI prototyping.

## Table of Contents

-   [Features](#features)
-   [Installation](#installation)
-   [How to Use](#how-to-use)
    -   [1. Enable Mocks via Environment Flag](#1-enable-mocks-via-environment-flag)
    -   [2. Register Mock Rules](#2-register-mock-rules)
    -   [3. Add the Interceptor to Dio](#3-add-the-interceptor-to-dio)
-   [Mocking Capabilities](#mocking-capabilities)
    -   [Basic Path Matching](#basic-path-matching)
    -   [Matching by Regular Expression (RegExp)](#matching-by-regular-expression-regexp)
    -   [Matching by Full URL](#matching-by-full-url)
    -   [Matching with Query Parameters](#matching-with-query-parameters)
    -   [Mocking Different HTTP Methods](#mocking-different-http-methods)
    -   [Simulating Network Latency (Delay)](#simulating-network-latency-delay)
    -   [Mocking Error Responses](#mocking-error-responses)
    -   [Mocking Different Response Body Types](#mocking-different-response-body-types)
-   [Logging Mocked Requests](#logging-mocked-requests)
-   [Testing with Mocks](#testing-with-mocks)
    -   [Philosophy](#philosophy)
    -   [Example: Testing a Repository](#example-testing-a-repository)
-   [Contributing](#contributing)
-   [License](#license)

## Features

-   ✅ **Clean Architecture**: A universal core engine with a dedicated adapter for Dio.
-   ✅ **Easy to Use**: Simple and intuitive API for registering mock rules.
-   ✅ **Environment-Controlled**: Enable or disable mocks globally with an environment flag.
-   ✅ **Flexible Matching**: Match requests by path, full URL, RegExp, and query parameters.
-   ✅ **Realistic Simulations**: Simulate status codes, errors, delays, and custom headers.
-   ✅ **Customizable Logging**: Built-in logging for mocked requests, with custom print function support.

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

Use the `MockRegistry` to define the rules for your mock responses. This is typically done once at application startup or before your tests run.

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

// 1. Create the engine, enabled/disabled by the environment flag
final mockEngine = MockHttpEngine(enabled: kEnableApiMock);

// 2. Create a Dio instance and add the interceptor
final dio = Dio();
dio.interceptors.add(MockInterceptor(engine: mockEngine));

// Now you can use dio as usual
await dio.get('/products');
```

## Mocking Capabilities

The `MockRule` class offers flexible ways to match incoming requests and define their responses.

### Basic Path Matching

Match requests based on a specific path and HTTP method.

```dart
MockRegistry.register(
  MockRule(
    path: '/users',
    method: 'GET',
    handler: (request) => MockResponse.json([
      {'id': 1, 'name': 'Alice'},
      {'id': 2, 'name': 'Bob'},
    ]),
  ),
);
```

### Matching by Regular Expression (RegExp)

Use `MockRule.regex` for dynamic paths, such as fetching resources by ID.

```dart
MockRegistry.register(
  MockRule.regex(
    pattern: r'\/users\/\d+', // Matches /users/1, /users/123, etc.
    method: 'GET',
    handler: (request) {
      final userId = request.url.split('/').last;
      return MockResponse.json({'id': userId, 'name': 'User $userId'});
    },
  ),
);
```

### Matching by Full URL

Use `MockRule.url` to match an exact URL, including the domain, protocol, and path.

```dart
MockRegistry.register(
  MockRule.url(
    url: 'https://api.example.com/health',
    method: 'GET',
    handler: (request) => MockResponse.text('OK - API is healthy'),
  ),
);
```

### Matching with Query Parameters

The `queryParams` property allows you to match requests only if they contain specific query parameters.

```dart
MockRegistry.register(
  MockRule(
    path: '/search',
    method: 'GET',
    queryParams: {'q': 'flutter', 'page': '1'},
    handler: (request) => MockResponse.json({'results': ['Flutter rocks!']}),
  ),
);
```

### Mocking Different HTTP Methods

Define separate rules for different HTTP methods (GET, POST, PUT, DELETE, etc.) to the same path.

```dart
// GET /items
MockRegistry.register(
  MockRule(
    path: '/items',
    method: 'GET',
    handler: (request) => MockResponse.json({'items': []}),
  ),
);

// POST /items
MockRegistry.register(
  MockRule(
    path: '/items',
    method: 'POST',
    handler: (request) => MockResponse.json({'message': 'Item created'}, statusCode: 201),
  ),
);
```

### Simulating Network Latency (Delay)

Use the `delayMs` property in `MockRule` to simulate network latency for a specific mock response.

```dart
MockRegistry.register(
  MockRule(
    path: '/slow-data',
    method: 'GET',
    delayMs: 2000, // Delays the response by 2 seconds
    handler: (request) => MockResponse.json({'data': 'This came after a delay!'}),
  ),
);
```

### Mocking Error Responses

To simulate an error, simply provide a `statusCode` of 400 or higher in your `MockResponse`.

```dart
MockRegistry.register(
  MockRule(
    path: '/auth/login',
    method: 'POST',
    handler: (request) => MockResponse.json(
      {'error': 'Invalid credentials'},
      statusCode: 401,
    ),
  ),
);
```

### Mocking Different Response Body Types

Use the factory constructors of `MockResponse` to easily create JSON, text, or byte array responses.

```dart
// JSON Response (default for .json factory)
MockRegistry.register(
  MockRule(
    path: '/data',
    method: 'GET',
    handler: (request) => MockResponse.json({'key': 'value'}),
  ),
);

// Text Response
MockRegistry.register(
  MockRule(
    path: '/status',
    method: 'GET',
    handler: (request) => MockResponse.text('Service is operational'),
  ),
);

// Bytes Response (e.g., for images or binary data)
import 'dart:typed_data';
MockRegistry.register(
  MockRule(
    path: '/image',
    method: 'GET',
    handler: (request) => MockResponse.bytes(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47])), // PNG header example
  ),
);
```

## Logging Mocked Requests

You can enable logging for mocked requests to see details directly in your console. This is useful for debugging and understanding which mocks are being hit.

To enable logging, set the `log` parameter to `true` when creating the `MockInterceptor`. You can also provide a custom `logPrint` function.

```dart
import 'package:flutter/foundation.dart'; // For debugPrint in Flutter

// ...
final dio = Dio();
dio.interceptors.add(
  MockInterceptor(
    engine: mockEngine,
    log: true, // Enable logging
    // Optional: Provide a custom logPrint function (defaults to print)
    // logPrint: debugPrint, // Use debugPrint in Flutter apps
  ),
);
```

Example log output:

```
╔══ 🚀 Mocked Request ══╗
║ URI: http://example.com/products
║ Method: GET
║
╟── Mock Response ───
║ Status: 200
║ Data: {"items":[{"id":1,"name":"Mock Product"}]}
╚════════════════════╝
```

## Testing with Mocks

A primary use case for this package is to write clean and reliable tests for your application's data layer (e.g., repositories or data sources) without making real network requests.

### Philosophy

The goal is to test your data layer's logic (how it handles success, errors, and data parsing) without depending on a live server. By mocking the server response at the network level, your data source class doesn't need to know it's being tested.

### Example: Testing a Repository

Imagine you have a `ProductRepository` that fetches products from an API.

```dart
// Your repository class
class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _dio.get('/products');
      final items = (response.data['items'] as List);
      return items.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      // In a real app, you'd have more robust error handling
      throw Exception('Failed to fetch products');
    }
  }
}

class Product {
  final int id;
  final String name;
  Product({required this.id, required this.name});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(id: json['id'], name: json['name']);
  }
}
```

Now, let's write a test for this repository.

```dart
// In your test file
import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';

void main() {
  late Dio dio;
  late ProductRepository productRepository;
  late MockHttpEngine mockEngine;

  setUp(() {
    // 1. Create the mock engine, enabled for tests
    mockEngine = MockHttpEngine(enabled: true);
    
    // 2. Create a new Dio instance for each test and add the interceptor
    dio = Dio();
    dio.interceptors.add(MockInterceptor(engine: mockEngine));
    
    // 3. Create an instance of your repository
    productRepository = ProductRepository(dio);

    // 4. Clear all mocks before each test to ensure isolation
    MockRegistry.clear();
  });

  test('fetchProducts returns a list of products on success', () async {
    // Arrange: Define the mock response for this specific test
    MockRegistry.register(
      MockRule(
        path: '/products',
        method: 'GET',
        handler: (request) => MockResponse.json({
          'items': [
            {'id': 1, 'name': 'Mock Product 1'},
            {'id': 2, 'name': 'Mock Product 2'},
          ]
        }),
      ),
    );

    // Act: Call the method you want to test
    final products = await productRepository.fetchProducts();

    // Assert: Verify the result
    expect(products, isA<List<Product>>());
    expect(products.length, 2);
    expect(products.first.name, 'Mock Product 1');
  });

  test('fetchProducts throws an exception on server error', () async {
    // Arrange: Mock a server error response
    MockRegistry.register(
      MockRule(
        path: '/products',
        method: 'GET',
        handler: (request) => MockResponse.json(
          {'error': 'Internal Server Error'},
          statusCode: 500,
        ),
      ),
    );

    // Act & Assert: Verify that the correct exception is thrown
    expect(
      () => productRepository.fetchProducts(),
      throwsA(isA<Exception>()),
    );
  });
}
```

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
