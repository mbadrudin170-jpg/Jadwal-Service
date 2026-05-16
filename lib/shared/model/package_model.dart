// path: lib/shared/model/package_model.dart
// refactored: Complete rewrite to align with project conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for a package offered.
class PackageModel implements HasId {
  @override
  final String id;

  /// The name of the package.
  final String name;

  /// The price of the package.
  final int price;

  /// The duration of the package.
  final int duration;

  /// The type of duration for the package.
  final DurationType type;

  /// The number of points given as a reward for purchasing this package.
  final int rewardPoints;

  /// The number of points required to redeem this package.
  final int redemptionPoints;

  /// The status of whether this package is public or not.
  final bool isPublic;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this package has been deleted (soft delete).
  final bool isDeleted;

  /// The time this package was archived.
  final DateTime? archivedAt;

  /// Constructor for `PackageModel`.
  PackageModel({
    final String? id,
    required this.name,
    required this.price,
    required this.duration,
    required this.type,
    this.rewardPoints = 0,
    this.redemptionPoints = 0,
    this.isPublic = true,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('PackageModel created: $id, name: $name');
  }

  /// Creates a copy of this [PackageModel] with modified values.
  PackageModel copyWith({
    final String? id,
    final String? name,
    final int? price,
    final int? duration,
    final DurationType? type,
    final int? rewardPoints,
    final int? redemptionPoints,
    final bool? isPublic,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      redemptionPoints: redemptionPoints ?? this.redemptionPoints,
      isPublic: isPublic ?? this.isPublic,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final Object? value) {
    if (value == true || value == 1) return true;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Helper to parse DurationType from a string.
  static DurationType _parseType(final dynamic value) {
    return DurationType.values.firstWhere(
      (final e) => e.name == value,
      orElse: () => DurationType.days, // Default value
    );
  }

  /// Creates a `PackageModel` instance from SQLite map data.
  factory PackageModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating PackageModel from SQLite: ${map[ColumnNames.id]}');
    return PackageModel(
      id: map[ColumnNames.id] as String?,
      name: map[ColumnNames.name] as String? ?? '',
      price: map[ColumnNames.price] as int? ?? 0,
      duration: map[ColumnNames.duration] as int? ?? 0,
      type: _parseType(map[ColumnNames.type]),
      rewardPoints: map[ColumnNames.rewardPoints] as int? ?? 0,
      redemptionPoints: map[ColumnNames.redemptionPoints] as int? ?? 0,
      isPublic: _parseBool(map[ColumnNames.isPublic]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts `PackageModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.price: price,
      ColumnNames.duration: duration,
      ColumnNames.type: type.name,
      ColumnNames.rewardPoints: rewardPoints,
      ColumnNames.redemptionPoints: redemptionPoints,
      ColumnNames.isPublic: isPublic ? 1 : 0,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a `PackageModel` instance from Firebase map data.
  factory PackageModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating PackageModel from Firebase: $id');
    return PackageModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      price: data[ColumnNames.price] as int? ?? 0,
      duration: data[ColumnNames.duration] as int? ?? 0,
      type: _parseType(data[ColumnNames.type]),
      rewardPoints: data[ColumnNames.rewardPoints] as int? ?? 0,
      redemptionPoints: data[ColumnNames.redemptionPoints] as int? ?? 0,
      isPublic: _parseBool(data[ColumnNames.isPublic]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts `PackageModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.name: name,
      ColumnNames.price: price,
      ColumnNames.duration: duration,
      ColumnNames.type: type.name,
      ColumnNames.rewardPoints: rewardPoints,
      ColumnNames.redemptionPoints: redemptionPoints,
      ColumnNames.isPublic: isPublic,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
