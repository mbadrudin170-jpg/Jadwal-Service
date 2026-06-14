// path: lib/shared/model/notifikasi_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

class NotifikasiModel implements HasId {
  @override
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime tanggalTampil;
  final String title;
  final String description;
  final bool isRead;
  final TipeNotifikasiEnum type;
  final DateTime updatedAt;
  final String idTujuan;
  final String userId;
  final bool isDeleted;
  final DateTime? archivedAt;

  NotifikasiModel({
    final String? id,
    required this.startDate,
    required this.endDate,
    required this.tanggalTampil,
    required this.title,
    required this.description,
    this.isRead = false,
    required this.type,
    required this.updatedAt,
    required this.idTujuan,
    required this.userId,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('NotifikasiModel created: $id, title: $title');
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
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      title: title ?? this.title,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      idTujuan: idTujuan ?? this.idTujuan,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
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
      startDate: ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      endDate: ParserUtil.parseDateTime(map[NamaKolom.tangglberakhir]) ??
          DateTime.now(),
      title: map[NamaKolom.judul] as String? ?? '',
      description: map[NamaKolom.deskripsi] as String? ?? '',
      isRead: ParserUtil.parseBool(map[NamaKolom.setatusDibaca]),
      type: _safeParseEnum(
            TipeNotifikasiEnum.values,
            map[NamaKolom.tipe],
          ) ??
          TipeNotifikasiEnum.transaksi,
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]) ??
          DateTime.now(),
      idTujuan: map[NamaKolom.idTujuan] as String? ?? '',
      userId: map[NamaKolom.userId] as String? ?? '',
      isDeleted: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      tanggalTampil: ParserUtil.parseDateTime(map[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggalMulai: startDate.millisecondsSinceEpoch,
      NamaKolom.tangglberakhir: endDate.millisecondsSinceEpoch,
      NamaKolom.judul: title,
      NamaKolom.deskripsi: description,
      NamaKolom.setatusDibaca: isRead ? 1 : 0,
      NamaKolom.tipe: type.name,
      NamaKolom.diperbaruiPada: updatedAt.millisecondsSinceEpoch,
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.userId: userId,
      NamaKolom.diHapus: isDeleted ? 1 : 0,
      NamaKolom.diarsipkanPada: archivedAt?.millisecondsSinceEpoch,
      NamaKolom.tanggalTampil: tanggalTampil.millisecondsSinceEpoch,
    };
  }

  factory NotifikasiModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating NotifikasiModel from Firebase: $id');
    return NotifikasiModel(
      id: id,
      startDate: ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      endDate: ParserUtil.parseDateTime(data[NamaKolom.tangglberakhir]) ??
          DateTime.now(),
      tanggalTampil: ParserUtil.parseDateTime(data[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
      title: data[NamaKolom.judul] as String? ?? '',
      description: data[NamaKolom.deskripsi] as String? ?? '',
      isRead: ParserUtil.parseBool(data[NamaKolom.setatusDibaca]),
      type: _safeParseEnum(
            TipeNotifikasiEnum.values,
            data[NamaKolom.tipe],
          ) ??
          TipeNotifikasiEnum.transaksi,
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]) ??
          DateTime.now(),
      idTujuan: data[NamaKolom.idTujuan] as String? ?? '',
      userId: data[NamaKolom.userId] as String? ?? '',
      isDeleted: ParserUtil.parseBool(data[NamaKolom.diHapus]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggalMulai: Timestamp.fromDate(startDate.toUtc()),
      NamaKolom.tangglberakhir: Timestamp.fromDate(endDate.toUtc()),
      NamaKolom.judul: title,
      NamaKolom.deskripsi: description,
      NamaKolom.setatusDibaca: isRead,
      NamaKolom.tipe: type.name,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(updatedAt.toUtc()),
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.userId: userId,
      NamaKolom.diHapus: isDeleted,
      NamaKolom.tanggalTampil: Timestamp.fromDate(tanggalTampil.toUtc()),
      NamaKolom.diarsipkanPada:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
