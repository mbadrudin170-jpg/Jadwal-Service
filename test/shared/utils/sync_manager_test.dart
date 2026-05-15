// path: test/shared/utils/sync_manager_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

// Karena PreferensiService biasanya menggunakan static methods,
// pastikan Anda membungkus atau melakukan refaktorisasi jika perlu.
// Di sini kita asumsikan mock bisa dibuat untuk service tersebut.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SyncManager syncManager;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    syncManager = SyncManager();
  });

  group('SyncManager Unit Tests', () {
    final tDateTime = DateTime.utc(2024, 5, 14, 10);
    final tEpochZero = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    test('getTerakhirUnduh harus mengembalikan Epoch 0 jika data null',
        () async {
      // Catatan: Jika PreferensiService menggunakan static methods,
      // Anda mungkin perlu menggunakan plugin seperti 'mocktail' atau
      // mengubah static method menjadi instance method agar bisa di-mock.

      // Skenario: PreferensiService.getTerakhirUnduh() mengembalikan null
      final result = await syncManager.getTerakhirUnduh();

      expect(result, tEpochZero);
    });

    test('setTerakhirUnduh harus menyimpan waktu yang diberikan', () async {
      await syncManager.setTerakhirUnduh(tDateTime);
      final result = await syncManager.getTerakhirUnduh();
      expect(result, tDateTime);
    });

    test('getTerakhirUnggah harus mengembalikan waktu yang valid jika tersedia',
        () async {
      // Simulasi penyimpanan
      await syncManager.setTerakhirUnggah(tDateTime);
      final result = await syncManager.getTerakhirUnggah();
      expect(result, tDateTime);
    });

    test('resetWaktuSinkronisasi harus memanggil fungsi reset di service',
        () async {
      await syncManager.resetWaktuSinkronisasi();

      final download = await syncManager.getTerakhirUnduh();
      final upload = await syncManager.getTerakhirUnggah();

      expect(download, tEpochZero);
      expect(upload, tEpochZero);
    });
  });
}
