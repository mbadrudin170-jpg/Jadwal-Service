// path: lib/shared/model/settings_model.dart
// diubah: Menggunakan ParserUtil untuk konsistensi parsing dan .toUtc() untuk penyimpanan.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Global ID for the settings document.
const String idGlobalSetting = 'global_config';

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
    this.id = idGlobalSetting,
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
      autoSyncInterval: map[NamaKolom.waktuOtomatisSinkroniasi] as int? ?? 24,
      autoDeleteArchiveDays:
          map[NamaKolom.waktuOtomatisHapusDataArsip] as int? ?? 30,
      maintenanceMode: ParserUtil.parseBool(map[NamaKolom.modeMaintenance]),
      maintenanceInfo: map[NamaKolom.infoMaintenance] as String? ?? '',
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  /// Converts `SettingsModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.waktuOtomatisSinkroniasi: autoSyncInterval,
      NamaKolom.waktuOtomatisHapusDataArsip: autoDeleteArchiveDays,
      NamaKolom.modeMaintenance: maintenanceMode ? 1 : 0,
      NamaKolom.infoMaintenance: maintenanceInfo,
      NamaKolom.diperbaruiPada: updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a `SettingsModel` instance from Firebase map data.
  factory SettingsModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating SettingsModel from Firebase');
    return SettingsModel(
      id: data[NamaKolom.id] as String? ?? idGlobalSetting,
      autoSyncInterval: data[NamaKolom.waktuOtomatisSinkroniasi] as int? ?? 24,
      autoDeleteArchiveDays:
          data[NamaKolom.waktuOtomatisHapusDataArsip] as int? ?? 30,
      maintenanceMode: ParserUtil.parseBool(data[NamaKolom.modeMaintenance]),
      maintenanceInfo: data[NamaKolom.infoMaintenance] as String? ?? '',
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  /// Converts `SettingsModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.waktuOtomatisSinkroniasi: autoSyncInterval,
      NamaKolom.waktuOtomatisHapusDataArsip: autoDeleteArchiveDays,
      NamaKolom.modeMaintenance: maintenanceMode,
      NamaKolom.infoMaintenance: maintenanceInfo,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(updatedAt.toUtc()),
    };
  }
}
