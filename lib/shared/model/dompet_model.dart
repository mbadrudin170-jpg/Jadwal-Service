// path: lib/model/dompet_model.dart
// diubah: Menggunakan UUID untuk ID dan memastikan non-nullable.
// ditambahkan: Metode fromFirestore dan toFirestore untuk interaksi dengan Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DompetModel {
  final String id; // diubah: menjadi non-nullable
  final String namaDompet;
  final double saldo;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  DompetModel({
    String? id, // diubah: id bisa null saat pembuatan
    required this.namaDompet,
    required this.saldo,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4(); // ditambah: inisialisasi UUID jika id null

  DompetModel copyWith({
    String? id,
    String? namaDompet,
    double? saldo,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return DompetModel(
      id: id ?? this.id,
      namaDompet: namaDompet ?? this.namaDompet,
      saldo: saldo ?? this.saldo,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // Konversi dari format database lokal (SQLite)
  // diubah: nama metode dari fromMap menjadi fromSqlite untuk konsistensi
  factory DompetModel.fromSqlite(Map<String, dynamic> map) {
    return DompetModel(
      id: map['id'],
      namaDompet: map['namaDompet'] ?? '',
      saldo: (map['saldo'] as num?)?.toDouble() ?? 0.0,
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  // Konversi ke format database lokal (SQLite)
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  // --- Interaksi Firestore ---
  // saya ubah ke fromFirebase
  // ditambahkan: Factory constructor dari data Firestore
  factory DompetModel.fromFirebase(String id, Map<String, dynamic> data) {
    return DompetModel(
      id: id,
      namaDompet: data['namaDompet'] ?? '',
      saldo: (data['saldo'] as num?)?.toDouble() ?? 0.0,
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: data['isDeleted'] ?? false,
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  // ditambahkan: Metode konversi ke format Firestore
  Map<String, dynamic> toFirebase() {
    // saya ubah ke toFirebase
    return {
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui':
          FieldValue.serverTimestamp(), // Praktik terbaik untuk Firestore
      'isDeleted': isDeleted,
      if (diarsipkan != null) 'diarsipkan': Timestamp.fromDate(diarsipkan!),
    };
  }
}
