// path: lib/shared/utils/format_util.dart

// File ini berisi kumpulan kelas utilitas untuk pemformatan data.
// Setiap kelas bertanggung jawab atas satu jenis format (Tanggal, Jam, Uang)
// untuk memastikan kode yang terorganisir dan mudah dikelola.

import 'package:intl/intl.dart';

/// Kelas utilitas untuk pemformatan tanggal dan waktu.
class FormatDateTime {
  FormatDateTime._();

  /// Mengubah [DateTime] menjadi format tanggal dan jam "d MMM yyyy, HH:mm".
  static String formatDateAndTime(final DateTime date) {
    final format = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    return format.format(date);
  }

  /// Mengubah [DateTime] menjadi format tanggal dan jam ringkas "E, d MMM yy, HH:mm".
  /// Contoh: "Sel, 20 Agu 26, 10:00"
  static String formatDateAndTimeCompact(final DateTime date) {
    final format = DateFormat('E, d MMM yy, HH:mm', 'id_ID');
    return format.format(date);
  }
}

/// Kelas utilitas untuk semua pemformatan yang terkait dengan tanggal.
class FormatDate {
  // Konstruktor privat untuk mencegah instansiasi.
  FormatDate._();

  /// Mengubah [DateTime] menjadi format tanggal "d MMM yyyy" (contoh: "17 Agu 2024").
  static String formatDateBasic(final DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  /// Mengubah [DateTime] menjadi format tanggal ringkas "E, d MMM yy" (contoh: "Sel, 17 Agu 26").
  static String formatDateCompact(final DateTime date) {
    return DateFormat('E, d MMM yy', 'id_ID').format(date);
  }

  /// Mengubah [DateTime] menjadi format bulan dan tahun "MMMM yyyy" (contoh: "Agustus 2024").
  static String formatMonthYear(final DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }
}

/// Kelas utilitas untuk semua pemformatan yang terkait dengan waktu/jam.
class TimeFormat {
  // Konstruktor privat untuk mencegah instansiasi.
  TimeFormat._();

  /// Mengubah [DateTime] menjadi format jam dan menit "HH:mm".
  static String formatHourMinute(final DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Mengubah [DateTime] menjadi format jam, menit, dan detik "HH:mm:ss".
  static String formatFullTime(final DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  /// Mengonversi string waktu (ISO 8601) menjadi format "HH:mm".
  static String formatTextToHour(final String timeText) {
    try {
      final dateTime = DateTime.parse(timeText);
      return DateFormat('HH:mm').format(dateTime);
    } on Exception {
      return '--:--'; // Fallback jika format teks tidak valid.
    }
  }
}

/// Kelas utilitas untuk pemformatan mata uang.
class CurrencyFormat {
  // Konstruktor privat untuk mencegah instansiasi.
  CurrencyFormat._();

  /// Memformat angka [double] menjadi format mata uang Rupiah ("Rp 50.000").
  static String formatCurrency(final double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0, // Rupiah tidak menggunakan desimal.
    );
    return formatter.format(amount);
  }
}

/// Kelas utilitas untuk memformat angka dengan separator ribuan.
class NumberFormatter {
  // Konstruktor privat untuk mencegah instansiasi.
  NumberFormatter._();

  /// Memformat angka [int] menjadi string dengan separator titik (contoh: 15000 → "15.000").
  static String formatWithSeparator(final int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(value);
  }
}
