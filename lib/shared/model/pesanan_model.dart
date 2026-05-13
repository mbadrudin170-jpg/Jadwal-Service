// path: lib/model/pesanan_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase disesuaikan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PesananModel {
  final String id;
  final String idPelanggan;
  final String idPaket;
  final DateTime tanggal;
  final String status;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  PesananModel({
    String? id,
    required this.idPelanggan,
    required this.idPaket,
    required this.tanggal,
    required this.status,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  PesananModel copyWith({
    String? id,
    String? idPelanggan,
    String? idPaket,
    DateTime? tanggal,
    String? status,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return PesananModel(
      id: id ?? this.id,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      idPaket: idPaket ?? this.idPaket,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  // =========================
  // SQLITE
  // =========================

  factory PesananModel.fromSqlite(Map<String, dynamic> map) {
    return PesananModel(
      id: map['id'] as String? ?? '',
      idPelanggan: map['id_pelanggan'] as String? ?? '',
      idPaket: map['id_paket'] as String? ?? '',
      tanggal: _parseDateTime(map['tanggal']) ?? DateTime.now(),
      status: map['status'] as String? ?? 'baru',
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'tanggal': tanggal.millisecondsSinceEpoch,
      'status': status,
      'diperbarui': diperbarui?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory PesananModel.fromFirebase(String id, Map<String, dynamic> data) {
    return PesananModel(
      id: id,
      idPelanggan: data['id_pelanggan'] as String? ?? '',
      idPaket: data['id_paket'] as String? ?? '',
      tanggal: _parseDateTime(data['tanggal']) ?? DateTime.now(),
      status: data['status'] as String? ?? 'baru',
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: data['isDeleted'] == true,
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'tanggal': Timestamp.fromDate(tanggal),
      'status': status,
      'diperbarui': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      if (diarsipkan != null) 'diarsipkan': Timestamp.fromDate(diarsipkan!),
    };
  }
}
