import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:wiseclient/wiseclient.dart';

import '../interceptors/interceptors.dart';

/// Creates a [WiseClient] for native
WiseClient createClient({
  required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
  BaseOptions? options,
  Iterable<Interceptor>? addedInterceptors,
  bool useNativeAdapter = false,
}) =>
    NativeWiseClient(
      baseOptions: options,
      refreshFunction: refreshFunction,
      useNativeAdapter: useNativeAdapter,
    );

/// Implements [DioForNative] for native
class NativeWiseClient extends DioForNative implements WiseClient {
  /// Creates a [NativeWiseClient] instance
  NativeWiseClient({
    required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
    required bool useNativeAdapter,
    BaseOptions? baseOptions,
    Iterable<Interceptor>? addedInterceptors,
  }) {
    options = baseOptions ?? BaseOptions();
    httpClientAdapter = useNativeAdapter ? NativeAdapter() : IOHttpClientAdapter();
    if (addedInterceptors != null) {
      interceptors.addAll(
        addedInterceptors,
      );
    } else {
      interceptors.addAll(
        [
          getFreshInterceptor(refreshFunction: refreshFunction),
          ErrorInterceptor(),
        ],
      );
    }
  }

  @override
  bool get isWebClient => false;
}
