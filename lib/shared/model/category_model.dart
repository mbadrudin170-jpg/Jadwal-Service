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

/// Model that represents a transaction category.
class CategoryModel implements HasId {
  @override
  final String id;

  /// The name of the category.
  final String name;

  /// The type of the category (e.g., expense, income).
  final CategoryType type;

  /// A list of sub-categories under this category.
  final List<SubCategoryModel> subCategories;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this category has been deleted (soft delete).
  final bool isDeleted;

  /// The time this category was archived.
  final DateTime? archivedAt;

  /// Main constructor for [CategoryModel].
  CategoryModel({
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

  /// Creates a copy of [CategoryModel] with some updated fields.
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

  /// Helper to parse date values from various formats.
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

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor to create [CategoryModel] from SQLite data.
  factory CategoryModel.fromSqlite(final Map<String, dynamic> map) {
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
        Log.error('Failed to parse subcategories from JSON', e: e, st: st);
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

  /// Converts [CategoryModel] to a Map for SQLite storage.
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
    return data;
  }

  /// Factory constructor to create [CategoryModel] from Firebase data.
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

  /// Converts [CategoryModel] to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    final data = {
      ColumnNames.name: name,
      ColumnNames.type: type.name,
      ColumnNames.subCategoryId:
          subCategories.map((final sub) => sub.toFirebase()).toList(),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
    return data;
  }
}
