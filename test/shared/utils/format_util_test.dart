// path: test/shared/utils/format_util_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wifi/shared/utils/format_util.dart';

void main() {
  // Inisialisasi data lokal untuk pengujian format tanggal dan waktu
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('FormatWaktuLengkap', () {
    final date = DateTime(2023, 10, 26, 10, 30);

    test(
      '01. formatLengkap harus mengembalikan format tanggal dan waktu yang benar',
      () {
        // Diharapkan format '26 Okt 2023, 10:30'
        expect(FormatWaktuLengkap.formatLengkap(date), '26 Okt 2023, 10:30');
      },
    );

    test(
      '02. formatSingkat harus mengembalikan format hari, tanggal, dan waktu yang benar',
      () {
        // Diharapkan format 'Kam, 26 Okt 23, 10:30'
        expect(FormatWaktuLengkap.formatSingkat(date), 'Kam, 26 Okt 23, 10:30');
      },
    );
  });

  group('FormatTanggal', () {
    final date = DateTime(2023, 10, 26);

    test(
      '01. formatDasar harus mengembalikan format tanggal dasar yang benar',
      () {
        // Diharapkan format '26 Okt 2023'
        expect(FormatTanggal.formatDasar(date), '26 Okt 2023');
      },
    );

    test(
      '02. formatSingkat harus mengembalikan format hari dan tanggal yang benar',
      () {
        // Diharapkan format 'Kam, 26 Okt 23'
        expect(FormatTanggal.formatSingkat(date), 'Kam, 26 Okt 23');
      },
    );

    test(
      '03. formatBulanTahun harus mengembalikan format bulan dan tahun yang benar',
      () {
        // Diharapkan format 'Oktober 2023'
        expect(FormatTanggal.formatBulanTahun(date), 'Oktober 2023');
      },
    );
  });

  group('FormatJam', () {
    final time = DateTime(2023, 1, 1, 14, 45, 30);

    test(
      '01. formatJamMenit harus mengembalikan format jam dan menit yang benar',
      () {
        // Diharapkan format '14:45'
        expect(FormatJam.formatJamMenit(time), '14:45');
      },
    );

    test(
      '02. formatJamMenitDetik harus mengembalikan format jam, menit, dan detik yang benar',
      () {
        // Diharapkan format '14:45:30'
        expect(FormatJam.formatJamMenitDetik(time), '14:45:30');
      },
    );

    test(
      '03. formatTextToHour harus mengonversi teks waktu menjadi format jam:menit',
      () {
        // Menggunakan format lokal tanpa 'Z' (UTC) agar tidak terpengaruh zona waktu mesin/CI device
        const timeText = '2023-10-26T14:45:30';
        // Diharapkan format '14:45'
        expect(FormatJam.formatTextToHour(timeText), '14:45');
      },
    );

    test(
      '04. formatTextToHour harus mengembalikan "--:--" untuk format yang salah',
      () {
        const invalidTimeText = 'waktu-tidak-valid';
        expect(FormatJam.formatTextToHour(invalidTimeText), '--:--');
      },
    );
  });

  group('FormatUang', () {
    test(
      '01. formatMataUang harus mengembalikan format mata uang Rupiah yang benar',
      () {
        // Diharapkan format 'Rp 1.250.000'
        expect(FormatUang.formatMataUang(1250000), 'Rp 1.250.000');
      },
    );

    test('02. formatMataUang harus menangani nilai nol', () {
      // Diharapkan format 'Rp 0'
      expect(FormatUang.formatMataUang(0), 'Rp 0');
    });
  });

  group('FormatNomor', () {
    test('01. formatRibuan harus memformat angka dengan pemisah ribuan', () {
      // Diharapkan format '1.234.567'
      expect(FormatNomor.formatRibuan(1234567), '1.234.567');
    });

    test('02. formatRibuan harus menangani angka di bawah seribu', () {
      // Diharapkan format '500'
      expect(FormatNomor.formatRibuan(500), '500');
    });
  });
}
