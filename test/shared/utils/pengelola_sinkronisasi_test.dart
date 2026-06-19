// path: test/shared/utils/pengelola_sinkronisasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/utils/pengelola_sinkronisasi.dart';

void main() {
  late PengelolaSinkronisasi pengelolaSinkronisasi;

  // Mendefinisikan kunci yang digunakan di LayananPreferensi
  const String kunciTerakhirUnduh = 'terakhir_unduh';
  const String kunciTerakhirUnggah = 'terakhir_unggah';

  setUp(() {
    pengelolaSinkronisasi = PengelolaSinkronisasi();
    // Atur nilai awal mock untuk setiap tes, agar tes independen
    SharedPreferences.setMockInitialValues({});
  });

  group('PengelolaSinkronisasi - Waktu Unduh', () {
    test(
      '01. harus mengembalikan epoch jika tidak ada waktu unduh yang tersimpan',
      () async {
        final waktu = await pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
        expect(waktu, DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
      },
    );

    test('02. harus menyimpan dan mengambil waktu terakhir unduh dengan benar',
        () async {
      final waktuSimpan = DateTime(2023, 10, 27, 10, 0).toUtc();

      await pengelolaSinkronisasi.simpanWaktuTerakhirUnduh(waktuSimpan);
      final waktuAmbil = await pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();

      // Membandingkan dalam millisecondsSinceEpoch untuk presisi
      expect(
        waktuAmbil.millisecondsSinceEpoch,
        waktuSimpan.millisecondsSinceEpoch,
      );

      // Verifikasi langsung di SharedPreferences mock
      final prefs = await SharedPreferences.getInstance();
      final storedTimestamp = prefs.getInt(kunciTerakhirUnduh);
      expect(storedTimestamp, waktuSimpan.millisecondsSinceEpoch);
    });
  });

  group('PengelolaSinkronisasi - Waktu Unggah', () {
    test(
      '01. harus mengembalikan epoch jika tidak ada waktu unggah yang tersimpan',
      () async {
        final waktu = await pengelolaSinkronisasi.ambilWaktuTerakhirUnggah();
        expect(waktu, DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
      },
    );

    test('02. harus menyimpan dan mengambil waktu terakhir unggah dengan benar',
        () async {
      final waktuSimpan = DateTime(2023, 10, 27, 11, 0).toUtc();

      await pengelolaSinkronisasi.simpanWaktuTerakhirUnggah(waktuSimpan);
      final waktuAmbil = await pengelolaSinkronisasi.ambilWaktuTerakhirUnggah();

      expect(
        waktuAmbil.millisecondsSinceEpoch,
        waktuSimpan.millisecondsSinceEpoch,
      );

      final prefs = await SharedPreferences.getInstance();
      final storedTimestamp = prefs.getInt(kunciTerakhirUnggah);
      expect(storedTimestamp, waktuSimpan.millisecondsSinceEpoch);
    });
  });

  group('PengelolaSinkronisasi - Reset', () {
    test('01. harus mereset waktu unduh dan unggah', () async {
      final waktuUnduh = DateTime(2023, 10, 27, 10, 0).toUtc();
      final waktuUnggah = DateTime(2023, 10, 27, 11, 0).toUtc();

      // Atur nilai awal untuk mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        kunciTerakhirUnduh: waktuUnduh.millisecondsSinceEpoch,
        kunciTerakhirUnggah: waktuUnggah.millisecondsSinceEpoch,
      });
      
      // Buat instance baru agar mengambil nilai dari mock
      pengelolaSinkronisasi = PengelolaSinkronisasi();

      // Pastikan nilai awal bisa diambil
      final waktuUnduhSebelum =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
      final waktuUnggahSebelum =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnggah();
      expect(waktuUnduhSebelum.millisecondsSinceEpoch,
          waktuUnduh.millisecondsSinceEpoch);
      expect(waktuUnggahSebelum.millisecondsSinceEpoch,
          waktuUnggah.millisecondsSinceEpoch);

      // Lakukan reset
      await pengelolaSinkronisasi.resetWaktuSinkronisasi();

      // Ambil nilai setelah di-reset
      final waktuUnduhSetelah =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
      final waktuUnggahSetelah =
          await pengelolaSinkronisasi.ambilWaktuTerakhirUnggah();

      // Harusnya kembali ke nilai default (epoch)
      expect(
          waktuUnduhSetelah, DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
      expect(
          waktuUnggahSetelah, DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));

      // Verifikasi juga di SharedPreferences mock bahwa kuncinya sudah tidak ada
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(kunciTerakhirUnduh), isFalse);
      expect(prefs.containsKey(kunciTerakhirUnggah), isFalse);
    });
  });
}
