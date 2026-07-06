// path: lib/fitur/investasi/model/investasi_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'investasi_model.freezed.dart';

@freezed
abstract class InvestasiModel with _$InvestasiModel implements HasId {
  const InvestasiModel._();
  const factory InvestasiModel({
    required String id,
    required String idInvestor, // ID pelanggan dengan role investor
    required String idTransaksi, // ID transaksi terkait
    required double jumlahModal, // Jumlah modal yang ditanamkan (Rupiah)
    required int jumlahLembar, // Jumlah lembar/saham yang dibeli
    DateTime? tanggalInvestasi,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? diperbaruiPada,
  }) = _InvestasiModel;

  // ---------- SQLite ----------
  factory InvestasiModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating InvestasiModel from SQLite: ${map[NamaKolom.id]}');
    return InvestasiModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      idInvestor: map[NamaKolom.idInvestor] as String? ?? '',
      idTransaksi: map[NamaKolom.idTransaksi] as String? ?? '',
      jumlahModal: (map[NamaKolom.jumlahModal] as num?)?.toDouble() ?? 0.0,
      jumlahLembar: (map[NamaKolom.jumlahLembar] as int?) ?? 0,
      tanggalInvestasi: ParserUtil.parseDateTime(
        map[NamaKolom.tanggalInvestasi],
      ),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idInvestor: idInvestor,
      NamaKolom.idTransaksi: idTransaksi,
      NamaKolom.jumlahModal: jumlahModal,
      NamaKolom.jumlahLembar: jumlahLembar,
      NamaKolom.tanggalInvestasi: tanggalInvestasi?.millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  // ---------- Firebase ----------
  factory InvestasiModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating InvestasiModel from Firebase: $id');
    return InvestasiModel(
      id: id,
      idInvestor: data[NamaKolom.idInvestor] as String? ?? '',
      idTransaksi: data[NamaKolom.idTransaksi] as String? ?? '',
      jumlahModal: (data[NamaKolom.jumlahModal] as num?)?.toDouble() ?? 0.0,
      jumlahLembar: (data[NamaKolom.jumlahLembar] as int?) ?? 0,
      tanggalInvestasi: ParserUtil.parseDateTime(
        data[NamaKolom.tanggalInvestasi],
      ),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.idInvestor: idInvestor,
      NamaKolom.idTransaksi: idTransaksi,
      NamaKolom.jumlahModal: jumlahModal,
      NamaKolom.jumlahLembar: jumlahLembar,
      NamaKolom.tanggalInvestasi: Timestamp.fromDate(
        tanggalInvestasi ?? DateTime.now(),
      ),
      NamaKolom.dihapus: diHapus,
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        diperbaruiPada ?? DateTime.now(),
      ),
    };
  }
}
