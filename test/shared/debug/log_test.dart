// path: test/shared/debug/log_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/debug/log.dart';

void main() {
  group('Log', () {
    // Test ini bertujuan untuk memastikan tidak ada error yang terjadi saat
    // memanggil metode-metode logging. Verifikasi output aktual di konsol
    // tidak dimungkinkan dalam unit test.

    test('01. info() harus berjalan tanpa error', () {
      expect(() => Log.info('Pesan info'), returnsNormally);
    });

    test('02. warning() harus berjalan tanpa error', () {
      expect(() => Log.warning('Pesan peringatan'), returnsNormally);
    });

    test('03. error() harus berjalan tanpa error', () {
      expect(
          () => Log.error('Pesan error',
              e: Exception('Test Exception'), s: StackTrace.current),
          returnsNormally);
    });

    test('04. api() harus berjalan tanpa error', () {
      expect(
          () => Log.api(
                '/test',
                {'key': 'value'},
                method: 'GET',
              ),
          returnsNormally);
    });

    group('Format Data', () {
      test('05. harus menangani data Map', () {
        expect(() => Log.info('Data Map', {'a': 1, 'b': 'test'}), returnsNormally);
      });

      test('06. harus menangani data List', () {
        expect(() => Log.info('Data List', [1, 'a', true]), returnsNormally);
      });

      test('07. harus menangani data DateTime', () {
        expect(() => Log.info('Data DateTime', {'time': DateTime.now()}),
            returnsNormally);
      });

      test('08. harus menangani data Timestamp', () {
        expect(() => Log.info('Data Timestamp', {'time': Timestamp.now()}),
            returnsNormally);
      });

      test('09. harus menangani data null', () {
        expect(() => Log.info('Data null', null), returnsNormally);
      });

      test('10. harus menangani tipe data primitif lainnya', () {
        expect(() => Log.info('Data int', 123), returnsNormally);
        expect(() => Log.info('Data double', 45.67), returnsNormally);
        expect(() => Log.info('Data bool', false), returnsNormally);
      });

      test('11. harus menangani objek yang tidak dapat di-serialize', () {
        final object = Object();
        expect(() => Log.info('Data Object', object), returnsNormally);
      });
    });
  });
}
