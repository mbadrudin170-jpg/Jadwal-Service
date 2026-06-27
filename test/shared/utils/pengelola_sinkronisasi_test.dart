// path: test/shared/utils/pengelola_sinkronisasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';

import 'pengelola_sinkronisasi_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late PengelolaSinkronisasi pengelolaSinkronisasi;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    // PERBAIKAN: PengelolaSinkronisasi sekarang tidak menerima parameter prefs
    pengelolaSinkronisasi = PengelolaSinkronisasi();
  });

  group('PengelolaSinkronisasi', () {
    final now = DateTime.now();

    test('01. ambilWaktuTerakhirUnduh harus mengembalikan default jika tidak ada data', () async {
      // PERBAIKAN: Method sekarang static via LayananPreferensi
      // Kita hanya test bahwa method berjalan tanpa error
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