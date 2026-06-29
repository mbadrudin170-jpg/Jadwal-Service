// path: lib/fitur/dompet/provider/dompet_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'dompet_provider.freezed.dart';
part 'dompet_provider.g.dart';

@freezed
abstract class DetailDompetState with _$DetailDompetState {
  const factory DetailDompetState({
    required List<TransaksiModel> daftarTransaksi,
    DompetModel? dompet,
    required int totalTransaksi,
    required double totalPemasukan,
    required double totalPengeluaran,
    required double totalSaldo,
    required String namaDompet,
  }) = _DetailDompetState;
}

@freezed
abstract class DompetState with _$DompetState {
  const factory DompetState({
    @Default([]) List<DompetModel> daftarDompet,
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
      daftarDompet: results[0] as List<DompetModel>,
      totalSaldoPositif: results[1] as double,
      totalSaldoNegatif: (results[2] as double).abs(),
      totalSaldo: results[3] as double,
    );
  }

  /// fungsi untuk menambah data dompet baru
  Future<void> tambahDompet(DompetModel dompet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.tambahDompet(dompet);
      return _loadData();
    });
  }

  /// fungsi untuk update satu data dompet
  Future<void> updateDompet(DompetModel dompet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.updateDompet(dompet);
      return _loadData();
    });
  }

  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.softDelete(id);
      return _loadData();
    });
  }

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

  void invalidateDompet() {
    ref.invalidateSelf();
    ref.invalidate(detailDompetProvider);
  }
}

@riverpod
Future<DetailDompetState> detailDompet(Ref ref, String idDompet) async {
  try {
    final dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    final results = await Future.wait([
      transaksiOp.ambilBerdasarkanIdDompet(idDompet),
      dompetOpSqlite.ambilBerdasarkanId(idDompet),
    ]);
    final daftarTransaksi = results[0] as List<TransaksiModel>;
    final dompet = results[1] as DompetModel?;
    double totalPemasukan = 0;
    double totalPengeluaran = 0;
    for (final transaksi in daftarTransaksi) {
      if (transaksi.tipe == TipeTransaksi.income) {
        totalPemasukan += transaksi.jumlah;
      } else if (transaksi.tipe == TipeTransaksi.expense) {
        totalPengeluaran += transaksi.jumlah;
      }
    }
    final totalSaldo = totalPemasukan - totalPengeluaran;
    final namaDompet = dompet?.nama ?? 'Dompet Tidak Ditemukan';
    return DetailDompetState(
      daftarTransaksi: daftarTransaksi,
      dompet: dompet,
      totalTransaksi: daftarTransaksi.length,
      totalPemasukan: totalPemasukan,
      totalPengeluaran: totalPengeluaran,
      totalSaldo: totalSaldo,
      namaDompet: namaDompet,
    );
  } on Exception catch (e, s) {
    Log.error('Error diDetailDompet: $e', e: e, s: s);
    rethrow;
  }
}
