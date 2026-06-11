// path: lib/fitur/dompet/provider/wallet_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/wallet_model.dart';

part 'wallet_provider.freezed.dart';
part 'wallet_provider.g.dart';

@freezed
abstract class WalletState with _$WalletState {
  const factory WalletState({
    @Default([]) List<WalletModel> wallets,
    @Default(0.0) double totalSaldoPositif,
    @Default(0.0) double totalSaldoNegatif,
    @Default(0.0) double totalSaldo,
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
      operation.ambilSaldoPositif(),
      operation.ambilSaldoNegatif(),
      operation.ambilTotalsaldo(),
    ]);

    return WalletState(
      wallets: results[0] as List<WalletModel>,
      totalSaldoPositif: results[1] as double,
      totalSaldoNegatif: (results[2] as double).abs(),
      totalSaldo: results[3] as double,
    );
  }

  /// fungsi untuk menambah data dompet baru
  Future<void> tambahDompet(WalletModel wallet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.tambahDompet(wallet);
      
      return _loadData();
    });
  }

  /// fungsi untuk update satu data dompet
  Future<void> updateDompet(WalletModel wallet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.updateDompet(wallet);
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
  Future<void> softDeleteAll() async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(walletOperationProvider);
      await operation.softDeleteAll();
      return _loadData();
    });
  }

  /// fungsi untuk menyegarkan data dompet
  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadData);
  }
}
