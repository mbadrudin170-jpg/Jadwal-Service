// path: lib/shared/model/versi_apk_user_model.dart
// diubah: Penamaan metode diseragamkan, logika Firebase disesuaikan, impor enum diperbaiki, dan mengimplementasikan MemilikiId.
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// Model yang merepresentasikan informasi versi aplikasi untuk pengguna.
class VersiApkUserModel implements MemilikiId {
  /// ID unik untuk setiap entri versi.
  @override
  final String id;

  /// Catatan rilis atau changelog untuk versi ini.
  final String catatanRilis;

  /// Peta yang berisi nomor build untuk setiap arsitektur APK.
  final Map<ArsitekturApkEnum, int> nomorBuildTerbaru;

  /// Peta yang berisi tautan unduhan untuk setiap arsitektur APK.
  final Map<ArsitekturApkEnum, String> tautanUnduhan;

  /// Nomor versi yang ditampilkan kepada pengguna, contoh: "1.0.2".
  final String versiTerbaru;

  /// Menandakan apakah pembaruan ke versi ini bersifat wajib.
  final bool wajibUpdate;

  /// Tautan ke video tutorial YouTube yang relevan dengan versi ini.
  final String youtubeTutorial;

  /// Penanda soft delete.
  final bool isDeleted;

  /// Timestamp kapan versi ini diarsipkan.
  final DateTime? diarsipkan;

  /// Timestamp kapan versi ini terakhir diperbarui.
  final DateTime? diperbarui;

  /// Konstruktor untuk membuat instance `VersiApkUserModel`.
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
  // =========================
  /// Mengubah model menjadi Map JSON untuk keperluan logging.
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
  /// Factory constructor untuk membuat `VersiApkUserModel` dari data SQLite.
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

  /// Mengubah model menjadi Map untuk disimpan di database SQLite.
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
// TODO: tugas selanjutnya adalah merubah semua data yang disimpan ke sqlite kolom  tanggal diubah  ke millisecondsSinceEpoch, dan menyesuaikan tipe nya dengan sqlite.dart

  // =========================
  // FIREBASE
  // =========================
  /// Factory constructor untuk membuat `VersiApkUserModel` dari data Firebase.
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

  /// Mengubah model menjadi Map untuk disimpan di Firestore.
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

  /// Helper untuk mem-parsing `DateTime` dari berbagai format.
  static DateTime? _parseDateTime(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  /// Nilai default untuk `nomorBuildTerbaru`.
  static const Map<ArsitekturApkEnum, int> defaultNomorBuildTerbaru = {
    ArsitekturApkEnum.bit_32: 0,
    ArsitekturApkEnum.bit_64: 0,
    ArsitekturApkEnum.universal: 0,
  };

  /// Nilai default untuk `tautanUnduhan`.
  static const Map<ArsitekturApkEnum, String> defaultTautanUnduhan = {
    ArsitekturApkEnum.bit_32: '',
    ArsitekturApkEnum.bit_64: '',
    ArsitekturApkEnum.universal: '',
  };

  /// Helper untuk mengonversi String menjadi `ArsitekturApkEnum`.
  static ArsitekturApkEnum? _arsitekturDariString(String value) {
    try {
      return ArsitekturApkEnum.values.firstWhere((e) => e.name == value);
    } on Exception catch (_) {
      return null;
    }
  }

  /// Helper untuk mem-parsing data nomor build dari format Map atau JSON String.
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
      } on Exception catch (e) {
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

  /// Helper untuk mem-parsing data tautan unduhan dari format Map atau JSON String.
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
      } on Exception catch (e) {
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

  /// Membuat salinan dari instance `VersiApkUserModel` dengan beberapa nilai yang diubah.
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
