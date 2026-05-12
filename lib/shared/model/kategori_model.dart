// path: lib/model/kategori_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';

enum TipeKategori { pemasukan, pengeluaran, transfer }

class KategoriModel {
  final String id;
  final String nama;
  final TipeKategori tipe;
  final List<SubKategoriModel> subKategori;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  KategoriModel({
    String? id,
    required this.nama,
    required this.tipe,
    this.subKategori = const [],
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  KategoriModel copyWith({
    String? id,
    String? nama,
    TipeKategori? tipe,
    List<SubKategoriModel>? subKategori,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return KategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      subKategori: subKategori ?? this.subKategori,
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

  // diubah: Nama metode dari fromMap menjadi fromSqlite
  factory KategoriModel.fromSqlite(Map<String, dynamic> map) {
    List<SubKategoriModel> parseSubKategori(dynamic data) {
      if (data == null) return [];
      try {
        List<dynamic> list;
        if (data is String && data.isNotEmpty) {
          list = jsonDecode(data);
        } else if (data is List) {
          list = data;
        } else {
          return [];
        }
        return list
            .map(
              (item) => SubKategoriModel.fromSqlite(item as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }

    return KategoriModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      tipe: TipeKategori.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeKategori.pemasukan,
      ),
      subKategori: parseSubKategori(map['id_sub_kategori']),
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  // diubah: Nama metode dari toMapForSqlite menjadi toSqlite
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe.name,
      'id_sub_kategori': jsonEncode(
        subKategori.map((sub) => sub.toSqlite()).toList(),
      ),
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  // ditambahkan: Factory fromFirebase
  factory KategoriModel.fromFirebase(String id, Map<String, dynamic> data) {
    List<SubKategoriModel> parseSubKategori(dynamic subKategoriData) {
      if (subKategoriData is List) {
        return subKategoriData
            .map((item) => SubKategoriModel.fromFirebase(item['id'], item as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    }

    return KategoriModel(
      id: id,
      nama: data['nama'] ?? '',
      tipe: TipeKategori.values.firstWhere(
        (e) => e.name == data['tipe'],
        orElse: () => TipeKategori.pemasukan,
      ),
      subKategori: parseSubKategori(data['id_sub_kategori']),
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: data['isDeleted'] ?? false,
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  // diubah: Nama metode dan logika penyimpanan subkategori diubah
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe.name,
      // diubah: Menyimpan subkategori sebagai List<Map> asli
      'id_sub_kategori': subKategori.map((sub) => sub.toFirebase()).toList(),
      'diperbarui': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
