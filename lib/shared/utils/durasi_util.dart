// path: lib/shared/utils/durasi_util.dart

import 'package:jiffy/jiffy.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';

/// Kelas utilitas untuk perhitungan durasi yang konsisten di seluruh aplikasi.
class DurasiUtil {
  DurasiUtil._();

  /// Menghitung durasi paket dalam satuan menit.
  /// 
  /// [paket] Model paket yang akan dihitung durasinya.
  /// Mengembalikan total durasi dalam menit.
  static int hitungDurasiDalamMenit(PaketModel paket) {
    return _konversiKeMenit(paket.tipe, paket.durasi);
  }

  /// Menghitung durasi total (paket + bonus) dalam menit.
  /// 
  /// [paket] Model paket.
  /// [durasiBonus] Durasi bonus (opsional).
  /// [tipeBonus] Tipe durasi bonus (opsional).
  /// Mengembalikan total durasi dalam menit.
  static int hitungTotalDurasiDalamMenit(
    PaketModel paket, {
    int? durasiBonus,
    TipeDurasiPaket? tipeBonus,
  }) {
    int totalMenit = _konversiKeMenit(paket.tipe, paket.durasi);
    
    if (durasiBonus != null && durasiBonus > 0 && tipeBonus != null) {
      totalMenit += _konversiKeMenit(tipeBonus, durasiBonus);
    }
    
    return totalMenit;
  }

  /// Menambahkan durasi ke DateTime tertentu.
  /// 
  /// [tanggal] Tanggal awal.
  /// [tipe] Tipe durasi (menit, jam, hari, bulan).
  /// [jumlah] Jumlah durasi.
  /// Mengembalikan DateTime baru setelah penambahan durasi.
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
        // Menggunakan Jiffy untuk perhitungan bulan yang akurat
        return Jiffy.parseFromDateTime(tanggal).add(months: jumlah).dateTime;
    }
  }

  /// Konversi tipe durasi ke jumlah menit.
  /// 
  /// [tipe] Tipe durasi.
  /// [jumlah] Jumlah durasi.
  /// Mengembalikan total durasi dalam menit.
  static int _konversiKeMenit(TipeDurasiPaket tipe, int jumlah) {
    switch (tipe) {
      case TipeDurasiPaket.minutes:
        return jumlah;
      case TipeDurasiPaket.hours:
        return jumlah * 60;
      case TipeDurasiPaket.days:
        return jumlah * 24 * 60;
      case TipeDurasiPaket.months:
        // Asumsi 1 bulan = 30 hari untuk konversi ke menit
        // Ini hanya untuk keperluan sorting/perbandingan, bukan perhitungan tanggal aktual
        return jumlah * 30 * 24 * 60;
    }
  }
}