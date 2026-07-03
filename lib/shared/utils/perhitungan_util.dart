// path: lib/shared/utils/perhitungan_util.dart

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/durasi_util.dart';

class PerhitunganUtil {
  static DateTime hitungTanggalBerakhir(
    final DateTime tanggalMulai,
    final PaketModel paket, {
    final int? durasiBonus,
    final TipeDurasiPaket? tipeDurasiBonus,
  }) {
    Log.info('FUNGSI GLOBAL: hitungTanggalBerakhir() dipanggil.');
    Log.info('  - Tanggal Mulai: ${tanggalMulai.toIso8601String()}');
    Log.info('  - Nama Paket: ${paket.nama}');
    var hasil = DurasiUtil.tambahDurasi(tanggalMulai, paket.tipe, paket.durasi);
    if (durasiBonus != null && durasiBonus > 0 && tipeDurasiBonus != null) {
      Log.info('  - Menambahkan Bonus: $durasiBonus ${tipeDurasiBonus.name}');
      hasil = DurasiUtil.tambahDurasi(hasil, tipeDurasiBonus, durasiBonus);
    }
    Log.info('  - Hasil Tanggal Berakhir: ${hasil.toIso8601String()}');
    return hasil;
  }

  static String poinKadaluarsa({
    required DateTime tanggalMulai,
    DateTime? sekarang,
  }) {
    final tanggalSekarang = sekarang ?? DateTime.now();
    final selisihHari = tanggalSekarang.difference(tanggalMulai).inDays;

    if (selisihHari > 30) {
      return 'Hangus';
    }
    return '';
  }

  // static String ambilTeksSisaMasaAktif(
  //   final DateTime tanggalBerakhir, {
  //   final DateTime? sekarang,
  // }) {
  //   final nowUtc = (sekarang ?? DateTime.now()).toUtc();
  //   final endUtc = tanggalBerakhir.toUtc();
  //   final sisa = endUtc.difference(nowUtc);

  //   if (sisa.isNegative) {
  //     return 'Berakhir';
  //   } else {
  //     if (sisa.inDays > 0) {
  //       return 'Sisa ${sisa.inDays} hari';
  //     } else if (sisa.inHours > 0) {
  //       return 'Sisa ${sisa.inHours} jam';
  //     } else if (sisa.inMinutes > 0) {
  //       return 'Sisa ${sisa.inMinutes} menit';
  //     } else {
  //       return 'Berakhir dalam beberapa saat';
  //     }
  //   }
  // }

  /// Fungsi untuk pengujian menggunakan pustaka timeago.
  static String cobaAmbilTeksSisaMasaAktif(
    final DateTime tanggalBerakhir, {
    final DateTime? sekarang,
  }) {
    if (tanggalBerakhir.isBefore(sekarang ?? DateTime.now())) {
      return 'Berakhir';
    }
    timeago.setLocaleMessages('id', timeago.IdMessages());
    return timeago.format(
      tanggalBerakhir,
      locale: 'id',
      clock: sekarang,
      allowFromNow: true,
    );
  }

  static Color ambilWarnaSisaMasaAktif(
    final DateTime tanggalBerakhir, {
    final DateTime? sekarang,
  }) {
    final now = sekarang ?? DateTime.now();
    final selisih = tanggalBerakhir.difference(now);
    if (selisih.isNegative) {
      return Colors.red;
    }
    final sisaHari = selisih.inDays;
    final sisaJam = selisih.inHours;
    if (sisaHari > 7) {
      return Colors.green;
    }
    if (sisaHari > 0 || sisaJam > 0) {
      return Colors.orange;
    }
    return Colors.red;
  }
}
