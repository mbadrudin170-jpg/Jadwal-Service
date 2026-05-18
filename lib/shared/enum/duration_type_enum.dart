// path: lib/shared/enum/duration_type_enum.dart
// diubah: Menambahkan dokumentasi untuk getter displayName.

/// Enum untuk jenis durasi sebuah paket.
enum DurationType {
  /// Durasi dalam menit.
  minutes,

  /// Durasi dalam jam.
  hours,

  /// Durasi dalam hari.
  days,

  /// Durasi dalam bulan.
  months;

  /// Merepresentasikan nama dari setiap jenis durasi dalam format yang mudah dibaca.
  String get displayName {
    switch (this) {
      case DurationType.minutes:
        return 'Menit';
      case DurationType.hours:
        return 'Jam';
      case DurationType.days:
        return 'Hari';
      case DurationType.months:
        return 'Bulan';
    }
  }
}
