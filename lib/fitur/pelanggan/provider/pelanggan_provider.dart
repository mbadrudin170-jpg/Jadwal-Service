// path lib/fitur/pelanggan/provider/pelanggan_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/admin/pelanggan.dart';
import 'package:wifi/fitur/poin/operasi/sqlite_points_data_source.dart';
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
  PelangganOpSqlite get pelangganOpSqlite =>
      ref.watch(pelangganOpSqliteProvider);
  SQLitePointsDataSource get poinDataSource =>
      ref.watch(sqlitePointsDataSourceProvider);

  @override
  FutureOr<PelangganState> build() {
    return _ambilData();
  }

  Future<PelangganState> _ambilData() async {
    final hasil = await pelangganOpSqlite.ambilSemua();
    double totalPoin = 0;
    for (final pelanggan in hasil) {
      totalPoin += await poinDataSource.ambilTotalPoin(pelanggan.id);
    }
    return PelangganState(
      daftarPelanggan: hasil,
      jumlahPelanggan: hasil.length,
      totalPoin: totalPoin.toInt(),
    );
  }

  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    state = await AsyncValue.guard(() async {
      await pelangganOpSqlite.tambahPelanggan(pelanggan);
      ref.invalidate(pelangganDetailProvider);
      ref.invalidateSelf();
      return _ambilData();
    });
  }

  Future<void> perbaruiPelanggan(PelangganModel pelanggan) async {
    state = await AsyncValue.guard(() async {
      await pelangganOpSqlite.perbaruiPelanggan(pelanggan);
      ref.invalidate(pelangganDetailProvider);
      ref.invalidateSelf();
      return _ambilData();
    });
  }

  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      await pelangganOpSqlite.softDelete(id);
      ref.invalidate(pelangganDetailProvider);
      ref.invalidateSelf();
      return _ambilData();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
  }
}

/// Provider untuk menyimpan state opsi urutan pelanggan yang dipilih oleh user.
@riverpod
class UrutanPelangganState extends _$UrutanPelangganState {
  @override
  UrutanPelanggan build() {
    return UrutanPelanggan.namaAZ;
  }

  void ubahUrutan(UrutanPelanggan urutanBaru) {
    state = urutanBaru;
  }
}

/// =========================================================================
/// TULIS DI SINI (Bagian paling bawah file pelanggan_provider.dart)
/// =========================================================================

/// Provider generator modern untuk status mode pencarian aktif/tidak
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
Future<(PelangganModel?, int)> pelangganDetail(Ref ref, String id) async {
  final pelangganOpSqlte = ref.watch(pelangganOpSqliteProvider);
  final transaksiOpSqlite = ref.watch(transaksiOpSqliteProvider);
  final pelanggan = await pelangganOpSqlte.ambilBerdasarkanId(id);
  final poin = await transaksiOpSqlite.ambilTotalPoin(id);
  return (pelanggan, poin);
}
