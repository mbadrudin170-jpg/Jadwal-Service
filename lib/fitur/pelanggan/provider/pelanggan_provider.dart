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
      ref.read(pelangganOpSqliteProvider);
  SQLitePointsDataSource get poinDataSource =>
      ref.read(sqlitePointsDataSourceProvider);

  @override
  FutureOr<PelangganState> build() {
    return _ambilData();
  }

  Future<PelangganState> _ambilData() async {
    final hasil = await pelangganOpSqlite.ambilSemua();
    int totalPoinSistem = 0;
    for (final pelanggan in hasil) {
      final poin = await poinDataSource.ambilTotalPoin(pelanggan.id);
      totalPoinSistem += poin;
    }
    return PelangganState(
      daftarPelanggan: hasil,
      jumlahPelanggan: hasil.length,
      totalPoin: totalPoinSistem, 
    );
  }

  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await pelangganOpSqlite.tambahPelanggan(pelanggan);
      // Tidak perlu meng-invalidate detail karena ini pelanggan baru
      return _ambilData();
    });
  }

  Future<void> perbaruiPelanggan(PelangganModel pelanggan) async {
    state = await AsyncValue.guard(() async {
      await pelangganOpSqlite.perbaruiPelanggan(pelanggan);
      _invalidateDetailPelanggan(
        pelanggan.id,
      ); // PERBAIKAN 2: Kirimkan ID yang spesifik
      return _ambilData();
    });
  }

  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      await pelangganOpSqlite.softDelete(id);
      _invalidateDetailPelanggan(id); // PERBAIKAN 2: Kirimkan ID yang spesifik
      return _ambilData();
    });
  }

  void _invalidateDetailPelanggan(String id) {
    ref.invalidate(pelangganDetailProvider(id));
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
// PERBAIKAN 4: Mengubah tipe Ref menjadi PelangganDetailRef (Wajib bagi riverpod generator)
Future<(PelangganModel?, int)> pelangganDetail(Ref ref, String id) async {
  final pelangganOpSqlte = ref.watch(pelangganOpSqliteProvider);
  final transaksiOpSqlite = ref.watch(transaksiOpSqliteProvider);
  final pelanggan = await pelangganOpSqlte.ambilBerdasarkanId(id);
  final poin = await transaksiOpSqlite.ambilTotalPoin(id);

  return (pelanggan, poin);
}
