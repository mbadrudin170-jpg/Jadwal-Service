// path: lib/shared/utils/perhitungan_util.dart

// File ini berisi fungsi utilitas untuk menghitung dan menampilkan
// sisa masa aktif paket pengguna berdasarkan tanggal berakhir.

import 'package:flutter/material.dart';

/// Kelas utilitas untuk berbagai perhitungan terkait paket pelanggan.
///
/// Menyediakan fungsi untuk menghitung sisa hari, status hangus,
/// teks representasi masa aktif, dan warna indikator status.
class PerhitunganUtil {
  /// Mengecek apakah poin pelanggan sudah hangus.
  ///
  /// Poin dianggap hangus jika selisih antara [tanggalMulai] dan sekarang
  /// lebih dari 30 hari. [now] dapat digunakan untuk pengujian.
  static String getPoinHangus({required DateTime tanggalMulai, DateTime? now}) {
    final tanggalSekarang = now ?? DateTime.now();
    final selisihHari = tanggalSekarang.difference(tanggalMulai).inDays;

    if (selisihHari > 30) {
      return 'Hangus';
    }
    return '';
  }

  /// Fungsi ini menghitung selisih hari antara tanggal berakhir dan tanggal sekarang.
  /// Mengembalikan jumlah sisa hari dalam bentuk integer.
  /// Jika tanggal berakhir sudah lewat, hasilnya akan menjadi negatif.
  static int sisaHari(DateTime tanggalBerakhir, {DateTime? now}) {
    final tanggalSekarang = DateUtils.dateOnly(now ?? DateTime.now());
    final akhir = DateUtils.dateOnly(tanggalBerakhir);
    return akhir.difference(tanggalSekarang).inDays;
  }

  /// diubah: Logika fungsi diperbarui untuk memberikan detail waktu yang lebih presisi (hari, jam, menit).
  /// Fungsi untuk mendapatkan representasi teks dari sisa masa aktif.
  /// Contoh: "Sisa 5 hari", "Sisa 12 jam", atau "Berakhir".
  static String getTeksSisaMasaAktif(
    DateTime tanggalBerakhir, {
    DateTime? now,
  }) {
    final sisa = tanggalBerakhir.difference(now ?? DateTime.now());

    if (sisa.isNegative) {
      return 'Berakhir';
    } else {
      if (sisa.inDays > 0) {
        return 'Sisa ${sisa.inDays} hari';
      } else if (sisa.inHours > 0) {
        return 'Sisa ${sisa.inHours} jam';
      } else if (sisa.inMinutes > 0) {
        return 'Sisa ${sisa.inMinutes} menit';
      } else {
        return 'Berakhir dalam beberapa saat';
      }
    }
  }

  /// Fungsi untuk mendapatkan warna yang merepresentasikan status masa aktif.
  /// Ini berguna untuk memberikan isyarat visual di UI.
  /// - Hijau: Jika sisa masa aktif lebih dari 7 hari.
  /// - Oranye: Jika sisa masa aktif antara 1 hingga 7 hari.
  /// - Merah: Jika paket berakhir hari ini atau sudah kadaluarsa.
  static Color getWarnaSisaMasaAktif(
    DateTime tanggalBerakhir, {
    DateTime? now,
  }) {
    final sisa = sisaHari(tanggalBerakhir, now: now);

    if (sisa > 7) {
      return Colors.green;
    } else if (sisa > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
