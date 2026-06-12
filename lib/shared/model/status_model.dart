// path: lib/shared/model/status_model.dart
// diubah: Menggunakan ParserUtil untuk konsistensi parsing dan .toUtc() untuk penyimpanan.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Global ID for the status document.
const String globalStatusId = 'global_status';

/// Model representing a simple status with an update timestamp.
class StatusModel implements HasId {
  @override
  final String id;

  /// The timestamp of the last update.
  final DateTime updatedAt;
  StatusModel({
    this.id = globalStatusId,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  StatusModel copyWith({
    final String? id,
    final DateTime? updatedAt,
  }) {
    return StatusModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StatusModel.fromSqlite(
    final Map<String, dynamic> map,
  ) {
    return StatusModel(
      id: map[NamaKolom.id] as String? ?? globalStatusId,
      updatedAt: ParserUtil.parseDateTime(
            map[NamaKolom.updatedAt],
          ) ??
          DateTime.now(),
    );
  }

  /// Converts `StatusModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.updatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a `StatusModel` instance from Firebase map data.
  factory StatusModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating StatusModel from Firebase');
    return StatusModel(
      id: data[NamaKolom.id] as String? ?? globalStatusId,
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.updatedAt]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.updatedAt: Timestamp.fromDate(updatedAt.toUtc()),
    };
  }
}
