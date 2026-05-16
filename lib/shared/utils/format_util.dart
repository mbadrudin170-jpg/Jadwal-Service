// path: lib/shared/utils/format_util.dart

// File ini berisi kumpulan kelas utilitas untuk pemformatan data.
// Setiap kelas bertanggung jawab atas satu jenis format (Tanggal, Jam, Uang)
// untuk memastikan kode yang terorganisir dan mudah dikelola.

import 'package:intl/intl.dart';

/// Kelas utilitas untuk semua pemformatan yang terkait dengan tanggal.
class FormatUtil {
  // Konstruktor privat untuk mencegah instansiasi.
  FormatUtil._();

  /// Mengubah [DateTime] menjadi format tanggal "d MMM yyyy" (contoh: "17 Agu 2024").
  static String formatDateBasic(final DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  /// Mengubah [DateTime] menjadi format tanggal dan jam "d MMM yyyy, HH:mm".
  static String formatDateAndTime(final DateTime date) {
    final format = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    return format.format(date);
  }

  /// Mengubah [DateTime] menjadi format tanggal ringkas "E, d MMM yy" (contoh: "Sel, 17 Agu 26").
  static String formatDateCompact(final DateTime date) {
    return DateFormat('E, d MMM yy', 'id_ID').format(date);
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
