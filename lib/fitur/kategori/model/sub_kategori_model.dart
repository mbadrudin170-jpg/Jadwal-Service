// path: lib/fitur/kategori/model/sub_kategori_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'sub_kategori_model.freezed.dart';

@freezed
abstract class SubKategoriModel with _$SubKategoriModel implements HasId {
  const SubKategoriModel._();
  const factory SubKategoriModel({
    required String id,
    required String nama,
    required String idKategori,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _SubKategoriModel;

  factory SubKategoriModel.fromSqlite(final Map<String, dynamic> map) {
    return SubKategoriModel(
      id: map[NamaKolom.id] as String? ?? '',
      nama: map[NamaKolom.nama] as String? ?? '',
      idKategori: map[NamaKolom.idKategori] as String? ?? '',
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.idKategori: idKategori,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  factory SubKategoriModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    return SubKategoriModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      idKategori: data[NamaKolom.idKategori] as String? ?? '',
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.idKategori: idKategori,
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((diperbaruiPada ?? DateTime.now()).toUtc()),
      NamaKolom.dihapus: diHapus,
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
