// path: lib/fitur/transaksi/provider/transaksi_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';
import 'package:wifi/fitur/statistik/provider/statistik_provider.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

part 'transaksi_provider.freezed.dart';
part 'transaksi_provider.g.dart';

@freezed
abstract class TransaksiState with _$TransaksiState {
  const factory TransaksiState({
    @Default([]) List<TransaksiModel> transaksi,
    @Default(0.0) double totalPemasukan,
    @Default(0.0) double totalPengeluaran,
    @Default(0.0) double total,
    @Default(0) int totalPoinSemuaPelanggan,
    required List<PaketTerlarisModel> paketTerlaris,
    required List<double> pendapatanHarian,
    required List<double> pendapatanMingguan,
    required List<double> pendapatanBulanan,
  }) = _TransaksiState;
}

@riverpod
class Transaksi extends _$Transaksi {
  TransaksiOpSqlite get _transaksiOpSqlite =>
      ref.read(transaksiOpSqliteProvider);

  @override
  FutureOr<TransaksiState> build() {
    return _loadData();
  }

  Future<TransaksiState> _loadData() async {
    final hasil = await Future.wait([
      _transaksiOpSqlite.ambilSemua(),
      _transaksiOpSqlite.getTotalIncome(),
      _transaksiOpSqlite.getTotalExpense(),
      _transaksiOpSqlite.getNetTotal(),
      _transaksiOpSqlite.ambilTotalPoinSemuaPelanggan(),
      _transaksiOpSqlite.ambilPendapatanHarian(),
      _transaksiOpSqlite.ambilPendapatanMingguan(),
      _transaksiOpSqlite.ambilPendapatanBulanan(),
    ]);

    final transaksi = hasil[0] as List<TransaksiModel>;

    return TransaksiState(
      transaksi: transaksi,
      totalPemasukan: hasil[1] as double,
      totalPengeluaran: hasil[2] as double,
      total: hasil[3] as double,
      totalPoinSemuaPelanggan: hasil[4] as int,
      paketTerlaris: hasil[0] as List<PaketTerlarisModel>,
      pendapatanHarian: hasil[4] as List<double>,
      pendapatanMingguan: hasil[5] as List<double>,
      pendapatanBulanan: hasil[6] as List<double>,
    );
  }

  // ✅ Method untuk ambil poin per pelanggan
  Future<int> getTotalPoinPelanggan(String idPelanggan) async {
    return await _transaksiOpSqlite.ambilTotalPoin(idPelanggan);
  }

  // ✅ Method untuk ambil poin banyak pelanggan (paralel)
  Future<Map<String, int>> getTotalPoinBanyakPelanggan(List<String> ids) async {
    final Map<String, int> hasil = {};
    for (final id in ids) {
      hasil[id] = await _transaksiOpSqlite.ambilTotalPoin(id);
    }
    return hasil;
  }

  Future<List<int>> getTotalPoinBanyakPelangganParallel(
    List<String> ids,
  ) async {
    final List<Future<int>> futures = ids
        .map((id) => _transaksiOpSqlite.ambilTotalPoin(id))
        .toList();
    return await Future.wait(futures);
  }

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.tambahTransaksi(transaksi);
      _invalidateSistemTerkait();
      return _loadData();
    });
  }

  Future<void> updateTransaksi(TransaksiModel transaksi) async {
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.perbaruiTransaksi(transaksi.id, transaksi);
      _invalidateSistemTerkait();
      return _loadData();
    });
  }

  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.softDelete(id);
      _invalidateSistemTerkait();
      return _loadData();
    });
  }

  Future<void> softDeleteAll() async {
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.softDeleteAll();
      _invalidateSistemTerkait();
      return _loadData();
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadData);
  }

  void _invalidateSistemTerkait() {
    ref.invalidate(dompetProvider);
    ref.invalidate(statistikProvider);
  }
}
