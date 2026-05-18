// path: lib/shared/model/status_model.dart
// diubah: Menggunakan ParserUtil untuk konsistensi parsing dan .toUtc() untuk penyimpanan.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
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
  final DateTime? updatedAt;

  /// Constructor for `StatusModel`.
  StatusModel({
    this.id = globalStatusId,
    this.updatedAt,
  });

  /// Creates a copy of this `StatusModel` with some modified values.
  StatusModel copyWith({
    final String? id,
    final DateTime? updatedAt,
  }) {
    return StatusModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // DIHAPUS: Helper parsing internal dipindahkan ke ParserUtil

  /// Creates a `StatusModel` instance from SQLite map data.
  factory StatusModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating StatusModel from SQLite');
    return StatusModel(
      id: map[ColumnNames.id] as String? ?? globalStatusId,
      // DIUBAH: Menggunakan ParserUtil
      updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts `StatusModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      // DIUBAH: Memastikan updatedAt tidak pernah null
      ColumnNames.updatedAt: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  /// Creates a `StatusModel` instance from Firebase map data.
  factory StatusModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating StatusModel from Firebase');
    return StatusModel(
      id: data[ColumnNames.id] as String? ?? globalStatusId,
      // DIUBAH: Menggunakan ParserUtil
      updatedAt: ParserUtil.parseDateTime(data[ColumnNames.updatedAt]),
    );
  }

  /// Converts `StatusModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      // DIUBAH: Memastikan updatedAt tidak pernah null dan menggunakan .toUtc()
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
    };
  }
}
