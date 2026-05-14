// path: lib/shared/model/sub_kategori_model.dart
// diubah: Penamaan metode diseragamkan, ditambahkan dokumentasi lengkap dan keamanan tipe.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// Model yang merepresentasikan sebuah sub-kategori.
///
/// Sub-kategori selalu berada di bawah sebuah [KategoriModel] induk.
class SubKategoriModel implements MemilikiId {
  /// ID unik dari sub-kategori, biasanya dihasilkan oleh UUID.
  @override
  final String id;

  /// Nama dari sub-kategori.
  final String nama;

  /// ID dari [KategoriModel] induk.
  final String idKategori;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? diperbarui;

  /// Penanda jika data ini telah dihapus (soft delete).
  final bool isDeleted;

  /// Waktu kapan data ini diarsipkan.
  final DateTime? diarsipkan;

  /// Konstruktor utama untuk membuat instance [SubKategoriModel].
  SubKategoriModel({
    String? id,
    required this.nama,
    required this.idKategori,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari instance [SubKategoriModel] dengan beberapa nilai yang diubah.
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

  /// Helper untuk mengubah nilai dinamis menjadi DateTime.
  static DateTime? _parseDateTime(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  /// Helper untuk mengubah nilai dinamis menjadi boolean dengan aman.
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [SubKategoriModel] dari data SQLite.
  factory SubKategoriModel.fromSqlite(Map<String, dynamic> map) {
    return SubKategoriModel(
      id: map['id'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      idKategori: map['id_kategori'] as String? ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: _parseBool(map['isDeleted']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengubah instance [SubKategoriModel] menjadi Map untuk disimpan di SQLite.
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

  /// Factory constructor untuk membuat [SubKategoriModel] dari data Firebase.
  factory SubKategoriModel.fromFirebase(String id, Map<String, dynamic> data) {
    return SubKategoriModel(
      id: id,
      nama: data['nama'] as String? ?? '',
      idKategori: data['id_kategori'] as String? ?? '',
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: _parseBool(data['isDeleted']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  /// Mengubah instance [SubKategoriModel] menjadi Map untuk disimpan di Firebase.
  /// ID disertakan karena sub-kategori disimpan sebagai daftar di dalam dokumen kategori.
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'nama': nama,
      'id_kategori': idKategori,
      'diperbarui': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan != null ? Timestamp.fromDate(diarsipkan!) : null,
    };
  }
}
// TODO: tugas selanjutnya adalah merubah semua data yang disimpan ke sqlite kolom  tanggal diubah  ke millisecondsSinceEpoch, dan menyesuaikan tipe nya dengan sqlite.dart
