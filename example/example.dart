import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:flutter/foundation.dart'; // For debugPrint in Flutter environments

const bool kEnableApiMock = bool.fromEnvironment('ENABLE_API_MOCK', defaultValue: false);

Future<void> main() async {
  // --- 1. Setup the Mock Engine and Interceptor ---
  // The MockHttpEngine is the core logic, enabled/disabled by the flag.
  final mockEngine = MockHttpEngine(enabled: kEnableApiMock);

  // The MockInterceptor integrates the engine with Dio.
  final dio = Dio();
  dio.interceptors.add(
    MockInterceptor(
      engine: mockEngine,
      log: true, // Enable logging for mocked requests
      logPrint: (message) => kDebugMode ? debugPrint(message) : print(message), // Use debugPrint in Flutter
    ),
  );

  // --- 2. Register Mock Rules ---
  // Define all your mock rules here. They are global to the MockRegistry.
  setupMocks();

  // --- 3. Run Examples ---
  print('--- Running MSW Dio Interceptor Example ---');
  print('Mocks enabled: $kEnableApiMock\n');

  if (!kEnableApiMock) {
    print(
      '[INFO] To run with mocks, use: dart --define=ENABLE_API_MOCK=true run example/example.dart',
    );
  }

  await runBasicExamples(dio);
  await runAdvancedMatchingExamples(dio);
  await runErrorAndDelayExamples(dio);
}

void setupMocks() {
  // Basic GET request mock
  MockRegistry.register(
    MockRule(
      path: '/products',
      method: 'GET',
      handler: (request) async {
        return MockResponse.json({
          'items': [
            {'id': 1, 'name': 'Product A (Mock)'},
            {'id': 2, 'name': 'Product B (Mock)'},
          ],
        });
      },
    ),
  );

  // Mock with regex for dynamic paths
  MockRegistry.register(
    MockRule.regex(
      pattern: r'\/users\/\d+',
      method: 'GET',
      handler: (request) async {
        final userId = request.url.split('/').last;
        return MockResponse.json({'id': userId, 'name': 'User $userId (Mock)'});
      },
    ),
  );

  // Mock with full URL matching
  MockRegistry.register(
    MockRule.url(
      url: 'https://api.example.com/status',
      method: 'GET',
      handler: (request) async {
        return MockResponse.text('API is UP (Mock)');
      },
    ),
  );

  // Mock with query parameters
  MockRegistry.register(
    MockRule(
      path: '/search',
      method: 'GET',
      queryParams: {'q': 'dart'},
      handler: (request) async {
        return MockResponse.json({'results': ['Dart is awesome!']});
      },
    ),
  );

  // Mock a POST request
  MockRegistry.register(
    MockRule(
      path: '/orders',
      method: 'POST',
      handler: (request) async {
        return MockResponse.json({'orderId': 'mock-123', 'status': 'created'}, statusCode: 201);
      },
    ),
  );

  // Mock an error response
  MockRegistry.register(
    MockRule(
      path: '/auth/profile',
      method: 'GET',
      handler: (request) async {
        return MockResponse.json(
          {'error': 'Unauthorized'},
          statusCode: 401,
        );
      },
    ),
  );

  // Mock a request with simulated delay
  MockRegistry.register(
    MockRule(
      path: '/slow-data',
      method: 'GET',
      delayMs: 1500, // 1.5 seconds delay
      handler: (request) async {
        return MockResponse.json({'data': 'This came after a delay!'});
      },
    ),
  );
}

Future<void> runBasicExamples(Dio dio) async {
  print('\n--- Basic Examples ---');

  // Fetch products
  await _makeRequest(dio, () => dio.get('http://example.com/products'), 'GET /products');

  // Create an order
  await _makeRequest(dio, () => dio.post('http://example.com/orders', data: {'item': 'new'}), 'POST /orders');
}

Future<void> runAdvancedMatchingExamples(Dio dio) async {
  print('\n--- Advanced Matching Examples ---');

  // Fetch user by ID (regex)
  await _makeRequest(dio, () => dio.get('http://example.com/users/456'), 'GET /users/456 (regex)');

  // Check API status (full URL)
  await _makeRequest(dio, () => dio.get('https://api.example.com/status'), 'GET https://api.example.com/status (full URL)');

  // Search with query params
  await _makeRequest(dio, () => dio.get('http://example.com/search', queryParameters: {'q': 'dart'}), 'GET /search?q=dart (query params)');
}

Future<void> runErrorAndDelayExamples(Dio dio) async {
  print('\n--- Error and Delay Examples ---');

  // Fetch protected profile (error)
  await _makeRequest(dio, () => dio.get('http://example.com/auth/profile'), 'GET /auth/profile (error)');

  // Fetch slow data (delay)
  await _makeRequest(dio, () => dio.get('http://example.com/slow-data'), 'GET /slow-data (delay)');
}

Future<void> _makeRequest(Dio dio, Future<Response> Function() requestFn, String description) async {
  try {
    print('Requesting: $description');
    final response = await requestFn();
    print('✅ Success [${response.statusCode}]: ${response.data}');
  } on DioException catch (e) {
    print('❌ Error [${e.response?.statusCode ?? e.type}]: ${e.response?.data ?? e.message}');
  } catch (e) {
    print('❌ Unexpected Error: $e');
  }
}