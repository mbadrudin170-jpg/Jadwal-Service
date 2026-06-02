// path: lib/admin/providers/transaction_provider.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/halaman/tab/transaction_page_a.dart'; // Impor enum SortBy
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

part 'transaction_provider.g.dart';

class TransactionState {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;
  final double netTotal;
  final SortBy sortBy;

  TransactionState({
    this.transactions = const [],
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.netTotal = 0.0,
    this.sortBy = SortBy.newest,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    double? totalIncome,
    double? totalExpense,
    double? netTotal,
    SortBy? sortBy,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netTotal: netTotal ?? this.netTotal,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

@riverpod
class Transaction extends _$Transaction {
  // PERBAIKAN 1: Gunakan ref.watch agar reaktif dan aman sesuai standar resmi
  TransactionOperation get _operation =>
      ref.watch(transactionOperationProvider);

  @override
  FutureOr<TransactionState> build() {
    // Menentukan sorting default saat pertama kali build dijalankan
    return _loadData(SortBy.newest);
  }

  // PERBAIKAN 2: Passing nilai sortBy ke dalam fungsi load data
  // untuk menghindari pembacaan `state.value` yang tidak menentu saat async loading
  Future<TransactionState> _loadData(SortBy targetSortBy) async {
    final results = await Future.wait([
      _operation.getAllTransactions(),
      _operation.getTotalIncome(),
      _operation.getTotalExpense(),
      _operation.getNetTotal(),
    ]);

    final transactions = results[0] as List<TransactionModel>;

    // Jalankan sorting lokal sebelum state dilempar ke UI
    _performSort(transactions, targetSortBy);

    return TransactionState(
      transactions: transactions,
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

    final List<TransactionModel> sortedTransactions =
        List.from(currentState.transactions);
    _performSort(sortedTransactions, newSortBy);

    state = AsyncValue.data(currentState.copyWith(
      transactions: sortedTransactions,
      sortBy: newSortBy,
    ));
  }

  void _performSort(List<TransactionModel> transactions, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.newest:
        transactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortBy.oldest:
        transactions.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortBy.highestAmount:
        transactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortBy.lowestAmount:
        transactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
  }

  // ==========================================================
  // Fungsi Mutasi Data (Gunakan ref.read di dalam scope aksi ini aman)
  // ==========================================================

  Future<void> addTransaction(TransactionModel transaction) async {
    // Ambil sorting saat ini sebelum masuk state loading
    final currentSort = state.value?.sortBy ?? SortBy.newest;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _operation.addTransaction(transaction);
      return _loadData(currentSort);
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final currentSort = state.value?.sortBy ?? SortBy.newest;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _operation.updateTransaction(transaction.id, transaction);
      return _loadData(currentSort);
    });
  }

  Future<void> softDelete(String id) async {
    final currentSort = state.value?.sortBy ?? SortBy.newest;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _operation.softDelete(id);
      return _loadData(currentSort);
    });
  }

  Future<void> softDeleteAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _operation.softDeleteAll();
      return _loadData(SortBy.newest); // Reset ke newest jika semua dihapus
    });
  }

  Future<void> refresh() async {
    final currentSort = state.value?.sortBy ?? SortBy.newest;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadData(currentSort));
  }
}
