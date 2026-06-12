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
      startDate:
          ParserUtil.parseDateTime(map[NamaKolom.startDate]) ?? DateTime.now(),
      endDate:
          ParserUtil.parseDateTime(map[NamaKolom.endDate]) ?? DateTime.now(),
      title: map[NamaKolom.title] as String? ?? '',
      description: map[NamaKolom.description] as String? ?? '',
      isRead: ParserUtil.parseBool(map[NamaKolom.isRead]),
      type: _safeParseEnum(
            TipeNotifikasiEnum.values,
            map[NamaKolom.type],
          ) ??
          TipeNotifikasiEnum.transaksi,
      updatedAt:
          ParserUtil.parseDateTime(map[NamaKolom.updatedAt]) ?? DateTime.now(),
      idTujuan: map[NamaKolom.idTujuan] as String? ?? '',
      userId: map[NamaKolom.userId] as String? ?? '',
      isDeleted: ParserUtil.parseBool(map[NamaKolom.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.archivedAt]),
      tanggalTampil: ParserUtil.parseDateTime(map[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.startDate: startDate.millisecondsSinceEpoch,
      NamaKolom.endDate: endDate.millisecondsSinceEpoch,
      NamaKolom.title: title,
      NamaKolom.description: description,
      NamaKolom.isRead: isRead ? 1 : 0,
      NamaKolom.type: type.name,
      NamaKolom.updatedAt: updatedAt.millisecondsSinceEpoch,
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.userId: userId,
      NamaKolom.isDeleted: isDeleted ? 1 : 0,
      NamaKolom.archivedAt: archivedAt?.millisecondsSinceEpoch,
      NamaKolom.tanggalTampil: tanggalTampil.millisecondsSinceEpoch,
    };
  }

  factory NotifikasiModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating NotifikasiModel from Firebase: $id');
    return NotifikasiModel(
      id: id,
      startDate:
          ParserUtil.parseDateTime(data[NamaKolom.startDate]) ?? DateTime.now(),
      endDate:
          ParserUtil.parseDateTime(data[NamaKolom.endDate]) ?? DateTime.now(),
      tanggalTampil: ParserUtil.parseDateTime(data[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
      title: data[NamaKolom.title] as String? ?? '',
      description: data[NamaKolom.description] as String? ?? '',
      isRead: ParserUtil.parseBool(data[NamaKolom.isRead]),
      type: _safeParseEnum(
            TipeNotifikasiEnum.values,
            data[NamaKolom.type],
          ) ??
          TipeNotifikasiEnum.transaksi,
      updatedAt:
          ParserUtil.parseDateTime(data[NamaKolom.updatedAt]) ?? DateTime.now(),
      idTujuan: data[NamaKolom.idTujuan] as String? ?? '',
      userId: data[NamaKolom.userId] as String? ?? '',
      isDeleted: ParserUtil.parseBool(data[NamaKolom.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.archivedAt]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.startDate: Timestamp.fromDate(startDate.toUtc()),
      NamaKolom.endDate: Timestamp.fromDate(endDate.toUtc()),
      NamaKolom.title: title,
      NamaKolom.description: description,
      NamaKolom.isRead: isRead,
      NamaKolom.type: type.name,
      NamaKolom.updatedAt: Timestamp.fromDate(updatedAt.toUtc()),
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.userId: userId,
      NamaKolom.isDeleted: isDeleted,
      NamaKolom.tanggalTampil: Timestamp.fromDate(tanggalTampil.toUtc()),
      NamaKolom.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
