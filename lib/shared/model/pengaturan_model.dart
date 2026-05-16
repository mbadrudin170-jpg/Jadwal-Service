// path: lib/shared/model/pengaturan_model.dart
// diubah: Menggunakan konstanta dari NamaKolom untuk nama field database.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/database_column_name.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// ID global untuk dokumen pengaturan.
const String idPengaturanGlobal = 'konfigurasi_global';

/// Model untuk pengaturan aplikasi.
class PengaturanModel implements MemilikiId {
  @override
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

  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory PengaturanModel.fromSqlite(final Map<String, dynamic> map) {
    return PengaturanModel(
      intervalSinkronisasiOtomatis:
          map[NamaKolom.intervalSinkronisasiOtomatis] as int? ?? 24,
      hapusOtomatisDataArsip:
          map[NamaKolom.hapusOtomatisDataArsip] as int? ?? 30,
      modePemeliharaan: (map[NamaKolom.modePemeliharaan] as int? ?? 0) == 1,
      infoPemeliharaan: map[NamaKolom.infoPemeliharaan] as String? ?? '',
      diperbarui: _parseDateTime(map[NamaKolom.diperbarui]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.intervalSinkronisasiOtomatis: intervalSinkronisasiOtomatis,
      NamaKolom.hapusOtomatisDataArsip: hapusOtomatisDataArsip,
      NamaKolom.modePemeliharaan: modePemeliharaan ? 1 : 0,
      NamaKolom.infoPemeliharaan: infoPemeliharaan,
      NamaKolom.diperbarui: diperbarui?.millisecondsSinceEpoch,
    };
  }

  factory PengaturanModel.fromFirebase(final Map<String, dynamic> data) {
    return PengaturanModel(
      id: data[NamaKolom.id] as String? ?? idPengaturanGlobal,
      intervalSinkronisasiOtomatis:
          data[NamaKolom.intervalSinkronisasiOtomatis] as int? ?? 24,
      hapusOtomatisDataArsip:
          data[NamaKolom.hapusOtomatisDataArsip] as int? ?? 30,
      modePemeliharaan: data[NamaKolom.modePemeliharaan] as bool? ?? false,
      infoPemeliharaan: data[NamaKolom.infoPemeliharaan] as String? ?? '',
      diperbarui: _parseDateTime(data[NamaKolom.diperbarui]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.intervalSinkronisasiOtomatis: intervalSinkronisasiOtomatis,
      NamaKolom.hapusOtomatisDataArsip: hapusOtomatisDataArsip,
      NamaKolom.modePemeliharaan: modePemeliharaan,
      NamaKolom.infoPemeliharaan: infoPemeliharaan,
      NamaKolom.diperbarui:
          Timestamp.fromDate((diperbarui ?? DateTime.now()).toUtc()),
    };
  }
}
