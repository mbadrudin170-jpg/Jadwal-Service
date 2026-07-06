// path: lib/fitur/pelanggan/model/pelanggan_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'pelanggan_model.freezed.dart';

@freezed
abstract class PelangganModel with _$PelangganModel implements HasId {
  const PelangganModel._();
  const factory PelangganModel({
    required String id,
    required String nama,
    required String telepon,
    required String alamat,
    required String kataSandi,
    required String macAddress,
    @Default(AppRole.user) AppRole role,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? terkahirAktif,
  }) = _PelangganModel;

  factory PelangganModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating CustomerModel from SQLite: ${map[NamaKolom.id]}');
    return PelangganModel(
      id: map[NamaKolom.id] as String? ?? '',
      nama: map[NamaKolom.nama] as String? ?? '',
      telepon: map[NamaKolom.telepon] as String? ?? '',
      alamat: map[NamaKolom.alamat] as String? ?? '',
      kataSandi: map[NamaKolom.kataSandi] as String? ?? '',
      macAddress: map[NamaKolom.macAddress] as String? ?? '',
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      terkahirAktif: ParserUtil.parseDateTime(map[NamaKolom.terkahirAktif]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.telepon: telepon,
      NamaKolom.alamat: alamat,
      NamaKolom.kataSandi: kataSandi,
      NamaKolom.macAddress: macAddress,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.terkahirAktif: terkahirAktif?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [PelangganModel] from a Firebase document.
  factory PelangganModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating CustomerModel from Firebase: $id');
    return PelangganModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      telepon: data[NamaKolom.telepon] as String? ?? '',
      alamat: data[NamaKolom.alamat] as String? ?? '',
      kataSandi: data[NamaKolom.kataSandi] as String? ?? '',
      macAddress: data[NamaKolom.macAddress] as String? ?? '',
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      terkahirAktif: ParserUtil.parseDateTime(data[NamaKolom.terkahirAktif]),
    );
  }

  /// Converts the [PelangganModel] to a map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.telepon: telepon,
      NamaKolom.alamat: alamat,
      NamaKolom.kataSandi: kataSandi,
      NamaKolom.macAddress: macAddress,
      NamaKolom.dihapus: diHapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
      NamaKolom.terkahirAktif: terkahirAktif != null
          ? Timestamp.fromDate(terkahirAktif!.toUtc())
          : null,
    };
  }
}
