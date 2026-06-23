// path: lib/fitur/transaksi/model/transaksi_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'transaksi_model.freezed.dart';

@freezed
abstract class TransaksiModel with _$TransaksiModel implements HasId {
  const TransaksiModel._(); // Private constructor untuk method custom

  const factory TransaksiModel({
    required String id,
    required DateTime tanggal,
    required String deskripsi,
    required double jumlah,
    required TipeTransaksi tipe,
    required String idDompet,
    required String idKategori,
    String? idDompetTujuan,
    String? idPelanggan,
    String? idPaket,
    String? idSubKategori,
    @Default(StatusPembayaran.paid) StatusPembayaran statusPembayaran,
    @Default(0) int poinDidapat,
    @Default(0) int poinDigunakan,
    DateTime? diperbaruiPada,
    DateTime? diarsipkanPada,
    @Default(false) bool diHapus,
    int? durasiPaket,
    TipeDurasiPaket? tipeDurasiPaket,
    @Default(0) int durasiBonus,
    TipeDurasiPaket? tipeDurasiBonus,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    @Default(false) bool statusAktivasi,
  }) = _TransaksiModel;

  factory TransaksiModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Membuat TransaksiModel dari SQLite: ${map[NamaKolom.id]}');
    return TransaksiModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      tanggal:
          ParserUtil.parseDateTime(map[NamaKolom.tanggal]) ?? DateTime.now(),
      deskripsi: map[NamaKolom.deskripsi] as String? ?? '',
      jumlah: (map[NamaKolom.jumlah] as num? ?? 0).toDouble(),
      tipe:
          ParserUtil.safeParseEnum(TipeTransaksi.values, map[NamaKolom.tipe]) ??
          TipeTransaksi.expense,
      idDompet: map[NamaKolom.idDompet] as String? ?? '',
      idKategori: map[NamaKolom.idKategori] as String? ?? '',
      idDompetTujuan: map[NamaKolom.idDompetTujuan] as String?,
      idPelanggan: map[NamaKolom.idPelanggan] as String?,
      idPaket: map[NamaKolom.idPaket] as String?,
      idSubKategori: map[NamaKolom.idSubKategori] as String?,
      statusPembayaran:
          ParserUtil.safeParseEnum(
            StatusPembayaran.values,
            map[NamaKolom.statusPembayaran],
          ) ??
          StatusPembayaran.unpaid,
      poinDidapat: (map[NamaKolom.poinDidapat] as num? ?? 0).toInt(),
      poinDigunakan: (map[NamaKolom.poinDigunakan] as num? ?? 0).toInt(),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      durasiPaket: (map[NamaKolom.durasiPaket] as num?)?.toInt(),
      tipeDurasiPaket: ParserUtil.safeParseEnum(
        TipeDurasiPaket.values,
        map[NamaKolom.tipeDurasiPaket],
      ),
      durasiBonus: (map[NamaKolom.durasiBonus] as num? ?? 0).toInt(),
      tipeDurasiBonus: ParserUtil.safeParseEnum(
        TipeDurasiPaket.values,
        map[NamaKolom.tipeDurasiBonus],
      ),
      tanggalMulai: ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]),
      tanggalBerakhir: ParserUtil.parseDateTime(map[NamaKolom.tangglBerakhir]),
      statusAktivasi: ParserUtil.parseBool(map[NamaKolom.statusAktivasi]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggal: tanggal.millisecondsSinceEpoch,
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.jumlah: jumlah,
      NamaKolom.tipe: tipe.name,
      NamaKolom.idDompet: idDompet,
      NamaKolom.idKategori: idKategori,
      NamaKolom.idDompetTujuan: idDompetTujuan,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.idSubKategori: idSubKategori,
      NamaKolom.statusPembayaran: statusPembayaran.name,
      NamaKolom.poinDidapat: poinDidapat,
      NamaKolom.poinDigunakan: poinDigunakan,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.durasiPaket: durasiPaket,
      NamaKolom.tipeDurasiPaket: tipeDurasiPaket?.name,
      NamaKolom.durasiBonus: durasiBonus,
      NamaKolom.tipeDurasiBonus: tipeDurasiBonus?.name,
      NamaKolom.tanggalMulai: tanggalMulai?.millisecondsSinceEpoch,
      NamaKolom.tangglBerakhir: tanggalBerakhir?.millisecondsSinceEpoch,
      NamaKolom.statusAktivasi: statusAktivasi ? 1 : 0,
    };
  }

  factory TransaksiModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Membuat TransaksiModel dari Firebase: $id');
    return TransaksiModel(
      id: id,
      tanggal:
          ParserUtil.parseDateTime(data[NamaKolom.tanggal]) ?? DateTime.now(),
      deskripsi: data[NamaKolom.deskripsi] as String? ?? '',
      jumlah: (data[NamaKolom.jumlah] as num? ?? 0).toDouble(),
      tipe:
          ParserUtil.safeParseEnum(
            TipeTransaksi.values,
            data[NamaKolom.tipe],
          ) ??
          TipeTransaksi.expense,
      idDompet: data[NamaKolom.idDompet] as String? ?? '',
      idKategori: data[NamaKolom.idKategori] as String? ?? '',
      idDompetTujuan: data[NamaKolom.idDompetTujuan] as String?,
      idPelanggan: data[NamaKolom.idPelanggan] as String?,
      idPaket: data[NamaKolom.idPaket] as String?,
      idSubKategori: data[NamaKolom.idSubKategori] as String?,
      statusPembayaran:
          ParserUtil.safeParseEnum(
            StatusPembayaran.values,
            data[NamaKolom.statusPembayaran],
          ) ??
          StatusPembayaran.unpaid,
      poinDidapat: (data[NamaKolom.poinDidapat] as num? ?? 0).toInt(),
      poinDigunakan: (data[NamaKolom.poinDigunakan] as num? ?? 0).toInt(),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      durasiPaket: (data[NamaKolom.durasiPaket] as num?)?.toInt(),
      tipeDurasiPaket: ParserUtil.safeParseEnum(
        TipeDurasiPaket.values,
        data[NamaKolom.tipeDurasiPaket],
      ),
      durasiBonus: (data[NamaKolom.durasiBonus] as num? ?? 0).toInt(),
      tipeDurasiBonus: ParserUtil.safeParseEnum(
        TipeDurasiPaket.values,
        data[NamaKolom.tipeDurasiBonus],
      ),
      tanggalMulai: ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]),
      tanggalBerakhir: ParserUtil.parseDateTime(data[NamaKolom.tangglBerakhir]),
      statusAktivasi: ParserUtil.parseBool(data[NamaKolom.statusAktivasi]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggal: Timestamp.fromDate(tanggal.toUtc()),
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.jumlah: jumlah,
      NamaKolom.tipe: tipe.name,
      NamaKolom.idDompet: idDompet,
      NamaKolom.idKategori: idKategori,
      NamaKolom.idDompetTujuan: idDompetTujuan,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.idSubKategori: idSubKategori,
      NamaKolom.statusPembayaran: statusPembayaran.name,
      NamaKolom.poinDidapat: poinDidapat,
      NamaKolom.poinDigunakan: poinDigunakan,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
      NamaKolom.dihapus: diHapus,
      NamaKolom.durasiPaket: durasiPaket,
      NamaKolom.tipeDurasiPaket: tipeDurasiPaket?.name,
      NamaKolom.durasiBonus: durasiBonus,
      NamaKolom.tipeDurasiBonus: tipeDurasiBonus?.name,
      NamaKolom.tanggalMulai: tanggalMulai != null
          ? Timestamp.fromDate(tanggalMulai!.toUtc())
          : null,
      NamaKolom.tangglBerakhir: tanggalBerakhir != null
          ? Timestamp.fromDate(tanggalBerakhir!.toUtc())
          : null,
      NamaKolom.statusAktivasi: statusAktivasi,
    };
  }
}
