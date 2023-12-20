import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:wiseclient/src/wiseclient_base.dart';

import '../interceptors/interceptors.dart';

/// Creates a [WiseClient] for native
WiseClient createClient({
  required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
  BaseOptions? baseOptions,
  Iterable<Interceptor>? addedInterceptors,
  bool useNativeAdapter = false,
  bool proxyman = false,
}) =>
    WebWiseClient(
      baseOptions: baseOptions,
      refreshFunction: refreshFunction,
      addedInterceptors: addedInterceptors,
    );

/// Implements [DioForBrowser] for native
base class WebWiseClient extends DioForBrowser with WiseClient {
  /// Creates a [WebWiseClient] instance
  WebWiseClient({
    required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
    BaseOptions? baseOptions,
    Iterable<Interceptor>? addedInterceptors,
  }) {
    options = baseOptions ?? BaseOptions();
    httpClientAdapter = BrowserHttpClientAdapter();
    if (addedInterceptors != null) {
      interceptors.addAll(addedInterceptors);
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
  bool get isWebClient => true;
}
