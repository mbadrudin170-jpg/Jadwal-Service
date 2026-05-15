// path: test/shared/data/services/preferensi_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/data/services/preferensi_service.dart';

void main() {
  // Inisialisasi SharedPreferences untuk lingkungan testing
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferensiService Unit Tests', () {
    const String keyUnduh = 'terakhir_unduh';
    const String keyUnggah = 'terakhir_unggah';

    setUp(() {
      // Membersihkan data mock sebelum setiap test
      SharedPreferences.setMockInitialValues({});
    });

    test('getTerakhirUnduh harus mengembalikan null jika belum ada data',
        () async {
      final result = await PreferensiService.getTerakhirUnduh();
      expect(result, isNull);
    });

    test('setTerakhirUnduh harus menyimpan timestamp dalam milidetik',
        () async {
      final tWaktu = DateTime.utc(2024, 5, 14, 10, 30);

      await PreferensiService.setTerakhirUnduh(tWaktu);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(keyUnduh), tWaktu.millisecondsSinceEpoch);
    });

    test('getTerakhirUnduh harus mengembalikan DateTime yang benar (UTC)',
        () async {
      const tMillis = 1715682600000; // 2024-05-14T10:30:00.000Z
      SharedPreferences.setMockInitialValues({keyUnduh: tMillis});

      final result = await PreferensiService.getTerakhirUnduh();

      expect(result, isNotNull);
      expect(result!.isUtc, isTrue);
      expect(result.millisecondsSinceEpoch, tMillis);
    });

    test('resetWaktuSinkronisasi harus menghapus kedua key dari storage',
        () async {
      // Arrange: Isi data awal
      SharedPreferences.setMockInitialValues({
        keyUnduh: 123456789,
        keyUnggah: 987654321,
      });

      // Act
      await PreferensiService.resetWaktuSinkronisasi();

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(keyUnduh), isFalse);
      expect(prefs.containsKey(keyUnggah), isFalse);
    });

    test('setTerakhirUnggah harus menangani konversi ke UTC secara otomatis',
        () async {
      final waktuLokal = DateTime(2024, 5, 14, 10, 30); // Waktu lokal perangkat

      await PreferensiService.setTerakhirUnggah(waktuLokal);

      final result = await PreferensiService.getTerakhirUnggah();
      expect(result!.isUtc, isTrue);
      expect(result.millisecondsSinceEpoch,
          waktuLokal.toUtc().millisecondsSinceEpoch,);
    });
  });
}
