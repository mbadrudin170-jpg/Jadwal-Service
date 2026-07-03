// path lib/fitur/voucher/model/voucher_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'voucher_model.freezed.dart';

@freezed
abstract class VoucherModel with _$VoucherModel implements HasId {
  const VoucherModel._();

  const factory VoucherModel({
    required String id,
    required String voucher,
    required String idPaket,
    @Default(false) bool terpakai,
    @Default(false) bool dihapus,
    DateTime? diperbaruiPada,
    DateTime? diarsipkanPada,
  }) = _VoucherModel;

  factory VoucherModel.fromFirebase(String id, Map<String, dynamic> data) {
    return VoucherModel(
      id: id,
      voucher: data['voucher'] as String? ?? '',
      idPaket: data['idPaket'] as String? ?? '',
      terpakai: ParserUtil.parseBool(data['terpakai']),
      dihapus: ParserUtil.parseBool(data['dihapus']),
      diperbaruiPada: ParserUtil.parseDateTime(data['diperbaruiPada']),
      diarsipkanPada: ParserUtil.parseDateTime(data['diarsipkanPada']),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'voucher': voucher,
      'idPaket': idPaket,
      'terpakai': terpakai,
      'dihapus': dihapus,
      'diperbaruiPada': Timestamp.fromDate((diperbaruiPada ?? DateTime.now())),
      'diarsipkanPada': diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
    };
  }
}
