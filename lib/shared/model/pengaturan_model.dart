// path: lib/shared/model/pengaturan_model.dart
// diubah: Menghapus logika timestamp dari toSqlite() untuk memindahkan tanggung jawab ke lapisan operasi.
// diubah: Menambahkan metode `copyWith` untuk memungkinkan pembaruan properti secara immutable.
// Ini memperbaiki error `undefined_method` yang terjadi di `PengaturanOperasi`.
// diubah: Menggunakan konstanta `idPengaturanGlobal` secara konsisten di semua factory constructor.
// diubah: Mengimplementasikan MemilikiId untuk konsistensi dengan unggah data generik.
// diubah: Semua kolom tanggal disimpan sebagai millisecondsSinceEpoch (INTEGER) di SQLite.

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
    final String? id,
    final int? intervalSinkronisasiOtomatis,
    final int? hapusOtomatisDataArsip,
    final bool? modePemeliharaan,
    final String? infoPemeliharaan,
    final DateTime? diperbarui,
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
  ///
  /// Menerima [Timestamp] dari Firestore, [int] millisecondsSinceEpoch dari SQLite,
  /// [DateTime], atau [String] format ISO-8601 (backward compatibility).
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    // Menangani millisecondsSinceEpoch dari SQLite (INTEGER)
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    // Backward compatibility untuk data lama yang masih dalam format String
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Membuat instance `PengaturanModel` dari data Map SQLite.
  factory PengaturanModel.fromSqlite(final Map<String, dynamic> map) {
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
  ///
  /// Semua kolom DateTime sekarang disimpan sebagai millisecondsSinceEpoch (INTEGER).
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan ? 1 : 0,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': diperbarui?.millisecondsSinceEpoch, // INTEGER
    };
  }

  /// Membuat instance `PengaturanModel` dari data Map Firebase.
  factory PengaturanModel.fromFirebase(final Map<String, dynamic> data) {
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
