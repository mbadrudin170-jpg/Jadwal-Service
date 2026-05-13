// path: lib/shared/model/kategori_model.dart
// diubah: Penamaan metode diseragamkan, logika Firebase diperbaiki, dan ditambahkan dokumentasi serta keamanan tipe.
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';

/// Enum untuk mendefinisikan tipe-tipe kategori transaksi.
enum TipeKategori {
  /// Mewakili transaksi yang menambah saldo (uang masuk).
  pemasukan,

  /// Mewakili transaksi yang mengurangi saldo (uang keluar).
  pengeluaran,

  /// Mewakili transaksi pemindahan dana antar dompet.
  transfer,
}

/// Model yang merepresentasikan sebuah kategori transaksi.
///
/// Setiap kategori memiliki nama, tipe, dan bisa memiliki daftar sub-kategori.
class KategoriModel {
  /// ID unik dari kategori, biasanya dihasilkan oleh UUID.
  final String id;

  /// Nama dari kategori.
  final String nama;

  /// Tipe dari kategori (pemasukan, pengeluaran, atau transfer).
  final TipeKategori tipe;

  /// Daftar sub-kategori yang berada di bawah kategori ini.
  final List<SubKategoriModel> subKategori;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? diperbarui;

  /// Penanda jika data ini telah dihapus (soft delete).
  final bool isDeleted;

  /// Waktu kapan data ini diarsipkan.
  final DateTime? diarsipkan;

  /// Konstruktor utama untuk membuat instance [KategoriModel].
  KategoriModel({
    String? id,
    required this.nama,
    required this.tipe,
    this.subKategori = const [],
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari instance [KategoriModel] dengan beberapa nilai yang diubah.
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

  /// Helper untuk mengubah nilai dinamis menjadi DateTime.
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Helper untuk parsing enum dengan aman dari String.
  static T? _safeParseEnum<T extends Enum>(List<T> values, dynamic name) {
    if (name == null) return null;
    try {
      return values.firstWhere((e) => e.name == name as String);
    } catch (e) {
      return null;
    }
  }

  /// Helper untuk mengubah nilai dinamis menjadi boolean dengan aman.
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [KategoriModel] dari data SQLite.
  factory KategoriModel.fromSqlite(Map<String, dynamic> map) {
    List<SubKategoriModel> parseSubKategori(dynamic data) {
      if (data == null) return [];
      try {
        List<dynamic> list;
        if (data is String && data.isNotEmpty) {
          list = jsonDecode(data) as List<dynamic>;
        } else if (data is List) {
          list = data;
        } else {
          return [];
        }
        return list
            .map((item) {
              if (item is Map<String, dynamic>) {
                return SubKategoriModel.fromSqlite(item);
              }
              return null;
            })
            .whereType<SubKategoriModel>()
            .toList();
      } catch (e) {
        return [];
      }
    }

    return KategoriModel(
      id: map['id'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      tipe: _safeParseEnum(TipeKategori.values, map['tipe']) ??
          TipeKategori.pemasukan,
      subKategori: parseSubKategori(map['id_sub_kategori']),
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: _parseBool(map['isDeleted']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengubah instance [KategoriModel] menjadi Map untuk disimpan di SQLite.
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

  /// Factory constructor untuk membuat [KategoriModel] dari data Firebase.
  factory KategoriModel.fromFirebase(String id, Map<String, dynamic> data) {
    List<SubKategoriModel> parseSubKategori(dynamic subKategoriData) {
      if (subKategoriData is List) {
        return subKategoriData
            .map((item) {
              if (item is Map<String, dynamic>) {
                // Dokumen sub-koleksi tidak memiliki ID terpisah di dalam datanya,
                // jadi kita bisa meng-generate atau menggunakan ID dari field jika ada.
                final String subId = item['id'] as String? ?? const Uuid().v4();
                return SubKategoriModel.fromFirebase(subId, item);
              }
              return null;
            })
            .whereType<SubKategoriModel>()
            .toList();
      }
      return [];
    }

    return KategoriModel(
      id: id,
      nama: data['nama'] as String? ?? '',
      tipe: _safeParseEnum(TipeKategori.values, data['tipe']) ??
          TipeKategori.pemasukan,
      subKategori: parseSubKategori(data['id_sub_kategori']),
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: _parseBool(data['isDeleted']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  /// Mengubah instance [KategoriModel] menjadi Map untuk disimpan di Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      // 'id' tidak perlu disimpan karena sudah menjadi ID dokumen
      'nama': nama,
      'tipe': tipe.name,
      'id_sub_kategori': subKategori.map((sub) => sub.toFirebase()).toList(),
      'diperbarui': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan != null ? Timestamp.fromDate(diarsipkan!) : null,
    };
  }
}
