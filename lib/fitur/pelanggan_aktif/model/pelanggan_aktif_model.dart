// path: lib/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'pelanggan_aktif_model.freezed.dart';

@freezed
abstract class PelangganAktifModel with _$PelangganAktifModel implements HasId {
  const PelangganAktifModel._();
  const factory PelangganAktifModel({
    required String id,
    required String idPelanggan,
    required String idPaket,
    required String idTransaksi,
    required DateTime tanggalMulai,
    required DateTime tanggalBerakhir,
    required StatusPembayaran status,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _PelangganAktifModel;

  factory PelangganAktifModel.fromSqlite(Map<String, dynamic> map) {
    try {
      final tanggalMulai = ParserUtil.parseDateTime(
        map[NamaKolom.tanggalMulai],
      );
      final tanggalBerakhir = ParserUtil.parseDateTime(
        map[NamaKolom.tangglBerakhir],
      );

      if (tanggalMulai == null) {
        throw ArgumentError.notNull('startDate from SQLite');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('endDate from SQLite');
      }

      final model = PelangganAktifModel(
        id: map[NamaKolom.id] as String,
        idPelanggan: map[NamaKolom.idPelanggan] as String? ?? '',
        idPaket: map[NamaKolom.idPaket] as String? ?? '',
        idTransaksi: map[NamaKolom.idTransaksi] as String? ?? '',
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaran.values.firstWhere(
          (final e) => e.name == map[NamaKolom.status],
          orElse: () => StatusPembayaran.paid,
        ),
        diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
        diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
        diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      );
      Log.info('ActiveCustomerModel loaded from SQLite: ${model.id}');
      return model;
    } catch (e, s) {
      Log.error('Failed to parse from SQLite: $map', e: e, s: s);
      rethrow;
    }
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.idTransaksi: idTransaksi,
      NamaKolom.tanggalMulai: tanggalMulai.millisecondsSinceEpoch,
      NamaKolom.tangglBerakhir: tanggalBerakhir.millisecondsSinceEpoch,
      NamaKolom.status: status.name,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  factory PelangganAktifModel.fromFirebase(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      final tanggalMulai = ParserUtil.parseDateTime(
        data[NamaKolom.tanggalMulai],
      );
      final tanggalBerakhir = ParserUtil.parseDateTime(
        data[NamaKolom.tangglBerakhir],
      );

      if (tanggalMulai == null) {
        throw ArgumentError.notNull('startDate from Firebase');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('endDate from Firebase');
      }

      final model = PelangganAktifModel(
        id: id,
        idPelanggan: data[NamaKolom.idPelanggan] as String? ?? '',
        idPaket: data[NamaKolom.idPaket] as String? ?? '',
        idTransaksi: data[NamaKolom.idTransaksi] as String? ?? '',
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaran.values.firstWhere(
          (e) => e.name == data[NamaKolom.status],
          orElse: () => StatusPembayaran.paid,
        ),
        diperbaruiPada: ParserUtil.parseDateTime(
          data[NamaKolom.diperbaruiPada],
        ),
        diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
        diarsipkanPada: ParserUtil.parseDateTime(
          data[NamaKolom.diarsipkanPada],
        ),
      );
      Log.info('ActiveCustomerModel loaded from Firebase: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from Firebase: $data', e: e, s: stack);
      rethrow;
    }
  }

  Map<String, dynamic> toFirebase() {
    Log.info('Preparing toFirebase for ActiveCustomerModel $id');
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.idTransaksi: idTransaksi,
      NamaKolom.tanggalMulai: Timestamp.fromDate(tanggalMulai.toUtc()),
      NamaKolom.tangglBerakhir: Timestamp.fromDate(tanggalBerakhir.toUtc()),
      NamaKolom.status: status.name,
      NamaKolom.dihapus: diHapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
