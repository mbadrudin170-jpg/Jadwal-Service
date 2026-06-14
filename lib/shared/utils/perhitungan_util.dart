// path: lib/shared/utils/calculation_util.dart

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';

class PerhitunganUtil {
  static DateTime hitungTanggalBerakhir(
    final DateTime tanggalMulai,
    final PaketModel paket, {
    final int? durasiBonus,
    final DurationType? tipeDurasiBonus,
  }) {
    Log.info('FUNGSI GLOBAL: hitungTanggalBerakhir() dipanggil.');
    Log.info('  - Tanggal Mulai: ${tanggalMulai.toIso8601String()}');
    Log.info('  - Nama Paket: ${paket.name}');

    DateTime hasil = _tambahDurasi(tanggalMulai, paket.type, paket.duration);

    if (durasiBonus != null && durasiBonus > 0 && tipeDurasiBonus != null) {
      Log.info('  - Menambahkan Bonus: $durasiBonus ${tipeDurasiBonus.name}');
      hasil = _tambahDurasi(hasil, tipeDurasiBonus, durasiBonus);
    }

    Log.info('  - Hasil Tanggal Berakhir: ${hasil.toIso8601String()}');
    return hasil;
  }

  static DateTime _tambahDurasi(
    final DateTime asal,
    final DurationType tipe,
    final int jumlah,
  ) {
    switch (tipe) {
      case DurationType.minutes:
        return asal.add(Duration(minutes: jumlah));
      case DurationType.hours:
        return asal.add(Duration(hours: jumlah));
      case DurationType.days:
        return asal.add(Duration(days: jumlah));
      case DurationType.months:
        return Jiffy.parseFromDateTime(asal).add(months: jumlah).dateTime;
    }
  }

  static String getPoinKadaluarsa(
      {required DateTime tanggalMulai, DateTime? sekarang}) {
    final tanggalSekarang = sekarang ?? DateTime.now();
    final selisihHari = tanggalSekarang.difference(tanggalMulai).inDays;

    if (selisihHari > 30) {
      return 'Hangus';
    }
    return '';
  }

  static int sisaHari(DateTime endDate, {DateTime? seakrang}) {
    final selisihHari = DateUtils.dateOnly(seakrang ?? DateTime.now());
    final tanggalBerakhir = DateUtils.dateOnly(endDate);
    return tanggalBerakhir.difference(selisihHari).inDays;
  }

  static String ambilTeksSisaMasaAktif(
    final DateTime tanggalBerakhir, {
    final DateTime? sekarang,
  }) {
    final sisaHari = tanggalBerakhir.difference(sekarang ?? DateTime.now());

    if (sisaHari.isNegative) {
      return 'Berakhir';
    } else {
      if (sisaHari.inDays > 0) {
        return 'Sisa ${sisaHari.inDays} hari';
      } else if (sisaHari.inHours > 0) {
        return 'Sisa ${sisaHari.inHours} jam';
      } else if (sisaHari.inMinutes > 0) {
        return 'Sisa ${sisaHari.inMinutes} menit';
      } else {
        return 'Berakhir dalam beberapa saat';
      }
    }
  }

  static Color ambilWarnaSisaMasaAktif(
    final DateTime tanggalBerakhir, {
    final DateTime? sekarang,
  }) {
    final sisa = sisaHari(tanggalBerakhir, seakrang: sekarang);

    if (sisa > 7) {
      return Colors.green;
    } else if (sisa > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
