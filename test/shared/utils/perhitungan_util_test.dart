// path: test/shared/utils/perhitungan_util_test.dart
// diubah: Menambahkan pengujian lengkap untuk PerhitunganUtil.
// ditambahkan: Pengujian getPoinHangus.
// ditambahkan: Pengujian sisaHari.
// ditambahkan: Pengujian getTeksSisaMasaAktif.
// ditambahkan: Pengujian getWarnaSisaMasaAktif.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/utils/calculation_util.dart';

void main() {
  group('PerhitunganUtil', () {
    group('getPoinHangus', () {
      test(
        'harus mengembalikan Hangus jika lebih dari 30 hari',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 31);

          final tanggalMulai = DateTime(2025, 12);

          // Act
          final hasil = PerhitunganUtil.getPoinHangus(
            tanggalMulai: tanggalMulai,
            now: sekarang,
          );

          // Assert
          expect(hasil, 'Hangus');
        },
      );

      test(
        'harus mengembalikan string kosong jika belum 30 hari',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 20);

          final tanggalMulai = DateTime(2026);

          // Act
          final hasil = PerhitunganUtil.getPoinHangus(
            tanggalMulai: tanggalMulai,
            now: sekarang,
          );

          // Assert
          expect(hasil, '');
        },
      );

      test(
        'harus mengembalikan string kosong jika tepat 30 hari',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 31);

          final tanggalMulai = DateTime(2026);

          // Act
          final hasil = PerhitunganUtil.getPoinHangus(
            tanggalMulai: tanggalMulai,
            now: sekarang,
          );

          // Assert
          expect(hasil, '');
        },
      );
    });

    group('sisaHari', () {
      test(
        'harus mengembalikan sisa hari positif',
        () {
          // Arrange
          final sekarang = DateTime(2026);

          final tanggalBerakhir = DateTime(2026, 1, 10);

          // Act
          final hasil = PerhitunganUtil.sisaHari(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, 9);
        },
      );

      test(
        'harus mengembalikan nol jika hari ini berakhir',
        () {
          // Arrange
          final sekarang = DateTime(2026);

          final tanggalBerakhir = DateTime(2026);

          // Act
          final hasil = PerhitunganUtil.sisaHari(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, 0);
        },
      );

      test(
        'harus mengembalikan nilai negatif jika sudah lewat',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 10);

          final tanggalBerakhir = DateTime(2026);

          // Act
          final hasil = PerhitunganUtil.sisaHari(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, -9);
        },
      );

      test(
        'harus mengabaikan jam dan hanya menghitung tanggal',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 1, 23, 59);

          final tanggalBerakhir = DateTime(2026, 1, 2, 0, 1);

          // Act
          final hasil = PerhitunganUtil.sisaHari(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, 1);
        },
      );
    });

    group('getTeksSisaMasaAktif', () {
      test(
        'harus mengembalikan teks sisa hari',
        () {
          // Arrange
          final sekarang = DateTime(2026);

          final tanggalBerakhir = sekarang.add(
            const Duration(days: 5),
          );

          // Act
          final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, 'Sisa 5 hari');
        },
      );

      test(
        'harus mengembalikan teks sisa jam',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 1, 10);

          final tanggalBerakhir = sekarang.add(
            const Duration(hours: 12),
          );

          // Act
          final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, 'Sisa 12 jam');
        },
      );

      test(
        'harus mengembalikan teks sisa menit',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 1, 10);

          final tanggalBerakhir = sekarang.add(
            const Duration(minutes: 30),
          );

          // Act
          final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, 'Sisa 30 menit');
        },
      );

      test(
        'harus mengembalikan Berakhir jika waktu negatif',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 10);

          final tanggalBerakhir = DateTime(2026);

          // Act
          final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, 'Berakhir');
        },
      );

      test(
        'harus mengembalikan Berakhir dalam beberapa saat',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 1, 10);

          final tanggalBerakhir = sekarang.add(
            const Duration(seconds: 20),
          );

          // Act
          final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(
            hasil,
            'Berakhir dalam beberapa saat',
          );
        },
      );
    });

    group('getWarnaSisaMasaAktif', () {
      test(
        'harus mengembalikan warna hijau jika lebih dari 7 hari',
        () {
          // Arrange
          final sekarang = DateTime(2026);

          final tanggalBerakhir = DateTime(2026, 1, 20);

          // Act
          final hasil = PerhitunganUtil.getWarnaSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, Colors.green);
        },
      );

      test(
        'harus mengembalikan warna orange jika kurang dari 7 hari',
        () {
          // Arrange
          final sekarang = DateTime(2026);

          final tanggalBerakhir = DateTime(2026, 1, 5);

          // Act
          final hasil = PerhitunganUtil.getWarnaSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, Colors.orange);
        },
      );

      test(
        'harus mengembalikan warna merah jika hari ini berakhir',
        () {
          // Arrange
          final sekarang = DateTime(2026);

          final tanggalBerakhir = DateTime(2026);

          // Act
          final hasil = PerhitunganUtil.getWarnaSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, Colors.red);
        },
      );

      test(
        'harus mengembalikan warna merah jika sudah kadaluarsa',
        () {
          // Arrange
          final sekarang = DateTime(2026, 1, 10);

          final tanggalBerakhir = DateTime(2026);

          // Act
          final hasil = PerhitunganUtil.getWarnaSisaMasaAktif(
            tanggalBerakhir,
            now: sekarang,
          );

          // Assert
          expect(hasil, Colors.red);
        },
      );
    });

    // TODO: Tambahkan pengujian edge case timezone berbeda.
    // TODO: Tambahkan pengujian performa jika util digunakan dalam list besar.
  });
}
