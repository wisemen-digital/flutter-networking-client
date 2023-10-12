import 'package:dio/dio.dart';

/// Class [ErrorInterceptor] to catch and handle errors returned by dio
class ErrorInterceptor extends Interceptor {
  /// Constructor
  ErrorInterceptor();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    throw err;
  }
}
