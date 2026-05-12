// path: lib/utils/perhitungan_util.dart

// File ini berisi fungsi utilitas untuk menghitung dan menampilkan
// sisa masa aktif paket pengguna berdasarkan tanggal berakhir.

import 'package:flutter/material.dart';

// diubah: Nama kelas diubah menjadi lebih umum untuk menampung fungsi perhitungan lainnya.
class PerhitunganUtil {
  // diubah: Logika diubah untuk menghitung status 'Hangus' berdasarkan selisih 30 hari dari tanggal mulai.
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
    // ditambah: Mengambil tanggal saat ini tanpa informasi jam, menit, atau detik.
    final tanggalSekarang = DateUtils.dateOnly(now ?? DateTime.now());

    // ditambah: Mengambil tanggal berakhir tanpa informasi waktu untuk perbandingan yang akurat.
    final akhir = DateUtils.dateOnly(tanggalBerakhir);

    // ditambah: Menghitung selisih hari antara tanggal berakhir dan sekarang.
    return akhir.difference(tanggalSekarang).inDays;
  }

  /// diubah: Logika fungsi diperbarui untuk memberikan detail waktu yang lebih presisi (hari, jam, menit).
  /// Fungsi untuk mendapatkan representasi teks dari sisa masa aktif.
  /// Contoh: "Sisa 5 hari", "Sisa 12 jam", atau "Berakhir".
  static String getTeksSisaMasaAktif(
    DateTime tanggalBerakhir, {
    DateTime? now,
  }) {
    // diubah: Menghitung selisih waktu yang presisi menggunakan Duration untuk mendapatkan jam dan menit.
    final sisa = tanggalBerakhir.difference(now ?? DateTime.now());

    // diubah: Jika sisa durasi negatif (sudah lewat), langsung kembalikan teks "Berakhir".
    if (sisa.isNegative) {
      return 'Berakhir';
    } else {
      // ditambah: Logika untuk menampilkan sisa waktu dalam hari, jam, atau menit jika belum berakhir.
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
    // ditambah: Menghitung sisa hari sebagai dasar penentuan warna.
    final sisa = sisaHari(tanggalBerakhir, now: now);

    // ditambah: Logika untuk memilih warna berdasarkan sisa hari.
    if (sisa > 7) {
      return Colors.green;
    } else if (sisa > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
