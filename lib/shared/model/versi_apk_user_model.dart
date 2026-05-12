// path: lib/model/versi_apk_user_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase disesuaikan.
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/enum/enum.dart';

class VersiApkUserModel {
  final String id;
  final String catatanRilis;
  final Map<ArsitekturApkEnum, int> nomorBuildTerbaru;
  final Map<ArsitekturApkEnum, String> tautanUnduhan;
  final String versiTerbaru;
  final bool wajibUpdate;
  final String youtubeTutorial;
  final bool isDeleted;
  final DateTime? diarsipkan;
  final DateTime? diperbarui;

  VersiApkUserModel({
    required this.id,
    this.catatanRilis = '',
    this.nomorBuildTerbaru = defaultNomorBuildTerbaru,
    this.tautanUnduhan = defaultTautanUnduhan,
    this.versiTerbaru = '',
    this.wajibUpdate = false,
    this.youtubeTutorial = '',
    this.isDeleted = false,
    this.diarsipkan,
    this.diperbarui,
  });

  // =========================
  // JSON SERIALIZATION (FOR LOGGING)
  // ditambahkan: karena butuh serialisasi untuk logging
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catatanRilis': catatanRilis,
      'nomorBuildTerbaru':
          nomorBuildTerbaru.map((key, value) => MapEntry(key.name, value)),
      'tautanUnduhan':
          tautanUnduhan.map((key, value) => MapEntry(key.name, value)),
      'versiTerbaru': versiTerbaru,
      'wajibUpdate': wajibUpdate,
      'youtubeTutorial': youtubeTutorial,
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }

  // =========================
  // SQLITE
  // =========================
  factory VersiApkUserModel.fromSqlite(Map<String, dynamic> map) {
    return VersiApkUserModel(
      id: map['id'] as String? ?? '',
      catatanRilis: map['catatan_rilis'] as String? ?? '',
      versiTerbaru: map['versi_terbaru'] as String? ?? '',
      youtubeTutorial: map['youtube_tutorial'] as String? ?? '',
      wajibUpdate: map['wajib_update'] == 1,
      isDeleted: map['isDeleted'] == 1,
      nomorBuildTerbaru: _parseNomorBuild(map['nomor_build_terbaru']),
      tautanUnduhan: _parseTautanUnduhan(map['tautan_unduhan']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'catatan_rilis': catatanRilis,
      'versi_terbaru': versiTerbaru,
      'youtube_tutorial': youtubeTutorial,
      'diarsipkan': diarsipkan?.toIso8601String(),
      'diperbarui': diperbarui?.toIso8601String(),
      'nomor_build_terbaru': jsonEncode(
        nomorBuildTerbaru.map((key, value) => MapEntry(key.name, value)),
      ),
      'tautan_unduhan': jsonEncode(
        tautanUnduhan.map((key, value) => MapEntry(key.name, value)),
      ),
      'wajib_update': wajibUpdate ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  // =========================
  // FIREBASE
  // =========================
  factory VersiApkUserModel.fromFirebase(String id, Map<String, dynamic> map) {
    return VersiApkUserModel(
      id: id,
      catatanRilis: map['catatan_rilis'] as String? ?? '',
      versiTerbaru: map['versi_terbaru'] as String? ?? '',
      youtubeTutorial: map['youtube_tutorial'] as String? ?? '',
      wajibUpdate: map['wajib_update'] == true,
      isDeleted: map['isDeleted'] == true,
      nomorBuildTerbaru: _parseNomorBuild(map['nomor_build_terbaru']),
      tautanUnduhan: _parseTautanUnduhan(map['tautan_unduhan']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'catatan_rilis': catatanRilis,
      'versi_terbaru': versiTerbaru,
      'youtube_tutorial': youtubeTutorial,
      'diperbarui': FieldValue.serverTimestamp(),
      if (diarsipkan != null) 'diarsipkan': Timestamp.fromDate(diarsipkan!),
      'nomor_build_terbaru': nomorBuildTerbaru.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'tautan_unduhan': tautanUnduhan.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'wajib_update': wajibUpdate,
      'isDeleted': isDeleted,
    };
  }

  // =========================
  // HELPERS
  // =========================

  static DateTime? _parseDateTime(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  static const Map<ArsitekturApkEnum, int> defaultNomorBuildTerbaru = {
    ArsitekturApkEnum.bit_32: 0,
    ArsitekturApkEnum.bit_64: 0,
    ArsitekturApkEnum.universal: 0,
  };

  static const Map<ArsitekturApkEnum, String> defaultTautanUnduhan = {
    ArsitekturApkEnum.bit_32: '',
    ArsitekturApkEnum.bit_64: '',
    ArsitekturApkEnum.universal: '',
  };

  static ArsitekturApkEnum? _arsitekturDariString(String value) {
    try {
      return ArsitekturApkEnum.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  static Map<ArsitekturApkEnum, int> _parseNomorBuild(dynamic data) {
    final hasil = <ArsitekturApkEnum, int>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          mapData = decoded;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Gagal parse nomor build: $e');
        }
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final arsitektur = _arsitekturDariString(item.key.toString());
        if (arsitektur != null) {
          hasil[arsitektur] =
              item.value is num ? (item.value as num).toInt() : 0;
        }
      }
    }

    return {...defaultNomorBuildTerbaru, ...hasil};
  }

  static Map<ArsitekturApkEnum, String> _parseTautanUnduhan(dynamic data) {
    final hasil = <ArsitekturApkEnum, String>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          mapData = decoded;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Gagal parse tautan unduhan: $e');
        }
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final arsitektur = _arsitekturDariString(item.key.toString());
        if (arsitektur != null) {
          hasil[arsitektur] = item.value?.toString() ?? '';
        }
      }
    }

    return {...defaultTautanUnduhan, ...hasil};
  }

  VersiApkUserModel copyWith({
    String? id,
    String? catatanRilis,
    Map<ArsitekturApkEnum, int>? nomorBuildTerbaru,
    Map<ArsitekturApkEnum, String>? tautanUnduhan,
    String? versiTerbaru,
    bool? wajibUpdate,
    String? youtubeTutorial,
    bool? isDeleted,
    DateTime? diarsipkan,
    DateTime? diperbarui,
  }) {
    return VersiApkUserModel(
      id: id ?? this.id,
      catatanRilis: catatanRilis ?? this.catatanRilis,
      nomorBuildTerbaru: nomorBuildTerbaru ?? this.nomorBuildTerbaru,
      tautanUnduhan: tautanUnduhan ?? this.tautanUnduhan,
      versiTerbaru: versiTerbaru ?? this.versiTerbaru,
      wajibUpdate: wajibUpdate ?? this.wajibUpdate,
      youtubeTutorial: youtubeTutorial ?? this.youtubeTutorial,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
