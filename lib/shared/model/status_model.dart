// path: lib/shared/model/status_model.dart
// new file: Refactored to align with the project's standard model structure.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

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

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Creates a `StatusModel` instance from SQLite map data.
  factory StatusModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating StatusModel from SQLite');
    return StatusModel(
      id: map[ColumnNames.id] as String? ?? globalStatusId,
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts `StatusModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a `StatusModel` instance from Firebase map data.
  factory StatusModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating StatusModel from Firebase');
    return StatusModel(
      id: data[ColumnNames.id] as String? ?? globalStatusId,
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
    );
  }

  /// Converts `StatusModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
    };
  }
}
