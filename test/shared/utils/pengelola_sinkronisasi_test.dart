// path: test/shared/utils/pengelola_sinkronisasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';

void main() {
  late PengelolaSinkronisasi pengelolaSinkronisasi;

  setUp(() {
    // Karena PengelolaSinkronisasi bergantung pada LayananPreferensi,
    // kita perlu menginisialisasi SharedPreferences untuk setiap tes.
    SharedPreferences.setMockInitialValues({});
    pengelolaSinkronisasi = PengelolaSinkronisasi();
  });

  group('PengelolaSinkronisasi', () {
    final now = DateTime.now();

    test(
        '01. ambilWaktuTerakhirUnduhPreferensi harus mengembalikan default jika tidak ada data',
        () async {
      final defaultTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final result =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnduhPreferensi();
      expect(result, defaultTime);
    });

    test(
        '02. simpan dan ambilWaktuTerakhirUnduhPreferensi harus menyimpan dan mengambil waktu dengan benar',
        () async {
      await pengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(now);
      final retrievedTime =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnduhPreferensi();
      expect(retrievedTime.toUtc().millisecondsSinceEpoch,
          now.toUtc().millisecondsSinceEpoch);
    });

    test(
        '03. resetWaktuSinkronisasiPreferensi harus mereset waktu unduh dan unggah',
        () async {
      // Simpan waktu
      await pengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(now);
      await pengelolaSinkronisasi.simpanWaktuTerakhirUnggahPreferensi(now);

      // Pastikan waktu tersimpan
      var retrievedUnduh =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnduhPreferensi();
      var retrievedUnggah =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnggahPreferensi();
      expect(retrievedUnduh.millisecondsSinceEpoch, isNot(0));
      expect(retrievedUnggah.millisecondsSinceEpoch, isNot(0));

      // Reset
      await pengelolaSinkronisasi.resetWaktuSinkronisasiPreferensi();

      // Pastikan waktu sudah direset ke default
      final defaultTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      retrievedUnduh =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnduhPreferensi();
      retrievedUnggah =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnggahPreferensi();
      expect(retrievedUnduh, defaultTime);
      expect(retrievedUnggah, defaultTime);
    });
  });
}
