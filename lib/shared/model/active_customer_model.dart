// path: lib/shared/model/active_customer_model.dart
// diubah: Menghapus parser internal dan menggunakan ParserUtil.
// diubah: Menambahkan .toUtc() saat menyimpan ke Firebase untuk konsistensi.
// diubah: Memastikan updatedAt tidak pernah null saat menyimpan ke Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Model for active customer data.
class PelangganAktifModel implements HasId {
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
  PelangganAktifModel({
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
  PelangganAktifModel copyWith({
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
    return PelangganAktifModel(
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
  factory PelangganAktifModel.fromSqlite(final Map<String, dynamic> map) {
    try {
      final startDate = ParserUtil.parseDateTime(map[NamaKolom.startDate]);
      final endDate = ParserUtil.parseDateTime(map[NamaKolom.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from SQLite');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from SQLite');
      }

      final model = PelangganAktifModel(
        id: map[NamaKolom.id] as String,
        customerId: map[NamaKolom.customerId] as String? ?? '',
        packageId: map[NamaKolom.packageId] as String? ?? '',
        transactionId: map[NamaKolom.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (final e) => e.name == map[NamaKolom.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: ParserUtil.parseDateTime(map[NamaKolom.updatedAt]),
        isDeleted: ParserUtil.parseBool(map[NamaKolom.isDeleted]),
        archivedAt: ParserUtil.parseDateTime(map[NamaKolom.archivedAt]),
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
      NamaKolom.id: id,
      NamaKolom.customerId: customerId,
      NamaKolom.packageId: packageId,
      NamaKolom.transactionId: transactionId,
      NamaKolom.startDate: startDate.millisecondsSinceEpoch,
      NamaKolom.endDate: endDate.millisecondsSinceEpoch,
      NamaKolom.status: status.name,
      NamaKolom.updatedAt: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.isDeleted: isDeleted ? 1 : 0,
      NamaKolom.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `ActiveCustomerModel` instance from Firebase map data.
  factory PelangganAktifModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    try {
      final startDate = ParserUtil.parseDateTime(data[NamaKolom.startDate]);
      final endDate = ParserUtil.parseDateTime(data[NamaKolom.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from Firebase');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from Firebase');
      }

      final model = PelangganAktifModel(
        id: id,
        customerId: data[NamaKolom.customerId] as String? ?? '',
        packageId: data[NamaKolom.packageId] as String? ?? '',
        transactionId: data[NamaKolom.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (final e) => e.name == data[NamaKolom.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: ParserUtil.parseDateTime(data[NamaKolom.updatedAt]),
        isDeleted: ParserUtil.parseBool(data[NamaKolom.isDeleted]),
        archivedAt: ParserUtil.parseDateTime(data[NamaKolom.archivedAt]),
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
      NamaKolom.id: id,
      NamaKolom.customerId: customerId,
      NamaKolom.packageId: packageId,
      NamaKolom.transactionId: transactionId,
      NamaKolom.startDate: Timestamp.fromDate(startDate.toUtc()),
      NamaKolom.endDate: Timestamp.fromDate(endDate.toUtc()),
      NamaKolom.status: status.name,
      NamaKolom.isDeleted: isDeleted,
      // DIUBAH: Memastikan updatedAt tidak pernah null.
      NamaKolom.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      NamaKolom.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
