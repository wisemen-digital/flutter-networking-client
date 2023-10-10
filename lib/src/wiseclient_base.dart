import 'package:dio/dio.dart';
import 'client/wiseclient_native.dart' if (dart.library.html) 'client/wiseclient_web.dart';
import 'options.dart';

/// A networking client that extends [Dio]
abstract class WiseClient implements Dio {
  /// Creates [WiseClient] instance
  factory WiseClient([WiseOptions? options]) => createClient(options);

  /// Checks if client is an instance on web or native
  bool get isWebClient => throw UnimplementedError();
}
