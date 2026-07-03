// path: lib/fitur/feedback/model/feedback_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'feedback_model.freezed.dart';

@freezed
abstract class FeedbackModel with _$FeedbackModel implements HasId {
  const FeedbackModel._();

  const factory FeedbackModel({
    required String id,
    required String pesan,
    DateTime? tanggal,
    required String userId,
    DateTime? diperbaruiPada,
    @Default(false) bool dihapus,
    DateTime? diarsipkanPada,
  }) = _FeedbackModel;

  factory FeedbackModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating FeedbackModel from SQLite: ${map[NamaKolom.id]}');
    return FeedbackModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      pesan: map[NamaKolom.pesan] as String? ?? '',
      userId: map[NamaKolom.userId] as String? ?? '',
      tanggal: ParserUtil.parseDateTime(map[NamaKolom.tanggal]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      dihapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.pesan: pesan,
      NamaKolom.userId: userId,
      NamaKolom.tanggal: (tanggal ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: dihapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  factory FeedbackModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Creating FeedbackModel from Firebase: $id');
    return FeedbackModel(
      id: id,
      pesan: data[NamaKolom.pesan] as String? ?? '',
      userId: data[NamaKolom.userId] as String? ?? '',
      tanggal: ParserUtil.parseDateTime(data[NamaKolom.tanggal]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      dihapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.pesan: pesan,
      NamaKolom.userId: userId,
      NamaKolom.tanggal: tanggal != null
          ? Timestamp.fromDate(tanggal!.toUtc())
          : DateTime.now().toUtc(),
      NamaKolom.dihapus: dihapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
