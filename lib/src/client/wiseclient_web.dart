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
}) =>
    WebWiseClient(
      baseOptions: baseOptions,
      refreshFunction: refreshFunction,
      addedInterceptors: addedInterceptors,
    );

/// Implements [DioForBrowser] for native
class WebWiseClient extends DioForBrowser implements WiseClient {
  /// Creates a [WebWiseClient] instance
  WebWiseClient({
    required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
    BaseOptions? baseOptions,
    Iterable<Interceptor>? addedInterceptors,
  }) {
    options = baseOptions ?? BaseOptions();
    httpClientAdapter = BrowserHttpClientAdapter();
    interceptors.addAll(
      [
        ...addedInterceptors ?? <Interceptor>[],
        ...[
          getFreshInterceptor(refreshFunction: refreshFunction),
          ErrorInterceptor(),
        ],
      ],
    );
  }

  @override
  bool get isWebClient => true;
}
