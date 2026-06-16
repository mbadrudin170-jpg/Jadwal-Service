// path: lib/shared/model/notifikasi_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

class NotifikasiModel implements HasId {
  @override
  final String id;
  final DateTime tanggalMulai;
  final DateTime tangglberakhir;
  final DateTime tanggalTampil;
  final String judul;
  final String deskripsi;
  final bool setatusDibaca;
  final TipeNotifikasiEnum tipe;
  final DateTime diperbaruiPada;
  final String idTujuan;
  final String userId;
  final bool dihapus;
  final DateTime? diarsipkanPada;

  NotifikasiModel({
    final String? id,
    required this.tanggalMulai,
    required this.tangglberakhir,
    required this.tanggalTampil,
    required this.judul,
    required this.deskripsi,
    this.setatusDibaca = false,
    required this.tipe,
    required this.diperbaruiPada,
    required this.idTujuan,
    required this.userId,
    this.dihapus = false,
    this.diarsipkanPada,
  }) : id = id ?? const Uuid().v4() {
    Log.info('NotifikasiModel created: $id, title: $judul');
  }

  NotifikasiModel copyWith({
    final String? id,
    final DateTime? startDate,
    final DateTime? endDate,
    final DateTime? tanggalTampil,
    final String? title,
    final String? description,
    final bool? isRead,
    final TipeNotifikasiEnum? type,
    final DateTime? updatedAt,
    final String? idTujuan,
    final String? userId,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return NotifikasiModel(
      id: id ?? this.id,
      tanggalMulai: startDate ?? this.tanggalMulai,
      tangglberakhir: endDate ?? this.tangglberakhir,
      judul: title ?? this.judul,
      deskripsi: description ?? this.deskripsi,
      setatusDibaca: isRead ?? this.setatusDibaca,
      tipe: type ?? this.tipe,
      diperbaruiPada: updatedAt ?? this.diperbaruiPada,
      idTujuan: idTujuan ?? this.idTujuan,
      userId: userId ?? this.userId,
      dihapus: isDeleted ?? this.dihapus,
      diarsipkanPada: archivedAt ?? this.diarsipkanPada,
      tanggalTampil: tanggalTampil ?? this.tanggalTampil,
    );
  }

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

  factory NotifikasiModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating NotifikasiModel from SQLite: ${map[NamaKolom.id]}');
    return NotifikasiModel(
      id: map[NamaKolom.id] as String?,
      tanggalMulai: ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tangglberakhir: ParserUtil.parseDateTime(map[NamaKolom.tangglberakhir]) ??
          DateTime.now(),
      judul: map[NamaKolom.judul] as String? ?? '',
      deskripsi: map[NamaKolom.deskripsi] as String? ?? '',
      setatusDibaca: ParserUtil.parseBool(map[NamaKolom.setatusDibaca]),
      tipe: _safeParseEnum(
            TipeNotifikasiEnum.values,
            map[NamaKolom.tipe],
          ) ??
          TipeNotifikasiEnum.transaksi,
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]) ??
          DateTime.now(),
      idTujuan: map[NamaKolom.idTujuan] as String? ?? '',
      userId: map[NamaKolom.userId] as String? ?? '',
      dihapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      tanggalTampil: ParserUtil.parseDateTime(map[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggalMulai: tanggalMulai.millisecondsSinceEpoch,
      NamaKolom.tangglberakhir: tangglberakhir.millisecondsSinceEpoch,
      NamaKolom.judul: judul,
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.setatusDibaca: setatusDibaca ? 1 : 0,
      NamaKolom.tipe: tipe.name,
      NamaKolom.diperbaruiPada: diperbaruiPada.millisecondsSinceEpoch,
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.userId: userId,
      NamaKolom.dihapus: dihapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.tanggalTampil: tanggalTampil.millisecondsSinceEpoch,
    };
  }

  factory NotifikasiModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating NotifikasiModel from Firebase: $id');
    return NotifikasiModel(
      id: id,
      tanggalMulai: ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tangglberakhir:
          ParserUtil.parseDateTime(data[NamaKolom.tangglberakhir]) ??
              DateTime.now(),
      tanggalTampil: ParserUtil.parseDateTime(data[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
      judul: data[NamaKolom.judul] as String? ?? '',
      deskripsi: data[NamaKolom.deskripsi] as String? ?? '',
      setatusDibaca: ParserUtil.parseBool(data[NamaKolom.setatusDibaca]),
      tipe: _safeParseEnum(
            TipeNotifikasiEnum.values,
            data[NamaKolom.tipe],
          ) ??
          TipeNotifikasiEnum.transaksi,
      diperbaruiPada:
          ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]) ??
              DateTime.now(),
      idTujuan: data[NamaKolom.idTujuan] as String? ?? '',
      userId: data[NamaKolom.userId] as String? ?? '',
      dihapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggalMulai: Timestamp.fromDate(tanggalMulai.toUtc()),
      NamaKolom.tangglberakhir: Timestamp.fromDate(tangglberakhir.toUtc()),
      NamaKolom.judul: judul,
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.setatusDibaca: setatusDibaca,
      NamaKolom.tipe: tipe.name,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(diperbaruiPada.toUtc()),
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.userId: userId,
      NamaKolom.dihapus: dihapus,
      NamaKolom.tanggalTampil: Timestamp.fromDate(tanggalTampil.toUtc()),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
