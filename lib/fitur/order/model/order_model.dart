// path: lib/fitur/order/model/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
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
    Log.info('Creating OrderModel from SQLite: ${map[NamaKolom.id]}');
    return OrderModel(
      id: map[NamaKolom.id] as String? ?? '',
      customerId: map[NamaKolom.idPelanggan] as String? ?? '',
      packageId: map[NamaKolom.idPaket] as String? ?? '',
      date: ParserUtil.parseDateTime(map[NamaKolom.tanggal]) ?? DateTime.now(),
      status: _parseStatus(map[NamaKolom.status]),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: customerId,
      NamaKolom.idPaket: packageId,
      NamaKolom.tanggal: date.millisecondsSinceEpoch,
      NamaKolom.status: status.name,
      NamaKolom.diperbaruiPada:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diHapus: isDeleted ? 1 : 0,
      NamaKolom.diarsipkanPada: archivedAt?.millisecondsSinceEpoch,
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
      customerId: data[NamaKolom.idPelanggan] as String? ?? '',
      packageId: data[NamaKolom.idPaket] as String? ?? '',
      date: (data[NamaKolom.tanggal] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(data[NamaKolom.status]),
      updatedAt: (data[NamaKolom.diperbaruiPada] as Timestamp?)?.toDate(),
      isDeleted: data[NamaKolom.diHapus] as bool? ?? false,
      archivedAt: (data[NamaKolom.diarsipkanPada] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: customerId,
      NamaKolom.idPaket: packageId,
      NamaKolom.tanggal: Timestamp.fromDate(date.toUtc()),
      NamaKolom.status: status.name,
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      NamaKolom.diHapus: isDeleted,
      NamaKolom.diarsipkanPada:
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
