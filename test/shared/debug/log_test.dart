// path: test/shared/debug/log_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/debug/log.dart';

void main() {
  group('Log', () {
    test('01. info harus mencatat pesan informasi', () {
      expect(() => Log.info('Info message'), returnsNormally);
    });

    test('02. warning harus mencatat pesan peringatan', () {
      expect(() => Log.warning('Warning message'), returnsNormally);
    });

    test('03. error harus mencatat pesan error', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => Log.error('Error message', e: error, s: stackTrace),
        returnsNormally,
      );
    });

    test('04. api harus mencatat panggilan API', () {
      expect(
        () => Log.api('/test/path', {'key': 'value'}, method: 'GET'),
        returnsNormally,
      );
    });

    test('05. hanya boleh log dalam debug mode', () {
      expect(() {
        Log.info('Test in debug mode');
        Log.warning('Test warning');
        Log.error('Test error');
        Log.api('/test', {}, method: 'POST');
      }, returnsNormally);
    });
  });
}
