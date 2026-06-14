// path: lib/shared/model/category_model.dart
// diubah: Menggunakan ParserUtil untuk konsistensi parsing dan .toUtc() untuk penyimpanan.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Model that represents a transaction category.
class KategoriModel implements HasId {
  @override
  final String id;

  /// The name of the category.
  final String name;

  /// The type of the category (e.g., expense, income).
  final TipeKategori type;

  /// A list of sub-categories under this category.
  final List<SubCategoryModel> subCategories;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this category has been deleted (soft delete).
  final bool isDeleted;

  /// The time this category was archived.
  final DateTime? archivedAt;

  /// Main constructor for [KategoriModel].
  KategoriModel({
    final String? id,
    required this.name,
    required this.type,
    this.subCategories = const [],
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CategoryModel created: $id, name: $name');
  }

  /// Creates a copy of [KategoriModel] with some updated fields.
  KategoriModel copyWith({
    final String? id,
    final String? name,
    final TipeKategori? type,
    final List<SubCategoryModel>? subCategories,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return KategoriModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subCategories: subCategories ?? this.subCategories,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Safe helper to parse an enum from a string.
  static T? _safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null || name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    Log.warning('Failed to parse enum for type $T', name);
    return null;
  }

  /// Factory constructor to create [KategoriModel] from SQLite data.
  factory KategoriModel.fromSqlite(final Map<String, dynamic> map) {
    List<SubCategoryModel> parseSubCategories(final dynamic data) {
      if (data == null) return [];
      try {
        if (data is String && data.isNotEmpty) {
          final list = jsonDecode(data) as List<dynamic>;
          return list
              .map((final item) {
                if (item is Map<String, dynamic>) {
                  return SubCategoryModel.fromSqlite(item);
                }
                return null;
              })
              .whereType<SubCategoryModel>()
              .toList();
        }
        return [];
      } on FormatException catch (e, st) {
        Log.error('Failed to parse subcategories from JSON', e: e, s: st);
        return [];
      }
    }

    return KategoriModel(
      id: map[NamaKolom.id] as String? ?? '',
      name: map[NamaKolom.nama] as String? ?? '',
      type: _safeParseEnum(TipeKategori.values, map[NamaKolom.tipe]) ??
          TipeKategori.expense,
      subCategories: parseSubCategories(map[NamaKolom.idSubKategori]),
      // DIUBAH: Menggunakan ParserUtil
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  /// Converts [KategoriModel] to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    final data = {
      NamaKolom.id: id,
      NamaKolom.nama: name,
      NamaKolom.tipe: type.name,
      NamaKolom.idSubKategori: jsonEncode(
        subCategories.map((final sub) => sub.toSqlite()).toList(),
      ),
      // DIUBAH: Memastikan updatedAt tidak pernah null
      NamaKolom.diperbaruiPada:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diHapus: isDeleted ? 1 : 0,
      NamaKolom.diarsipkanPada: archivedAt?.millisecondsSinceEpoch,
    };
    return data;
  }

  /// Factory constructor to create [KategoriModel] from Firebase data.
  factory KategoriModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    List<SubCategoryModel> parseSubCategories(final dynamic subCategoryData) {
      if (subCategoryData is List) {
        return subCategoryData
            .map((final item) {
              if (item is Map<String, dynamic>) {
                final String subId =
                    item[NamaKolom.id] as String? ?? const Uuid().v4();
                return SubCategoryModel.fromFirebase(subId, item);
              }
              return null;
            })
            .whereType<SubCategoryModel>()
            .toList();
      }
      return [];
    }

    return KategoriModel(
      id: id,
      name: data[NamaKolom.nama] as String? ?? '',
      type: _safeParseEnum(TipeKategori.values, data[NamaKolom.tipe]) ??
          TipeKategori.expense,
      subCategories: parseSubCategories(data[NamaKolom.idSubKategori]),
      // DIUBAH: Menggunakan ParserUtil
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      isDeleted: ParserUtil.parseBool(data[NamaKolom.diHapus]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  /// Converts [KategoriModel] to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    final data = {
      NamaKolom.nama: name,
      NamaKolom.tipe: type.name,
      NamaKolom.idSubKategori:
          subCategories.map((final sub) => sub.toFirebase()).toList(),
      NamaKolom.diHapus: isDeleted,
      // DIUBAH: Memastikan updatedAt tidak pernah null dan menggunakan .toUtc()
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      // DIUBAH: Menggunakan .toUtc() jika tidak null
      NamaKolom.diarsipkanPada:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
    return data;
  }
}
