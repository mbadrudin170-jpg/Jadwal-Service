// path: lib/fitur/dompet/model/dompet_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'dompet_model.freezed.dart';

@freezed
abstract class DompetModel with _$DompetModel implements HasId {
  const DompetModel._();

  const factory DompetModel({
    required String id,
    required String nama,
    @Default(0.0) double saldo,
    DateTime? diperbaruiPada,
    @Default(false) bool dihapus,
    DateTime? diarsipkanPada,
  }) = _DompetModel;

  // Method dari SQLite
  factory DompetModel.fromSqlite(Map<String, dynamic> map) {
    final id = map[NamaKolom.id] as String?;
    return DompetModel(
      id: id ?? const Uuid().v4(),
      nama: (map[NamaKolom.nama] as String?) ?? '',
      saldo: (map[NamaKolom.saldo] as num?)?.toDouble() ?? 0.0,
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      dihapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.saldo: saldo,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: dihapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  // Method dari Firebase
  factory DompetModel.fromFirebase(String id, Map<String, dynamic> data) {
    return DompetModel(
      id: id,
      nama: (data[NamaKolom.nama] as String?) ?? '',
      saldo: (data[NamaKolom.saldo] as num?)?.toDouble() ?? 0.0,
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      dihapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.saldo: saldo,
      NamaKolom.dihapus: dihapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
    };
  }
}
