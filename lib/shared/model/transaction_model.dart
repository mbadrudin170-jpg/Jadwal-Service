// path: lib/shared/model/transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

class TransaksiModel implements HasId {
  @override
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final TransactionType type;
  final String walletId;
  final String categoryId;
  final String? destinationWalletId;
  final String? customerId;
  final String? packageId;
  final String? idSubKategori;
  final PaymentStatus paymentStatus;
  final int earnedPoints;
  final int usedPoints;
  final DateTime? updatedAt;
  final DateTime? archivedAt;
  final bool isDeleted;
  final int? packageDuration;
  final DurationType? durationType;
  final int? durasiBonus;
  final DurationType? durasiBonusType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActivated;

  TransaksiModel({
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
    this.idSubKategori,
    this.paymentStatus = PaymentStatus.unpaid,
    this.earnedPoints = 0,
    this.usedPoints = 0,
    this.updatedAt,
    this.archivedAt,
    this.isDeleted = false,
    this.packageDuration,
    this.durationType,
    this.durasiBonus,
    this.durasiBonusType,
    this.startDate,
    this.endDate,
    this.isActivated = false,
  }) : id = id ?? const Uuid().v4() {
    Log.info('TransactionModel created: $id, type: ${type.name}');
  }

  TransaksiModel copyWith({
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
    final int? durasiBonus,
    final DurationType? durasiBonusType,
    final DateTime? startDate,
    final DateTime? endDate,
    final bool? isActivated,
  }) {
    return TransaksiModel(
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
      idSubKategori: subCategoryId ?? this.idSubKategori,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      usedPoints: usedPoints ?? this.usedPoints,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      packageDuration: packageDuration ?? this.packageDuration,
      durationType: durationType ?? this.durationType,
      durasiBonus: durasiBonus ?? this.durasiBonus,
      durasiBonusType: durasiBonusType ?? this.durasiBonusType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActivated: isActivated ?? this.isActivated,
    );
  }

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

  factory TransaksiModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating TransactionModel from SQLite: ${map[NamaKolom.id]}');
    return TransaksiModel(
      id: map[NamaKolom.id] as String? ?? '',
      date: ParserUtil.parseDateTime(map[NamaKolom.date]) ?? DateTime.now(),
      description: map[NamaKolom.description] as String? ?? '',
      amount: (map[NamaKolom.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, map[NamaKolom.type]) ??
          TransactionType.expense,
      walletId: map[NamaKolom.walletId] as String? ?? '',
      categoryId: map[NamaKolom.categoryId] as String? ?? '',
      destinationWalletId: map[NamaKolom.destinationWalletId] as String?,
      customerId: map[NamaKolom.customerId] as String?,
      packageId: map[NamaKolom.packageId] as String?,
      idSubKategori: map[NamaKolom.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            map[NamaKolom.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (map[NamaKolom.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (map[NamaKolom.usedPoints] as num? ?? 0).toInt(),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.archivedAt]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.isDeleted]),
      packageDuration: (map[NamaKolom.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, map[NamaKolom.durationType]),
      durasiBonus: (map[NamaKolom.durasiBonus] as num? ?? 0).toInt(),
      durasiBonusType: _safeParseEnum(
        DurationType.values,
        map[NamaKolom.durasiBonusType],
      ),
      startDate: ParserUtil.parseDateTime(map[NamaKolom.startDate]),
      endDate: ParserUtil.parseDateTime(map[NamaKolom.endDate]),
      isActivated: ParserUtil.parseBool(map[NamaKolom.isActivated]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.date: date.millisecondsSinceEpoch,
      NamaKolom.description: description,
      NamaKolom.amount: amount,
      NamaKolom.type: type.name,
      NamaKolom.walletId: walletId,
      NamaKolom.categoryId: categoryId,
      NamaKolom.destinationWalletId: destinationWalletId,
      NamaKolom.customerId: customerId,
      NamaKolom.packageId: packageId,
      NamaKolom.subCategoryId: idSubKategori,
      NamaKolom.paymentStatus: paymentStatus.name,
      NamaKolom.earnedPoints: earnedPoints,
      NamaKolom.usedPoints: usedPoints,
      NamaKolom.updatedAt: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.archivedAt: archivedAt?.millisecondsSinceEpoch,
      NamaKolom.isDeleted: isDeleted ? 1 : 0,
      NamaKolom.packageDuration: packageDuration,
      NamaKolom.durationType: durationType?.name,
      NamaKolom.durasiBonus: durasiBonus,
      NamaKolom.durasiBonusType: durasiBonusType?.name,
      NamaKolom.startDate: startDate?.millisecondsSinceEpoch,
      NamaKolom.endDate: endDate?.millisecondsSinceEpoch,
      NamaKolom.isActivated: isActivated ? 1 : 0,
    };
  }

  factory TransaksiModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating TransactionModel from Firebase: $id');
    return TransaksiModel(
      id: id,
      date: ParserUtil.parseDateTime(data[NamaKolom.date]) ?? DateTime.now(),
      description: data[NamaKolom.description] as String? ?? '',
      amount: (data[NamaKolom.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, data[NamaKolom.type]) ??
          TransactionType.expense,
      walletId: data[NamaKolom.walletId] as String? ?? '',
      categoryId: data[NamaKolom.categoryId] as String? ?? '',
      destinationWalletId: data[NamaKolom.destinationWalletId] as String?,
      customerId: data[NamaKolom.customerId] as String?,
      packageId: data[NamaKolom.packageId] as String?,
      idSubKategori: data[NamaKolom.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            data[NamaKolom.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (data[NamaKolom.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (data[NamaKolom.usedPoints] as num? ?? 0).toInt(),
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.archivedAt]),
      isDeleted: ParserUtil.parseBool(data[NamaKolom.isDeleted]),
      packageDuration: (data[NamaKolom.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, data[NamaKolom.durationType]),
      durasiBonus: (data[NamaKolom.durasiBonus] as num? ?? 0).toInt(),
      durasiBonusType: _safeParseEnum(
        DurationType.values,
        data[NamaKolom.durasiBonusType],
      ),
      startDate: ParserUtil.parseDateTime(data[NamaKolom.startDate]),
      endDate: ParserUtil.parseDateTime(data[NamaKolom.endDate]),
      isActivated: ParserUtil.parseBool(data[NamaKolom.isActivated]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.date: Timestamp.fromDate(date.toUtc()),
      NamaKolom.description: description,
      NamaKolom.amount: amount,
      NamaKolom.type: type.name,
      NamaKolom.walletId: walletId,
      NamaKolom.categoryId: categoryId,
      NamaKolom.destinationWalletId: destinationWalletId,
      NamaKolom.customerId: customerId,
      NamaKolom.packageId: packageId,
      NamaKolom.subCategoryId: idSubKategori,
      NamaKolom.paymentStatus: paymentStatus.name,
      NamaKolom.earnedPoints: earnedPoints,
      NamaKolom.usedPoints: usedPoints,
      NamaKolom.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      NamaKolom.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
      NamaKolom.isDeleted: isDeleted,
      NamaKolom.packageDuration: packageDuration,
      NamaKolom.durationType: durationType?.name,
      NamaKolom.durasiBonus: durasiBonus,
      NamaKolom.durasiBonusType: durasiBonusType?.name,
      NamaKolom.startDate:
          startDate != null ? Timestamp.fromDate(startDate!.toUtc()) : null,
      NamaKolom.endDate:
          endDate != null ? Timestamp.fromDate(endDate!.toUtc()) : null,
      NamaKolom.isActivated: isActivated,
    };
  }
}
