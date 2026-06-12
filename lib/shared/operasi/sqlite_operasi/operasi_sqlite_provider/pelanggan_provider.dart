// path: lib/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/pelanggan/ui/admin/customer.dart';
import 'package:wifi/fitur/poin/operasi/sqlite_points_data_source.dart';
import 'package:wifi/shared/debug/log.dart';

part 'pelanggan_provider.g.dart';

/// Provider asinkron untuk mengambil semua data customer beserta poin mereka dari SQLite.
@riverpod
Future<List<(CustomerModel, int)>> customerList(Ref ref) async {
  Log.info(
      'Mendapatkan daftar pelanggan aktif beserta poin dari SQLite via pelangganProvider...');

  final customerOp = ref.watch(customerOperationProvider);
  final pointsOp = ref.watch(sqlitePointsDataSourceProvider);
  final customers = await customerOp.ambilSemua();
  final List<Future<int>> pointsFutures = customers
      .map((CustomerModel c) => pointsOp.getTotalPoints(c.id))
      .toList();
  final points = await Future.wait(pointsFutures);
  final List<(CustomerModel, int)> result = [];
  for (int i = 0; i < customers.length; i++) {
    result.add((customers[i], points[i]));
  }

  return result;
}

/// Provider untuk menyimpan state opsi urutan pelanggan yang dipilih oleh user.
@riverpod
class UrutanPelangganState extends _$UrutanPelangganState {
  @override
  UrutanPelanggan build() {
    return UrutanPelanggan.nameAZ;
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

/// Provider untuk mengambil detail data satu pelanggan beserta poinnya secara asinkron
@riverpod
Future<(CustomerModel?, int)> customerDetail(Ref ref, String id) async {
  final customerOp = ref.watch(customerOperationProvider);
  final transactionOp = ref.watch(transactionOperationProvider);
  final customer = await customerOp.ambilBerdasarkanId(id);
  final points = await transactionOp.getTotalPoints(id);

  return (customer, points);
}
