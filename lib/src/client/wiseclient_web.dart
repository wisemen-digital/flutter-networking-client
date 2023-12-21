import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:wiseclient/src/wiseclient_base.dart';

import '../interceptors/interceptors.dart';

/// Creates a [WiseClient] for native
WiseClient createClient({
  Future<OAuth2Token> Function(OAuth2Token?, Dio)? refreshFunction,
  BaseOptions? baseOptions,
  bool useNativeAdapter = false,
  Iterable<Interceptor>? interceptorsToAdd,
  Iterable<Interceptor>? replacementInterceptors,
}) =>
    WebWiseClient(
      baseOptions: baseOptions,
      refreshFunction: refreshFunction,
      interceptorsToAdd: interceptorsToAdd,
      replacementInterceptors: replacementInterceptors,
    );

/// Implements [DioForBrowser] for native
base class WebWiseClient extends DioForBrowser with WiseClient {
  /// Creates a [WebWiseClient] instance
  WebWiseClient({
    Future<OAuth2Token> Function(OAuth2Token?, Dio)? refreshFunction,
    BaseOptions? baseOptions,
    Iterable<Interceptor>? interceptorsToAdd,
    Iterable<Interceptor>? replacementInterceptors,
  }) {
    options = baseOptions ?? BaseOptions();
    httpClientAdapter = BrowserHttpClientAdapter();
    if (replacementInterceptors != null) {
      interceptors.addAll(replacementInterceptors);
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
  bool get isWebClient => true;
}
