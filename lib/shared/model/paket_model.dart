// path: lib/model/paket_model.dart
// ditambahkan: Import cloud_firestore untuk FieldValue dan Timestamp.
// diubah: Menghapus field `jumlahPoin` yang tidak lagi digunakan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum TipeDurasi {
  menit,
  jam,
  hari,
  bulan;

  String get displayName {
    switch (this) {
      case TipeDurasi.menit:
        return 'Menit';
      case TipeDurasi.jam:
        return 'Jam';
      case TipeDurasi.hari:
        return 'Hari';
      case TipeDurasi.bulan:
        return 'Bulan';
    }
  }
}

class PaketModel {
  final String id;
  final String nama;
  final int harga;
  final int durasi;
  final TipeDurasi tipe;

  final int poinHadiah;
  final int poinPenukaran;

  final bool isPublic;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  PaketModel({
    String? id,
    required this.nama,
    required this.harga,
    required this.durasi,
    required this.tipe,
    this.poinHadiah = 0,
    this.poinPenukaran = 0,
    this.isPublic = true,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  // =========================
  // COPY WITH
  // =========================
  PaketModel copyWith({
    String? id,
    String? nama,
    int? harga,
    int? durasi,
    TipeDurasi? tipe,
    int? poinHadiah,
    int? poinPenukaran,
    bool? isPublic,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return PaketModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      durasi: durasi ?? this.durasi,
      tipe: tipe ?? this.tipe,
      poinHadiah: poinHadiah ?? this.poinHadiah,
      poinPenukaran: poinPenukaran ?? this.poinPenukaran,
      isPublic: isPublic ?? this.isPublic,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  // =========================
  // PARSER UTIL
  // =========================

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static TipeDurasi _parseTipe(dynamic value) {
    return TipeDurasi.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TipeDurasi.hari,
    );
  }

  // =========================
  // SQLITE
  // =========================

  factory PaketModel.fromSqlite(Map<String, dynamic> map) {
    return PaketModel(
      id: map['id'] as String?,
      nama: map['nama'] as String? ?? '',
      harga: map['harga'] as int? ?? 0,
      durasi: map['durasi'] as int? ?? 0,
      tipe: _parseTipe(map['tipe']),
      poinHadiah: map['poin_hadiah'] as int? ?? 0,
      poinPenukaran: map['poin_penukaran'] as int? ?? 0,
      isPublic: _parseBool(map['isPublic']),
      isDeleted: _parseBool(map['isDeleted']),
      diperbarui: _parseDateTime(map['diperbarui']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'tipe': tipe.name,
      'poin_hadiah': poinHadiah,
      'poin_penukaran': poinPenukaran,
      'isPublic': isPublic ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'diperbarui': diperbarui?.millisecondsSinceEpoch,
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory PaketModel.fromFirebase(String id, Map<String, dynamic> data) {
    return PaketModel(
      id: id,
      nama: data['nama'] as String? ?? '',
      harga: data['harga'] as int? ?? 0,
      durasi: data['durasi'] as int? ?? 0,
      tipe: _parseTipe(data['tipe']),
      poinHadiah: data['poin_hadiah'] as int? ?? 0,
      poinPenukaran: data['poin_penukaran'] as int? ?? 0,
      isPublic: _parseBool(data['isPublic']),
      isDeleted: _parseBool(data['isDeleted']),
      diperbarui: _parseDateTime(data['diperbarui']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  // diubah: Menggunakan FieldValue.serverTimestamp() dan Timestamp untuk konsistensi.
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'tipe': tipe.name,
      'poin_hadiah': poinHadiah,
      'poin_penukaran': poinPenukaran,
      'isPublic': isPublic,
      'isDeleted': isDeleted,
      'diperbarui': FieldValue.serverTimestamp(),
    };
    if (diarsipkan != null) {
      data['diarsipkan'] = Timestamp.fromDate(diarsipkan!);
    }
    return data;
  }
}
