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
      expect(await PreferenceService.getLastDownload(), isNull);
      expect(await PreferenceService.getLastUpload(), isNull);
    });

    test('harus bisa menyimpan dan mengambil waktu terakhir unduh dengan benar',
        () async {
      // ATUR
      final testTime = DateTime(2023, 10, 27, 10, 30);

      // JALANKAN
      await PreferenceService.setLastDownload(testTime);
      final retrievedTime = await PreferenceService.getLastDownload();

      // VERIFIKASI
      // Kita membandingkan dalam UTC untuk memastikan konsistensi
      expect(retrievedTime, isNotNull);
      expect(retrievedTime, equals(testTime.toUtc()));
    });

    test(
        'harus bisa menyimpan dan mengambil waktu terakhir unggah dengan benar',
        () async {
      // ATUR
      final testTime = DateTime(2023, 11, 15, 14, 0);

      // JALANKAN
      await PreferenceService.setLastUpload(testTime);
      final retrievedTime = await PreferenceService.getLastUpload();

      // VERIFIKASI
      expect(retrievedTime, isNotNull);
      expect(retrievedTime, equals(testTime.toUtc()));
    });

    test('harus bisa mereset kedua waktu sinkronisasi', () async {
      // ATUR
      final downloadTime = DateTime(2023, 1, 1);
      final uploadTime = DateTime(2023, 2, 2);
      await PreferenceService.setLastDownload(downloadTime);
      await PreferenceService.setLastUpload(uploadTime);

      // Pastikan data sudah tersimpan sebelum direset
      expect(await PreferenceService.getLastDownload(), isNotNull);
      expect(await PreferenceService.getLastUpload(), isNotNull);

      // JALANKAN
      await PreferenceService.resetSyncTime();

      // VERIFIKASI
      // Pastikan kedua data sudah terhapus
      expect(await PreferenceService.getLastDownload(), isNull);
      expect(await PreferenceService.getLastUpload(), isNull);
    });
  });
}
