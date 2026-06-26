// path: test/shared/utils/perhitungan_util_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';

void main() {
  group('hitungTanggalBerakhir', () {
    test(
      '01. harus menambahkan hari dengan benar ketika tipe durasi adalah days',
      () {
        final tanggalMulai = DateTime(2023, 1, 1);
        final tanggalBerakhir = hitungTanggalBerakhir(
          tanggalMulai: tanggalMulai,
          durasi: 10,
          tipeDurasi: TipeDurasiPaket.days,
        );
        expect(tanggalBerakhir, DateTime(2023, 1, 11));
      },
    );

    test(
      '02. harus menambahkan minggu dengan benar ketika tipe durasi adalah weeks',
      () {
        final tanggalMulai = DateTime(2023, 1, 1);
        final tanggalBerakhir = hitungTanggalBerakhir(
          tanggalMulai: tanggalMulai,
          durasi: 2,
          tipeDurasi: TipeDurasiPaket.weeks,
        );
        expect(tanggalBerakhir, DateTime(2023, 1, 15));
      },
    );

    test(
      '03. harus menambahkan bulan dengan benar ketika tipe durasi adalah months',
      () {
        final tanggalMulai = DateTime(2023, 1, 15);
        final tanggalBerakhir = hitungTanggalBerakhir(
          tanggalMulai: tanggalMulai,
          durasi: 3,
          tipeDurasi: TipeDurasiPaket.months,
        );
        // Harusnya 2023-04-15
        expect(tanggalBerakhir, DateTime(2023, 4, 15));
      },
    );

    test(
      '04. harus menangani penambahan bulan pada akhir bulan (Februari)',
      () {
        final tanggalMulai = DateTime(2023, 1, 31);
        final tanggalBerakhir = hitungTanggalBerakhir(
          tanggalMulai: tanggalMulai,
          durasi: 1,
          tipeDurasi: TipeDurasiPaket.months,
        );
        // Harusnya 2023-02-28, bukan Maret
        expect(tanggalBerakhir, DateTime(2023, 2, 28));
      },
    );

    test(
      '05. harus menambahkan tahun dengan benar ketika tipe durasi adalah years',
      () {
        final tanggalMulai = DateTime(2023, 2, 28);
        final tanggalBerakhir = hitungTanggalBerakhir(
          tanggalMulai: tanggalMulai,
          durasi: 1,
          tipeDurasi: TipeDurasiPaket.years,
        );
        expect(tanggalBerakhir, DateTime(2024, 2, 28));
      },
    );

    test('06. harus menangani tahun kabisat saat menambah tahun', () {
      // Dari non-kabisat ke kabisat
      final tanggalMulai1 = DateTime(2023, 2, 28);
      final tanggalBerakhir1 = hitungTanggalBerakhir(
        tanggalMulai: tanggalMulai1,
        durasi: 1,
        tipeDurasi: TipeDurasiPaket.years,
      );
      expect(tanggalBerakhir1, DateTime(2024, 2, 28));

      // Dari 29 Feb di tahun kabisat
      final tanggalMulai2 = DateTime(2024, 2, 29);
      final tanggalBerakhir2 = hitungTanggalBerakhir(
        tanggalMulai: tanggalMulai2,
        durasi: 1,
        tipeDurasi: TipeDurasiPaket.years,
      );
      expect(tanggalBerakhir2, DateTime(2025, 2, 28));
    });
  });

  group('sisaWaktu', () {
    test('07. harus mengembalikan "Berakhir Hari Ini" jika tanggal sama', () {
      final now = DateTime.now();
      expect(sisaWaktu(now), 'Berakhir Hari Ini');
    });

    test('08. harus mengembalikan "Kadaluwarsa" jika tanggal sudah lewat', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      expect(sisaWaktu(pastDate), 'Kadaluwarsa');
    });

    test('09. harus mengembalikan jumlah hari yang tersisa', () {
      final futureDate = DateTime.now().add(const Duration(days: 5, hours: 3));
      expect(sisaWaktu(futureDate), '5 hari lagi');
    });

    test('10. harus mengembalikan "1 hari lagi" untuk besok', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(sisaWaktu(tomorrow), '1 hari lagi');
    });
  });

  group('formatBytes', () {
    test('11. harus mengembalikan 0 B untuk 0 byte', () {
      expect(formatBytes(0), '0 B');
    });

    test('12. harus memformat bytes dengan benar', () {
      expect(formatBytes(500), '500 B');
    });

    test('13. harus memformat KiloBytes dengan benar', () {
      expect(formatBytes(1024), '1 KB');
      expect(formatBytes(1536), '1.5 KB');
    });

    test('14. harus memformat MegaBytes dengan benar', () {
      expect(formatBytes(1048576), '1 MB');
      expect(formatBytes(1572864), '1.5 MB');
    });

    test('15. harus memformat GigaBytes dengan benar', () {
      expect(formatBytes(1073741824), '1 GB');
      expect(formatBytes(1610612736), '1.5 GB');
    });

    test('16. harus memformat TeraBytes dengan benar', () {
      expect(formatBytes(1099511627776), '1 TB');
      expect(formatBytes(1649267441664), '1.5 TB');
    });

    test('17. harus menggunakan 2 desimal untuk presisi', () {
      expect(formatBytes(1234567), '1.18 MB');
    });
  });
}
