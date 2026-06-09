// path: lib/admin/providers/wallet_provider.dart

import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';

part 'wallet_provider.g.dart';
part 'wallet_provider.freezed.dart';

@freezed
class WalletState with _$WalletState {
  const factory WalletState({
    @Default([]) List<WalletModel> wallets,
    @Default(0.0) double totalPositiveBalance,
    @Default(0.0) double totalNegativeBalance,
    @Default(0.0) double totalBalance,
  }) = _WalletState;
}

@riverpod
class Wallet extends _$Wallet {
  @override
  FutureOr<WalletState> build() {
    return _loadData();
  }

  Future<WalletState> _loadData() async {
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

  Future<void> addWallet(final WalletModel wallet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
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

  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadData);
  }
}
