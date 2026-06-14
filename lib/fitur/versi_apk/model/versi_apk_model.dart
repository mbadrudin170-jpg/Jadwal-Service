// path: lib/fitur/versi_apk/model/versi_apk_model.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Model representing application version information for the user.
class VersiApkModel implements HasId {
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
  VersiApkModel({
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
  VersiApkModel copyWith({
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
    return VersiApkModel(
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
  // HELPERS (DIHAPUS: _parseDateTime)
  // =========================

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
        Log.error('Failed to parse build number JSON', e: e, s: st);
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
        Log.error('Failed to parse download links JSON', e: e, s: st);
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
  factory VersiApkModel.fromSqlite(final Map<String, dynamic> map) {
    return VersiApkModel(
      id: map[NamaKolom.id] as String? ?? '',
      releaseNotes: map[NamaKolom.catatanRilis] as String? ?? '',
      latestVersion: map[NamaKolom.versiTerkahir] as String? ?? '',
      youtubeTutorial: map[NamaKolom.linkYoutubeTutorial] as String? ?? '',
      // DIUBAH: Menggunakan ParserUtil
      isUpdateRequired: ParserUtil.parseBool(map[NamaKolom.wajibUpdate]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      latestBuildNumber: _parseBuildNumber(map[NamaKolom.nomorBuildTerakhir]),
      downloadLinks: _parseDownloadLinks(map[NamaKolom.linkDownload]),
      // DIUBAH: Menggunakan ParserUtil
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  /// Converts the model to a Map for SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.catatanRilis: releaseNotes,
      NamaKolom.versiTerkahir: latestVersion,
      NamaKolom.linkYoutubeTutorial: youtubeTutorial,
      // DIUBAH: Memastikan konsistensi
      NamaKolom.diarsipkanPada: archivedAt?.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.nomorBuildTerakhir: jsonEncode(
        latestBuildNumber
            .map((final key, final value) => MapEntry(key.name, value)),
      ),
      NamaKolom.linkDownload: jsonEncode(
        downloadLinks
            .map((final key, final value) => MapEntry(key.name, value)),
      ),
      NamaKolom.wajibUpdate: isUpdateRequired ? 1 : 0,
      NamaKolom.diHapus: isDeleted ? 1 : 0,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  /// Factory to create `ApkVersionModel` from Firebase data.
  factory VersiApkModel.fromFirebase(
      final String id, final Map<String, dynamic> map) {
    return VersiApkModel(
      id: id,
      releaseNotes: map[NamaKolom.catatanRilis] as String? ?? '',
      latestVersion: map[NamaKolom.versiTerkahir] as String? ?? '',
      youtubeTutorial: map[NamaKolom.linkYoutubeTutorial] as String? ?? '',
      isUpdateRequired: ParserUtil.parseBool(map[NamaKolom.wajibUpdate]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      latestBuildNumber: _parseBuildNumber(map[NamaKolom.nomorBuildTerakhir]),
      downloadLinks: _parseDownloadLinks(map[NamaKolom.linkDownload]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  /// Converts the model to a Map for Firestore.
  Map<String, dynamic> toFirebase() {
    return {
      // DIUBAH: 'id' tidak seharusnya menjadi bagian dari data dokumen
      NamaKolom.catatanRilis: releaseNotes,
      NamaKolom.versiTerkahir: latestVersion,
      NamaKolom.linkYoutubeTutorial: youtubeTutorial,
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      NamaKolom.diarsipkanPada:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
      NamaKolom.nomorBuildTerakhir: latestBuildNumber.map(
        (final key, final value) => MapEntry(key.name, value),
      ),
      NamaKolom.linkDownload: downloadLinks.map(
        (final key, final value) => MapEntry(key.name, value),
      ),
      NamaKolom.wajibUpdate: isUpdateRequired,
      NamaKolom.diHapus: isDeleted,
    };
  }
}
