// path: lib/fitur/settings/model/settings_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'settings_model.freezed.dart';

const String idGlobalSetting = 'global_config';

@freezed
abstract class SettingsModel with _$SettingsModel implements HasId {
  const SettingsModel._();
  const factory SettingsModel({
    @Default(idGlobalSetting) String id,
    @Default(24) int waktuOtomatisSinkroniasi,
    @Default(30) int waktuOtomatisHapusDataArsip,
    @Default(false) bool modeMaintenance,
    @Default('') String infoMaintenance,
    DateTime? diperbaruiPada,
  }) = _SettingModel;

  factory SettingsModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating SettingsModel from SQLite');
    return SettingsModel(
      id: map[NamaKolom.id] as String? ?? idGlobalSetting,
      waktuOtomatisSinkroniasi:
          map[NamaKolom.waktuOtomatisSinkroniasi] as int? ?? 24,
      waktuOtomatisHapusDataArsip:
          map[NamaKolom.waktuOtomatisHapusDataArsip] as int? ?? 30,
      modeMaintenance: ParserUtil.parseBool(map[NamaKolom.modeMaintenance]),
      infoMaintenance: map[NamaKolom.infoMaintenance] as String? ?? '',
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.waktuOtomatisSinkroniasi: waktuOtomatisSinkroniasi,
      NamaKolom.waktuOtomatisHapusDataArsip: waktuOtomatisHapusDataArsip,
      NamaKolom.modeMaintenance: modeMaintenance ? 1 : 0,
      NamaKolom.infoMaintenance: infoMaintenance,
      NamaKolom.diperbaruiPada: diperbaruiPada!.millisecondsSinceEpoch,
    };
  }

  factory SettingsModel.fromFirebase(Map<String, dynamic> data) {
    Log.info('Creating SettingsModel from Firebase');
    return SettingsModel(
      id: data[NamaKolom.id] as String? ?? idGlobalSetting,
      waktuOtomatisSinkroniasi:
          data[NamaKolom.waktuOtomatisSinkroniasi] as int? ?? 24,
      waktuOtomatisHapusDataArsip:
          data[NamaKolom.waktuOtomatisHapusDataArsip] as int? ?? 30,
      modeMaintenance: ParserUtil.parseBool(data[NamaKolom.modeMaintenance]),
      infoMaintenance: data[NamaKolom.infoMaintenance] as String? ?? '',
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.waktuOtomatisSinkroniasi: waktuOtomatisSinkroniasi,
      NamaKolom.waktuOtomatisHapusDataArsip: waktuOtomatisHapusDataArsip,
      NamaKolom.modeMaintenance: modeMaintenance,
      NamaKolom.infoMaintenance: infoMaintenance,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(diperbaruiPada!.toUtc()),
    };
  }
}
