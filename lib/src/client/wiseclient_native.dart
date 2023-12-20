import 'dart:io';

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
  bool proxyman = false,
}) =>
    NativeWiseClient(
      baseOptions: options,
      refreshFunction: refreshFunction,
      useNativeAdapter: useNativeAdapter,
      addedInterceptors: addedInterceptors,
      proxyman: proxyman,
    );

/// Implements [DioForNative] for native
base class NativeWiseClient extends DioForNative with WiseClient {
  /// Creates a [NativeWiseClient] instance
  NativeWiseClient({
    required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
    required bool useNativeAdapter,
    required bool proxyman,
    BaseOptions? baseOptions,
    Iterable<Interceptor>? addedInterceptors,
  }) {
    options = baseOptions ?? BaseOptions();
    if (proxyman) {
      httpClientAdapter = getProxyHttpClientAdapter();
    } else {
      httpClientAdapter = useNativeAdapter ? NativeAdapter() : IOHttpClientAdapter();
    }
    if (addedInterceptors != null) {
      interceptors.addAll(
        addedInterceptors,
      );
    } else {
      final fresh = Fresh.oAuth2(
        tokenStorage: InMemoryTokenStorage<OAuth2Token>(),
        refreshToken: refreshFunction,
      );
      interceptors.addAll(
        [
          BaseErrorInterceptor(),
          fresh,
        ],
      );
    }
  }

  @override
  bool get isWebClient => false;

  /// Client adapter for proxyman
  IOHttpClientAdapter getProxyHttpClientAdapter() {
    final proxy = Platform.isAndroid ? '192.168.2.187:9090' : '192.168.10.213:9090';

    return IOHttpClientAdapter()
      ..createHttpClient = () {
        return HttpClient()
          ..findProxy = ((url) => 'PROXY $proxy')
          ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; //Platform.isAndroid;
      };
  }
}
