// path: lib/fitur/paket/model/paket_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'paket_model.freezed.dart';

@freezed
abstract class PaketModel with _$PaketModel implements HasId {
  const PaketModel._();
  const factory PaketModel({
    required String id,
    required String nama,
    required int harga,
    required int durasi,
    required TipeDurasiPaket tipe,
    @Default(0) int poinHadiah,
    @Default(0) int poinPenukaran,
    @Default(false) bool statusPublik,
    DateTime? diperbaruiPada,
    @Default(false) bool statusHapus,
    DateTime? diarsipkanPada,
  }) = _PaketModel;

  static TipeDurasiPaket _parseType(dynamic value) {
    return TipeDurasiPaket.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TipeDurasiPaket.days,
    );
  }

  factory PaketModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating PackageModel from SQLite: ${map[NamaKolom.id]}');
    return PaketModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      nama: map[NamaKolom.nama] as String? ?? '',
      harga: map[NamaKolom.harga] as int? ?? 0,
      durasi: map[NamaKolom.durasi] as int? ?? 0,
      tipe: _parseType(map[NamaKolom.tipe]),
      poinHadiah: map[NamaKolom.poinHadiah] as int? ?? 0,
      poinPenukaran: map[NamaKolom.poinPenukaran] as int? ?? 0,
      statusPublik: ParserUtil.parseBool(map[NamaKolom.statusPublik]),
      statusHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.harga: harga,
      NamaKolom.durasi: durasi,
      NamaKolom.tipe: tipe.name,
      NamaKolom.poinHadiah: poinHadiah,
      NamaKolom.poinPenukaran: poinPenukaran,
      NamaKolom.statusPublik: statusPublik ? 1 : 0,
      NamaKolom.dihapus: statusHapus ? 1 : 0,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  factory PaketModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating PackageModel from Firebase: $id');
    return PaketModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      harga: data[NamaKolom.harga] as int? ?? 0,
      durasi: data[NamaKolom.durasi] as int? ?? 0,
      tipe: _parseType(data[NamaKolom.tipe]),
      poinHadiah: data[NamaKolom.poinHadiah] as int? ?? 0,
      poinPenukaran: data[NamaKolom.poinPenukaran] as int? ?? 0,
      statusPublik: ParserUtil.parseBool(data[NamaKolom.statusPublik]),
      statusHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.harga: harga,
      NamaKolom.durasi: durasi,
      NamaKolom.tipe: tipe.name,
      NamaKolom.poinHadiah: poinHadiah,
      NamaKolom.poinPenukaran: poinPenukaran,
      NamaKolom.statusPublik: statusPublik,
      NamaKolom.dihapus: statusHapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
    };
  }
}
