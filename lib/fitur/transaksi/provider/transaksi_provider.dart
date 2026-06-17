// path: lib/admin/providers/transaksi_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/page/transaksi_page_a.dart'; // Impor enum SortBy
import 'package:wifi/fitur/statistik/provider/statistik_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

part 'transaksi_provider.freezed.dart';
part 'transaksi_provider.g.dart';

@freezed
abstract class TransaksiState with _$TransaksiState {
  const factory TransaksiState({
    @Default([]) List<TransaksiModel> transaksi,
    @Default(0.0) double totalIncome,
    @Default(0.0) double totalExpense,
    @Default(0.0) double netTotal,
    @Default(SortBy.newest) SortBy sortBy,
  }) = _TransaksiState;
}

@riverpod
class Transaksi extends _$Transaksi {
  // PERBAIKAN 1: Gunakan ref.watch agar reaktif dan aman sesuai standar resmi
  TransaksiOpSqlite get _transaksiOpSqlite =>
      ref.watch(transaksiOpSqliteProvider);

  @override
  FutureOr<TransaksiState> build() {
    // Menentukan sorting default saat pertama kali build dijalankan
    return _loadData(SortBy.newest);
  }

  // PERBAIKAN 2: Passing nilai sortBy ke dalam fungsi load data
  // untuk menghindari pembacaan `state.value` yang tidak menentu saat async loading
  Future<TransaksiState> _loadData(SortBy targetSortBy) async {
    final results = await Future.wait([
      _transaksiOpSqlite.ambilSemua(),
      _transaksiOpSqlite.getTotalIncome(),
      _transaksiOpSqlite.getTotalExpense(),
      _transaksiOpSqlite.getNetTotal(),
    ]);

    final transaksi = results[0] as List<TransaksiModel>;

    // Jalankan sorting lokal sebelum state dilempar ke UI
    _performSort(transaksi, targetSortBy);

    return TransaksiState(
      transaksi: transaksi,
      totalIncome: results[1] as double,
      totalExpense: results[2] as double,
      netTotal: results[3] as double,
      sortBy: targetSortBy,
    );
  }

  void sortTransactions(SortBy newSortBy) {
    if (!state.hasValue) return;
    final currentState = state.value!;

    // Jika tipe sorting-nya sama, tidak perlu memproses ulang data
    if (currentState.sortBy == newSortBy) return;

    final List<TransaksiModel> sortedTransactions = List.from(
      currentState.transaksi,
    );
    _performSort(sortedTransactions, newSortBy);

    state = AsyncValue.data(
      currentState.copyWith(transaksi: sortedTransactions, sortBy: newSortBy),
    );
  }

  void _performSort(List<TransaksiModel> transactions, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.newest:
        transactions.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        break;
      case SortBy.oldest:
        transactions.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        break;
      case SortBy.highestAmount:
        transactions.sort((a, b) => b.jumlah.compareTo(a.jumlah));
        break;
      case SortBy.lowestAmount:
        transactions.sort((a, b) => a.jumlah.compareTo(b.jumlah));
        break;
    }
  }

  // ==========================================================
  // Fungsi Mutasi Data (Gunakan ref.read di dalam scope aksi ini aman)
  // ==========================================================

  Future<void> tambahTransaksi(TransaksiModel transaction) async {
    // Ambil sorting saat ini sebelum masuk state loading
    final currentSort = state.value?.sortBy ?? SortBy.newest;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.tambahTransaksi(transaction);
      ref.invalidate(dompetProvider);
      ref.invalidate(statistikProvider);
      return _loadData(currentSort);
    });
  }

  Future<void> updateTransaction(TransaksiModel transaction) async {
    final currentSort = state.value?.sortBy ?? SortBy.newest;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.perbaruiTransaksi(transaction.id, transaction);
      ref.invalidate(dompetProvider);
      ref.invalidate(statistikProvider);
      return _loadData(currentSort);
    });
  }

  Future<void> softDelete(String id) async {
    final currentSort = state.value?.sortBy ?? SortBy.newest;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.softDelete(id);
      ref.invalidate(dompetProvider);
      ref.invalidate(statistikProvider);
      return _loadData(currentSort);
    });
  }

  Future<void> softDeleteAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _transaksiOpSqlite.softDeleteAll();
      ref.invalidate(dompetProvider);
      ref.invalidate(statistikProvider);
      return _loadData(SortBy.newest);
    });
  }

  Future<void> refresh() async {
    final currentSort = state.value?.sortBy ?? SortBy.newest;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadData(currentSort));
  }
}
