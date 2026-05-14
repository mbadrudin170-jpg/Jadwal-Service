// path: lib/model/kritik_saran_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// Model untuk data kritik dan saran dari pengguna.
class KritikSaranModel implements MemilikiId {
  /// ID unik untuk setiap entri kritik dan saran.
  @override
  final String id;

  /// Isi dari kritik atau saran yang diberikan oleh pengguna.
  final String isi;

  /// Tanggal kapan kritik atau saran ini dibuat.
  final DateTime? tanggal;

  /// ID pengguna yang memberikan kritik atau saran.
  final String userId;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? diperbarui;

  /// Konstruktor untuk membuat instance `KritikSaranModel`.
  KritikSaranModel({
    String? id,
    required this.isi,
    this.tanggal,
    required this.userId,
    this.diperbarui,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari `KritikSaranModel` dengan beberapa nilai yang diubah.
  KritikSaranModel copyWith({
    String? id,
    String? isi,
    DateTime? tanggal,
    String? userId,
    DateTime? diperbarui,
  }) {
    return KritikSaranModel(
      id: id ?? this.id,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      userId: userId ?? this.userId,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }

  /// Helper untuk mengurai nilai tanggal dari berbagai format.
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue);
    return null;
  }
// TODO: tugas selanjutnya adalah merubah semua data yang disimpan ke sqlite kolom  tanggal diubah  ke millisecondsSinceEpoch, dan menyesuaikan tipe nya dengan sqlite.dart

  /// Membuat instance `KritikSaranModel` dari data Map SQLite.
  factory KritikSaranModel.fromSqlite(Map<String, dynamic> map) {
    return KritikSaranModel(
      id: map['id'] as String?,
      isi: map['isi'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      tanggal: _parseDateTime(map['tanggal']), // ← Pakai _parseDateTime
      diperbarui: _parseDateTime(map['diperbarui']), // ← Pakai _parseDateTime
    );
  }

  /// Mengonversi `KritikSaranModel` ke format Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'isi': isi,
      'tanggal': tanggal?.millisecondsSinceEpoch, // ← Konversi ke int
      'userId': userId,
      'diperbarui': diperbarui?.millisecondsSinceEpoch, // ← Konversi ke int
    };
  }

  /// Membuat instance `KritikSaranModel` dari data Map Firebase.
  factory KritikSaranModel.fromFirebase(String id, Map<String, dynamic> data) {
    return KritikSaranModel(
      id: id,
      isi: data['isi'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      tanggal: _parseDateTime(data['tanggal']) ?? DateTime.now(),
      diperbarui: _parseDateTime(data['diperbarui']),
    );
  }

  /// Mengonversi `KritikSaranModel` ke format Map untuk disimpan di Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'isi': isi,
      'tanggal': tanggal != null ? Timestamp.fromDate(tanggal!) : FieldValue.serverTimestamp(),
      'userId': userId,
      'diperbarui': FieldValue.serverTimestamp(),
    };
  }
}
