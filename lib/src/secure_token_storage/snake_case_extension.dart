import 'package:fresh_dio/fresh_dio.dart';

/// Returns [OAuth2Token] from [Map] with SnakeCase params
extension OAuth2TokenExtension on Map<String, dynamic> {
  /// Returns [OAuth2Token] from [Map] with SnakeCase params
  OAuth2Token get fromMapWithSnakeCase {
    return OAuth2Token(
      accessToken: this['access_token'] as String,
      tokenType:
          this['token_type'] != null ? this['token_type'] as String : null,
      expiresIn: this['expires_in'] != null ? this['expires_in'] as int : null,
      refreshToken: this['refresh_token'] != null
          ? this['refresh_token'] as String
          : null,
      scope: this['scope'] != null ? this['scope'] as String : null,
    );
  }
}
