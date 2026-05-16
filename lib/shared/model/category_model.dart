// path: lib/shared/model/category_model.dart
// diperbarui: Memindahkan enum ke file sendiri dan memperbaiki typo.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/model/sub_category_model.dart';

/// Model yang merepresentasikan sebuah kategori transaksi.
class CategoryModel implements HasId {
  @override
  final String id;
  final String name;
  final CategoryType type;
  final List<SubCategoryModel> subCategories;
  final DateTime? updatedAt;
  final bool isDeleted;
  final DateTime? archivedAt;

  /// Konstruktor utama untuk [CategoryModel].
  CategoryModel({
    final String? id,
    required this.name,
    required this.type,
    this.subCategories = const [],
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CategoryModel dibuat: $id, nama: $name');
  }

  /// Membuat salinan [CategoryModel] dengan beberapa field yang diperbarui.
  CategoryModel copyWith({
    final String? id,
    final String? name,
    final CategoryType? type,
    final List<SubCategoryModel>? subCategories,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subCategories: subCategories ?? this.subCategories,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper untuk mem-parsing nilai tanggal dari berbagai format.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Helper aman untuk mem-parsing enum dari string.
  static T? _safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null) return null;
    try {
      return values.firstWhere((final e) => e.name == name as String);
    } catch (e) {
      Log.warning('Gagal mem-parsing enum: $name');
      return null;
    }
  }

  /// Helper untuk mem-parsing boolean dari berbagai format.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [CategoryModel] dari data SQLite.
  factory CategoryModel.fromSqlite(final Map<String, dynamic> map) {
    List<SubCategoryModel> parseSubCategories(final dynamic data) {
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
                return SubCategoryModel.fromSqlite(item);
              }
              return null;
            })
            .whereType<SubCategoryModel>()
            .toList();
      } on Exception catch (e, st) {
        Log.warning('Gagal mem-parsing subkategori dari JSON', e: e, st: st);
        return [];
      }
    }

    return CategoryModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      type: _safeParseEnum(CategoryType.values, map[ColumnNames.type]) ??
          CategoryType.expense,
      subCategories: parseSubCategories(map[ColumnNames.subCategoryId]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi [CategoryModel] menjadi Map untuk penyimpanan SQLite.
  Map<String, dynamic> toSqlite() {
    final data = {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.type: type.name,
      ColumnNames.subCategoryId: jsonEncode(
        subCategories.map((final sub) => sub.toSqlite()).toList(),
      ),
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
    Log.info('CategoryModel.toSqlite: ${jsonEncode(data)}');
    return data;
  }

  /// Factory constructor untuk membuat [CategoryModel] dari data Firebase.
  factory CategoryModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    List<SubCategoryModel> parseSubCategories(final dynamic subCategoryData) {
      if (subCategoryData is List) {
        return subCategoryData
            .map((final item) {
              if (item is Map<String, dynamic>) {
                final String subId =
                    item[ColumnNames.id] as String? ?? const Uuid().v4();
                return SubCategoryModel.fromFirebase(subId, item);
              }
              return null;
            })
            .whereType<SubCategoryModel>()
            .toList();
      }
      return [];
    }

    return CategoryModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      type: _safeParseEnum(CategoryType.values, data[ColumnNames.type]) ??
          CategoryType.expense,
      subCategories: parseSubCategories(data[ColumnNames.subCategoryId]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi [CategoryModel] menjadi Map untuk penyimpanan Firebase.
  Map<String, dynamic> toFirebase() {
    final data = {
      ColumnNames.name: name,
      ColumnNames.type: type.name,
      ColumnNames.subCategoryId:
          subCategories.map((final sub) => sub.toFirebase()).toList(),
      ColumnNames.isDeleted: isDeleted, // <-- Typo diperbaiki di sini
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
    Log.info('CategoryModel.toFirebase: ${jsonEncode(data, toEncodable: (o) => o.toString())}');
    return data;
  }
}
