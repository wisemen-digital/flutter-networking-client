import 'package:fresh_dio/fresh_dio.dart';
import 'client/wiseclient_native.dart' if (dart.library.html) 'client/wiseclient_web.dart';
import 'options.dart';

/// A networking client that extends [Dio]
abstract interface class WiseClient implements Dio {
  /// Creates [WiseClient] instance
  factory WiseClient({
    required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
    WiseOptions? options,
    bool useNativeAdaptor = false,
    bool proxyman = false,
  }) =>
      createClient(
        options: options,
        refreshFunction: refreshFunction,
        useNativeAdapter: useNativeAdaptor,
        proxyman: proxyman,
      );

  /// Checks if client is an instance on web or native
  bool get isWebClient => throw UnimplementedError();

  /// [wGet] method replaces get with build in features
  Future<dynamic> wGet(String path, {Map<String, dynamic>? queryParameters, Object? body}) async {
    throw UnimplementedError();
  }

  /// [wPost] method replaces get with build in features
  Future<dynamic> wPost(String path, {Map<String, dynamic>? queryParameters, Object? body}) async {
    throw UnimplementedError();
  }

  /// [cancelAndReset] method cancels current requests and resets the canceltoken
  Future<void> cancelAndReset() async {
    throw UnimplementedError();
  }

  /// [cancelWiseRequests] method cancels current requests
  void cancelWiseRequests() {
    throw UnimplementedError();
  }

  /// [resetWiseCancelToken] method resets the cancel token
  void resetWiseCancelToken() {
    throw UnimplementedError();
  }
}
