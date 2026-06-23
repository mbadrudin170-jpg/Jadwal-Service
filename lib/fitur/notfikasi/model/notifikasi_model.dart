// path: lib/fitur/notfikasi/model/notifikasi_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'notifikasi_model.freezed.dart';

@freezed
abstract class NotifikasiModel with _$NotifikasiModel implements HasId {
  const NotifikasiModel._();
  const factory NotifikasiModel({
    required String id,
    required DateTime tanggalMulai,
    required DateTime tanggalBerakhir,
    required DateTime tanggalTampil,
    required String judul,
    required String deskripsi,
    @Default(false) bool setatusDibaca,
    required TipeNotifikasiEnum tipe,
    required DateTime diperbaruiPada,
    required String idTujuan,
    required String userId,
    @Default(false) bool dihapus,
    DateTime? diarsipkanPada,
    required AppRole targetRole,
  }) = _NotifikasiModel;

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

  factory NotifikasiModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating NotifikasiModel from SQLite: ${map[NamaKolom.id]}');
    return NotifikasiModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      tanggalMulai:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tanggalBerakhir:
          ParserUtil.parseDateTime(map[NamaKolom.tangglBerakhir]) ??
          DateTime.now(),
      judul: map[NamaKolom.judul] as String? ?? '',
      deskripsi: map[NamaKolom.deskripsi] as String? ?? '',
      setatusDibaca: ParserUtil.parseBool(map[NamaKolom.setatusDibaca]),
      tipe:
          _safeParseEnum(TipeNotifikasiEnum.values, map[NamaKolom.tipe]) ??
          TipeNotifikasiEnum.transaksi,
      diperbaruiPada:
          ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]) ??
          DateTime.now(),
      idTujuan: map[NamaKolom.idTujuan] as String? ?? '',
      targetRole:
          _safeParseEnum(AppRole.values, map[NamaKolom.targetRole]) ??
          AppRole.user,
      userId: map[NamaKolom.userId] as String? ?? '',
      dihapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      tanggalTampil:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggalMulai: tanggalMulai.millisecondsSinceEpoch,
      NamaKolom.tangglBerakhir: tanggalBerakhir.millisecondsSinceEpoch,
      NamaKolom.judul: judul,
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.setatusDibaca: setatusDibaca ? 1 : 0,
      NamaKolom.tipe: tipe.name,
      NamaKolom.diperbaruiPada: diperbaruiPada.millisecondsSinceEpoch,
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.targetRole: targetRole.name,
      NamaKolom.userId: userId,
      NamaKolom.dihapus: dihapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.tanggalTampil: tanggalTampil.millisecondsSinceEpoch,
    };
  }

  factory NotifikasiModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Creating NotifikasiModel from Firebase: $id');
    return NotifikasiModel(
      id: id,
      tanggalMulai:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tanggalBerakhir:
          ParserUtil.parseDateTime(data[NamaKolom.tangglBerakhir]) ??
          DateTime.now(),
      tanggalTampil:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
      judul: data[NamaKolom.judul] as String? ?? '',
      deskripsi: data[NamaKolom.deskripsi] as String? ?? '',
      setatusDibaca: ParserUtil.parseBool(data[NamaKolom.setatusDibaca]),
      tipe:
          _safeParseEnum(TipeNotifikasiEnum.values, data[NamaKolom.tipe]) ??
          TipeNotifikasiEnum.transaksi,
      diperbaruiPada:
          ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]) ??
          DateTime.now(),
      idTujuan: data[NamaKolom.idTujuan] as String? ?? '',
      targetRole:
          _safeParseEnum(AppRole.values, data[NamaKolom.targetRole]) ??
          AppRole.user,
      userId: data[NamaKolom.userId] as String? ?? '',
      dihapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggalMulai: Timestamp.fromDate(tanggalMulai.toUtc()),
      NamaKolom.tangglBerakhir: Timestamp.fromDate(tanggalBerakhir.toUtc()),
      NamaKolom.judul: judul,
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.setatusDibaca: setatusDibaca,
      NamaKolom.tipe: tipe.name,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(diperbaruiPada.toUtc()),
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.targetRole: targetRole.name,
      NamaKolom.userId: userId,
      NamaKolom.dihapus: dihapus,
      NamaKolom.tanggalTampil: Timestamp.fromDate(tanggalTampil.toUtc()),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
