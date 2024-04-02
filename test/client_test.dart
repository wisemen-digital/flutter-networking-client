import 'package:fresh_dio/fresh_dio.dart';
import 'package:test/test.dart';
import 'package:wiseclient/wiseclient.dart';

void main() {
  group('A group of basic tests to test functionality', () {
    final wiseOptions = WiseOptions.baseWithLocale(
      url: 'https://jsonplaceholder.typicode.com/',
      locale: 'en',
    );
    final awesome = WiseClient(
      wiseInterceptors: WiseInterceptor.values,
      options: wiseOptions,
      refreshFunction: (
        token,
        client,
      ) async {
        try {
          final newToken = await client.post<OAuth2Token>(
            '/oauth/token',
            data: {
              'client_id': 'clientId',
              'client_secret': 'clientSecret',
              'grant_type': 'refresh_token',
              'refresh_token': token?.refreshToken,
            },
          );

          return OAuth2Token(
            accessToken: newToken.data?.accessToken ?? '',
            refreshToken: newToken.data?.refreshToken,
          );
        } catch (e) {
          throw RevokeTokenException();
        }
      },
    );

    test('Client is native', () {
      expect(awesome.isWebClient, isFalse);
    });

    test('Expect url not to be empty', () async {
      expect(awesome.options.baseUrl, isNotEmpty);
    });

    test('Normal dio get works', () async {
      const path = 'todos/1';
      final something = await awesome.get<dynamic>(path);
      expect(something, isNotNull);
    });

    test('Normal dio post works', () async {
      const path = 'posts';
      const body = {
        'title': 'foo',
        'body': 'bar',
        'userId': 1,
      };
      final something = await awesome.post<dynamic>(
        path,
        data: body,
      );
      expect(something.data, isMap);
      expect((something.data as Map)['userId'], equals(1));
    });

    test('Wise get works', () async {
      const path = 'todos/1';
      final something = await awesome.wGet(path);
      expect(something, isMap);
    });

    test('Wise post works', () async {
      const path = 'posts';
      const body = {
        'title': 'foo',
        'body': 'bar',
        'userId': 1,
      };
      final something = await awesome.wPost(
        path,
        body: body,
      );
      expect(something, isMap);
      expect((something as Map)['userId'], equals(1));
    });

    test('Wise get throws dio exception on non existing path', () async {
      const path = 'todos/1/notfound';
      expect(() => awesome.wGet(path), throwsA(isA<DioException>()));
    });

    test('Dio get throws dio exception on non existing path', () async {
      const path = 'todos/1/notfound';
      expect(() => awesome.get<dynamic>(path), throwsA(isA<DioException>()));
    });

    test('Cancelled token does not finish request', () async {
      const path = 'todos/1';
      dynamic response;
      try {
        Future.delayed(
          const Duration(milliseconds: 5),
          awesome.cancelAndReset,
        );
        response = await awesome.wGet(path);
      } catch (e) {
        response = e.toString();
      }
      expect(response, isA<String>());
    });

    test('Can cancel and reset successfully', () async {
      const path = 'todos/1';
      dynamic response;
      try {
        Future.delayed(
          const Duration(milliseconds: 5),
          awesome.cancelAndReset,
        );
        response = await awesome.wGet(path);
      } catch (e) {
        response = e.toString();
      }
      expect(response, isA<String>());
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          final secondRequest = await awesome.wGet(path);
          expect(secondRequest, isMap);
        },
      );
    });
  });

  group('Tests with wisemen backend', () {
    //! replace with testing values
    const url = 'backend url';
    const clientSecret = 'replace with client secret';
    const clientId = 'replace with client id';
    const email = 'email';
    const password = 'password';
    final wiseOptions = WiseOptions.baseWithLocale(
      url: url,
      locale: 'nl',
    );
    final protected = WiseClient(
      wiseInterceptors: WiseInterceptor.values,
      options: wiseOptions,
      refreshFunction: (
        token,
        client,
      ) async {
        try {
          final newToken = await client.post<Map<String, dynamic>>(
            '$url/oauth/token',
            data: {
              'client_id': clientId,
              'client_secret': clientSecret,
              'grant_type': 'refresh_token',
              'refresh_token': token?.refreshToken,
            },
          );

          return OAuth2Token(
            accessToken: (newToken.data?['access_token'] as String?) ?? '',
            refreshToken: newToken.data?['refresh_token'] as String?,
            tokenType: newToken.data?['token_type'] as String?,
            expiresIn: newToken.data?['expires_in'] as int?,
          );
        } catch (e) {
          throw RevokeTokenException();
        }
      },
    );

    final unprotected = WiseClient(
      wiseInterceptors: [],
      options: wiseOptions,
    );

    test('Client has tokens after logging in', () async {
      const path = '/oauth/token';
      const body = {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'password',
        'username': email,
        'password': password,
      };
      final token = await unprotected.wPost(
        path,
        body: body,
      );

      expect(protected.interceptors.whereType<Fresh<OAuth2Token>>(), isNotEmpty);

      await protected.setFreshToken(
        token: OAuth2Token(
          accessToken: (token as Map<String, dynamic>)['access_token'] as String,
          refreshToken: token['refresh_token'] as String,
          expiresIn: token['expires_in'] as int,
          tokenType: token['token_type'] as String,
        ),
      );

      expect(token, isMap);
      expect(await protected.fresh.token, isNotNull);
      expect(await protected.authenticationStatus.first, equals(AuthenticationStatus.authenticated));
    });

    test('Client can execute a call with token', () async {
      const path = '/api/users/me';

      expect(await protected.fresh.token, isNotNull);
      expect(protected.interceptors.whereType<Fresh<OAuth2Token>>(), isNotEmpty);

      final result = await protected.wGet(
        path,
      );

      expect(result, isMap);
      expect((result as Map<String, dynamic>)['email'], equals(email));
    });

    test('Automatically refresh', () async {
      const path = '/api/users/me';

      final currentToken = await protected.fresh.token;

      await protected.setFreshToken(
        token: OAuth2Token(
          expiresIn: currentToken?.expiresIn,
          refreshToken: currentToken?.refreshToken,
          tokenType: currentToken?.tokenType,
          accessToken: currentToken?.accessToken ?? '',
        ),
      );
      await Future.delayed(
        const Duration(seconds: 1),
        () {},
      );

      final result = await protected.wGet(
        path,
      );

      expect(result, isMap);
      expect((result as Map<String, dynamic>)['email'], equals(email));
    });
  });
}
