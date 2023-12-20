import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'client/wiseclient_native.dart' if (dart.library.html) 'client/wiseclient_web.dart';
import 'exceptions/exceptions.dart';
import 'options.dart';

/// A networking client that extends [Dio]
abstract mixin class WiseClient implements Dio {
  /// Creates [WiseClient] instance
  factory WiseClient({
    required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
    WiseOptions? options,
    bool useNativeAdaptor = false,
    bool proxyman = false,
    Iterable<Interceptor>? addedInterceptors,
  }) =>
      createClient(
        options: options,
        refreshFunction: refreshFunction,
        useNativeAdapter: useNativeAdaptor,
        proxyman: proxyman,
        addedInterceptors: addedInterceptors,
      );

  /// Checks if client is an instance on web or native
  bool get isWebClient => throw UnimplementedError();

  /// [Fresh] to handle authentication
  final Fresh<OAuth2Token> _fresh = Fresh.oAuth2(
    tokenStorage: InMemoryTokenStorage<OAuth2Token>(),
    refreshToken: (_, __) async => const OAuth2Token(accessToken: ''),
  );

  /// [CancelToken] for wise requests
  CancelToken cancelToken = CancelToken();

  /// [Stream] of [AuthenticationStatus], only works if [Fresh] client is in use
  Stream<AuthenticationStatus> get authenticationStatus {
    return _fresh.authenticationStatus;
  }

  /// [wGet] method replaces get with build in features
  Future<dynamic> wGet(String path, {Map<String, dynamic>? queryParameters, Object? body}) async {
    try {
      final response = await get<dynamic>(
        path,
        cancelToken: cancelToken,
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
  Future<dynamic> wPost(String path, {Map<String, dynamic>? queryParameters, Object? body}) async {
    try {
      final response = await post<dynamic>(
        path,
        cancelToken: cancelToken,
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

  /// [wPut] method replaces put with build in features
  Future<dynamic> wPut(String path, {Map<String, dynamic>? queryParameters, Object? body}) async {
    try {
      final response = await put<dynamic>(
        path,
        cancelToken: cancelToken,
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
  Future<void> cancelAndReset({Duration? cancelDuration}) async {
    cancelToken.cancel();
    await Future.delayed(
      cancelDuration ?? const Duration(milliseconds: 300),
      () {
        cancelToken = CancelToken();
      },
    );
  }

  /// [cancelWiseRequests] method cancels current requests
  void cancelWiseRequests() {
    cancelToken.cancel();
  }

  /// [resetWiseCancelToken] method resets the cancel token
  void resetWiseCancelToken() {
    cancelToken = CancelToken();
  }

  /// [removeFreshToken] method that removes bearer authentication token
  void removeFreshToken() {
    _fresh
      ..setToken(null)
      ..revokeToken();
  }

  /// [setFreshToken] method that sets bearer authentication token
  void setFreshToken({required OAuth2Token token}) {
    _fresh.setToken(token);
  }
}
