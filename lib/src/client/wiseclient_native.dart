import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:wiseclient/wiseclient.dart';

import '../interceptors/interceptors.dart';

/// Creates a [WiseClient] for native
WiseClient createClient({
  Future<OAuth2Token> Function(OAuth2Token?, Dio)? refreshFunction,
  BaseOptions? options,
  bool useNativeAdapter = false,
  Iterable<Interceptor>? interceptorsToAdd,
  Iterable<Interceptor>? replacementInterceptors,
}) =>
    NativeWiseClient(
      baseOptions: options,
      refreshFunction: refreshFunction,
      useNativeAdapter: useNativeAdapter,
      interceptorsToAdd: interceptorsToAdd,
      replacementInterceptors: replacementInterceptors,
    );

/// Implements [DioForNative] for native
base class NativeWiseClient extends DioForNative with WiseClient {
  /// Creates a [NativeWiseClient] instance
  NativeWiseClient({
    required bool useNativeAdapter,
    Future<OAuth2Token> Function(OAuth2Token?, Dio)? refreshFunction,
    BaseOptions? baseOptions,
    Iterable<Interceptor>? interceptorsToAdd,
    Iterable<Interceptor>? replacementInterceptors,
  }) {
    options = baseOptions ?? BaseOptions();
    httpClientAdapter = useNativeAdapter ? NativeAdapter() : IOHttpClientAdapter();
    if (replacementInterceptors != null) {
      interceptors.addAll(
        replacementInterceptors,
      );
    } else {
      fresh = Fresh.oAuth2(
        tokenStorage: InMemoryTokenStorage<OAuth2Token>(),
        refreshToken: refreshFunction!,
      );
      interceptors.addAll(
        [
          BaseErrorInterceptor(),
          fresh,
          if (interceptorsToAdd != null) ...interceptorsToAdd,
        ],
      );
    }
  }

  @override
  bool get isWebClient => false;
}
