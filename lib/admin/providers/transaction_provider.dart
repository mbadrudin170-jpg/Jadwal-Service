// path: lib/admin/providers/transaction_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/halaman/tab/transaction_page_a.dart'; // Impor enum SortBy
import 'package:wifi/admin/providers/app_providers.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';

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

// final transactionProvider =
//     AsyncNotifierProvider<TransactionNotifier, TransactionState>(
//   TransactionNotifier.new,
// );

@riverpod
class Transaction extends _$Transaction {
  TransactionOperation get _operation {
    return ref.read(transactionOperationProvider);
  }

  @override
  Future<TransactionState> build() async {
    return _loadData();
  }

  Future<TransactionState> _loadData() async {
    final results = await Future.wait([
      _operation.getAllTransactions(),
      _operation.getTotalIncome(),
      _operation.getTotalExpense(),
      _operation.getNetTotal(),
    ]);

    final transactions = results[0] as List<TransactionModel>;
    final currentSortBy = state.value?.sortBy ?? SortBy.newest;

    _performSort(transactions, currentSortBy);

    return TransactionState(
      transactions: transactions,
      totalIncome: results[1] as double,
      totalExpense: results[2] as double,
      netTotal: results[3] as double,
      sortBy: currentSortBy,
    );
  }

  void sortTransactions(SortBy newSortBy) {
    // PERBAIKAN: Gunakan `state.hasValue` dan `state.value`
    if (!state.hasValue) return;
    final currentState = state.value!;

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

  Future<void> addTransaction(TransactionModel transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _operation.addTransaction(transaction);
      return _loadData();
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _operation.updateTransaction(transaction.id, transaction);
      return _loadData();
    });
  }

  Future<void> softDelete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _operation.softDelete(id);
      return _loadData();
    });
  }

  Future<void> softDeleteAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _operation.softDeleteAll();
      return _loadData();
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadData);
  }
}
