// path: lib/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/halaman/lainnya/customer.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';

part 'pelanggan_provider.g.dart';

/// Provider asinkron untuk mengambil data daftar pelanggan yang aktif dari SQLite.
/// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.
@riverpod
Future<List<CustomerModel>> customerList(Ref ref) async {
  Log.info(
      'Mendapatkan daftar pelanggan aktif dari SQLite via pelangganProvider...');

  // Mengambil instance CustomerOperation dari operasi_sqlite_provider.dart
  final pelangganOperasi = ref.watch(customerOperationProvider);
  return await pelangganOperasi.getAll();
}

/// Provider untuk menyimpan state opsi urutan pelanggan yang dipilih oleh user.
@riverpod
class UrutanPelangganState extends _$UrutanPelangganState {
  @override
  UrutanPelanggan build() {
    // Nilai default awal saat halaman pertama kali dibuka
    return UrutanPelanggan.nameAZ;
  }

  /// Fungsi untuk mengubah status urutan dari UI
  void ubahUrutan(UrutanPelanggan urutanBaru) {
    state = urutanBaru;
  }
}
