import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:wiseclient/src/exceptions/exceptions.dart';
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

  /// [CancelToken] for wise requests
  CancelToken _cancelToken = CancelToken();

  @override
  bool get isWebClient => true;

  /// [wGet] method replaces get with build in features
  @override
  Future<dynamic> wGet(String path, {Map<String, dynamic>? queryParameters, Object? body}) async {
    try {
      final response = await get<dynamic>(
        path,
        cancelToken: _cancelToken,
        queryParameters: queryParameters,
        data: body,
      );
      return response.data;
    } on DioException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// [wPost] method replaces get with build in features
  @override
  Future<dynamic> wPost(String path, {Map<String, dynamic>? queryParameters, Object? body}) async {
    try {
      final response = await post<dynamic>(
        path,
        cancelToken: _cancelToken,
        queryParameters: queryParameters,
        data: body,
      );
      return response.data;
    } on DioException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// [cancelAndReset] method cancels current requests and resets the canceltoken
  @override
  Future<void> cancelAndReset({Duration? cancelDuration}) async {
    _cancelToken.cancel();
    await Future.delayed(
      cancelDuration ?? const Duration(milliseconds: 300),
      () {
        _cancelToken = CancelToken();
      },
    );
  }

  /// [cancelWiseRequests] method cancels current requests
  @override
  void cancelWiseRequests() {
    _cancelToken.cancel();
  }

  /// [resetWiseCancelToken] method resets the cancel token
  @override
  void resetWiseCancelToken() {
    _cancelToken = CancelToken();
  }
}
