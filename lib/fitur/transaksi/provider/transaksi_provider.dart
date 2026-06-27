// path: lib/fitur/transaksi/provider/transaksi_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/poin/provider/poin_provider.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';
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
  TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);
  PointsPageDataSource get _pointsDataSource =>
      ref.read(pointsDataSourceProvider);
  @override
  FutureOr<TransaksiState> build() {
    return _loadData();
  }

  Future<TransaksiState> _loadData() async {
    final userId = await ref.watch(userIdProvider.future);
    final hasil = await Future.wait([
      _transaksiOp.ambilSemua(), // [0]
      _transaksiOp.getTotalIncome(), // [1]
      _transaksiOp.getTotalExpense(), // [2]
      _transaksiOp.getNetTotal(), // [3]
      _transaksiOp.ambilTotalPoinSemuaPelanggan(), // [4]
      _transaksiOp.ambilPaketTerlaris(), // [5] ✅ TAMBAHKAN
      _transaksiOp.ambilPendapatanHarian(), // [6]
      _transaksiOp.ambilPendapatanMingguan(), // [7]
      _transaksiOp.ambilPendapatanBulanan(), // [8]
      _transaksiOp.ambilTotalPendapatanPerbulan(), //[9]
      userId != null
          ? _pointsDataSource.ambilTotalPoin(userId) // [10]
          : Future<int>.value(0),
      userId != null
          ? _transaksiOp.ambilBerdasarkanIdPelanggan(userId) // [11]
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
    return await _transaksiOp.ambilTotalPoin(idPelanggan);
  }

  // ✅ Method untuk ambil poin banyak pelanggan (paralel)
  Future<Map<String, int>> getTotalPoinBanyakPelanggan(List<String> ids) async {
    final Map<String, int> hasil = {};
    for (final id in ids) {
      hasil[id] = await _transaksiOp.ambilTotalPoin(id);
    }
    return hasil;
  }

  Future<List<int>> getTotalPoinBanyakPelangganParallel(
    List<String> ids,
  ) async {
    final List<Future<int>> futures = ids
        .map((id) => _transaksiOp.ambilTotalPoin(id))
        .toList();
    return await Future.wait(futures);
  }

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    state = await AsyncValue.guard(() async {
      await _transaksiOp.tambahTransaksi(transaksi);
      _invalidateSistemTerkait();
      return _loadData();
    });
  }

  Future<void> updateTransaksi(TransaksiModel transaksi) async {
    state = await AsyncValue.guard(() async {
      await _transaksiOp.perbaruiTransaksi(transaksi.id, transaksi);
      _invalidateSistemTerkait();
      return _loadData();
    });
  }

  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      await _transaksiOp.softDelete(id);
      _invalidateSistemTerkait();
      return _loadData();
    });
  }

  Future<void> softDeleteAll() async {
    state = await AsyncValue.guard(() async {
      await _transaksiOp.softDeleteAll();
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

  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    Ref ref,
    String idPelanggan,
  ) async {
    Log.info(
      '[RiwayatPoin] 🔍 Mengambil riwayat poin untuk pelanggan: $idPelanggan',
    );
    try {
      final transaksiOp = ref.read(transaksiOpGlobalProvider);
      final semuaTransaksi = await transaksiOp.ambilBerdasarkanIdPelanggan(
        idPelanggan,
      );
      Log.info('[RiwayatPoin] 📊 Total transaksi: ${semuaTransaksi.length}');
      return semuaTransaksi;
    } catch (e, s) {
      Log.error('[RiwayatPoin] ❌ ERROR: $e', e: e, s: s);
      rethrow;
    }
  }

  void _invalidateSistemTerkait() {
    ref.invalidate(dompetProvider);
  }
}

@Riverpod(keepAlive: true)
Future<({List<TransaksiModel> transaksi, int totalPoin})>
riwayatTransaksiPelanggan(Ref ref, String idPelanggan) async {
  Log.info(
    '[RiwayatTransaksi] 🔍 Mengambil riwayat transaksi untuk pelanggan: $idPelanggan',
  );
  try {
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    final results = await Future.wait([
      transaksiOp.ambilBerdasarkanIdPelanggan(idPelanggan),
      transaksiOp.ambilTotalPoin(idPelanggan),
    ]);
    final semuaTransaksi = results[0] as List<TransaksiModel>;
    final totalPoinUser = results[1] as int;
    Log.info('[RiwayatTransaksi] 📊 Total transaksi: ${semuaTransaksi.length}');
    Log.info('[RiwayatTransaksi] 🎯 Total poin: $totalPoinUser');
    return (transaksi: semuaTransaksi, totalPoin: totalPoinUser);
  } catch (e, s) {
    Log.error('[RiwayatTransaksi] ❌ ERROR: $e', e: e, s: s);
    rethrow;
  }
}
