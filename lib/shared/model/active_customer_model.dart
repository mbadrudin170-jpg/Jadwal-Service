// path: lib/shared/model/active_customer_model.dart
// diubah: Menghapus parser internal dan menggunakan ParserUtil.
// diubah: Menambahkan .toUtc() saat menyimpan ke Firebase untuk konsistensi.
// diubah: Memastikan updatedAt tidak pernah null saat menyimpan ke Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Model for active customer data.
class ActiveCustomerModel implements HasId {
  @override
  final String id;

  /// The ID of the customer associated with this entry.
  final String customerId;

  /// The ID of the package purchased by the customer.
  final String packageId;

  /// The ID of the transaction associated with the package purchase.
  final String? transactionId;

  /// The start date of the package activation.
  final DateTime startDate;

  /// The end date of the package.
  final DateTime endDate;

  /// The payment status of the package.
  final PaymentStatus status;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this entry has been deleted (soft delete).
  final bool isDeleted;

  /// The time this entry was archived.
  final DateTime? archivedAt;

  /// Constructor for `ActiveCustomerModel`.
  ActiveCustomerModel({
    final String? id,
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
    final String? id,
    final String? customerId,
    final String? packageId,
    final String? transactionId,
    final DateTime? startDate,
    final DateTime? endDate,
    final PaymentStatus? status,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
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

  /// Creates an `ActiveCustomerModel` instance from SQLite map data.
  factory ActiveCustomerModel.fromSqlite(final Map<String, dynamic> map) {
    try {
      final startDate = ParserUtil.parseDateTime(map[ColumnNames.startDate]);
      final endDate = ParserUtil.parseDateTime(map[ColumnNames.endDate]);

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
          (final e) => e.name == map[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]),
        isDeleted: ParserUtil.parseBool(map[ColumnNames.isDeleted]),
        archivedAt: ParserUtil.parseDateTime(map[ColumnNames.archivedAt]),
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
      ColumnNames.updatedAt:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `ActiveCustomerModel` instance from Firebase map data.
  factory ActiveCustomerModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    try {
      final startDate = ParserUtil.parseDateTime(data[ColumnNames.startDate]);
      final endDate = ParserUtil.parseDateTime(data[ColumnNames.endDate]);

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
          (final e) => e.name == data[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: ParserUtil.parseDateTime(data[ColumnNames.updatedAt]),
        isDeleted: ParserUtil.parseBool(data[ColumnNames.isDeleted]),
        archivedAt: ParserUtil.parseDateTime(data[ColumnNames.archivedAt]),
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
    Log.info('Preparing toFirebase for ActiveCustomerModel $id');
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: Timestamp.fromDate(startDate.toUtc()),
      ColumnNames.endDate: Timestamp.fromDate(endDate.toUtc()),
      ColumnNames.status: status.name,
      ColumnNames.isDeleted: isDeleted,
      // DIUBAH: Memastikan updatedAt tidak pernah null.
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
