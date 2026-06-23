// path: lib/shared/utils/parser_util.dart
// baru: File utilitas untuk parsing data secara konsisten.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';

class ParserUtil {
  // Mencegah class ini diinstansiasi.
  ParserUtil._();

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);

    // Jika format tidak dikenali, catat sebagai peringatan.
    Log.warning('Format DateTime tidak dikenali: $value');
    return null;
  }

  static bool parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lowered = value.toLowerCase();
      return lowered == 'true' || lowered == '1';
    }
    // Jika format tidak dikenali, anggap false.
    Log.warning('Format bool tidak dikenali: $value, dianggap false.');
    return false;
  }

  static T? safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null || name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    Log.warning('Gagal mengurai enum untuk tipe $T', name);
    return null;
  }
}
