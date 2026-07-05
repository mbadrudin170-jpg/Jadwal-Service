// path lib/fitur/riwayat_aktivasi/provider/detail_langganan_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/utils/future_util.dart';

part 'detail_langganan_provider.g.dart';
part 'detail_langganan_provider.freezed.dart';

@freezed
abstract class DetailLanggananState with _$DetailLanggananState {
  const factory DetailLanggananState({
    TransaksiModel? transaksi,
    PelangganModel? pelanggan,
    PaketModel? paket,
  }) = _DetailLanggananState;
}

@riverpod
Future<DetailLanggananState?> ambilDetailLangganan(
  Ref ref,
  String idTransaksi,
) async {
  final transaksiOp = ref.watch(transaksiOpGlobalProvider);
  final pelangganOpSqlite = ref.watch(pelangganOpGlobalProvider);
  final paketOpSqlite = ref.watch(paketOpSqliteProvider);

  // 1. Ambil data transaksi utama
  final transaksi = await transaksiOp.ambilBerdasarkanId(idTransaksi);
  if (transaksi == null) return null;

  // 2. Ambil data relasi secara paralel untuk menghemat waktu pemuatan
final hasil = await loadAll([
  transaksi.idPelanggan != null
      ? pelangganOpSqlite.ambilBerdasarkanId(transaksi.idPelanggan!)
      : Future<PelangganModel?>.value(),
  transaksi.idPaket != null
      ? paketOpSqlite.ambilBerdasarkanId(transaksi.idPaket!)
      : Future<PaketModel?>.value(),
]);
  return DetailLanggananState(
    transaksi: transaksi,
    pelanggan: hasil[0] as PelangganModel?,
    paket: hasil[1] as PaketModel?,
  );
}
