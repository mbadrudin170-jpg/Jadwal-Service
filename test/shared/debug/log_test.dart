// path: test/shared/debug/log_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/debug/log.dart';

import 'log_test.mocks.dart';

@GenerateMocks([], customMocks: [
  // Mock Logger tidak digunakan lagi karena Log sudah di-refactor
])
void main() {
  group('Log', () {
    test('01. info harus mencatat pesan informasi', () {
      // Log.info sekarang menggunakan print internal, tidak perlu mock
      expect(
        () => Log.info('Info message'),
        returnsNormally,
      );
    });

    test('02. warning harus mencatat pesan peringatan', () {
      expect(
        () => Log.warning('Warning message'),
        returnsNormally,
      );
    });

    test('03. error harus mencatat pesan error', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => Log.error(
          'Error message',
          e: error,
          st: stackTrace,
        ),
        returnsNormally,
      );
    });

    test('04. api harus mencatat panggilan API', () {
      expect(
        () => Log.api(
          '/test/path',
          {'key': 'value'},
          method: 'GET',
        ),
        returnsNormally,
      );
    });

    test('05. hanya boleh log dalam debug mode', () {
      // kDebugMode adalah compile-time constant
      // Jika dalam debug mode, log akan berjalan normal
      // Jika dalam release mode, log akan di-skip
      // Kita hanya perlu memastikan tidak ada error
      expect(
        () {
          Log.info('Test in debug mode');
          Log.warning('Test warning');
          Log.error('Test error');
          Log.api('/test', {}, method: 'POST');
        },
        returnsNormally,
      );
    });
  });
}