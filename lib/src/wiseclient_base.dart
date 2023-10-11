import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:wiseclient/src/exceptions/unknown_exception.dart';
import 'client/wiseclient_native.dart' if (dart.library.html) 'client/wiseclient_web.dart';
import 'options.dart';

/// A networking client that extends [Dio]
abstract interface class WiseClient implements Dio {
  /// Creates [WiseClient] instance
  factory WiseClient({
    required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
    WiseOptions? options,
    bool useNativeAdaptor = false,
  }) =>
      createClient(
        options: options,
        refreshFunction: refreshFunction,
        useNativeAdapter: useNativeAdaptor,
      );

  /// Checks if client is an instance on web or native
  bool get isWebClient => throw UnimplementedError();

  /// [wGet] method replaces get with build in features
  static Future<dynamic> wGet() async {
    try {} on DioException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
