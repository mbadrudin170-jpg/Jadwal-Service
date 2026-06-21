// path: lib/admin/providers/transaksi_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
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
  }) = _TransaksiState;
}

@riverpod
class Transaksi extends _$Transaksi {
  // PERBAIKAN 1: Gunakan ref.watch agar reaktif dan aman sesuai standar resmi
  TransaksiOpSqlite get _transaksiOpSqlite =>
      ref.watch(transaksiOpSqliteProvider);

  @override
  FutureOr<TransaksiState> build() {
    return _loadData();
  }

  // PERBAIKAN 2: Passing nilai sortBy ke dalam fungsi load data
  // untuk menghindari pembacaan `state.value` yang tidak menentu saat async loading
  Future<TransaksiState> _loadData() async {
    final hasil = await Future.wait([
      _transaksiOpSqlite.ambilSemua(),
      _transaksiOpSqlite.getTotalIncome(),
      _transaksiOpSqlite.getTotalExpense(),
      _transaksiOpSqlite.getNetTotal(),
    ]);

    final transaksi = hasil[0] as List<TransaksiModel>;

    return TransaksiState(
      transaksi: transaksi,
      totalPemasukan: hasil[1] as double,
      totalPengeluaran: hasil[2] as double,
      total: hasil[3] as double,
    );
  }

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    // Ambil sorting saat ini sebelum masuk state loading
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.tambahTransaksi(transaksi);
      ref.invalidate(dompetProvider);
      ref.invalidate(statistikProvider);
      return _loadData();
    });
  }

  Future<void> updateTransaksi(TransaksiModel transaksi) async {
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.perbaruiTransaksi(transaksi.id, transaksi);
      ref.invalidate(dompetProvider);
      ref.invalidate(statistikProvider);
      return _loadData();
    });
  }

  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.softDelete(id);
      ref.invalidate(dompetProvider);
      ref.invalidate(statistikProvider);
      return _loadData();
    });
  }

  Future<void> softDeleteAll() async {
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.softDeleteAll();
      ref.invalidate(dompetProvider);
      ref.invalidate(statistikProvider);
      return _loadData();
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadData);
  }
}
