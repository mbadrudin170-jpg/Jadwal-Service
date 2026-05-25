// path: lib/shared/utils/calculation_util.dart

// File ini berisi fungsi utilitas untuk menghitung dan menampilkan
// sisa masa aktif paket pengguna berdasarkan tanggal berakhir.

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Kelas utilitas untuk berbagai perhitungan terkait paket pelanggan.
///
/// Menyediakan fungsi untuk menghitung sisa hari, status hangus,
/// teks representasi masa aktif, dan warna indikator status.
class CalculationUtil {

  /// menghitung kapan tanggal berkahirnya sebuah paket user
  static DateTime hitungTanggalBerakhir(
    final DateTime startDate,
    final PackageModel paket,
  ) {
    Log.info('FUNGSI GLOBAL: hitungTanggalBerakhir() dipanggil.');
    Log.info('  - Tanggal Mulai: ${startDate.toIso8601String()}');
    Log.info('  - Nama Paket: ${paket.name}');
    Log.info('  - Tipe Durasi: ${paket.type.name}');
    Log.info('  - Durasi: ${paket.duration}');

    DateTime hasil;
    switch (paket.type) {
      case DurationType.hours:
        hasil = startDate.add(Duration(hours: paket.duration));
        break;
      case DurationType.days:
        hasil = startDate.add(Duration(days: paket.duration));
        break;
      case DurationType.months:
        hasil = Jiffy.parseFromDateTime(startDate)
            .add(months: paket.duration)
            .dateTime;
        break;
      case DurationType.minutes:
        hasil = startDate.add(Duration(minutes: paket.duration));
        break;
    }

    Log.info('  - Hasil Tanggal Berakhir: ${hasil.toIso8601String()}');
    return hasil;
  }

  /// Mengecek apakah poin pelanggan sudah hangus.
  ///
  /// Poin dianggap hangus jika selisih antara [startDate] dan sekarang
  /// lebih dari 30 hari. [now] dapat digunakan untuk pengujian.
  static String getExpiredPoints(
      {required final DateTime startDate, final DateTime? now}) {
    final currentDate = now ?? DateTime.now();
    final dayDifference = currentDate.difference(startDate).inDays;

    if (dayDifference > 30) {
      return 'Hangus';
    }
    return '';
  }

  /// Fungsi ini menghitung selisih hari antara tanggal berakhir dan tanggal sekarang.
  /// Mengembalikan jumlah sisa hari dalam bentuk integer.
  /// Jika tanggal berakhir sudah lewat, hasilnya akan menjadi negatif.
  static int remainingDays(final DateTime endDate, {final DateTime? now}) {
    final currentDate = DateUtils.dateOnly(now ?? DateTime.now());
    final end = DateUtils.dateOnly(endDate);
    return end.difference(currentDate).inDays;
  }

  /// Fungsi untuk mendapatkan representasi teks dari sisa masa aktif.
  /// Contoh: "Sisa 5 hari", "Sisa 12 jam", atau "Berakhir".
  static String getRemainingActivePeriodText(
    final DateTime endDate, {
    final DateTime? now,
  }) {
    final remaining = endDate.difference(now ?? DateTime.now());

    if (remaining.isNegative) {
      return 'Berakhir';
    } else {
      if (remaining.inDays > 0) {
        return 'Sisa ${remaining.inDays} hari';
      } else if (remaining.inHours > 0) {
        return 'Sisa ${remaining.inHours} jam';
      } else if (remaining.inMinutes > 0) {
        return 'Sisa ${remaining.inMinutes} menit';
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
  static Color getRemainingActivePeriodColor(
    final DateTime endDate, {
    final DateTime? now,
  }) {
    final remaining = remainingDays(endDate, now: now);

    if (remaining > 7) {
      return Colors.green;
    } else if (remaining > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
