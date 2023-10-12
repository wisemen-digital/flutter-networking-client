import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:wiseclient/wiseclient.dart';

void main() {
  group('A group of tests', () {
    final wiseOptions = WiseOptions.baseWithLocale(
      url: 'https://jsonplaceholder.typicode.com/',
      locale: 'en',
    );
    final awesome = WiseClient(
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
          rethrow;
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
      expect(response, isNotEmpty);
    });
  });
}
