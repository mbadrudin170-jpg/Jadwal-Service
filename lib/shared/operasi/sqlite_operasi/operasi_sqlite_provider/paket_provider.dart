// path: lib/shared/operasi/sqlite_operasi/operasi_sqlite_provider/paket_provider.dart
// path: lib/shared/operasi/sqlite_operasi/operasi_sqlite_provider/paket_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
// Penting: Import enum UrutanPaket agar provider tahu tipe data statusnya
import 'package:wifi/admin/halaman/lainnya/package.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';

part 'paket_provider.g.dart';

/// Provider asinkron untuk mengambil data daftar paket yang aktif dari SQLite.
/// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.
@riverpod
Future<List<PackageModel>> packageList(Ref ref) async {
  Log.info('Mendapatkan daftar paket aktif dari SQLite via paketProvider...');

  // Mengambil instance PackageOperation dari operasi_sqlite_provider.dart
  final paketOperasi = ref.watch(packageOperationProvider);
  return await paketOperasi.getByAktif();
}

/// Provider untuk menyimpan state opsi urutan paket yang dipilih oleh user.
@riverpod
class UrutanPaketState extends _$UrutanPaketState {
  @override
  UrutanPaket build() {
    // Nilai default awal saat halaman pertama kali dibuka
    return UrutanPaket.durasiTerpendek;
  }

  /// Fungsi untuk mengubah status urutan dari UI
  void ubahUrutan(UrutanPaket urutanBaru) {
    state = urutanBaru;
  }
}
