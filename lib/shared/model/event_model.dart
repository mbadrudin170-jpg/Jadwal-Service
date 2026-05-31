// path: lib/shared/model/event_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

/// Model data untuk Pengumuman (Event).
class EventModel implements HasId {
  @override
  final String id;

  /// URL gambar pengumuman.
  final String imageUrl;

  /// Status apakah pengumuman sedang aktif.
  final bool isActive;

  /// Tanggal dibuat.
  final DateTime createdAt;

  /// Tanggal diperbarui (opsional).
  final DateTime? updatedAt;

  /// Konstruktor untuk EventModel.
  EventModel({
    final String? id,
    required this.imageUrl,
    this.isActive = false,
    required this.createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('EventModel created: $id');
  }

  /// Membuat salinan [EventModel] dengan beberapa properti yang diubah.
  EventModel copyWith({
    final String? id,
    final String? imageUrl,
    final bool? isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Membuat [EventModel] dari SQLite map.
  factory EventModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating EventModel from SQLite: ${map[ColumnNames.id]}');
    return EventModel(
      id: map[ColumnNames.id] as String? ?? '',
      imageUrl: map[ColumnNames.imageUrl] as String? ?? '',
      isActive: ParserUtil.parseBool(map[ColumnNames.isActive]),
      createdAt: ParserUtil.parseDateTime(map[ColumnNames.createdAt]) ??
          DateTime.now(),
      updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Mengonversi [EventModel] ke map untuk penyimpanan SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.imageUrl: imageUrl,
      ColumnNames.isActive: isActive ? 1 : 0,
      ColumnNames.createdAt: createdAt.millisecondsSinceEpoch,
      ColumnNames.updatedAt:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  /// Membuat [EventModel] dari Firebase document.
  factory EventModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating EventModel from Firebase: $id');
    return EventModel(
      id: id,
      imageUrl: data[ColumnNames.imageUrl] as String? ?? '',
      isActive: ParserUtil.parseBool(data[ColumnNames.isActive]),
      createdAt: ParserUtil.parseDateTime(data[ColumnNames.createdAt]) ??
          DateTime.now(),
      updatedAt: ParserUtil.parseDateTime(data[ColumnNames.updatedAt]),
    );
  }

  /// Mengonversi [EventModel] ke map untuk penyimpanan Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id: id,
      ColumnNames.imageUrl: imageUrl,
      ColumnNames.isActive: isActive,
      ColumnNames.createdAt: Timestamp.fromDate(createdAt.toUtc()),
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
    };
  }
}
