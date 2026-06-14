// path: lib/shared/model/transaksi_model.dart

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
      date: ParserUtil.parseDateTime(map[NamaKolom.tanggal]) ?? DateTime.now(),
      description: map[NamaKolom.deskripsi] as String? ?? '',
      amount: (map[NamaKolom.jumlah] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, map[NamaKolom.tipe]) ??
          TransactionType.expense,
      walletId: map[NamaKolom.idDompet] as String? ?? '',
      categoryId: map[NamaKolom.idKategori] as String? ?? '',
      destinationWalletId: map[NamaKolom.idDompetTujuan] as String?,
      customerId: map[NamaKolom.idPelanggan] as String?,
      packageId: map[NamaKolom.idPaket] as String?,
      idSubKategori: map[NamaKolom.idSubKategori] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            map[NamaKolom.statusPembayaran],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (map[NamaKolom.poinDidapat] as num? ?? 0).toInt(),
      usedPoints: (map[NamaKolom.poinDigunakan] as num? ?? 0).toInt(),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      packageDuration: (map[NamaKolom.durasiPaket] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, map[NamaKolom.tipeDurasiPaket]),
      durasiBonus: (map[NamaKolom.durasiBonus] as num? ?? 0).toInt(),
      durasiBonusType: _safeParseEnum(
        DurationType.values,
        map[NamaKolom.durasiBonusType],
      ),
      startDate: ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]),
      endDate: ParserUtil.parseDateTime(map[NamaKolom.tangglberakhir]),
      isActivated: ParserUtil.parseBool(map[NamaKolom.statusAktivasi]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggal: date.millisecondsSinceEpoch,
      NamaKolom.deskripsi: description,
      NamaKolom.jumlah: amount,
      NamaKolom.tipe: type.name,
      NamaKolom.idDompet: walletId,
      NamaKolom.idKategori: categoryId,
      NamaKolom.idDompetTujuan: destinationWalletId,
      NamaKolom.idPelanggan: customerId,
      NamaKolom.idPaket: packageId,
      NamaKolom.idSubKategori: idSubKategori,
      NamaKolom.statusPembayaran: paymentStatus.name,
      NamaKolom.poinDidapat: earnedPoints,
      NamaKolom.poinDigunakan: usedPoints,
      NamaKolom.diperbaruiPada:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diarsipkanPada: archivedAt?.millisecondsSinceEpoch,
      NamaKolom.diHapus: isDeleted ? 1 : 0,
      NamaKolom.durasiPaket: packageDuration,
      NamaKolom.tipeDurasiPaket: durationType?.name,
      NamaKolom.durasiBonus: durasiBonus,
      NamaKolom.durasiBonusType: durasiBonusType?.name,
      NamaKolom.tanggalMulai: startDate?.millisecondsSinceEpoch,
      NamaKolom.tangglberakhir: endDate?.millisecondsSinceEpoch,
      NamaKolom.statusAktivasi: isActivated ? 1 : 0,
    };
  }

  factory TransaksiModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating TransactionModel from Firebase: $id');
    return TransaksiModel(
      id: id,
      date: ParserUtil.parseDateTime(data[NamaKolom.tanggal]) ?? DateTime.now(),
      description: data[NamaKolom.deskripsi] as String? ?? '',
      amount: (data[NamaKolom.jumlah] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, data[NamaKolom.tipe]) ??
          TransactionType.expense,
      walletId: data[NamaKolom.idDompet] as String? ?? '',
      categoryId: data[NamaKolom.idKategori] as String? ?? '',
      destinationWalletId: data[NamaKolom.idDompetTujuan] as String?,
      customerId: data[NamaKolom.idPelanggan] as String?,
      packageId: data[NamaKolom.idPaket] as String?,
      idSubKategori: data[NamaKolom.idSubKategori] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            data[NamaKolom.statusPembayaran],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (data[NamaKolom.poinDidapat] as num? ?? 0).toInt(),
      usedPoints: (data[NamaKolom.poinDigunakan] as num? ?? 0).toInt(),
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      isDeleted: ParserUtil.parseBool(data[NamaKolom.diHapus]),
      packageDuration: (data[NamaKolom.durasiPaket] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, data[NamaKolom.tipeDurasiPaket]),
      durasiBonus: (data[NamaKolom.durasiBonus] as num? ?? 0).toInt(),
      durasiBonusType: _safeParseEnum(
        DurationType.values,
        data[NamaKolom.durasiBonusType],
      ),
      startDate: ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]),
      endDate: ParserUtil.parseDateTime(data[NamaKolom.tangglberakhir]),
      isActivated: ParserUtil.parseBool(data[NamaKolom.statusAktivasi]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggal: Timestamp.fromDate(date.toUtc()),
      NamaKolom.deskripsi: description,
      NamaKolom.jumlah: amount,
      NamaKolom.tipe: type.name,
      NamaKolom.idDompet: walletId,
      NamaKolom.idKategori: categoryId,
      NamaKolom.idDompetTujuan: destinationWalletId,
      NamaKolom.idPelanggan: customerId,
      NamaKolom.idPaket: packageId,
      NamaKolom.idSubKategori: idSubKategori,
      NamaKolom.statusPembayaran: paymentStatus.name,
      NamaKolom.poinDidapat: earnedPoints,
      NamaKolom.poinDigunakan: usedPoints,
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      NamaKolom.diarsipkanPada:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
      NamaKolom.diHapus: isDeleted,
      NamaKolom.durasiPaket: packageDuration,
      NamaKolom.tipeDurasiPaket: durationType?.name,
      NamaKolom.durasiBonus: durasiBonus,
      NamaKolom.durasiBonusType: durasiBonusType?.name,
      NamaKolom.tanggalMulai:
          startDate != null ? Timestamp.fromDate(startDate!.toUtc()) : null,
      NamaKolom.tangglberakhir:
          endDate != null ? Timestamp.fromDate(endDate!.toUtc()) : null,
      NamaKolom.statusAktivasi: isActivated,
    };
  }
}
