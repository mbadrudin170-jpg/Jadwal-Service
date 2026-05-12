// path: lib/utils/format_util.dart

// File ini berisi kumpulan kelas utilitas untuk pemformatan data.
// Setiap kelas bertanggung jawab atas satu jenis format (Tanggal, Jam, Uang)
// untuk memastikan kode yang terorganisir dan mudah dikelola.

import 'package:intl/intl.dart';

/// Kelas utilitas untuk semua pemformatan yang terkait dengan tanggal.
class FormatTanggal {
  // Konstruktor privat untuk mencegah instansiasi.
  FormatTanggal._();

  /// Mengubah [DateTime] menjadi format tanggal "d MMM yyyy" (contoh: "17 Agu 2024").
  static String formatTanggalBasic(DateTime tanggal) {
    return DateFormat('d MMM yyyy', 'id_ID').format(tanggal);
  }

  /// Mengubah [DateTime] menjadi format tanggal dan jam "d MMM yyyy, HH:mm".
  static String formatTanggalDanJam(DateTime tanggal) {
    final format = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    return format.format(tanggal);
  }

  /// Mengubah [DateTime] menjadi format tanggal ringkas "E, d MMM yy" (contoh: "Sel, 17 Agu 26").
  static String formatTanggalRingkas(DateTime tanggal) {
    return DateFormat('E, d MMM yy', 'id_ID').format(tanggal);
  }
}

/// Kelas utilitas untuk semua pemformatan yang terkait dengan waktu/jam.
class FormatJam {
  // Konstruktor privat untuk mencegah instansiasi.
  FormatJam._();

  /// Mengubah [DateTime] menjadi format jam dan menit "HH:mm".
  static String formatJamMenit(DateTime waktu) {
    return DateFormat('HH:mm').format(waktu);
  }

  /// Mengubah [DateTime] menjadi format jam, menit, dan detik "HH:mm:ss".
  static String formatJamLengkap(DateTime waktu) {
    return DateFormat('HH:mm:ss').format(waktu);
  }

  /// Mengonversi string waktu (ISO 8601) menjadi format "HH:mm".
  static String formatTeksKeJam(String teksWaktu) {
    try {
      final dateTime = DateTime.parse(teksWaktu);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '--:--'; // Fallback jika format teks tidak valid.
    }
  }
}

/// Kelas utilitas untuk pemformatan mata uang.
class FormatUang {
  // Konstruktor privat untuk mencegah instansiasi.
  FormatUang._();

  /// Memformat angka [double] menjadi format mata uang Rupiah ("Rp 50.000").
  static String formatMataUang(double jumlah) {
    // Kembali ke implementasi standar yang menghasilkan format -Rp XX.XXX
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0, // Rupiah tidak menggunakan desimal.
    );
    return formatter.format(jumlah);
  }
}
