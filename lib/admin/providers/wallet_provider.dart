// path: lib/admin/providers/wallet_provider.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';

// 1. Wajib tambahkan part file untuk generator
part 'wallet_provider.g.dart';

// State Immutable untuk menampung data UI WalletPage
class WalletState {
  final List<WalletModel> wallets;
  final double totalPositiveBalance;
  final double totalNegativeBalance;
  final double totalBalance;

  WalletState({
    this.wallets = const [],
    this.totalPositiveBalance = 0.0,
    this.totalNegativeBalance = 0.0,
    this.totalBalance = 0.0,
  });

  WalletState copyWith({
    List<WalletModel>? wallets,
    double? totalPositiveBalance,
    double? totalNegativeBalance,
    double? totalBalance,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      totalPositiveBalance: totalPositiveBalance ?? this.totalPositiveBalance,
      totalNegativeBalance: totalNegativeBalance ?? this.totalNegativeBalance,
      totalBalance: totalBalance ?? this.totalBalance,
    );
  }
}

// 2. Class Notifier Modern Menggunakan Anotasi @riverpod
// Secara default ini bersifat autoDispose. Jika ingin state bertahan saat berpindah halaman,
// gunakan @Riverpod(keepAlive: true)
@riverpod
class Wallet extends _$Wallet {
  // Method ini menggantikan fungsi build() lama.
  // Di sini kita langsung memanggil fungsi load data internal kita.
  @override
  FutureOr<WalletState> build() {
    return _loadData();
  }

  // Method internal reaktif untuk membaca database lokal
  Future<WalletState> _loadData() async {
    // RESMI: Gunakan ref.watch untuk dependency provider lain di dalam build/load data
    final operation = ref.watch(walletOperationProvider);
    final results = await Future.wait([
      operation.getWallets(),
      operation.getPositiveBalance(),
      operation.getNegativeBalance(),
      operation.getTotalBalance(),
    ]);

    return WalletState(
      wallets: results[0] as List<WalletModel>,
      totalPositiveBalance: results[1] as double,
      totalNegativeBalance: (results[2] as double).abs(),
      totalBalance: results[3] as double,
    );
  }

  // ==========================================
  // Method Aksi dari UI (Mutations)
  // ==========================================

  Future<void> addWallet(final WalletModel wallet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // RESMI: Gunakan ref.read di dalam event callback / fungsi aksi
      final operation = ref.read(walletOperationProvider);
      await operation.createWallet(wallet);
      return _loadData();
    });
  }

  Future<void> updateWallet(final WalletModel wallet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.updateWallet(wallet);
      return _loadData();
    });
  }

  Future<void> softDelete(final String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.softDelete(id);
      return _loadData();
    });
  }

  Future<void> deleteAllWallets() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.deleteAllWallets();
      return _loadData();
    });
  }

  // Method untuk refresh manual jika dibutuhkan oleh UI (misal: pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadData);
  }
}
