// path: test/shared/utils/format_util_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/utils/format_util.dart';

void main() {
  // ========== FormatTanggal ==========
  group('FormatTanggal', () {
    group('formatTanggalBasic', () {
      test('memformat tanggal dengan format d MMM yyyy', () {
        final date = DateTime(2024, 8, 17);
        final result = FormatTanggal.formatTanggalBasic(date);
        expect(result, '17 Agu 2024');
      });

      test('menangani bulan berbeda', () {
        final date = DateTime(2024, 1, 5);
        final result = FormatTanggal.formatTanggalBasic(date);
        expect(result, '5 Jan 2024');
      });

      test('menangani akhir tahun', () {
        final date = DateTime(2024, 12, 31);
        final result = FormatTanggal.formatTanggalBasic(date);
        expect(result, '31 Des 2024');
      });
    });

    group('formatTanggalDanJam', () {
      test('memformat tanggal dengan jam dan menit', () {
        final date = DateTime(2024, 8, 17, 14, 30);
        final result = FormatTanggal.formatTanggalDanJam(date);
        expect(result, '17 Agu 2024, 14:30');
      });

      test('menangani jam satu digit', () {
        final date = DateTime(2024, 8, 17, 9, 5);
        final result = FormatTanggal.formatTanggalDanJam(date);
        expect(result, '17 Agu 2024, 09:05');
      });
    });

    group('formatTanggalRingkas', () {
      test('memformat tanggal ringkas dengan hari', () {
        // 17 Agustus 2024 adalah hari Sabtu
        final date = DateTime(2024, 8, 17);
        final result = FormatTanggal.formatTanggalRingkas(date);
        expect(result, 'Sab, 17 Agu 24');
      });

      test('menangani hari berbeda', () {
        // 1 Januari 2024 adalah hari Senin
        final date = DateTime(2024, 1, 1);
        final result = FormatTanggal.formatTanggalRingkas(date);
        expect(result, 'Sen, 1 Jan 24');
      });
    });
  });

  // ========== FormatJam ==========
  group('FormatJam', () {
    group('formatJamMenit', () {
      test('memformat waktu ke HH:mm', () {
        final time = DateTime(2024, 1, 1, 14, 30);
        final result = FormatJam.formatJamMenit(time);
        expect(result, '14:30');
      });

      test('menangani jam satu digit dengan leading zero', () {
        final time = DateTime(2024, 1, 1, 9, 5);
        final result = FormatJam.formatJamMenit(time);
        expect(result, '09:05');
      });

      test('menangani tengah malam', () {
        final time = DateTime(2024, 1, 1, 0, 0);
        final result = FormatJam.formatJamMenit(time);
        expect(result, '00:00');
      });
    });

    group('formatJamLengkap', () {
      test('memformat waktu ke HH:mm:ss', () {
        final time = DateTime(2024, 1, 1, 14, 30, 45);
        final result = FormatJam.formatJamLengkap(time);
        expect(result, '14:30:45');
      });

      test('menangani detik satu digit', () {
        final time = DateTime(2024, 1, 1, 9, 5, 3);
        final result = FormatJam.formatJamLengkap(time);
        expect(result, '09:05:03');
      });
    });

    group('formatTeksKeJam', () {
      test('mengonversi string ISO 8601 ke HH:mm', () {
        final result = FormatJam.formatTeksKeJam('2024-08-17T14:30:00.000');
        expect(result, '14:30');
      });

      test('menangani string ISO tanpa milidetik', () {
        final result = FormatJam.formatTeksKeJam('2024-08-17T09:05:00');
        expect(result, '09:05');
      });

      test('mengembalikan fallback untuk string tidak valid', () {
        final result = FormatJam.formatTeksKeJam('bukan-waktu');
        expect(result, '--:--');
      });

      test('mengembalikan fallback untuk string kosong', () {
        final result = FormatJam.formatTeksKeJam('');
        expect(result, '--:--');
      });

      test(
          'mengembalikan fallback untuk null (jika parameter diubah jadi nullable)',
          () {
        // Method saat ini menerima String non-nullable,
        // jadi test ini hanya sebagai dokumentasi jika refactor nanti.
        // Untuk sekarang, string kosong sudah ditangani.
      });
    });
  });

  // ========== FormatUang ==========
  group('FormatUang', () {
    group('formatMataUang', () {
      test('memformat angka bulat ke Rupiah', () {
        final result = FormatUang.formatMataUang(50000);
        expect(result, 'Rp 50.000');
      });

      test('memformat angka dengan desimal (dibulatkan)', () {
        final result = FormatUang.formatMataUang(12345.67);
        expect(result, 'Rp 12.346'); // decimalDigits: 0 akan membulatkan
      });

      test('memformat nol', () {
        final result = FormatUang.formatMataUang(0);
        expect(result, 'Rp 0');
      });

      test('memformat angka besar', () {
        final result = FormatUang.formatMataUang(1500000);
        expect(result, 'Rp 1.500.000');
      });

      test('memformat angka negatif', () {
        final result = FormatUang.formatMataUang(-50000);
        expect(result, '-Rp 50.000');
      });
    });
  });
}
