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
      final result = await syncManager.ambilTanggalTerakhirDownload();
      expect(result, epochTime);
    });

    test('setLastDownload harus menyimpan waktu unduh dengan benar', () async {
      final testDate = DateTime.now();
      await syncManager.setLastDownload(testDate);
      final result = await syncManager.ambilTanggalTerakhirDownload();

      // Membandingkan milidetik karena SharedPreferences dapat kehilangan presisi mikrosaat
      expect(
        result.millisecondsSinceEpoch,
        testDate.millisecondsSinceEpoch,
      );
    });

    test(
        'getLastUpload harus mengembalikan epoch ketika tidak ada data yang tersimpan',
        () async {
      final result = await syncManager.getLastUpload();
      expect(result, epochTime);
    });

    test('setLastUpload harus menyimpan waktu unggah dengan benar', () async {
      final testDate = DateTime.now();
      await syncManager.setLastUpload(testDate);
      final result = await syncManager.getLastUpload();

      expect(
        result.millisecondsSinceEpoch,
        testDate.millisecondsSinceEpoch,
      );
    });

    test('resetSyncTime harus mereset waktu unduh dan unggah', () async {
      // 1. Atur beberapa waktu awal
      final downloadTime = DateTime.now().subtract(const Duration(hours: 1));
      final uploadTime = DateTime.now().subtract(const Duration(minutes: 30));
      await syncManager.setLastDownload(downloadTime);
      await syncManager.setLastUpload(uploadTime);

      // 2. Pastikan waktu telah diatur
      var lastDownload = await syncManager.ambilTanggalTerakhirDownload();
      var lastUpload = await syncManager.getLastUpload();
      expect(lastDownload.isAtSameMomentAs(epochTime), isFalse);
      expect(lastUpload.isAtSameMomentAs(epochTime), isFalse);

      // 3. Panggil metode reset
      await syncManager.resetSyncTime();

      // 4. Periksa apakah kedua waktu kembali ke epoch
      lastDownload = await syncManager.ambilTanggalTerakhirDownload();
      lastUpload = await syncManager.getLastUpload();
      expect(lastDownload, epochTime);
      expect(lastUpload, epochTime);
    });
  });
}
