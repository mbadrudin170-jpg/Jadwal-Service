// path: lib/model/sub_kategori_model.dart
// diubah: Penamaan metode diseragamkan (fromSqlite, toSqlite, fromFirebase, toFirebase).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SubKategoriModel {
  final String id;
  final String nama;
  final String idKategori; 
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  SubKategoriModel({
    String? id,
    required this.nama,
    required this.idKategori,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  SubKategoriModel copyWith({
    String? id,
    String? nama,
    String? idKategori,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return SubKategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      idKategori: idKategori ?? this.idKategori,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  // diubah: Nama metode diubah dari fromMap menjadi fromSqlite
  factory SubKategoriModel.fromSqlite(Map<String, dynamic> map) {
    return SubKategoriModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      idKategori: map['id_kategori'] ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == 1 || map['isDeleted'] == true,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  // diubah: Nama metode diubah dari toMapForSqlite menjadi toSqlite
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nama': nama,
      'id_kategori': idKategori,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  // ditambahkan: Factory fromFirebase
  factory SubKategoriModel.fromFirebase(String id, Map<String, dynamic> data) {
    return SubKategoriModel(
      id: id,
      nama: data['nama'] ?? '',
      idKategori: data['id_kategori'] ?? '',
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: data['isDeleted'] ?? false,
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  // diubah: Nama metode diubah dari toMapForFirebase menjadi toFirebase
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'nama': nama,
      'id_kategori': idKategori,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
