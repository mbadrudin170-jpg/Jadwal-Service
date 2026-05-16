// path: lib/shared/model/order_model.dart
// new file: Renamed from pesanan_model.dart and refactored to English.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for order data.
class OrderModel implements HasId {
  @override
  final String id;

  /// The ID of the customer who placed the order.
  final String customerId;

  /// The ID of the package ordered.
  final String packageId;

  /// The date the order was created.
  final DateTime date;

  /// The status of the order (e.g., "new", "processing", "completed").
  final String status;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this order has been deleted (soft delete).
  final bool isDeleted;

  /// The time this order was archived.
  final DateTime? archivedAt;

  /// Constructor for `OrderModel`.
  OrderModel({
    final String? id,
    required this.customerId,
    required this.packageId,
    required this.date,
    required this.status,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('OrderModel created: $id for customer $customerId');
  }

  /// Creates a copy of `OrderModel` with some modified values.
  OrderModel copyWith({
    final String? id,
    final String? customerId,
    final String? packageId,
    final DateTime? date,
    final String? status,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      date: date ?? this.date,
      status: status ?? this.status,
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
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
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

  /// Creates an `OrderModel` instance from SQLite map data.
  factory OrderModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating OrderModel from SQLite: ${map[ColumnNames.id]}');
    return OrderModel(
      id: map[ColumnNames.id] as String? ?? '',
      customerId: map[ColumnNames.customerId] as String? ?? '',
      packageId: map[ColumnNames.packageId] as String? ?? '',
      date: _parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      status: map[ColumnNames.status] as String? ?? 'new',
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts `OrderModel` to a Map format for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.date: date.millisecondsSinceEpoch,
      ColumnNames.status: status,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `OrderModel` instance from Firebase map data.
  factory OrderModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating OrderModel from Firebase: $id');
    return OrderModel(
      id: id,
      customerId: data[ColumnNames.customerId] as String? ?? '',
      packageId: data[ColumnNames.packageId] as String? ?? '',
      date: _parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
      status: data[ColumnNames.status] as String? ?? 'new',
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts `OrderModel` to a Map format for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.date: Timestamp.fromDate(date.toUtc()),
      ColumnNames.status: status,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
