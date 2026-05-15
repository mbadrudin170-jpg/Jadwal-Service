// path: test/shared/debug/log_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/debug/log.dart';

void main() {
  group('Log', () {
    test('Log.info should run without errors', () {
      expect(() => Log.info('Test info message'), returnsNormally);
      expect(() => Log.info('Test info message with data', {'key': 'value'}),
          returnsNormally);
    });

    test('Log.warning should run without errors', () {
      expect(() => Log.warning('Test warning message'), returnsNormally);
      expect(
          () => Log.warning('Test warning message with data', [1, 2, 3]),
          returnsNormally);
    });

    test('Log.error should run without errors', () {
      expect(() => Log.error('Test error message'), returnsNormally);
      expect(
          () => Log.error(
                'Test error message with exception and stacktrace',
                e: Exception('Test Exception'),
                st: StackTrace.current,
              ),
          returnsNormally);
    });

    test('Log.api should run without errors', () {
      expect(
          () => Log.api(
                '/test/api',
                {'request': 'data'},
                method: 'GET',
              ),
          returnsNormally);
    });
  });
}
