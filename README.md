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

## Logging

You can enable logging for mocked requests to see details directly in your console. This is useful for debugging and understanding which mocks are being hit.

To enable logging, set the `log` parameter to `true` when creating the `MockInterceptor`.

```dart
import 'package:flutter/foundation.dart'; // For debugPrint

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

## Advanced Usage

### Matching by RegExp

Use `MockRule.regex` to match requests against a regular expression. This is useful for dynamic paths, like fetching items by ID.

```dart
MockRegistry.register(
  MockRule.regex(
    pattern: r'\/users\/\d+', // Matches /users/1, /users/123, etc.
    method: 'GET',
    handler: (request) => MockResponse.json({'id': 123, 'name': 'John'}),
  ),
);
```

### Matching by Full URL

Use `MockRule.url` to match an exact URL, including the domain.

```dart
MockRegistry.register(
  MockRule.url(
    url: 'https://api.example.com/v1/me',
    method: 'GET',
    handler: (request) => MockResponse.json({'name': 'Authenticated User'}),
  ),
);
```

### Matching with Query Parameters

The `queryParams` property ensures that a rule only matches if the request contains the specified query parameters.

```dart
MockRegistry.register(
  MockRule(
    path: '/search',
    method: 'GET',
    queryParams: {'q': 'test', 'page': '1'},
    handler: (request) => MockResponse.json({'results': []}),
  ),
);
```

### Simulating Network Latency

Use the `delayMs` property to simulate network latency for a specific mock.

```dart
MockRegistry.register(
  MockRule(
    path: '/slow-request',
    method: 'GET',
    delayMs: 1500, // Delays the response by 1.5 seconds
    handler: (request) => MockResponse.text('Finally got here!'),
  ),
);
```

## Testing

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

  setUp(() {
    // 1. Create a new Dio instance for each test
    dio = Dio();

    // 2. Add the interceptor, making sure it's enabled for tests
    dio.interceptors.add(MswDioInterceptor(enabled: true));
    
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
        response: MockResponse.json({
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
        response: MockResponse.json({'error': 'Internal Server Error'}),
        statusCode: 500,
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