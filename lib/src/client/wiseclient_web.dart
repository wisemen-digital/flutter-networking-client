import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:wiseclient/src/wiseclient_base.dart';

/// Creates a [WiseClient] for native
WiseClient createClient([BaseOptions? options]) => WebWiseClient(options);

/// Implements [DioForBrowser] for native
class WebWiseClient extends DioForBrowser implements WiseClient {
  /// Creates a [WebWiseClient] instance
  WebWiseClient([BaseOptions? options]) {
    this.options = options ?? BaseOptions();
    httpClientAdapter = BrowserHttpClientAdapter();
  }

  @override
  bool get isWebClient => true;
}
