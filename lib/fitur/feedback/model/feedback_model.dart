// path: lib/fitur/feedback/model/feedback_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Model for feedback data from users.
class FeedbackModel implements HasId {
  @override
  final String id;

  /// The content of the feedback.
  final String content;

  /// The date the feedback was created.
  final DateTime? date;

  /// The ID of the user who submitted the feedback.
  final String userId;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this feedback has been deleted (soft delete).
  final bool isDeleted;

  /// The time this feedback was archived.
  final DateTime? archivedAt;

  /// Constructor to create a [FeedbackModel] instance.
  FeedbackModel({
    final String? id,
    required this.content,
    this.date,
    required this.userId,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('FeedbackModel created: $id, userId: $userId');
  }

  /// Creates a copy of [FeedbackModel] with some updated fields.
  FeedbackModel copyWith({
    final String? id,
    final String? content,
    final DateTime? date,
    final String? userId,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  // DIHAPUS: Helper parsing internal dipindahkan ke ParserUtil

  /// Creates a [FeedbackModel] instance from SQLite data.
  factory FeedbackModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating FeedbackModel from SQLite: ${map[NamaKolom.id]}');
    return FeedbackModel(
      id: map[NamaKolom.id] as String?,
      content: map[NamaKolom.isi] as String? ?? '',
      userId: map[NamaKolom.userId] as String? ?? '',
      // DIUBAH: Menggunakan ParserUtil
      date: ParserUtil.parseDateTime(map[NamaKolom.tanggal]),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  /// Converts [FeedbackModel] to a Map format for SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.isi: content,
      NamaKolom.userId: userId,
      NamaKolom.tanggal: (date ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diHapus: isDeleted ? 1 : 0,
      NamaKolom.diarsipkanPada: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [FeedbackModel] instance from Firebase data.
  factory FeedbackModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating FeedbackModel from Firebase: $id');
    return FeedbackModel(
      id: id,
      content: data[NamaKolom.isi] as String? ?? '',
      userId: data[NamaKolom.userId] as String? ?? '',
      // DIUBAH: Menggunakan ParserUtil
      date: ParserUtil.parseDateTime(data[NamaKolom.tanggal]),
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      isDeleted: ParserUtil.parseBool(data[NamaKolom.diHapus]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  /// Converts [FeedbackModel] to a Map format for Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.isi: content,
      NamaKolom.userId: userId,
      NamaKolom.tanggal: date != null
          ? Timestamp.fromDate(date!.toUtc())
          : DateTime.now().toUtc(),
      NamaKolom.diHapus: isDeleted,
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      NamaKolom.diarsipkanPada:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
