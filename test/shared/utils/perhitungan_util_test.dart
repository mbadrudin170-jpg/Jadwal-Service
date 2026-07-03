// path: test/shared/utils/perhitungan_util_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';

void main() {
  group('PerhitunganUtil', () {
    test('01. hitungTanggalBerakhir harus menambahkan hari dengan benar', () {
      final tanggalMulai = DateTime(2023);
      final paket = const PaketModel(
        id: '1',
        nama: 'Paket Test',
        harga: 10000,
        durasi: 10,
        tipe: TipeDurasiPaket.days,
      );

      final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
        tanggalMulai,
        paket,
      );

      expect(tanggalBerakhir, DateTime(2023, 1, 11));
    });

    test('02. hitungTanggalBerakhir harus menambahkan bulan dengan benar', () {
      final tanggalMulai = DateTime(2023, 1, 15);
      final paket = const PaketModel(
        id: '1',
        nama: 'Paket Test',
        harga: 10000,
        durasi: 3,
        tipe: TipeDurasiPaket.months,
      );

      final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
        tanggalMulai,
        paket,
      );

      expect(tanggalBerakhir, DateTime(2023, 4, 15));
    });

    test('03. hitungTanggalBerakhir harus menangani bonus', () {
      final tanggalMulai = DateTime(2023);
      final paket = const PaketModel(
        id: '1',
        nama: 'Paket Test',
        harga: 10000,
        durasi: 1,
        tipe: TipeDurasiPaket.days,
      );

      final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
        tanggalMulai,
        paket,
        durasiBonus: 3,
        tipeDurasiBonus: TipeDurasiPaket.hours,
      );

      expect(tanggalBerakhir, DateTime(2023, 1, 1, 3));
    });

    test(
      '04. cobaAmbilTeksSisaMasaAktif harus mengembalikan "Berakhir" jika sudah lewat',
      () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        expect(
          PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(pastDate),
          'Berakhir',
        );
      },
    );

    test('05. cobaAmbilTeksSisaMasaAktif harus mengembalikan sisa waktu', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final result = PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(futureDate);
      expect(result, contains('5'));
    });

    test(
      '06. ambilWarnaSisaMasaAktif harus mengembalikan hijau jika > 7 hari',
      () {
        final futureDate = DateTime.now().add(const Duration(days: 10));
        expect(
          PerhitunganUtil.ambilWarnaSisaMasaAktif(futureDate),
          Colors.green,
        );
      },
    );

    test(
      '07. ambilWarnaSisaMasaAktif harus mengembalikan orange jika <= 7 hari',
      () {
        final futureDate = DateTime.now().add(const Duration(days: 3));
        expect(
          PerhitunganUtil.ambilWarnaSisaMasaAktif(futureDate),
          Colors.orange,
        );
      },
    );

    test(
      '08. ambilWarnaSisaMasaAktif harus mengembalikan merah jika sudah lewat',
      () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        expect(PerhitunganUtil.ambilWarnaSisaMasaAktif(pastDate), Colors.red);
      },
    );

    test('09. poinKadaluarsa harus mengembalikan "Hangus" jika > 30 hari', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 31));
      expect(PerhitunganUtil.poinKadaluarsa(tanggalMulai: oldDate), 'Hangus');
    });

    test(
      '10. poinKadaluarsa harus mengembalikan string kosong jika <= 30 hari',
      () {
        final recentDate = DateTime.now().subtract(const Duration(days: 20));
        expect(PerhitunganUtil.poinKadaluarsa(tanggalMulai: recentDate), '');
      },
    );
  });
}
