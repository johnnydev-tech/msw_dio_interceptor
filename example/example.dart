import 'package:dio/dio.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';

const bool kEnableApiMock = bool.fromEnvironment('ENABLE_API_MOCK', defaultValue: false);

Future<void> main() async {
  // --- 1. Setup the Interceptor ---
  final dio = Dio();
  dio.interceptors.add(
    MockInterceptor(
      engine: MockHttpEngine(enabled: kEnableApiMock),
    ),
  );

  // --- 2. Register Mock Rules ---
  setupMocks();

  // --- 3. Make Requests ---
  print('--- Running MSW Dio Interceptor Example ---');
  print('Mocks enabled: $kEnableApiMock\n');

  if (!kEnableApiMock) {
    print(
      '[INFO] To run with mocks, use: dart --define=ENABLE_API_MOCK=true run example/example.dart',
    );
  }

  try {
    print('Fetching /products...');
    final response = await dio.get('http://example.com/products');
    print('✅ Response [${response.statusCode}]: ${response.data}');
  } on DioException catch (e) {
    print('❌ Error [${e.response?.statusCode}]: ${e.message}');
  }

  try {
    print('\nFetching /auth/profile...');
    await dio.get('http://example.com/auth/profile');
  } on DioException catch (e) {
    print('❌ Error [${e.response?.statusCode}]: ${e.response?.data}');
  }
}

void setupMocks() {
  MockRegistry.register(
    MockRule(
      path: '/products',
      method: 'GET',
      handler: (request) async {
        return MockResponse.json({
          'items': [
            {'id': 1, 'name': 'Product A (from Mock)'},
            {'id': 2, 'name': 'Product B (from Mock)'},
          ],
        });
      },
    ),
  );

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
}
