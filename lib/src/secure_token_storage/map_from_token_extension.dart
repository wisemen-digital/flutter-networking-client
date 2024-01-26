import 'package:fresh_dio/fresh_dio.dart';

/// extension to convert [OAuth2TokenToMap] to [Map]
extension OAuth2TokenToMap on OAuth2Token {
  /// Returns [Map] from [OAuth2Token]
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'refreshToken': refreshToken,
      'scope': scope,
    };
  }
}
