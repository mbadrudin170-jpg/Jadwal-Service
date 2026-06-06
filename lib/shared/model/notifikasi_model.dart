// path: lib/shared/model/notifikasi_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
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
    Log.info('Creating NotifikasiModel from SQLite: ${map[ColumnNames.id]}');
    return NotifikasiModel(
      id: map[ColumnNames.id] as String?,
      startDate: ParserUtil.parseDateTime(map[ColumnNames.startDate]) ??
          DateTime.now(),
      endDate:
          ParserUtil.parseDateTime(map[ColumnNames.endDate]) ?? DateTime.now(),
      title: map[ColumnNames.title] as String? ?? '',
      description: map[ColumnNames.description] as String? ?? '',
      isRead: ParserUtil.parseBool(map[ColumnNames.isRead]),
      type: _safeParseEnum(
            TipeNotifikasiEnum.values,
            map[ColumnNames.type],
          ) ??
          TipeNotifikasiEnum.transaksi,
      updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]) ??
          DateTime.now(),
      idTujuan: map[ColumnNames.idTujuan] as String? ?? '',
      isDeleted: ParserUtil.parseBool(map[ColumnNames.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(map[ColumnNames.archivedAt]),
      tanggalTampil: ParserUtil.parseDateTime(map[ColumnNames.tanggalTampil]) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.startDate: startDate.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate.millisecondsSinceEpoch,
      ColumnNames.title: title,
      ColumnNames.description: description,
      ColumnNames.isRead: isRead ? 1 : 0,
      ColumnNames.type: type.name,
      ColumnNames.updatedAt: updatedAt.millisecondsSinceEpoch,
      ColumnNames.idTujuan: idTujuan,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
      ColumnNames.tanggalTampil: tanggalTampil.millisecondsSinceEpoch,
    };
  }

  factory NotifikasiModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating NotifikasiModel from Firebase: $id');
    return NotifikasiModel(
      id: id,
      startDate: ParserUtil.parseDateTime(data[ColumnNames.startDate]) ??
          DateTime.now(),
      endDate:
          ParserUtil.parseDateTime(data[ColumnNames.endDate]) ?? DateTime.now(),
      tanggalTampil:
          ParserUtil.parseDateTime(data[ColumnNames.tanggalTampil]) ??
              DateTime.now(),
      title: data[ColumnNames.title] as String? ?? '',
      description: data[ColumnNames.description] as String? ?? '',
      isRead: ParserUtil.parseBool(data[ColumnNames.isRead]),
      type: _safeParseEnum(
            TipeNotifikasiEnum.values,
            data[ColumnNames.type],
          ) ??
          TipeNotifikasiEnum.transaksi,
      updatedAt: ParserUtil.parseDateTime(data[ColumnNames.updatedAt]) ??
          DateTime.now(),
      idTujuan: data[ColumnNames.idTujuan] as String? ?? '',
      isDeleted: ParserUtil.parseBool(data[ColumnNames.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id: id,
      ColumnNames.startDate: Timestamp.fromDate(startDate.toUtc()),
      ColumnNames.endDate: Timestamp.fromDate(endDate.toUtc()),
      ColumnNames.title: title,
      ColumnNames.description: description,
      ColumnNames.isRead: isRead,
      ColumnNames.type: type.name,
      ColumnNames.updatedAt: Timestamp.fromDate(updatedAt.toUtc()),
      ColumnNames.idTujuan: idTujuan,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.tanggalTampil: Timestamp.fromDate(tanggalTampil.toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
