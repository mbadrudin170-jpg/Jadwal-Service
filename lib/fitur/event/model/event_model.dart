// path: lib/fitur/event/model/event_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'event_model.freezed.dart';

@freezed
abstract class EventModel with _$EventModel implements HasId {
  const EventModel._();
  const factory EventModel({
    required String id,
    required String linkGambar,
    @Default(false) bool statusAktif,
    required DateTime tanggalDibuat,
    required DateTime tanggalMulai,
    required DateTime tanggalBerakhir,
    DateTime? diperbaruiPada,
  }) = _EventModel;

  /// Membuat [EventModel] dari SQLite map.
  factory EventModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating EventModel from SQLite: ${map[NamaKolom.id]}');
    return EventModel(
      id: map[NamaKolom.id] as String? ?? '',
      linkGambar: map[NamaKolom.linkGambar] as String? ?? '',
      statusAktif: ParserUtil.parseBool(map[NamaKolom.statusAktif]),
      tanggalDibuat:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalDibuat]) ??
          DateTime.now(),
      tanggalMulai:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tanggalBerakhir:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalBerakhir]) ??
          DateTime.now(),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  /// Mengonversi [EventModel] ke map untuk penyimpanan SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.linkGambar: linkGambar,
      NamaKolom.statusAktif: statusAktif ? 1 : 0,
      NamaKolom.tanggalDibuat: tanggalDibuat.millisecondsSinceEpoch,
      NamaKolom.tanggalMulai: tanggalMulai.millisecondsSinceEpoch,
      NamaKolom.tanggalBerakhir: tanggalBerakhir.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  /// Membuat [EventModel] dari Supabase document.
  factory EventModel.fromSupabase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Creating EventModel from Supabase: $id');
    return EventModel(
      id: id,
      linkGambar: data[NamaKolom.linkGambar] as String? ?? '',
      statusAktif: ParserUtil.parseBool(data[NamaKolom.statusAktif]),
      tanggalDibuat:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalDibuat]) ??
          DateTime.now(),
      tanggalMulai:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tanggalBerakhir:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalBerakhir]) ??
          DateTime.now(),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  /// Mengonversi [EventModel] ke map untuk penyimpanan Supabase.
  Map<String, dynamic> toSupabase() {
    return {
      NamaKolom.id: id,
      NamaKolom.linkGambar: linkGambar,
      NamaKolom.statusAktif: statusAktif,
      NamaKolom.tanggalMulai: tanggalMulai.toIso8601String(),
      NamaKolom.tanggalBerakhir: tanggalBerakhir.toIso8601String(),
      NamaKolom.tanggalDibuat: tanggalDibuat.toIso8601String(),
      NamaKolom.diperbaruiPada: (diperbaruiPada ?? DateTime.now())
          .toIso8601String(),
    };
  }
}
