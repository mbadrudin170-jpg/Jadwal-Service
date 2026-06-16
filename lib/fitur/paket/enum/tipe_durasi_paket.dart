// path: lib/fitur/paket/enum/tipe_durasi_paket.dart

enum TipeDurasiPaket {
  minutes,

  hours,

  days,

  months;

  String get displayName {
    switch (this) {
      case TipeDurasiPaket.minutes:
        return 'Menit';
      case TipeDurasiPaket.hours:
        return 'Jam';
      case TipeDurasiPaket.days:
        return 'Hari';
      case TipeDurasiPaket.months:
        return 'Bulan';
    }
  }
}
