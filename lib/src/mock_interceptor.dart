import 'package:dio/dio.dart';

import 'mock_engine.dart';
import 'mock_request.dart';

typedef LogPrint = void Function(String message);

/// A Dio interceptor that uses a [MockHttpEngine] to mock requests.
class MockInterceptor extends Interceptor {
  final MockHttpEngine engine;
  final bool log;
  final LogPrint logPrint;

  MockInterceptor({
    required this.engine,
    this.log = false,
    this.logPrint = print,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final mockRequest = MockRequest(
      url: options.uri.toString(),
      path: options.uri.path,
      method: options.method,
      query: options.queryParameters,
      headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
      body: options.data,
    );

    final mockResponse = await engine.handle(mockRequest);

    if (mockResponse != null) {
      final dioResponse = Response(
        data: mockResponse.data,
        statusCode: mockResponse.statusCode,
        requestOptions: options,
        headers: Headers.fromMap(
          mockResponse.headers?.map((k, v) => MapEntry(k, [v])) ?? {},
        ),
      );

      if (log) {
        _logMockedRequest(options, dioResponse);
      }

      if (mockResponse.statusCode >= 400) {
        handler.reject(
          DioException(requestOptions: options, response: dioResponse),
          true,
        );
      } else {
        handler.resolve(dioResponse, true);
      }
      return;
    }

    handler.next(options);
  }

  void _logMockedRequest(RequestOptions options, Response response) {
    final buffer = StringBuffer();
    buffer.writeln('╔══ 🚀 Mocked Request ══╗');
    buffer.writeln('║ URI: ${options.uri}');
    buffer.writeln('║ Method: ${options.method}');
    buffer.writeln('║');
    buffer.writeln('╟── Mock Response ───');
    buffer.writeln('║ Status: ${response.statusCode}');
    buffer.writeln('║ Data: ${response.data}');
    buffer.writeln('╚════════════════════╝');
    logPrint(buffer.toString());
  }
}