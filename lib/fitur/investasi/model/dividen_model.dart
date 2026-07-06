// path: lib/fitur/investasi/model/dividen_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'dividen_model.freezed.dart';

@freezed
abstract class DividenModel with _$DividenModel implements HasId {
  const DividenModel._();
  const factory DividenModel({
    required String id,
    required String idInvestasi, // ID investasi terkait
    required String idInvestor, // ID pelanggan investor
    required double jumlahDividen,
    required DateTime tanggalPembagian,
    required bool sudahDibayar,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? diperbaruiPada,
  }) = _DividenModel;

  // ---------- SQLite ----------
  factory DividenModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating DividenModel from SQLite: ${map[NamaKolom.id]}');
    return DividenModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      idInvestasi: map[NamaKolom.idInvestasi] as String? ?? '',
      idInvestor: map[NamaKolom.idInvestor] as String? ?? '',
      jumlahDividen: (map[NamaKolom.jumlahDividen] as num?)?.toDouble() ?? 0.0,
      tanggalPembagian:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalPembagian]) ??
          DateTime.now(),
      sudahDibayar: ParserUtil.parseBool(map[NamaKolom.sudahDibayar]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idInvestasi: idInvestasi,
      NamaKolom.idInvestor: idInvestor,
      NamaKolom.jumlahDividen: jumlahDividen,
      NamaKolom.tanggalPembagian: tanggalPembagian.millisecondsSinceEpoch,
      NamaKolom.sudahDibayar: sudahDibayar ? 1 : 0,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  // ---------- Firebase ----------
  factory DividenModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating DividenModel from Firebase: $id');
    return DividenModel(
      id: id,
      idInvestasi: data[NamaKolom.idInvestasi] as String? ?? '',
      idInvestor: data[NamaKolom.idInvestor] as String? ?? '',
      jumlahDividen: (data[NamaKolom.jumlahDividen] as num?)?.toDouble() ?? 0.0,
      tanggalPembagian:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalPembagian]) ??
          DateTime.now(),
      sudahDibayar: ParserUtil.parseBool(data[NamaKolom.sudahDibayar]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.idInvestasi: idInvestasi,
      NamaKolom.idInvestor: idInvestor,
      NamaKolom.jumlahDividen: jumlahDividen,
      NamaKolom.tanggalPembagian: Timestamp.fromDate(tanggalPembagian),
      NamaKolom.sudahDibayar: sudahDibayar,
      NamaKolom.dihapus: diHapus,
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        diperbaruiPada ?? DateTime.now(),
      ),
    };
  }
}
