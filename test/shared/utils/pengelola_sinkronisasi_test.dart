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
    pengelolaSinkronisasi = PengelolaSinkronisasi(prefs: mockSharedPreferences);
  });

  group('PengelolaSinkronisasi', () {
    final fitur = Fitur.pelanggan;
    final now = DateTime.now();

    test('01. setLastSync should save the timestamp', () async {
      when(mockSharedPreferences.setInt(any, any)).thenAnswer((_) async => true);

      await pengelolaSinkronisasi.aturSinkronisasiTerakhir(fitur, now);

      verify(mockSharedPreferences.setInt(
        fitur.syncKey,
        now.millisecondsSinceEpoch,
      )).called(1);
    });

    test('02. getLastSync should retrieve the saved timestamp', () {
      when(mockSharedPreferences.getInt(fitur.syncKey))
          .thenReturn(now.millisecondsSinceEpoch);

      final result = pengelolaSinkronisasi.ambilSinkronisasiTerakhir(fitur);

      expect(result, equals(now));
    });

    test('03. getLastSync should return null if no timestamp is saved', () {
      when(mockSharedPreferences.getInt(fitur.syncKey)).thenReturn(null);

      final result = pengelolaSinkronisasi.ambilSinkronisasiTerakhir(fitur);

      expect(result, isNull);
    });

    test('04. shouldSync should return true if last sync is null', () {
      when(mockSharedPreferences.getInt(fitur.syncKey)).thenReturn(null);

      final result = pengelolaSinkronisasi.perluSinkronisasi(fitur);

      expect(result, isTrue);
    });

    test('05. shouldSync should return true if sync interval has passed', () {
      final lastSync = now.subtract(const Duration(minutes: 31));
      when(mockSharedPreferences.getInt(fitur.syncKey))
          .thenReturn(lastSync.millisecondsSinceEpoch);

      final result = pengelolaSinkronisasi.perluSinkronisasi(fitur);

      expect(result, isTrue);
    });

    test('06. shouldSync should return false if sync interval has not passed', () {
      final lastSync = now.subtract(const Duration(minutes: 15));
      when(mockSharedPreferences.getInt(fitur.syncKey))
          .thenReturn(lastSync.millisecondsSinceEpoch);

      final result = pengelolaSinkronisasi.perluSinkronisasi(fitur);

      expect(result, isFalse);
    });

    test('07. shouldSync should respect custom sync interval', () {
      final lastSync = now.subtract(const Duration(hours: 2));
      when(mockSharedPreferences.getInt(fitur.syncKey))
          .thenReturn(lastSync.millisecondsSinceEpoch);

      // Interval default (30 menit) -> harus sinkronisasi
      expect(pengelolaSinkronisasi.perluSinkronisasi(fitur), isTrue);

      // Interval custom (3 jam) -> tidak perlu sinkronisasi
      expect(
        pengelolaSinkronisasi.perluSinkronisasi(
          fitur,
          interval: const Duration(hours: 3),
        ),
        isFalse,
      );
    });

    test('08. resetAllSyncTimestamps should remove all sync keys', () async {
      when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);

      await pengelolaSinkronisasi.resetSemuaPenandaWaktuSinkronisasi();

      for (final f in Fitur.values) {
        verify(mockSharedPreferences.remove(f.syncKey)).called(1);
      }
    });
  });
}
