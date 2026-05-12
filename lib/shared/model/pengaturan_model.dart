// path: lib/model/pengaturan_model.dart
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

  // ditambah: Metode copyWith untuk membuat salinan objek dengan nilai yang diperbarui.
  // Ini adalah pola umum untuk model data dan diperlukan untuk memperbaiki error kompilasi.
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
      id: idPengaturanGlobal, // diubah: karena untuk konsistensi, menggunakan konstanta global.
      intervalSinkronisasiOtomatis:
          map['interval_sinkronisasi_otomatis'] as int? ?? 24,
      hapusOtomatisDataArsip: map['hapus_otomatis_data_arsip'] as int? ?? 30,
      modePemeliharaan: (map['mode_pemeliharaan'] as int? ?? 0) == 1,
      infoPemeliharaan: map['info_pemeliharaan'] as String? ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  Map<String, dynamic> toSqlite() {
    // Perhatikan: ID di sini sekarang menggunakan ID dari instance, yang akan
    // ditimpa menjadi 'konfigurasi_global' di dalam PengaturanOperasi.
    // Namun, skema tabel mengharapkan INTEGER, jadi kita perlu penanganan khusus.
    // Solusi di PengaturanOperasi (menggunakan copyWith) lebih bersih karena memisahkan concern.
    // Untuk konsistensi, kita akan tetap menggunakan ID string di model, dan membiarkan
    // lapisan data yang menangani pemetaan ke tipe data database.
    return {
      // 'id' tidak lagi di-hardcode di sini. Nilai yang benar akan diatur oleh PengaturanOperasi
      // sebelum disisipkan ke database, yang mana akan menggunakan ID dari `toSqlite` jika `id` adalah int.
      // Karena `id` adalah String, kita akan membiarkannya dan PengaturanOperasi akan menimpanya.
      // Ini adalah perbaikan dari versi sebelumnya yang salah.
      'id': id,
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan ? 1 : 0,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': DateTime.now().toIso8601String(),
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory PengaturanModel.fromFirebase(Map<String, dynamic> data) {
    return PengaturanModel(
      id: data['id'] as String? ?? idPengaturanGlobal, // diubah: karena untuk konsistensi, menggunakan konstanta global.
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
