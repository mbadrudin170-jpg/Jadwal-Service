// path: lib/fitur/versi_apk/model/versi_apk_model.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'versi_apk_model.freezed.dart';

@freezed
abstract class VersiApkModel with _$VersiApkModel implements HasId {
  const VersiApkModel._(); // Private constructor untuk method custom

  const factory VersiApkModel({
    required String id,
    @Default('') String catatanRilis,
    @Default(<ArsitekturApk, int>{}) Map<ArsitekturApk, int> nomorBuildTerakhir,
    @Default(<ArsitekturApk, String>{}) Map<ArsitekturApk, String> linkDownload,
    @Default('') String versiTerkahir,
    @Default(false) bool wajibUpdate,
    @Default('') String linkYoutubeTutorial,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? diperbaruiPada,
  }) = _VersiApkModel;

  // =========================
  // HELPERS
  // =========================

  static ArsitekturApk? _architectureFromString(String? value) {
    if (value == null) return null;
    for (final val in ArsitekturApk.values) {
      if (val.name == value) {
        return val;
      }
    }
    return null;
  }

  static Map<ArsitekturApk, int> _parseBuildNumber(dynamic data) {
    final result = <ArsitekturApk, int>{};
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

  static Map<ArsitekturApk, String> _parseDownloadLinks(dynamic data) {
    final result = <ArsitekturApk, String>{};
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

  factory VersiApkModel.fromSqlite(Map<String, dynamic> map) {
    return VersiApkModel(
      id: map[NamaKolom.id] as String,
      catatanRilis: map[NamaKolom.catatanRilis] as String? ?? '',
      versiTerkahir: map[NamaKolom.versiTerkahir] as String? ?? '',
      linkYoutubeTutorial: map[NamaKolom.linkYoutubeTutorial] as String? ?? '',
      wajibUpdate: ParserUtil.parseBool(map[NamaKolom.wajibUpdate]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      nomorBuildTerakhir: _parseBuildNumber(map[NamaKolom.nomorBuildTerakhir]),
      linkDownload: _parseDownloadLinks(map[NamaKolom.linkDownload]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.catatanRilis: catatanRilis,
      NamaKolom.versiTerkahir: versiTerkahir,
      NamaKolom.linkYoutubeTutorial: linkYoutubeTutorial,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.nomorBuildTerakhir: jsonEncode(
        nomorBuildTerakhir.map((key, value) => MapEntry(key.name, value)),
      ),
      NamaKolom.linkDownload: jsonEncode(
        linkDownload.map((key, value) => MapEntry(key.name, value)),
      ),
      NamaKolom.wajibUpdate: wajibUpdate ? 1 : 0,
      NamaKolom.dihapus: diHapus ? 1 : 0,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory VersiApkModel.fromFirebase(String id, Map<String, dynamic> map) {
    return VersiApkModel(
      id: id,
      catatanRilis: map[NamaKolom.catatanRilis] as String? ?? '',
      versiTerkahir: map[NamaKolom.versiTerkahir] as String? ?? '',
      linkYoutubeTutorial: map[NamaKolom.linkYoutubeTutorial] as String? ?? '',
      wajibUpdate: ParserUtil.parseBool(map[NamaKolom.wajibUpdate]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      nomorBuildTerakhir: _parseBuildNumber(map[NamaKolom.nomorBuildTerakhir]),
      linkDownload: _parseDownloadLinks(map[NamaKolom.linkDownload]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.catatanRilis: catatanRilis,
      NamaKolom.versiTerkahir: versiTerkahir,
      NamaKolom.linkYoutubeTutorial: linkYoutubeTutorial,
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((diperbaruiPada ?? DateTime.now()).toUtc()),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
      NamaKolom.nomorBuildTerakhir: nomorBuildTerakhir.map(
        (key, value) => MapEntry(key.name, value),
      ),
      NamaKolom.linkDownload: linkDownload.map(
        (key, value) => MapEntry(key.name, value),
      ),
      NamaKolom.wajibUpdate: wajibUpdate,
      NamaKolom.dihapus: diHapus,
    };
  }
}
