// path: lib/shared/utils/durasi_util.dart

import 'package:jiffy/jiffy.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';

class DurasiUtil {
  DurasiUtil._();

  static int hitungDurasiDalamMenit(PaketModel paket) {
    return _konversiKeMenit(paket.tipe, paket.durasi);
  }

  static int hitungTotalDurasiDalamMenit(
    PaketModel paket, {
    int? durasiBonus,
    TipeDurasiPaket? tipeBonus,
  }) {
    var totalMenit = _konversiKeMenit(paket.tipe, paket.durasi);

    if (durasiBonus != null && durasiBonus > 0 && tipeBonus != null) {
      totalMenit += _konversiKeMenit(tipeBonus, durasiBonus);
    }

    return totalMenit;
  }

  static DateTime tambahDurasi(
    DateTime tanggal,
    TipeDurasiPaket tipe,
    int jumlah,
  ) {
    switch (tipe) {
      case TipeDurasiPaket.minutes:
        return tanggal.add(Duration(minutes: jumlah));
      case TipeDurasiPaket.hours:
        return tanggal.add(Duration(hours: jumlah));
      case TipeDurasiPaket.days:
        return tanggal.add(Duration(days: jumlah));
      case TipeDurasiPaket.months:
        return Jiffy.parseFromDateTime(tanggal).add(months: jumlah).dateTime;
    }
  }

  static int _konversiKeMenit(TipeDurasiPaket tipe, int jumlah) {
    switch (tipe) {
      case TipeDurasiPaket.minutes:
        return jumlah;
      case TipeDurasiPaket.hours:
        return jumlah * 60;
      case TipeDurasiPaket.days:
        return jumlah * 24 * 60;
      case TipeDurasiPaket.months:
        return jumlah * 30 * 24 * 60;
    }
  }
}
