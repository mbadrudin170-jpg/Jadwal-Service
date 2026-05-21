// path: lib/shared/model/package_model.dart
// diubah: Menggunakan ParserUtil untuk konsistensi parsing dan .toUtc() untuk penyimpanan.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

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

  // DIHAPUS: Helper parsing internal dipindahkan ke ParserUtil

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
      // DIUBAH: Menggunakan ParserUtil
      isPublic: ParserUtil.parseBool(map[ColumnNames.isPublic]),
      isDeleted: ParserUtil.parseBool(map[ColumnNames.isDeleted]),
      updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(map[ColumnNames.archivedAt]),
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
      // DIUBAH: Memastikan updatedAt tidak pernah null
      ColumnNames.updatedAt:
          (updatedAt ?? DateTime.now()).toUtc().millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.toUtc().millisecondsSinceEpoch,
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
      // DIUBAH: Menggunakan ParserUtil
      isPublic: ParserUtil.parseBool(data[ColumnNames.isPublic]),
      isDeleted: ParserUtil.parseBool(data[ColumnNames.isDeleted]),
      updatedAt: ParserUtil.parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts `PackageModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id:id,
      ColumnNames.name: name,
      ColumnNames.price: price,
      ColumnNames.duration: duration,
      ColumnNames.type: type.name,
      ColumnNames.rewardPoints: rewardPoints,
      ColumnNames.redemptionPoints: redemptionPoints,
      ColumnNames.isPublic: isPublic,
      ColumnNames.isDeleted: isDeleted,
      // DIUBAH: Memastikan updatedAt tidak pernah null dan menggunakan .toUtc()
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      // DIUBAH: Menggunakan .toUtc() jika tidak null
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
