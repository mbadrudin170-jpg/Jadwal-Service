// path: lib/fitur/order/model/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'order_model.freezed.dart';

@freezed
abstract class OrderModel with _$OrderModel implements HasId {
  const OrderModel._(); // untuk method custom tambahan jika perlu

  // HAPUS @override di baris ini
  const factory OrderModel({
    @JsonKey(includeFromJson: false, includeToJson: false) required String id,
    required String customerId,
    required String packageId,
    required DateTime date,
    @Default(StatusOrderEnum.baru) StatusOrderEnum status,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    DateTime? archivedAt,
  }) = _OrderModel;
  // Pabrik untuk membuat id secara otomatis jika tidak diberikan
  factory OrderModel.create({
    String? id,
    required String customerId,
    required String packageId,
    required DateTime date,
    StatusOrderEnum status = StatusOrderEnum.baru,
    DateTime? updatedAt,
    bool isDeleted = false,
    DateTime? archivedAt,
  }) {
    final generatedId = id ?? const Uuid().v4();
    Log.info('OrderModel created: $generatedId for customer $customerId');
    return OrderModel(
      id: generatedId,
      customerId: customerId,
      packageId: packageId,
      date: date,
      status: status,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      archivedAt: archivedAt,
    );
  }

  // ---------- SQLite ----------
  factory OrderModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating OrderModel from SQLite: ${map[ColumnNames.id]}');
    return OrderModel(
      id: map[ColumnNames.id] as String? ?? '',
      customerId: map[ColumnNames.customerId] as String? ?? '',
      packageId: map[ColumnNames.packageId] as String? ?? '',
      date: ParserUtil.parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      status: _parseStatus(map[ColumnNames.status]),
      updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: ParserUtil.parseBool(map[ColumnNames.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.date: date.millisecondsSinceEpoch,
      ColumnNames.status: status.name,
      ColumnNames.updatedAt:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  // ---------- Firebase ----------
  factory OrderModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating OrderModel from Firebase: $id');
    // Kita bisa gunakan metode fromJson yang dihasilkan oleh Freezed
    // Tapi karena Firebase pakai Timestamp, perlu konversi.
    // Alternatif: buat dariJson manual seperti di bawah.
    return OrderModel(
      id: id,
      customerId: data[ColumnNames.customerId] as String? ?? '',
      packageId: data[ColumnNames.packageId] as String? ?? '',
      date: (data[ColumnNames.date] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(data[ColumnNames.status]),
      updatedAt: (data[ColumnNames.updatedAt] as Timestamp?)?.toDate(),
      isDeleted: data[ColumnNames.isDeleted] as bool? ?? false,
      archivedAt: (data[ColumnNames.archivedAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.date: Timestamp.fromDate(date.toUtc()),
      ColumnNames.status: status.name,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }

  // Helper enum parser (sama seperti milik Anda)
  static StatusOrderEnum _parseStatus(dynamic name) {
    if (name is! String) return StatusOrderEnum.baru;
    return StatusOrderEnum.values.firstWhere(
      (e) => e.name == name,
      orElse: () => StatusOrderEnum.baru,
    );
  }
}
