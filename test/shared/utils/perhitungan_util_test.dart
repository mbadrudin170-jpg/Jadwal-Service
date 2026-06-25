// path: test/shared/utils/perhitungan_util_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';

void main() {
  group('PerhitunganUtil', () {
    final tanggalMulai = DateTime(2023, 1, 1, 10, 0); // 1 Jan 2023, 10:00

    group('hitungTanggalBerakhir', () {
      test(
        '01. harus menghitung tanggal berakhir dengan benar untuk durasi HARI',
        () {
          final paket = PaketModel(
            id: '1',
            nama: 'Paket Harian',
            harga: 10000,
            durasi: 7,
            tipe: TipeDurasiPaket.days,
          );

          final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
            tanggalMulai,
            paket,
          );
          expect(tanggalBerakhir, DateTime(2023, 1, 8, 10, 0));
        },
      );

      test(
        '02. harus menghitung tanggal berakhir dengan benar untuk durasi BULAN',
        () {
          final paket = PaketModel(
            id: '2',
            nama: 'Paket Bulanan',
            harga: 50000,
            durasi: 2,
            tipe: TipeDurasiPaket.months,
          );

          final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
            tanggalMulai,
            paket,
          );
          expect(tanggalBerakhir, DateTime(2023, 3, 1, 10, 0));
        },
      );

      test('03. harus menambahkan durasi bonus dengan benar', () {
        final paket = PaketModel(
          id: '3',
          nama: 'Paket Bonus',
          harga: 20000,
          durasi: 10,
          tipe: TipeDurasiPaket.days,
        );

        final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
          tanggalMulai,
          paket,
          durasiBonus: 5,
          tipeDurasiBonus: TipeDurasiPaket.days,
        );
        // 1 Jan + 10 hari (paket) + 5 hari (bonus) = 16 Jan
        expect(tanggalBerakhir, DateTime(2023, 1, 16, 10, 0));
      });
    });

    group('sisaHari', () {
      final sekarang = DateTime(2023, 10, 20); // 20 Okt 2023

      test(
        '01. harus mengembalikan selisih hari positif untuk tanggal di masa depan',
        () {
          final target = DateTime(2023, 10, 25);
          expect(target.difference(sekarang).inDays, 5);
        },
      );

      test(
        '02. harus mengembalikan selisih hari negatif untuk tanggal di masa lalu',
        () {
          final target = DateTime(2023, 10, 15);
          expect(target.difference(sekarang).inDays, -5);
        },
      );

      test('03. harus mengembalikan 0 jika tanggalnya sama', () {
        final target = DateTime(2023, 10, 20, 23, 59); // Waktu diabaikan
        expect(target.difference(sekarang).inDays, 0);
      });
    });

    group('cobaAmbilTeksSisaMasaAktif', () {
      final sekarang = DateTime(2023, 10, 20, 10, 0);

      test("01. harus mengembalikan 'Berakhir' jika tanggal sudah lewat", () {
        final tanggalBerakhir = sekarang.subtract(const Duration(seconds: 1));
        expect(
          PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
            tanggalBerakhir,
            sekarang: sekarang,
          ),
          'Berakhir',
        );
      });

      test('02. harus mengembalikan sisa hari', () {
        final tanggalBerakhir = sekarang.add(const Duration(days: 3, hours: 5));
        expect(
          PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
            tanggalBerakhir,
            sekarang: sekarang,
          ),
          '3 hari lagi',
        );
      });

      test('03. harus mengembalikan sisa jam', () {
        final tanggalBerakhirFix = sekarang.add(
          const Duration(hours: 5, minutes: 30),
        );
        expect(
          PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
            tanggalBerakhirFix,
            sekarang: sekarang,
          ),
          '5 jam lagi',
        );
      });

      test('04. harus mengembalikan sisa menit', () {
        final tanggalBerakhirFix = sekarang.add(const Duration(minutes: 45));
        expect(
          PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
            tanggalBerakhirFix,
            sekarang: sekarang,
          ),
          '45 menit lagi',
        );
      });

      test("05. harus mengembalikan 'beberapa saat lagi'", () {
        final tanggalBerakhirFix = sekarang.add(const Duration(seconds: 30));
        expect(
          PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
            tanggalBerakhirFix,
            sekarang: sekarang,
          ),
          'beberapa saat lagi',
        );
      });
    });

    group('ambilWarnaSisaMasaAktif', () {
      final sekarang = DateTime(2023, 10, 20);

      test('01. harus mengembalikan hijau jika sisa lebih dari 7 hari', () {
        final tanggalBerakhir = sekarang.add(const Duration(days: 8));
        expect(
          PerhitunganUtil.ambilWarnaSisaMasaAktif(
            tanggalBerakhir,
            sekarang: sekarang,
          ),
          Colors.green,
        );
      });

      test('02. harus mengembalikan oranye jika sisa antara 1-7 hari', () {
        final tanggalBerakhir = sekarang.add(const Duration(days: 7));
        expect(
          PerhitunganUtil.ambilWarnaSisaMasaAktif(
            tanggalBerakhir,
            sekarang: sekarang,
          ),
          Colors.orange,
        );
      });

      test('03. harus mengembalikan merah jika sisa 0 hari atau kurang', () {
        final tanggalBerakhir = sekarang; // sisa 0 hari
        expect(
          PerhitunganUtil.ambilWarnaSisaMasaAktif(
            tanggalBerakhir,
            sekarang: sekarang,
          ),
          Colors.red,
        );

        final tanggalBerakhirLampau = sekarang.subtract(
          const Duration(days: 1),
        );
        expect(
          PerhitunganUtil.ambilWarnaSisaMasaAktif(
            tanggalBerakhirLampau,
            sekarang: sekarang,
          ),
          Colors.red,
        );
      });
    });

    group('poinKadaluarsa', () {
      final sekarang = DateTime(2023, 11, 1);
      test(
        "01. harus mengembalikan 'Hangus' jika tanggal mulai lebih dari 30 hari yang lalu",
        () {
          final tanggalMulai = DateTime(2023, 9, 30); // 32 hari yang lalu
          expect(
            PerhitunganUtil.poinKadaluarsa(
              tanggalMulai: tanggalMulai,
              sekarang: sekarang,
            ),
            'Hangus',
          );
        },
      );

      test(
        "02. harus mengembalikan string kosong jika tanggal mulai 30 hari yang lalu",
        () {
          final tanggalMulai = DateTime(2023, 10, 2); // 30 hari yang lalu
          expect(
            PerhitunganUtil.poinKadaluarsa(
              tanggalMulai: tanggalMulai,
              sekarang: sekarang,
            ),
            '',
          );
        },
      );

      test(
        "03. harus mengembalikan string kosong jika tanggal mulai kurang dari 30 hari yang lalu",
        () {
          final tanggalMulai = DateTime(2023, 10, 15); // 17 hari yang lalu
          expect(
            PerhitunganUtil.poinKadaluarsa(
              tanggalMulai: tanggalMulai,
              sekarang: sekarang,
            ),
            '',
          );
        },
      );
    });
  });
}
