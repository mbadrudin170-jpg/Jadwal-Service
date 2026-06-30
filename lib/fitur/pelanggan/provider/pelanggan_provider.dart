// path lib/fitur/pelanggan/provider/pelanggan_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/export/operation.dart';

part 'pelanggan_provider.g.dart';
part 'pelanggan_provider.freezed.dart';

@freezed
abstract class PelangganState with _$PelangganState {
  const factory PelangganState({
    @Default([]) List<PelangganModel> daftarPelanggan,
    @Default(0) int jumlahPelanggan,
    @Default(0) int totalPoin,
  }) = _PelangganState;
}

@Riverpod(keepAlive: true)
class Pelanggan extends _$Pelanggan {
  PelangganOpSqlite get _pelangganOpSqlite =>
      ref.read(pelangganOpSqliteProvider);
  PelangganOpGlobal get _pelangganOp => ref.read(pelangganOpGlobalProvider);

  TransaksiOpSqlite get _transaksiOpSqlite =>
      ref.read(transaksiOpSqliteProvider);

  @override
  FutureOr<PelangganState> build() {
    return _ambilData();
  }

  Future<PelangganState> _ambilData() async {
    final hasil = await _pelangganOpSqlite.ambilSemua();
    final hitungPoinFutures = hasil.map(
      (pelanggan) => _transaksiOpSqlite.ambilTotalPoin(pelanggan.id),
    );
    final daftarPoin = await Future.wait(hitungPoinFutures);
    final totalPoinSistem = daftarPoin.fold<int>(0, (sum, poin) => sum + poin);
    return PelangganState(
      daftarPelanggan: hasil,
      jumlahPelanggan: hasil.length,
      totalPoin: totalPoinSistem,
    );
  }

  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    try {
      await _pelangganOpSqlite.tambahPelanggan(pelanggan);
      ref.invalidateSelf();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    try {
      await _pelangganOp.updatePelanggan(pelanggan);
      _invalidateDetailPelanggan(pelanggan.id);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await _pelangganOpSqlite.softDelete(id);
      ref.invalidateSelf();
      _invalidateDetailPelanggan(id);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  void _invalidateDetailPelanggan(String? idPelanggan) {
    ref.invalidateSelf();
    if (idPelanggan != null) {
      ref.invalidate(pelangganDetailProvider(idPelanggan));
    } else {
      ref.invalidate(pelangganDetailProvider);
    }
    ref.invalidate(isSearchingPelangganProvider);
    ref.invalidate(searchQueryPelangganProvider);
    ref.invalidate(namaPelangganProvider);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
  }
}

@riverpod
class IsSearchingPelanggan extends _$IsSearchingPelanggan {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void setFalse() => state = false;
}

/// Provider generator modern untuk menyimpan text query pencarian pelanggan
@riverpod
class SearchQueryPelanggan extends _$SearchQueryPelanggan {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

@riverpod
Future<String?> namaPelanggan(Ref ref, String idPelanggan) async {
  if (idPelanggan.isEmpty) return null;
  final pelangganOp = ref.watch(pelangganOpGlobalProvider);
  final pelanggan = await pelangganOp.ambilBerdasarkanId(idPelanggan);
  return pelanggan?.nama;
}

@riverpod
Future<(PelangganModel?, int)> pelangganDetail(Ref ref, String id) async {
  final pelangganOp = ref.watch(pelangganOpGlobalProvider);
  final transaksiOp = ref.watch(transaksiOpGlobalProvider);
  final pelanggan = await pelangganOp.ambilBerdasarkanId(id);
  final poin = await transaksiOp.ambilTotalPoin(id);
  return (pelanggan, poin);
}
