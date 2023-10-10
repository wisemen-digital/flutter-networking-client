import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:wiseclient/wiseclient.dart';

/// Creates a [WiseClient] for native
WiseClient createClient([BaseOptions? options]) => NativeWiseClient(options);

/// Implements [DioForNative] for native
class NativeWiseClient extends DioForNative implements WiseClient {
  /// Creates a [NativeWiseClient] instance
  NativeWiseClient([BaseOptions? baseOptions]) {
    options = baseOptions ?? BaseOptions();
    httpClientAdapter = IOHttpClientAdapter();
  }

  @override
  bool get isWebClient => false;
}
