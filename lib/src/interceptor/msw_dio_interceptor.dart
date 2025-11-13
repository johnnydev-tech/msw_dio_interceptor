import 'package:dio/dio.dart';

import '../core/mock_registry.dart';

/// A Dio interceptor that mocks HTTP requests.
class MswDioInterceptor extends Interceptor {
  /// Whether the interceptor is enabled.
  final bool enabled;

  MswDioInterceptor({required this.enabled});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enabled) {
      return handler.next(options);
    }

    final rule = MockRegistry.find(options);

    if (rule == null) {
      return handler.next(options);
    }

    if (rule.delay > Duration.zero) {
      await Future.delayed(rule.delay);
    }

    final response = Response(
      requestOptions: options,
      data: rule.response.data,
      statusCode: rule.statusCode,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: [Headers.jsonContentType],
      }),
    );

    if (rule.statusCode >= 400) {
      return handler.reject(
        DioException(requestOptions: options, response: response),
        true,
      );
    }

    return handler.resolve(response, true);
  }
}
