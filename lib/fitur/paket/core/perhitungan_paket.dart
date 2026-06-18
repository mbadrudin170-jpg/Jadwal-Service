// path: lib/fitur/paket/core/perhitungan_paket.dart

import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';

/// Kelas utilitas untuk melakukan perhitungan terkait paket.
class PerhitunganPaket {
  /// Menghitung durasi paket dalam satuan menit.
  int hitungDurasiPaket(PaketModel paket) {
    switch (paket.tipe) {
      case TipeDurasiPaket.minutes:
        return paket.durasi;
      case TipeDurasiPaket.hours:
        return paket.durasi * 60;
      case TipeDurasiPaket.days:
        return paket.durasi * 24 * 60;
      case TipeDurasiPaket.months:
        return paket.durasi * 30 * 24 * 60; // Asumsi 1 bulan = 30 hari
    }
  }
}
