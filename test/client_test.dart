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

    setUp(() {
      // Additional setup goes here.
    });

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

  group('Tests with KOALA backend', () {
    const url = 'https://api.vo-koala.staging.appwi.se';
    const clientSecret = 'UdNRPZudJgLkPpxmdTg7oUQDMcBXVgTv4wAwTuWz';
    const clientId = '99cad2e7-7ecf-4a64-9b75-023bc4420af0';
    const email = 'michiel@appwise.be';
    const password = r'v43f9$u4zyH9';
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
          accessToken:
              'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5OWNhZDJlNy03ZWNmLTRhNjQtOWI3NS0wMjNiYzQ0MjBhZjAiLCJqdGkiOiI4N2FlMzU5YmI3MTBiODVhNzc4YmRkMWEzMjVkNDY3YjU0NjYzN2M5ZjYyZGExMTYwZjEzYWEyZGZkMWM3NDkxMTIwZWEyZmQwNTM1MDg3MyIsImlhdCI6MTcwMzI1NzY3MS4yMzg1MTMsIm5iZiI6MTcwMzI1NzY3MS4yMzg1MTYsImV4cCI6MTczNDg4MDA3MS4yMjg2MjIsInN1YiI6IjMiLCJzY29wZXMiOltdfQ.Y9dfcWz2HgbmkUoLPh1i-7-AE6XrnFKtVj_d4BAQa8XEQOdYSBKr5bZF5tAqywizpUsoze7_kQE3rxpv1f3FZ3_QlX1oqV0Vhx0i3VizS02ciUCzQ_mD-BQtVK4J-43lIEVHRRpDFkxZyLRBSGYDD8FMIxeaOPvaL1P3wi7nYr0URFRmpXx-NUSvEdr396d05WANmEz115J8fJAvgqm_gzE-sCapzC9Yv6EtsDL44TrrvUgjsGVgxDFCBQwdLYbKdS8gpc10ASqqfizeQT91NAW6xFVrq0CHSI6axrekK4RP9iJmSM2ECh3bQDStfDmTMdFB1XKolDOu8dZ7LcG2IjwUlJuDhff5VnvXKJPKLst0rj7dSykyBd459gxl-kg45Sla0idVQi7VbGgG61g-HGWC2xluPq3AkuVN9ikGnGMorM449_hv-S7ZLxk96FYqUUCrhE74IYaZMjx8Kax3Jf6ZYmjaqimupJad8vGaN2xc1uWpupMvkTYlwjB1-aKRvEmrVOrICQES_SBwk4IrjcdUrEteXkgMEe1RpRzEXnN3lHNBlNlupaf1m1JevB811dyl3bP0HFlwc71YFSuPK3Iplpq6o_TvN7NWVKKCtMjq20QSQCJXeYZ2cnaBp4mAkvNWkADXLU7o2Bp2cRSG4Kxc2H8Sliluvx0ts4wgblo',
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
