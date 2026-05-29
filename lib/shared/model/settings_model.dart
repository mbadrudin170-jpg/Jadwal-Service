// path: lib/shared/model/settings_model.dart
// diubah: Menggunakan ParserUtil untuk konsistensi parsing dan .toUtc() untuk penyimpanan.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

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
  final DateTime updatedAt;

  /// Constructor for `SettingsModel`.
  SettingsModel({
    this.id = globalSettingsId,
    this.autoSyncInterval = 24,
    this.autoDeleteArchiveDays = 30,
    this.maintenanceMode = false,
    this.maintenanceInfo = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

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

  // DIHAPUS: Helper parsing internal dipindahkan ke ParserUtil

  /// Creates a `SettingsModel` instance from SQLite map data.
  factory SettingsModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating SettingsModel from SQLite');
    return SettingsModel(
      autoSyncInterval: map[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays:
          map[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: ParserUtil.parseBool(map[ColumnNames.maintenanceMode]),
      maintenanceInfo: map[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]),
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
      ColumnNames.updatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a `SettingsModel` instance from Firebase map data.
  factory SettingsModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating SettingsModel from Firebase');
    return SettingsModel(
      id: data[ColumnNames.id] as String? ?? globalSettingsId,
      autoSyncInterval: data[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays:
          data[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: ParserUtil.parseBool(data[ColumnNames.maintenanceMode]),
      maintenanceInfo: data[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: ParserUtil.parseDateTime(data[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt: Timestamp.fromDate(updatedAt.toUtc()),
    };
  }
}
