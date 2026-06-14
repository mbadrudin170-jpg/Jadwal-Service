// path: lib/shared/model/sub_category_model.dart
// diubah: Menggunakan ParserUtil untuk konsistensi parsing dan .toUtc() untuk penyimpanan.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/kategori_model.dart' show KategoriModel;
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Model yang merepresentasikan sebuah sub-kategori.
///
/// Setiap sub-kategori selalu berada di bawah sebuah [KategoriModel] induk.
class SubCategoryModel implements HasId {
  /// ID unik dari sub-kategori, biasanya dibuat menggunakan UUID.
  @override
  final String id;

  /// Nama dari sub-kategori.
  final String name;

  /// ID dari [KategoriModel] induk.
  final String categoryId;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? updatedAt;

  /// Penanda untuk soft-delete (penghapusan sementara).
  final bool isDeleted;

  /// Waktu saat data ini diarsipkan.
  final DateTime? archivedAt;

  /// Konstruktor utama untuk membuat instance [SubCategoryModel].
  SubCategoryModel({
    final String? id,
    required this.name,
    required this.categoryId,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('SubCategoryModel dibuat: $name ($id)');
  }

  /// Membuat salinan dari instance [SubCategoryModel] ini dengan beberapa nilai yang diubah.
  SubCategoryModel copyWith({
    final String? id,
    final String? name,
    final String? categoryId,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return SubCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  // DIHAPUS: Helper parsing internal dipindahkan ke ParserUtil

  /// Factory constructor untuk membuat [SubCategoryModel] dari data SQLite.
  factory SubCategoryModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Membuat SubCategoryModel dari SQLite: ${map[NamaKolom.id]}');
    return SubCategoryModel(
      id: map[NamaKolom.id] as String? ?? '',
      name: map[NamaKolom.name] as String? ?? '',
      categoryId: map[NamaKolom.categoryId] as String? ?? '',
      // DIUBAH: Menggunakan ParserUtil
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.updatedAt]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.archivedAt]),
    );
  }

  /// Mengonversi instance [SubCategoryModel] ini menjadi Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Mengonversi SubCategoryModel ke format SQLite: $id');
    return {
      NamaKolom.id: id,
      NamaKolom.name: name,
      NamaKolom.categoryId: categoryId,
      // DIUBAH: Memastikan updatedAt tidak pernah null
      NamaKolom.updatedAt: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.isDeleted: isDeleted ? 1 : 0,
      NamaKolom.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor untuk membuat [SubCategoryModel] dari data Firebase.
  factory SubCategoryModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Membuat SubCategoryModel dari Firebase: $id');
    return SubCategoryModel(
      id: id,
      name: data[NamaKolom.name] as String? ?? '',
      categoryId: data[NamaKolom.categoryId] as String? ?? '',
      // DIUBAH: Menggunakan ParserUtil
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.updatedAt]),
      isDeleted: ParserUtil.parseBool(data[NamaKolom.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.archivedAt]),
    );
  }

  /// Mengonversi instance [SubCategoryModel] ini menjadi Map untuk disimpan di Firebase.
  /// ID disertakan karena sub-kategori disimpan sebagai daftar di dalam dokumen kategori.
  Map<String, dynamic> toFirebase() {
    Log.info('Mengonversi SubCategoryModel ke format Firebase: $id');
    return {
      NamaKolom.id: id,
      NamaKolom.name: name,
      NamaKolom.categoryId: categoryId,
      // DIUBAH: Memastikan updatedAt tidak pernah null dan menggunakan .toUtc()
      NamaKolom.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      NamaKolom.isDeleted: isDeleted,
      // DIUBAH: Menggunakan .toUtc() jika tidak null
      NamaKolom.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
