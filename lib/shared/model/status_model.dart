// path: lib/shared/model/status_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'status_model.freezed.dart';

const String globalStatusId = 'global_status';

@freezed
abstract class StatusModel with _$StatusModel implements HasId {
  const StatusModel._();
  const factory StatusModel({
    @Default(globalStatusId) String id,
    DateTime? diperbaruiPada,
  }) = _StatusModel;

  factory StatusModel.fromSqlite(
    final Map<String, dynamic> map,
  ) {
    return StatusModel(
      id: map[NamaKolom.id] as String? ?? globalStatusId,
      diperbaruiPada: ParserUtil.parseDateTime(
            map[NamaKolom.diperbaruiPada],
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.diperbaruiPada: diperbaruiPada!.millisecondsSinceEpoch,
    };
  }

  factory StatusModel.fromFirebase(Map<String, dynamic> data) {
    Log.info('Creating StatusModel from Firebase');
    return StatusModel(
      id: data[NamaKolom.id] as String? ?? globalStatusId,
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(diperbaruiPada!.toUtc()),
    };
  }
}
