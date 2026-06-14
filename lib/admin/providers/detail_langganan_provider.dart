// path: lib/admin/providers/detail_langganan_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';

part 'detail_langganan_provider.freezed.dart';
part 'detail_langganan_provider.g.dart';

@freezed
abstract class DetailLanggananState with _$DetailLanggananState {
  const factory DetailLanggananState({
    TransaksiModel? transaction,
    PelangganModel? customer,
    PaketModel? package,
  }) = _DetailLanggananState;
}

@riverpod
Future<DetailLanggananState?> ambilDetailLangganan(
  Ref ref,
  String idTransaksi,
) async {
  // Ambil semua operation repo
  final transaksiOpSqlite = ref.watch(transaksiOpSqliteProvider);
  final pelangganOpSqlite = ref.watch(pelangganOpSqliteProvider);
  final paketOpSqlite = ref.watch(paketOpSqliteProvider);

  // 1. Ambil data transaksi utama
  final transaksi = await transaksiOpSqlite.ambilBerdasarkanId(idTransaksi);
  if (transaksi == null) return null;

  // 2. Ambil data relasi secara paralel untuk menghemat waktu pemuatan
  final hasil = await Future.wait<Object?>([
    transaksi.customerId != null
        ? pelangganOpSqlite.ambilBerdasarkanId(transaksi.customerId!)
        : Future<PelangganModel?>.value(),
    transaksi.packageId != null
        ? paketOpSqlite.getById(transaksi.packageId!)
        : Future<PaketModel?>.value(),
  ]);

  return DetailLanggananState(
    transaction: transaksi,
    customer: hasil[0] as PelangganModel?,
    package: hasil[1] as PaketModel?,
  );
}
