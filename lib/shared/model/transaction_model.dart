// path: lib/shared/model/transaction_model.dart
// diubah: Menghapus parser internal dan menggunakan ParserUtil.
// diubah: Menambahkan .toUtc() saat menyimpan ke Firebase untuk konsistensi.
// diubah: Memastikan updatedAt tidak pernah null saat menyimpan ke Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Model that represents a single transaction in the application.
class TransactionModel implements HasId {
  @override
  final String id;

  /// The date and time when the transaction was created.
  final DateTime date;

  /// A description or note about the transaction.
  final String description;

  /// The amount of the transaction.
  final double amount;

  /// The type of transaction (e.g., income, expense, transfer, subscription).
  final TransactionType type;

  /// The ID of the source wallet.
  final String walletId;

  /// The ID of the main category of the transaction.
  final String categoryId;

  /// The ID of the destination wallet, only used for transfer transactions.
  final String? destinationWalletId;

  /// The ID of the customer associated with this transaction.
  final String? customerId;

  /// The ID of the package, if this is a subscription activation.
  final String? packageId;

  /// The ID of the sub-category of the transaction.
  final String? subCategoryId;

  /// The payment status of the transaction (e.g., paid, unpaid).
  final PaymentStatus paymentStatus;

  /// The number of points earned from this transaction.
  final int earnedPoints;

  /// The number of points used in this transaction.
  final int usedPoints;

  /// The last time this data was updated.
  final DateTime? updatedAt;

  /// The time this data was archived.
  final DateTime? archivedAt;

  /// A flag indicating if this data has been deleted (soft delete).
  final bool isDeleted;

  /// The duration of the subscription package (e.g., 30).
  final int? packageDuration;

  /// The type of duration for the package (e.g., day, month).
  final DurationType? durationType;

  /// The start date of the subscription period.
  final DateTime? startDate;

  /// The end date of the subscription period.
  final DateTime? endDate;

  /// A flag indicating if this is a new package activation.
  final bool isActivated;

  /// Main constructor for creating a [TransactionModel] instance.
  TransactionModel({
    final String? id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.walletId,
    required this.categoryId,
    this.destinationWalletId,
    this.customerId,
    this.packageId,
    this.subCategoryId,
    this.paymentStatus = PaymentStatus.unpaid,
    this.earnedPoints = 0,
    this.usedPoints = 0,
    this.updatedAt,
    this.archivedAt,
    this.isDeleted = false,
    this.packageDuration,
    this.durationType,
    this.startDate,
    this.endDate,
    this.isActivated = false,
  }) : id = id ?? const Uuid().v4() {
    Log.info('TransactionModel created: $id, type: ${type.name}');
  }

  /// Creates a copy of this [TransactionModel] with some modified values.
  TransactionModel copyWith({
    final String? id,
    final DateTime? date,
    final String? description,
    final double? amount,
    final TransactionType? type,
    final String? walletId,
    final String? categoryId,
    final String? destinationWalletId,
    final String? customerId,
    final String? packageId,
    final String? subCategoryId,
    final PaymentStatus? paymentStatus,
    final int? earnedPoints,
    final int? usedPoints,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
    final bool? isDeleted,
    final int? packageDuration,
    final DurationType? durationType,
    final DateTime? startDate,
    final DateTime? endDate,
    final bool? isActivated,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      destinationWalletId: destinationWalletId ?? this.destinationWalletId,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      usedPoints: usedPoints ?? this.usedPoints,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      packageDuration: packageDuration ?? this.packageDuration,
      durationType: durationType ?? this.durationType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActivated: isActivated ?? this.isActivated,
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

  /// Factory constructor to create [TransactionModel] from SQLite data.
  factory TransactionModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating TransactionModel from SQLite: ${map[ColumnNames.id]}');
    return TransactionModel(
      id: map[ColumnNames.id] as String? ?? '',
      date: ParserUtil.parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      description: map[ColumnNames.description] as String? ?? '',
      amount: (map[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, map[ColumnNames.type]) ??
          TransactionType.expense,
      walletId: map[ColumnNames.walletId] as String? ?? '',
      categoryId: map[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: map[ColumnNames.destinationWalletId] as String?,
      customerId: map[ColumnNames.customerId] as String?,
      packageId: map[ColumnNames.packageId] as String?,
      subCategoryId: map[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            map[ColumnNames.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (map[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (map[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(map[ColumnNames.archivedAt]),
      isDeleted: ParserUtil.parseBool(map[ColumnNames.isDeleted]),
      packageDuration: (map[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, map[ColumnNames.durationType]),
      startDate: ParserUtil.parseDateTime(map[ColumnNames.startDate]),
      endDate: ParserUtil.parseDateTime(map[ColumnNames.endDate]),
      isActivated: ParserUtil.parseBool(map[ColumnNames.isActivated]),
    );
  }

  /// Converts this [TransactionModel] to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.date: date.millisecondsSinceEpoch,
      ColumnNames.description: description,
      ColumnNames.amount: amount,
      ColumnNames.type: type.name,
      ColumnNames.walletId: walletId,
      ColumnNames.categoryId: categoryId,
      ColumnNames.destinationWalletId: destinationWalletId,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.subCategoryId: subCategoryId,
      ColumnNames.paymentStatus: paymentStatus.name,
      ColumnNames.earnedPoints: earnedPoints,
      ColumnNames.usedPoints: usedPoints,
      ColumnNames.updatedAt:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate: startDate?.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate?.millisecondsSinceEpoch,
      ColumnNames.isActivated: isActivated ? 1 : 0,
    };
  }

  /// Factory constructor to create [TransactionModel] from Firebase data.
  factory TransactionModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating TransactionModel from Firebase: $id');
    return TransactionModel(
      id: id,
      date: ParserUtil.parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
      description: data[ColumnNames.description] as String? ?? '',
      amount: (data[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, data[ColumnNames.type]) ??
          TransactionType.expense,
      walletId: data[ColumnNames.walletId] as String? ?? '',
      categoryId: data[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: data[ColumnNames.destinationWalletId] as String?,
      customerId: data[ColumnNames.customerId] as String?,
      packageId: data[ColumnNames.packageId] as String?,
      subCategoryId: data[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            data[ColumnNames.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (data[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (data[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: ParserUtil.parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(data[ColumnNames.archivedAt]),
      isDeleted: ParserUtil.parseBool(data[ColumnNames.isDeleted]),
      packageDuration: (data[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, data[ColumnNames.durationType]),
      startDate: ParserUtil.parseDateTime(data[ColumnNames.startDate]),
      endDate: ParserUtil.parseDateTime(data[ColumnNames.endDate]),
      isActivated: ParserUtil.parseBool(data[ColumnNames.isActivated]),
    );
  }

  /// Converts this [TransactionModel] to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id: id,
      ColumnNames.date: Timestamp.fromDate(date.toUtc()),
      ColumnNames.description: description,
      ColumnNames.amount: amount,
      ColumnNames.type: type.name,
      ColumnNames.walletId: walletId,
      ColumnNames.categoryId: categoryId,
      ColumnNames.destinationWalletId: destinationWalletId,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.subCategoryId: subCategoryId,
      ColumnNames.paymentStatus: paymentStatus.name,
      ColumnNames.earnedPoints: earnedPoints,
      ColumnNames.usedPoints: usedPoints,
      // DIUBAH: Memastikan updatedAt tidak pernah null.
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate:
          startDate != null ? Timestamp.fromDate(startDate!.toUtc()) : null,
      ColumnNames.endDate:
          endDate != null ? Timestamp.fromDate(endDate!.toUtc()) : null,
      ColumnNames.isActivated: isActivated,
    };
  }
}
