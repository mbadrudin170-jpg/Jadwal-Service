// path: test/shared/utils/sync_manager_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

void main() {
  // Pastikan binding Flutter diinisialisasi untuk SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();

  late SyncManager syncManager;

  // Variabel untuk menyimpan waktu epoch sebagai referensi
  final epochTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  setUp(() async {
    // Inisialisasi SharedPreferences dengan nilai palsu untuk pengujian
    SharedPreferences.setMockInitialValues({});
    syncManager = SyncManager();
    // Reset SharedPreferences sebelum setiap pengujian untuk isolasi
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  group('Tes Integrasi SyncManager', () {
    test(
        'getLastDownload harus mengembalikan epoch ketika tidak ada data yang tersimpan',
        () async {
      final result = await syncManager.ambilWaktuTerakhirDownload();
      expect(result, epochTime);
    });

    test('setLastDownload harus menyimpan waktu unduh dengan benar', () async {
      final testDate = DateTime.now();
      await syncManager.simpanWaktuTerakhirunduh(testDate);
      final result = await syncManager.ambilWaktuTerakhirDownload();

      // Membandingkan milidetik karena SharedPreferences dapat kehilangan presisi mikrosaat
      expect(
        result.millisecondsSinceEpoch,
        testDate.millisecondsSinceEpoch,
      );
    });

    test(
        'getLastUpload harus mengembalikan epoch ketika tidak ada data yang tersimpan',
        () async {
      final result = await syncManager.ambilWaktuTerakhirUnggah();
      expect(result, epochTime);
    });

    test('setLastUpload harus menyimpan waktu unggah dengan benar', () async {
      final testDate = DateTime.now();
      await syncManager.simpanWaktuTerkahirUnggah(testDate);
      final result = await syncManager.ambilWaktuTerakhirUnggah();

      expect(
        result.millisecondsSinceEpoch,
        testDate.millisecondsSinceEpoch,
      );
    });

    test('resetSyncTime harus mereset waktu unduh dan unggah', () async {
      // 1. Atur beberapa waktu awal
      final downloadTime = DateTime.now().subtract(const Duration(hours: 1));
      final uploadTime = DateTime.now().subtract(const Duration(minutes: 30));
      await syncManager.simpanWaktuTerakhirunduh(downloadTime);
      await syncManager.simpanWaktuTerkahirUnggah(uploadTime);

      // 2. Pastikan waktu telah diatur
      var lastDownload = await syncManager.ambilWaktuTerakhirDownload();
      var lastUpload = await syncManager.ambilWaktuTerakhirUnggah();
      expect(lastDownload.isAtSameMomentAs(epochTime), isFalse);
      expect(lastUpload.isAtSameMomentAs(epochTime), isFalse);

      // 3. Panggil metode reset
      await syncManager.resetWaktuSinkronisasi();

      // 4. Periksa apakah kedua waktu kembali ke epoch
      lastDownload = await syncManager.ambilWaktuTerakhirDownload();
      lastUpload = await syncManager.ambilWaktuTerakhirUnggah();
      expect(lastDownload, epochTime);
      expect(lastUpload, epochTime);
    });
  });
}
