// path: lib/shared/model/sub_kategori_model.dart
// diubah: Memperbaiki toFirebase agar tidak selalu mengirim ServerTimestamp.
// diubah: Penamaan metode diseragamkan, ditambahkan dokumentasi lengkap dan keamanan tipe.
// diubah: Mengubah penyimpanan tanggal ke millisecondsSinceEpoch untuk SQLite dan memperbaiki nama helper.
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
    final String? id,
    required this.nama,
    required this.idKategori,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari instance [SubKategoriModel] dengan beberapa nilai yang diubah.
  SubKategoriModel copyWith({
    final String? id,
    final String? nama,
    final String? idKategori,
    final DateTime? diperbarui,
    final bool? isDeleted,
    final DateTime? diarsipkan,
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
  static DateTime? parseDateTime(final dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return null;
  }

  /// Helper untuk mengubah nilai dinamis menjadi boolean dengan aman.
  static bool parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [SubKategoriModel] dari data SQLite.
  factory SubKategoriModel.fromSqlite(final Map<String, dynamic> map) {
    return SubKategoriModel(
      id: map['id'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      idKategori: map['id_kategori'] as String? ?? '',
      diperbarui: parseDateTime(map['diperbarui']),
      isDeleted: parseBool(map['isDeleted']),
      diarsipkan: parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengubah instance [SubKategoriModel] menjadi Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nama': nama,
      'id_kategori': idKategori,
      'diperbarui': diperbarui?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor untuk membuat [SubKategoriModel] dari data Firebase.
  factory SubKategoriModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return SubKategoriModel(
      id: id,
      nama: data['nama'] as String? ?? '',
      idKategori: data['id_kategori'] as String? ?? '',
      diperbarui: parseDateTime(data['diperbarui']),
      isDeleted: parseBool(data['isDeleted']),
      diarsipkan: parseDateTime(data['diarsipkan']),
    );
  }

  /// Mengubah instance [SubKategoriModel] menjadi Map untuk disimpan di Firebase.
  /// ID disertakan karena sub-kategori disimpan sebagai daftar di dalam dokumen kategori.
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'nama': nama,
      'id_kategori': idKategori,
      'diperbarui': diperbarui != null
          ? Timestamp.fromDate(diperbarui!)
          : FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan != null ? Timestamp.fromDate(diarsipkan!) : null,
    };
  }
}
