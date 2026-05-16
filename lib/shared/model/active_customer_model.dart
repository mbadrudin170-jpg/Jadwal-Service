// path: lib/shared/model/active_customer_model.dart
// new file: Refactored from pelanggan_aktif_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for active customer data.
class ActiveCustomerModel implements HasId {
  @override
  final String id;
  final String customerId;
  final String packageId;
  final String? transactionId;
  final DateTime startDate;
  final DateTime endDate;
  final PaymentStatus status;
  final DateTime? updatedAt;
  final bool isDeleted;
  final DateTime? archivedAt;

  /// Constructor for `ActiveCustomerModel`.
  ActiveCustomerModel({
    String? id,
    required this.customerId,
    required this.packageId,
    this.transactionId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('ActiveCustomerModel created: $id for customer $customerId');
  }

  /// Creates a copy of this `ActiveCustomerModel` with some modified values.
  ActiveCustomerModel copyWith({
    String? id,
    String? customerId,
    String? packageId,
    String? transactionId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentStatus? status,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? archivedAt,
  }) {
    return ActiveCustomerModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      transactionId: transactionId ?? this.transactionId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    Log.warning('Unrecognized DateTime format: $value');
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    Log.warning('Unrecognized Boolean format, defaulting to false: $value');
    return false;
  }

  /// Creates an `ActiveCustomerModel` instance from SQLite map data.
  factory ActiveCustomerModel.fromSqlite(Map<String, dynamic> map) {
    try {
      final startDate = _parseDateTime(map[ColumnNames.startDate]);
      final endDate = _parseDateTime(map[ColumnNames.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from SQLite');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from SQLite');
      }

      final model = ActiveCustomerModel(
        id: map[ColumnNames.id] as String,
        customerId: map[ColumnNames.customerId] as String? ?? '',
        packageId: map[ColumnNames.packageId] as String? ?? '',
        transactionId: map[ColumnNames.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (e) => e.name == map[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
        isDeleted: _parseBool(map[ColumnNames.isDeleted]),
        archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      );
      Log.info('ActiveCustomerModel loaded from SQLite: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from SQLite: $map', e: e, st: stack);
      rethrow;
    }
  }

  /// Converts `ActiveCustomerModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: startDate.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate.millisecondsSinceEpoch,
      ColumnNames.status: status.name,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `ActiveCustomerModel` instance from Firebase map data.
  factory ActiveCustomerModel.fromFirebase(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      final startDate = _parseDateTime(data[ColumnNames.startDate]);
      final endDate = _parseDateTime(data[ColumnNames.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from Firebase');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from Firebase');
      }

      final model = ActiveCustomerModel(
        id: id,
        customerId: data[ColumnNames.customerId] as String? ?? '',
        packageId: data[ColumnNames.packageId] as String? ?? '',
        transactionId: data[ColumnNames.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (e) => e.name == data[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
        isDeleted: _parseBool(data[ColumnNames.isDeleted]),
        archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
      );
      Log.info('ActiveCustomerModel loaded from Firebase: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from Firebase: $data', e: e, st: stack);
      rethrow;
    }
  }

  /// Converts `ActiveCustomerModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    Log.info('Preparing toFirebase for ActiveCustomerModel ${this.id}');
    return {
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: Timestamp.fromDate(startDate.toUtc()),
      ColumnNames.endDate: Timestamp.fromDate(endDate.toUtc()),
      ColumnNames.status: status.name,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
