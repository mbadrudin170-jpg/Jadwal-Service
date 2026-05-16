// path: lib/shared/model/apk_version_model.dart
// new file: Refactored from user_apk_version_model.dart to use English naming and proper structure.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model representing application version information for the user.
class ApkVersionModel implements HasId {
  @override
  final String id;

  /// Release notes or changelog for this version.
  final String releaseNotes;

  /// A map containing the latest build number for each APK architecture.
  final Map<ApkArchitectureEnum, int> latestBuildNumber;

  /// A map containing the download link for each APK architecture.
  final Map<ApkArchitectureEnum, String> downloadLinks;

  /// The user-facing version number, e.g., "1.0.2".
  final String latestVersion;

  /// Indicates whether updating to this version is mandatory.
  final bool isUpdateRequired;

  /// Link to a relevant YouTube tutorial for this version.
  final String youtubeTutorial;

  /// Soft delete flag.
  final bool isDeleted;

  /// Timestamp when this version was archived.
  final DateTime? archivedAt;

  /// Timestamp when this version was last updated.
  final DateTime? updatedAt;

  /// Constructor for creating an instance of `ApkVersionModel`.
  ApkVersionModel({
    final String? id,
    this.releaseNotes = '',
    this.latestBuildNumber = const {},
    this.downloadLinks = const {},
    this.latestVersion = '',
    this.isUpdateRequired = false,
    this.youtubeTutorial = '',
    this.isDeleted = false,
    this.archivedAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  /// Creates a copy of this model with updated values.
  ApkVersionModel copyWith({
    final String? id,
    final String? releaseNotes,
    final Map<ApkArchitectureEnum, int>? latestBuildNumber,
    final Map<ApkArchitectureEnum, String>? downloadLinks,
    final String? latestVersion,
    final bool? isUpdateRequired,
    final String? youtubeTutorial,
    final bool? isDeleted,
    final DateTime? archivedAt,
    final DateTime? updatedAt,
  }) {
    return ApkVersionModel(
      id: id ?? this.id,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      latestBuildNumber: latestBuildNumber ?? this.latestBuildNumber,
      downloadLinks: downloadLinks ?? this.downloadLinks,
      latestVersion: latestVersion ?? this.latestVersion,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      youtubeTutorial: youtubeTutorial ?? this.youtubeTutorial,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================
  // HELPERS
  // =========================

  /// Helper to parse `DateTime` from various formats.
  static DateTime? _parseDateTime(final dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return null;
  }

  /// Helper to convert a String to an `ApkArchitectureEnum` enum.
  static ApkArchitectureEnum? _architectureFromString(final String? value) {
    if (value == null) return null;
    for (final val in ApkArchitectureEnum.values) {
      if (val.name == value) {
        return val;
      }
    }
    return null;
  }

  /// Helper to parse build number data from a Map or JSON String.
  static Map<ApkArchitectureEnum, int> _parseBuildNumber(final dynamic data) {
    final result = <ApkArchitectureEnum, int>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) mapData = decoded;
      } on FormatException catch (e, st) {
        Log.error('Failed to parse build number JSON', e: e, st: st);
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final architecture = _architectureFromString(item.key.toString());
        if (architecture != null) {
          result[architecture] =
              item.value is num ? (item.value as num).toInt() : 0;
        }
      }
    }

    return result;
  }

  /// Helper to parse download link data from a Map or JSON String.
  static Map<ApkArchitectureEnum, String> _parseDownloadLinks(
      final dynamic data) {
    final result = <ApkArchitectureEnum, String>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) mapData = decoded;
      } on FormatException catch (e, st) {
        Log.error('Failed to parse download links JSON', e: e, st: st);
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final architecture = _architectureFromString(item.key.toString());
        if (architecture != null) {
          result[architecture] = item.value?.toString() ?? '';
        }
      }
    }

    return result;
  }

  // =========================
  // SQLITE
  // =========================

  /// Factory to create `ApkVersionModel` from SQLite data.
  factory ApkVersionModel.fromSqlite(final Map<String, dynamic> map) {
    return ApkVersionModel(
      id: map[ColumnNames.id] as String? ?? '',
      releaseNotes: map[ColumnNames.releaseNotes] as String? ?? '',
      latestVersion: map[ColumnNames.latestVersion] as String? ?? '',
      youtubeTutorial: map[ColumnNames.youtubeTutorial] as String? ?? '',
      isUpdateRequired: (map[ColumnNames.isUpdateRequired] as int? ?? 0) == 1,
      isDeleted: (map[ColumnNames.isDeleted] as int? ?? 0) == 1,
      latestBuildNumber:
          _parseBuildNumber(map[ColumnNames.latestBuildNumber]),
      downloadLinks: _parseDownloadLinks(map[ColumnNames.downloadLinks]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts the model to a Map for SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.releaseNotes: releaseNotes,
      ColumnNames.latestVersion: latestVersion,
      ColumnNames.youtubeTutorial: youtubeTutorial,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.latestBuildNumber: jsonEncode(
        latestBuildNumber.map((final key, final value) => MapEntry(key.name, value)),
      ),
      ColumnNames.downloadLinks: jsonEncode(
        downloadLinks.map((final key, final value) => MapEntry(key.name, value)),
      ),
      ColumnNames.isUpdateRequired: isUpdateRequired ? 1 : 0,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  /// Factory to create `ApkVersionModel` from Firebase data.
  factory ApkVersionModel.fromFirebase(
      final String id, final Map<String, dynamic> map) {
    return ApkVersionModel(
      id: id,
      releaseNotes: map[ColumnNames.releaseNotes] as String? ?? '',
      latestVersion: map[ColumnNames.latestVersion] as String? ?? '',
      youtubeTutorial: map[ColumnNames.youtubeTutorial] as String? ?? '',
      isUpdateRequired: map[ColumnNames.isUpdateRequired] as bool? ?? false,
      isDeleted: map[ColumnNames.isDeleted] as bool? ?? false,
      latestBuildNumber:
          _parseBuildNumber(map[ColumnNames.latestBuildNumber]),
      downloadLinks: _parseDownloadLinks(map[ColumnNames.downloadLinks]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts the model to a Map for Firestore.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.releaseNotes: releaseNotes,
      ColumnNames.latestVersion: latestVersion,
      ColumnNames.youtubeTutorial: youtubeTutorial,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      if (archivedAt != null)
        ColumnNames.archivedAt: Timestamp.fromDate(archivedAt!),
      ColumnNames.latestBuildNumber: latestBuildNumber.map(
        (final key, final value) => MapEntry(key.name, value),
      ),
      ColumnNames.downloadLinks: downloadLinks.map(
        (final key, final value) => MapEntry(key.name, value),
      ),
      ColumnNames.isUpdateRequired: isUpdateRequired,
      ColumnNames.isDeleted: isDeleted,
    };
  }
}
