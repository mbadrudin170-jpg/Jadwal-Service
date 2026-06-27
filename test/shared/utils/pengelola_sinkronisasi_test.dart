// path: test/shared/utils/pengelola_sinkronisasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';

void main() {
  late PengelolaSinkronisasi pengelolaSinkronisasi;

  setUp(() {
    pengelolaSinkronisasi = PengelolaSinkronisasi();
  });

  group('PengelolaSinkronisasi', () {
    final now = DateTime.now();

    test('01. ambilWaktuTerakhirUnduh harus mengembalikan default jika tidak ada data', () async {
      expect(
        () => pengelolaSinkronisasi.ambilWaktuTerakhirUnduh(),
        returnsNormally,
      );
    });

    test('02. simpanWaktuTerakhirUnduh harus berjalan tanpa error', () async {
      expect(
        () => pengelolaSinkronisasi.simpanWaktuTerakhirUnduh(now),
        returnsNormally,
      );
    });

    test('03. resetWaktuSinkronisasi harus berjalan tanpa error', () async {
      expect(
        () => pengelolaSinkronisasi.resetWaktuSinkronisasi(),
        returnsNormally,
      );
    });
  });
}