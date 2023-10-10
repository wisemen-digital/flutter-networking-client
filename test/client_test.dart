import 'package:test/test.dart';
import 'package:wiseclient/wiseclient.dart';

void main() {
  group('A group of tests', () {
    final wiseOptions = WiseOptions.baseWithLocale(
      baseUrl: 'https://jsonplaceholder.typicode.com/',
      locale: 'en',
    );
    final awesome = WiseClient(wiseOptions);

    setUp(() {
      // Additional setup goes here.
    });

    test('Client is native', () {
      expect(awesome.isWebClient, isFalse);
    });

    test('Normal get gets a response', () async {
      const path = 'todos/1';
      final something = await awesome.get<dynamic>(path);
      expect(something, isNotNull);
    });
  });
}
