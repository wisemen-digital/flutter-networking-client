import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';

import 'interceptors.dart';

/// [WiseInterceptor] enum to list the available interceptor options
enum WiseInterceptor {
  /// [fresh] interceptor to refresh authentication tokens
  fresh,

  /// [error] interceptor to handle dio exceptions
  error,

  /// [logging] interceptor to log requests
  logging;

  /// Function to get the correct interceptor
  Interceptor getInterceptor({Future<OAuth2Token> Function(OAuth2Token?, Dio)? refreshFunction}) {
    switch (this) {
      case WiseInterceptor.fresh:
        return getFreshInterceptor(
          refreshFunction: refreshFunction!,
        );
      case WiseInterceptor.error:
        return BaseErrorInterceptor();
      case WiseInterceptor.logging:
        return LogInterceptor(
          logPrint: (o) => log(o.toString()),
          requestBody: true,
          responseBody: true,
        );
    }
  }
}
