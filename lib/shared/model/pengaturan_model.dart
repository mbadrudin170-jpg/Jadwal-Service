// path: lib/shared/model/pengaturan_model.dart
// diubah: Menghapus logika timestamp dari toSqlite() untuk memindahkan tanggung jawab ke lapisan operasi.
// diubah: Menambahkan metode `copyWith` untuk memungkinkan pembaruan properti secara immutable.
// Ini memperbaiki error `undefined_method` yang terjadi di `PengaturanOperasi`.
// diubah: Menggunakan konstanta `idPengaturanGlobal` secara konsisten di semua factory constructor.

import 'package:cloud_firestore/cloud_firestore.dart';

const String idPengaturanGlobal = 'konfigurasi_global';

class PengaturanModel {
  final String id;
  final int intervalSinkronisasiOtomatis;
  final int hapusOtomatisDataArsip;
  final bool modePemeliharaan;
  final String infoPemeliharaan;
  final DateTime? diperbarui;

  PengaturanModel({
    this.id = idPengaturanGlobal,
    this.intervalSinkronisasiOtomatis = 24,
    this.hapusOtomatisDataArsip = 30,
    this.modePemeliharaan = false,
    this.infoPemeliharaan = '',
    this.diperbarui,
  });

  PengaturanModel copyWith({
    String? id,
    int? intervalSinkronisasiOtomatis,
    int? hapusOtomatisDataArsip,
    bool? modePemeliharaan,
    String? infoPemeliharaan,
    DateTime? diperbarui,
  }) {
    return PengaturanModel(
      id: id ?? this.id,
      intervalSinkronisasiOtomatis:
          intervalSinkronisasiOtomatis ?? this.intervalSinkronisasiOtomatis,
      hapusOtomatisDataArsip:
          hapusOtomatisDataArsip ?? this.hapusOtomatisDataArsip,
      modePemeliharaan: modePemeliharaan ?? this.modePemeliharaan,
      infoPemeliharaan: infoPemeliharaan ?? this.infoPemeliharaan,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // =========================
  // SQLITE
  // =========================

  factory PengaturanModel.fromSqlite(Map<String, dynamic> map) {
    return PengaturanModel(
      id: idPengaturanGlobal,
      intervalSinkronisasiOtomatis:
          map['interval_sinkronisasi_otomatis'] as int? ?? 24,
      hapusOtomatisDataArsip: map['hapus_otomatis_data_arsip'] as int? ?? 30,
      modePemeliharaan: (map['mode_pemeliharaan'] as int? ?? 0) == 1,
      infoPemeliharaan: map['info_pemeliharaan'] as String? ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan ? 1 : 0,
      'info_pemeliharaan': infoPemeliharaan,
      // diubah: `diperbarui` sekarang diatur oleh lapisan operasi, bukan di sini.
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory PengaturanModel.fromFirebase(Map<String, dynamic> data) {
    return PengaturanModel(
      id: data['id'] as String? ?? idPengaturanGlobal,
      intervalSinkronisasiOtomatis:
          data['interval_sinkronisasi_otomatis'] as int? ?? 24,
      hapusOtomatisDataArsip: data['hapus_otomatis_data_arsip'] as int? ?? 30,
      modePemeliharaan: data['mode_pemeliharaan'] as bool? ?? false,
      infoPemeliharaan: data['info_pemeliharaan'] as String? ?? '',
      diperbarui: _parseDateTime(data['diperbarui']),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': FieldValue.serverTimestamp(),
    };
  }
}
