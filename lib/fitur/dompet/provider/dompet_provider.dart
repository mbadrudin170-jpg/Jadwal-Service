// path: lib/fitur/dompet/provider/dompet_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';

part 'dompet_provider.freezed.dart';
part 'dompet_provider.g.dart';

@freezed
abstract class DompetState with _$DompetState {
  const factory DompetState({
    @Default([]) List<DompetModel> wallets,
    @Default(0.0) double totalSaldoPositif,
    @Default(0.0) double totalSaldoNegatif,
    @Default(0.0) double totalSaldo,
  }) = _DompetState;
}

@riverpod
class Dompet extends _$Dompet {
  @override
  FutureOr<DompetState> build() {
    return _loadData();
  }

  Future<DompetState> _loadData() async {
    final operation = ref.read(dompetOpSqliteProvider);
    final results = await Future.wait([
      operation.ambilSemua(),
      operation.ambilSaldoPositif(),
      operation.ambilSaldoNegatif(),
      operation.ambilTotalsaldo(),
    ]);

    return DompetState(
      wallets: results[0] as List<DompetModel>,
      totalSaldoPositif: results[1] as double,
      totalSaldoNegatif: (results[2] as double).abs(),
      totalSaldo: results[3] as double,
    );
  }

  /// fungsi untuk menambah data dompet baru
  Future<void> tambahDompet(DompetModel wallet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.tambahDompet(wallet);

      return _loadData();
    });
  }

  /// fungsi untuk update satu data dompet
  Future<void> updateDompet(DompetModel wallet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.updateDompet(wallet);
      return _loadData();
    });
  }

  /// fungsi untuk menghapus data dompet secara soft delete
  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.softDelete(id);
      return _loadData();
    });
  }

  /// fungsi untuk menghapus semua data dompet
  Future<void> softDeleteAll() async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.softDeleteAll();
      return _loadData();
    });
  }

  /// fungsi untuk menyegarkan data dompet
  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadData);
  }
}
