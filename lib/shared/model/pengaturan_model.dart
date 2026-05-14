// path: lib/shared/model/pengaturan_model.dart
// diubah: Menghapus logika timestamp dari toSqlite() untuk memindahkan tanggung jawab ke lapisan operasi.
// diubah: Menambahkan metode `copyWith` untuk memungkinkan pembaruan properti secara immutable.
// Ini memperbaiki error `undefined_method` yang terjadi di `PengaturanOperasi`.
// diubah: Menggunakan konstanta `idPengaturanGlobal` secara konsisten di semua factory constructor.
// diubah: Mengimplementasikan MemilikiId untuk konsistensi dengan unggah data generik.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// ID global untuk dokumen pengaturan.
const String idPengaturanGlobal = 'konfigurasi_global';

/// Model untuk pengaturan aplikasi.
class PengaturanModel implements MemilikiId {
  /// ID unik untuk dokumen pengaturan.
  @override
  final String id;

  /// Interval sinkronisasi otomatis dalam jam.
  final int intervalSinkronisasiOtomatis;

  /// Durasi dalam hari untuk menghapus data yang diarsipkan secara otomatis.
  final int hapusOtomatisDataArsip;

  /// Status mode pemeliharaan.
  final bool modePemeliharaan;

  /// Informasi yang ditampilkan saat mode pemeliharaan aktif.
  final String infoPemeliharaan;

  /// Waktu terakhir data diperbarui.
// TODO: tugas selanjutnya adalah merubah semua data yang disimpan ke sqlite kolom  tanggal diubah  ke millisecondsSinceEpoch, dan menyesuaikan tipe nya dengan sqlite.dart

  final DateTime? diperbarui;

  /// Konstruktor untuk `PengaturanModel`.
  PengaturanModel({
    this.id = idPengaturanGlobal,
    this.intervalSinkronisasiOtomatis = 24,
    this.hapusOtomatisDataArsip = 30,
    this.modePemeliharaan = false,
    this.infoPemeliharaan = '',
    this.diperbarui,
  });

  /// Membuat salinan dari `PengaturanModel` dengan beberapa nilai yang diubah.
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

  /// Helper untuk mengurai nilai tanggal dari berbagai format.
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Membuat instance `PengaturanModel` dari data Map SQLite.
  factory PengaturanModel.fromSqlite(Map<String, dynamic> map) {
    return PengaturanModel(
      intervalSinkronisasiOtomatis:
          map['interval_sinkronisasi_otomatis'] as int? ?? 24,
      hapusOtomatisDataArsip: map['hapus_otomatis_data_arsip'] as int? ?? 30,
      modePemeliharaan: (map['mode_pemeliharaan'] as int? ?? 0) == 1,
      infoPemeliharaan: map['info_pemeliharaan'] as String? ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  /// Mengonversi `PengaturanModel` ke format Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan ? 1 : 0,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }

  /// Membuat instance `PengaturanModel` dari data Map Firebase.
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

  /// Mengonversi `PengaturanModel` ke format Map untuk disimpan di Firebase.
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

// TODO: tugas selanjutnya adalah merubah semua data yang disimpan ke sqlite kolom  tanggal diubah  ke millisecondsSinceEpoch, dan menyesuaikan tipe nya dengan sqlite.dart
