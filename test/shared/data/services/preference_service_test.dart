// path: test/shared/data/services/preference_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/data/services/preference_service.dart';

void main() {
  group('PreferenceService', () {
    // Siapkan data awal palsu untuk SharedPreferences di memori
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('awalnya harus mengembalikan null untuk waktu unduh dan unggah',
        () async {
      // JALANKAN & VERIFIKASI
      expect(await PreferenceService.ambilWaktuTerakhirDownload(), isNull);
      expect(await PreferenceService.ambilWaktuTerakhirUnggah(), isNull);
    });

    test('harus bisa menyimpan dan mengambil waktu terakhir unduh dengan benar',
        () async {
      // ATUR
      final testTime = DateTime(2023, 10, 27, 10, 30);

      // JALANKAN
      await PreferenceService.simpanWaktuTerakhirunduh(testTime);
      final retrievedTime =
          await PreferenceService.ambilWaktuTerakhirDownload();

      // VERIFIKASI
      // Kita membandingkan dalam UTC untuk memastikan konsistensi
      expect(retrievedTime, isNotNull);
      expect(retrievedTime, equals(testTime.toUtc()));
    });

    test(
        'harus bisa menyimpan dan mengambil waktu terakhir unggah dengan benar',
        () async {
      // ATUR
      final testTime = DateTime(2023, 11, 15, 14);

      // JALANKAN
      await PreferenceService.simpanWaktuTerkahirUnggah(testTime);
      final retrievedTime = await PreferenceService.ambilWaktuTerakhirUnggah();

      // VERIFIKASI
      expect(retrievedTime, isNotNull);
      expect(retrievedTime, equals(testTime.toUtc()));
    });

    test('harus bisa mereset kedua waktu sinkronisasi', () async {
      // ATUR
      final downloadTime = DateTime(2023);
      final uploadTime = DateTime(2023, 2, 2);
      await PreferenceService.simpanWaktuTerakhirunduh(downloadTime);
      await PreferenceService.simpanWaktuTerkahirUnggah(uploadTime);

      // Pastikan data sudah tersimpan sebelum direset
      expect(await PreferenceService.ambilWaktuTerakhirDownload(), isNotNull);
      expect(await PreferenceService.ambilWaktuTerakhirUnggah(), isNotNull);

      // JALANKAN
      await PreferenceService.resetWaktuSinkronisasi();

      // VERIFIKASI
      // Pastikan kedua data sudah terhapus
      expect(await PreferenceService.ambilWaktuTerakhirDownload(), isNull);
      expect(await PreferenceService.ambilWaktuTerakhirUnggah(), isNull);
    });
  });
}
