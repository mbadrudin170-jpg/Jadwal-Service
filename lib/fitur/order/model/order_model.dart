// path: lib/fitur/order/model/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'order_model.freezed.dart';

@freezed
abstract class OrderModel with _$OrderModel implements HasId {
  const OrderModel._();
  const factory OrderModel({
    required String id,
    required String idPelanggan,
    required String idPaket,
    required DateTime tanggal,
    required StatusOrderEnum status,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _OrderModel;

  // ---------- SQLite ----------
  factory OrderModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating OrderModel from SQLite: ${map[NamaKolom.id]}');
    return OrderModel(
      id: map[NamaKolom.id] as String? ?? '',
      idPelanggan: map[NamaKolom.idPelanggan] as String? ?? '',
      idPaket: map[NamaKolom.idPaket] as String? ?? '',
      tanggal:
          ParserUtil.parseDateTime(map[NamaKolom.tanggal]) ?? DateTime.now(),
      status: _parseStatus(map[NamaKolom.status]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.tanggal: tanggal.millisecondsSinceEpoch,
      NamaKolom.status: status.name,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  // ---------- Firebase ----------
  factory OrderModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating OrderModel from Firebase: $id');
    return OrderModel(
      id: id,
      idPelanggan: data[NamaKolom.idPelanggan] as String? ?? '',
      idPaket: data[NamaKolom.idPaket] as String? ?? '',
      tanggal:
          (data[NamaKolom.tanggal] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(data[NamaKolom.status]),
      diperbaruiPada: (data[NamaKolom.diperbaruiPada] as Timestamp?)?.toDate(),
      diHapus: data[NamaKolom.dihapus] as bool? ?? false,
      diarsipkanPada: (data[NamaKolom.diarsipkanPada] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.tanggal: Timestamp.fromDate(tanggal),
      NamaKolom.status: status.name,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()),
      ),
      NamaKolom.dihapus: diHapus,
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
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
