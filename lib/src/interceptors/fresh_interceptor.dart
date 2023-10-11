import 'package:fresh_dio/fresh_dio.dart';

/// Creates a [Fresh] interceptor to refresh oauth tokens
Fresh<OAuth2Token> getFreshInterceptor({
  required Future<OAuth2Token> Function(OAuth2Token?, Dio) refreshFunction,
}) {
  return Fresh.oAuth2(
    tokenStorage: InMemoryTokenStorage<OAuth2Token>(),
    refreshToken: refreshFunction,
  );
}
