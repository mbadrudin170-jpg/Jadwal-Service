// path: lib/shared/model/kategori_model.dart
// Fitur: Model Data
// Tujuan: Mendefinisikan struktur data untuk kategori transaksi, termasuk konversi dari/ke format SQLite dan Firebase.
// Diubah: Memperbaiki toFirebase agar tidak selalu mengirim ServerTimestamp.
// Diubah: Semua kolom tanggal disimpan sebagai millisecondsSinceEpoch (INTEGER) di SQLite.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/memiliki_id.dart';
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
class KategoriModel implements MemilikiId {
  /// ID unik dari kategori, biasanya dihasilkan oleh UUID.
  @override
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
    final String? id,
    required this.nama,
    required this.tipe,
    this.subKategori = const [],
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari instance [KategoriModel] dengan beberapa nilai yang diubah.
  KategoriModel copyWith({
    final String? id,
    final String? nama,
    final TipeKategori? tipe,
    final List<SubKategoriModel>? subKategori,
    final DateTime? diperbarui,
    final bool? isDeleted,
    final DateTime? diarsipkan,
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

  /// Mengurai nilai tanggal dari berbagai format ke [DateTime].
  ///
  /// Menerima [Timestamp] dari Firestore, [int] millisecondsSinceEpoch dari SQLite,
  /// [DateTime], atau [String] format ISO-8601 (backward compatibility).
  /// Mengembalikan `null` jika nilai input null atau tidak dapat diurai.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    // Menangani millisecondsSinceEpoch dari SQLite (INTEGER)
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    // Backward compatibility untuk data lama yang masih dalam format String
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Mengurai nama enum dari [String] ke tipe enum [T] dengan aman.
  ///
  /// Mengembalikan `null` jika nama tidak ditemukan atau input null.
  static T? _safeParseEnum<T extends Enum>(
      final List<T> values, final dynamic name,) {
    if (name == null) return null;
    return values.cast<T?>().firstWhere(
          (final e) => e!.name == name as String,
          orElse: () => null,
        );
  }

  /// Mengurai nilai [bool] dari berbagai format (bool, int, String) dengan aman.
  ///
  /// Mengembalikan `false` jika input null atau format tidak dikenal.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [KategoriModel] dari data Map SQLite.
  factory KategoriModel.fromSqlite(final Map<String, dynamic> map) {
    List<SubKategoriModel> parseSubKategori(final dynamic data) {
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
            .map((final item) {
              if (item is Map<String, dynamic>) {
                return SubKategoriModel.fromSqlite(item);
              }
              return null;
            })
            .whereType<SubKategoriModel>()
            .toList();
      } on Exception {
        return [];
      }
    }

    return KategoriModel(
      id: map['id'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      tipe: _safeParseEnum(TipeKategori.values, map['tipe']) ??
          TipeKategori.pengeluaran,
      subKategori: parseSubKategori(map['id_sub_kategori']),
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: _parseBool(map['isDeleted']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengubah instance [KategoriModel] menjadi Map untuk disimpan di SQLite.
  ///
  /// Semua kolom DateTime sekarang disimpan sebagai millisecondsSinceEpoch (INTEGER).
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe.name,
      'id_sub_kategori': jsonEncode(
        subKategori.map((final sub) => sub.toSqlite()).toList(),
      ),
      'diperbarui': diperbarui?.millisecondsSinceEpoch, // INTEGER
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch, // INTEGER
    };
  }

  /// Factory constructor untuk membuat [KategoriModel] dari data Map Firebase.
  factory KategoriModel.fromFirebase(
      final String id, final Map<String, dynamic> data,) {
    List<SubKategoriModel> parseSubKategori(final dynamic subKategoriData) {
      if (subKategoriData is List) {
        return subKategoriData
            .map((final item) {
              if (item is Map<String, dynamic>) {
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
          TipeKategori.pengeluaran,
      subKategori: parseSubKategori(data['id_sub_kategori']),
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: _parseBool(data['isDeleted']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  /// Mengubah instance [KategoriModel] menjadi Map untuk disimpan di Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      'nama': nama,
      'tipe': tipe.name,
      'id_sub_kategori':
          subKategori.map((final sub) => sub.toFirebase()).toList(),
      'diperbarui': diperbarui != null
          ? Timestamp.fromDate(diperbarui!)
          : FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan != null ? Timestamp.fromDate(diarsipkan!) : null,
    };
  }
}
