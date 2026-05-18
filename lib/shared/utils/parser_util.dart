// path: lib/shared/utils/parser_util.dart
// baru: File utilitas untuk parsing data secara konsisten.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas utilitas untuk mengurai (parse) tipe data dari format yang beragam.
///
/// Memusatkan logika parsing untuk memastikan konsistensi di seluruh model
/// saat mengonversi data dari Firestore (Timestamp), SQLite (int), atau JSON (String).
class ParserUtil {
  // Mencegah class ini diinstansiasi.
  ParserUtil._();

  /// Mengurai nilai dinamis menjadi [DateTime].
  ///
  /// Menerima [Timestamp] dari Firestore, [int] (millisecondsSinceEpoch) dari SQLite,
  /// [String] (ISO 8601), atau [DateTime] yang sudah ada.
  /// Akan mengembalikan waktu dalam zona waktu lokal perangkat.
  static DateTime? parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);

    // Jika format tidak dikenali, catat sebagai peringatan.
    Log.warning('Format DateTime tidak dikenali: $value');
    return null;
  }

  /// Mengurai nilai dinamis menjadi [bool].
  ///
  /// Menerima [bool] asli, [int] (1 untuk true, lainnya false),
  /// atau [String] ('true', case-insensitive).
  static bool parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';

    // Jika format tidak dikenali, anggap false.
    Log.warning('Format bool tidak dikenali: $value, dianggap false.');
    return false;
  }
}
