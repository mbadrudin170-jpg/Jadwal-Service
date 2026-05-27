// path: lib/shared/providers/transaction_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';

// State class SAMA, tidak perlu diubah.
class TransactionState {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;
  final double netTotal;

  // isLoading dan error akan ditangani oleh AsyncValue, jadi bisa dihapus dari sini.
  TransactionState({
    this.transactions = const [],
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.netTotal = 0.0,
  });

  TransactionState copyWith({
    final List<TransactionModel>? transactions,
    final double? totalIncome,
    final double? totalExpense,
    final double? netTotal,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netTotal: netTotal ?? this.netTotal,
    );
  }
}

// 1. Ubah provider menjadi satu AsyncNotifierProvider.
// Ini akan mengelola state (AsyncValue<TransactionState>) secara otomatis.
final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, TransactionState>(
  TransactionNotifier.new,
);

// 2. Buat Class Notifier yang baru.
class TransactionNotifier extends AsyncNotifier<TransactionState> {
  // 3. Implementasi method `build` untuk mengambil data awal.
  // Method ini HANYA akan dipanggil sekali saat provider pertama kali dibaca.
  @override
  Future<TransactionState> build() {
    // Tidak perlu lagi `watch` trigger, cukup panggil method untuk load data.
    return _loadData();
  }

  // Method helper untuk mengambil semua data dari database.
  Future<TransactionState> _loadData() async {
    final operation = TransactionOperation();
    final results = await Future.wait([
      operation.getAllTransactions(),
      operation.getTotalIncome(),
      operation.getTotalExpense(),
      operation.getNetTotal(),
    ]);

    return TransactionState(
      transactions: results[0] as List<TransactionModel>,
      totalIncome: results[1] as double,
      totalExpense: results[2] as double,
      netTotal: results[3] as double,
    );
  }

  // 4. Buat method untuk setiap aksi (tambah, edit, hapus).

  Future<void> addTransaction(final TransactionModel transaction) async {
    // Mengatur state ke loading untuk memberikan feedback ke UI.
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = TransactionOperation();
      // Perbaikan: Gunakan nama method yang benar 'addTransaction'
      await operation.addTransaction(transaction);
      // Setelah berhasil, panggil ulang _loadData untuk mendapatkan state terbaru.
      return _loadData();
    });
  }

  Future<void> updateTransaction(final TransactionModel transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = TransactionOperation();
      // Perbaikan: Panggil 'updateTransaction' dengan parameter yang benar
      await operation.updateTransaction(transaction.id, transaction);
      return _loadData();
    });
  }

  Future<void> softDelete(final String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = TransactionOperation();
      await operation.softDelete(id);
      return _loadData();
    });
  }

  Future<void> softDeleteAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = TransactionOperation();
      await operation.softDeleteAll();
      return _loadData();
    });
  }

  // Method untuk me-refresh data secara manual dari luar (misal: pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadData);
  }
}
