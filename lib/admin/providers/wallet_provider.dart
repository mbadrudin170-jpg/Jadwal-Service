// path: lib/admin/providers/wallet_provider.dart

import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';

part 'wallet_provider.g.dart';
part 'wallet_provider.freezed.dart';

@freezed
abstract class WalletState with _$WalletState {
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

  /// fungsi untuk menambah data dompet baru
  Future<void> addWallet(WalletModel wallet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.createWallet(wallet);
      return _loadData();
    });
  }

  /// fungsi untuk update satu data dompet
  Future<void> updateWallet(WalletModel wallet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.updateWallet(wallet);
      return _loadData();
    });
  }

  /// fungsi untuk menghapus data dompet secara soft delete
  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.softDelete(id);
      return _loadData();
    });
  }

  /// fungsi untuk menghapus semua data dompet
  Future<void> deleteAllWallets() async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.deleteAllWallets();
      return _loadData();
    });
  }

  /// fungsi untuk menyegarkan data dompet
  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadData);
  }
}
