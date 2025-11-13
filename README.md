# MSW Dio Interceptor

[![Build Status](https://github.com/johnnydev-tech/msw_dio_interceptor/actions/workflows/ci.yaml/badge.svg)](https://github.com/johnnydev-tech/msw_dio_interceptor/actions/workflows/ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/msw_dio_interceptor)](https://pub.dev/packages/msw_dio_interceptor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible mock interceptor for `dio`, inspired by [Mock Service Worker (MSW)](https://mswjs.io/).

Create, register, and manage mock API responses for your Dart and Flutter applications with ease. This package allows you to intercept `dio` requests and return simulated responses based on configured rules, making it perfect for testing, development, and UI prototyping.

## Features

-   ✅ **Dio Focused**: Built specifically as a `dio` interceptor.
-   ✅ **Easy to Use**: Simple and intuitive API for registering mock rules.
-   ✅ **Environment-Controlled**: Enable or disable mocks globally with an environment flag.
-   ✅ **Flexible Matching**: Match requests by path, full URL, RegExp, query parameters, and HTTP method.
-   ✅ **Realistic Simulations**: Simulate status codes, errors, and delays.
-   ✅ **Scoped Mocks**: Group related mocks using namespaces.

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
      method: HttpMethod.get,
      response: MockResponse.json({
        'items': [{'id': 1, 'name': 'Product A'}]
      }),
      statusCode: 200,
      delayMs: 300, // Optional delay
    ),
  );
}
```

### 3. Add the Interceptor to Dio

Add the `MswDioInterceptor` to your Dio instance.

```dart
import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';

const bool kEnableApiMock = bool.fromEnvironment('ENABLE_API_MOCK');

final dio = Dio();
dio.interceptors.add(MswDioInterceptor(enabled: kEnableApiMock));

// Now you can use dio as usual
await dio.get('/products');
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
        method: HttpMethod.get,
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
        method: HttpMethod.get,
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
