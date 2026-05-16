// path: lib/shared/model/settings_model.dart
// new file: Refactored from pengaturan_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Global ID for the settings document.
const String globalSettingsId = 'global_config';

/// Model for application settings.
class SettingsModel implements HasId {
  @override
  final String id;

  /// The interval in hours for auto-sync.
  final int autoSyncInterval;

  /// The number of days after which archived data is auto-deleted.
  final int autoDeleteArchiveDays;

  /// A flag indicating if the application is in maintenance mode.
  final bool maintenanceMode;

  /// Information about the maintenance mode.
  final String maintenanceInfo;

  /// The timestamp of the last update.
  final DateTime? updatedAt;

  /// Constructor for `SettingsModel`.
  SettingsModel({
    this.id = globalSettingsId,
    this.autoSyncInterval = 24,
    this.autoDeleteArchiveDays = 30,
    this.maintenanceMode = false,
    this.maintenanceInfo = '',
    this.updatedAt,
  });

  /// Creates a copy of this `SettingsModel` with some modified values.
  SettingsModel copyWith({
    final String? id,
    final int? autoSyncInterval,
    final int? autoDeleteArchiveDays,
    final bool? maintenanceMode,
    final String? maintenanceInfo,
    final DateTime? updatedAt,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
      autoDeleteArchiveDays:
          autoDeleteArchiveDays ?? this.autoDeleteArchiveDays,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceInfo: maintenanceInfo ?? this.maintenanceInfo,
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

  /// Creates a `SettingsModel` instance from SQLite map data.
  factory SettingsModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating SettingsModel from SQLite');
    return SettingsModel(
      autoSyncInterval: map[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays:
          map[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: (map[ColumnNames.maintenanceMode] as int? ?? 0) == 1,
      maintenanceInfo: map[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode ? 1 : 0,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a `SettingsModel` instance from Firebase map data.
  factory SettingsModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating SettingsModel from Firebase');
    return SettingsModel(
      id: data[ColumnNames.id] as String? ?? globalSettingsId,
      autoSyncInterval: data[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays: data[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: data[ColumnNames.maintenanceMode] as bool? ?? false,
      maintenanceInfo: data[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
    };
  }
}
