// path: test/shared/data/services/layanan_preferensi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/data/services/layanan_preferensi.dart';

void main() {
  group('LayananPreferensi', () {
    const String kunciTerakhirUnduh = 'terakhir_unduh';
    const String kunciTerakhirUnggah = 'terakhir_unggah';

    setUp(() async {
      // Inisialisasi dengan nilai kosong sebelum setiap tes
      SharedPreferences.setMockInitialValues({});
    });

    test('01. ambilWaktuTerakhirUnduh harus mengembalikan null jika tidak ada data', () async {
      final waktu = await LayananPreferensi.ambilWaktuTerakhirUnduh();
      expect(waktu, isNull);
    });

    test('02. simpan dan ambilWaktuTerakhirUnduh harus mengembalikan waktu yang benar', () async {
      final waktuSimpan = DateTime.now();
      await LayananPreferensi.simpanWaktuTerakhirUnduh(waktuSimpan);

      final waktuAmbil = await LayananPreferensi.ambilWaktuTerakhirUnduh();
      
      // Compare milliseconds since epoch to avoid precision issues
      expect(waktuAmbil?.millisecondsSinceEpoch, waktuSimpan.toUtc().millisecondsSinceEpoch);
    });

    test('03. ambilWaktuTerakhirUnggah harus mengembalikan null jika tidak ada data', () async {
      final waktu = await LayananPreferensi.ambilWaktuTerakhirUnggah();
      expect(waktu, isNull);
    });

    test('04. simpan dan ambilWaktuTerakhirUnggah harus mengembalikan waktu yang benar', () async {
      final waktuSimpan = DateTime.now();
      await LayananPreferensi.simpanWaktuTerakhirUnggah(waktuSimpan);

      final waktuAmbil = await LayananPreferensi.ambilWaktuTerakhirUnggah();
      
      expect(waktuAmbil?.millisecondsSinceEpoch, waktuSimpan.toUtc().millisecondsSinceEpoch);
    });

    test('05. resetWaktuSinkronisasi harus menghapus kedua timestamp', () async {
      final waktuSekarang = DateTime.now();
      await LayananPreferensi.simpanWaktuTerakhirUnduh(waktuSekarang);
      await LayananPreferensi.simpanWaktuTerakhirUnggah(waktuSekarang);

      // Pastikan data tersimpan
      expect(await LayananPreferensi.ambilWaktuTerakhirUnduh(), isNotNull);
      expect(await LayananPreferensi.ambilWaktuTerakhirUnggah(), isNotNull);

      // Reset waktu
      await LayananPreferensi.resetWaktuSinkronisasi();

      // Pastikan data sudah null
      expect(await LayananPreferensi.ambilWaktuTerakhirUnduh(), isNull);
      expect(await LayananPreferensi.ambilWaktuTerakhirUnggah(), isNull);
    });

    test('06. _ambilTimestamp harus mengembalikan null jika nilai 0', () async {
      SharedPreferences.setMockInitialValues({
        kunciTerakhirUnduh: 0,
      });

      final waktu = await LayananPreferensi.ambilWaktuTerakhirUnduh();
      expect(waktu, isNull);
    });
    
    test('07. _simpanTimestamp menyimpan nilai dalam format UTC', () async {
      final waktuLokal = DateTime(2023, 1, 1, 10, 0, 0); // Waktu lokal
      await LayananPreferensi.simpanWaktuTerakhirUnduh(waktuLokal);

      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(kunciTerakhirUnduh);

      // Harusnya sama dengan versi UTC nya
      expect(timestamp, waktuLokal.toUtc().millisecondsSinceEpoch);
    });
  });
}
