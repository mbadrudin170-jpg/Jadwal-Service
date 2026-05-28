// path: lib/shared/providers/wallet_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';

// 1. Definisikan State
// State ini akan menampung semua data yang dibutuhkan oleh UI WalletPage.
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
    final List<WalletModel>? wallets,
    final double? totalPositiveBalance,
    final double? totalNegativeBalance,
    final double? totalBalance,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      totalPositiveBalance: totalPositiveBalance ?? this.totalPositiveBalance,
      totalNegativeBalance: totalNegativeBalance ?? this.totalNegativeBalance,
      totalBalance: totalBalance ?? this.totalBalance,
    );
  }
}

// 2. Buat AsyncNotifierProvider
final walletProvider = AsyncNotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);

// 3. Buat Class Notifier
class WalletNotifier extends AsyncNotifier<WalletState> {
  // Method ini akan dipanggil otomatis saat provider pertama kali digunakan.
  @override
  Future<WalletState> build() {
    return _loadData();
  }

  // Helper untuk mengambil semua data dalam satu operasi.
  Future<WalletState> _loadData() async {
    final operation = WalletOperation();
    final results = await Future.wait([
      operation.getWallets(),
      operation.getPositiveBalance(),
      operation.getNegativeBalance(),
      operation.getTotalBalance(),
    ]);

    return WalletState(
      wallets: results[0] as List<WalletModel>,
      totalPositiveBalance: results[1] as double,
      totalNegativeBalance: (results[2] as double).abs(), // Ambil nilai absolut
      totalBalance: results[3] as double,
    );
  }

  // Method untuk aksi dari UI

  Future<void> addWallet(final WalletModel wallet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final walletOperation = WalletOperation();
      await walletOperation.createWallet(wallet);
      return _loadData();
    });
  }

  Future<void> updateWallet(final WalletModel wallet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = WalletOperation();
      await operation.updateWallet(wallet);
      return _loadData();
    });
  }

  Future<void> softDelete(final String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = WalletOperation();
      await operation.softDelete(id);
      return _loadData();
    });
  }

  Future<void> deleteAllWallets() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final operation = WalletOperation();
      await operation.deleteAllWallets();
      return _loadData();
    });
  }

  // Method untuk refresh manual
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadData);
  }
}
