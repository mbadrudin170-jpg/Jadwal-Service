// path: lib/fitur/transaksi/provider/transaksi_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/poin/provider/poin_provider.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/user/providers/user_provider.dart';

part 'transaksi_provider.freezed.dart';
part 'transaksi_provider.g.dart';

@freezed
abstract class TransaksiState with _$TransaksiState {
  const factory TransaksiState({
    @Default([]) List<TransaksiModel> transaksi,
    required List<TransaksiModel> transaksiUser,
    @Default(0.0) double totalPemasukan,
    @Default(0.0) double totalPengeluaran,
    @Default(0.0) double total,
    @Default(0) int totalPoinSemuaPelanggan,
    required List<PaketTerlarisModel> paketTerlaris,
    required List<double> pendapatanHarian,
    required List<double> pendapatanMingguan,
    required List<double> pendapatanBulanan,
    required double totalPendapatanPerbulan,
    @Default(0) int totalPoinUser,
  }) = _TransaksiState;
}

@riverpod
class Transaksi extends _$Transaksi {
  TransaksiOpSqlite get _transaksiOpSqlite =>
      ref.read(transaksiOpSqliteProvider);
  PointsPageDataSource get _pointsDataSource =>
      ref.read(pointsDataSourceProvider);
  @override
  FutureOr<TransaksiState> build() {
    return _loadData();
  }

  Future<TransaksiState> _loadData() async {
    final userId = await ref.watch(userIdProvider.future);
    final hasil = await Future.wait([
      _transaksiOpSqlite.ambilSemua(), // [0]
      _transaksiOpSqlite.getTotalIncome(), // [1]
      _transaksiOpSqlite.getTotalExpense(), // [2]
      _transaksiOpSqlite.getNetTotal(), // [3]
      _transaksiOpSqlite.ambilTotalPoinSemuaPelanggan(), // [4]
      _transaksiOpSqlite.ambilPaketTerlaris(), // [5] ✅ TAMBAHKAN
      _transaksiOpSqlite.ambilPendapatanHarian(), // [6]
      _transaksiOpSqlite.ambilPendapatanMingguan(), // [7]
      _transaksiOpSqlite.ambilPendapatanBulanan(), // [8]
      _transaksiOpSqlite.ambilTotalPendapatanPerbulan(), //[9]
      userId != null
          ? _pointsDataSource.ambilTotalPoin(userId) // [10]
          : Future<int>.value(0),
      userId != null
          ? _transaksiOpSqlite.ambilBerdasarkanIdPelanggan(userId) // [11]
          : Future<List<TransaksiModel>>.value([]),
    ]);

    final transaksi = hasil[0] as List<TransaksiModel>;
    return TransaksiState(
      transaksi: transaksi,
      totalPemasukan: hasil[1] as double,
      totalPengeluaran: hasil[2] as double,
      total: hasil[3] as double,
      totalPoinSemuaPelanggan: hasil[4] as int,
      paketTerlaris: hasil[5] as List<PaketTerlarisModel>,
      pendapatanHarian: hasil[6] as List<double>,
      pendapatanMingguan: hasil[7] as List<double>,
      pendapatanBulanan: hasil[8] as List<double>,
      totalPendapatanPerbulan: hasil[9] as double,
      totalPoinUser: hasil[10] as int,
      transaksiUser: hasil[11] as List<TransaksiModel>,
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

  Future<void> refreshPoin() async {
    final userId = await ref.watch(userIdProvider.future);
    if (userId == null) return;

    final totalPoin = await _pointsDataSource.ambilTotalPoin(userId);

    if (state.hasValue) {
      final currentState = state.value!;
      state = AsyncValue.data(currentState.copyWith(totalPoinUser: totalPoin));
    }
  }

  void _invalidateSistemTerkait() {
    ref.invalidate(dompetProvider);
  }
}

@Riverpod(keepAlive: true)
Future<List<TransaksiModel>> transaksiPerPelanggan(
  Ref ref,
  String idPelanggan,
) {
  final transaksiOp = ref.read(transaksiOpSqliteProvider);
  return transaksiOp.ambilBerdasarkanIdPelanggan(idPelanggan);
}
