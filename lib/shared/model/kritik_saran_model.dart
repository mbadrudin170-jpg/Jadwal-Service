// path: lib/model/kritik_saran_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class KritikSaranModel {
  final String id;
  final String isi;
  final DateTime? tanggal;
  final String userId;
  final DateTime? diperbarui;

  KritikSaranModel({
    String? id,
    required this.isi,
    this.tanggal,
    required this.userId,
    this.diperbarui,
  }) : id = id ?? const Uuid().v4();

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

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue);
    return null;
  }

  factory KritikSaranModel.fromSqlite(Map<String, dynamic> map) {
    return KritikSaranModel(
      id: map['id'] as String?,
      isi: map['isi'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      tanggal: _parseDateTime(map['tanggal']), // ← Pakai _parseDateTime
      diperbarui: _parseDateTime(map['diperbarui']), // ← Pakai _parseDateTime
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'isi': isi,
      'tanggal': tanggal?.millisecondsSinceEpoch, // ← Konversi ke int
      'userId': userId,
      'diperbarui': diperbarui?.millisecondsSinceEpoch, // ← Konversi ke int
    };
  }

  // ditambahkan: Factory fromFirebase
  factory KritikSaranModel.fromFirebase(String id, Map<String, dynamic> data) {
    return KritikSaranModel(
      id: id,
      isi: data['isi'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      tanggal: _parseDateTime(data['tanggal']) ?? DateTime.now(),
      diperbarui: _parseDateTime(data['diperbarui']),
    );
  }

  // diubah: Nama metode dan logika diperbarui diubah
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'isi': isi,
      'tanggal': tanggal != null ? Timestamp.fromDate(tanggal!) : null,
      'userId': userId,
      'diperbarui': FieldValue.serverTimestamp(),
    };
  }
}
