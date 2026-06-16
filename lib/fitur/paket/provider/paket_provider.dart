// path: lib/fitur/paket/provider/paket_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/paket/page/paket.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/debug/log.dart';

part 'paket_provider.g.dart';

/// Provider asinkron untuk mengambil data daftar paket yang aktif dari SQLite.
/// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.
@riverpod
Future<List<PaketModel>> daftarPaket(DaftarPaketRef ref) async {
  Log.info('Mendapatkan daftar paket aktif dari SQLite via paketProvider...');

  // Mengambil instance PackageOperation dari operasi_sqlite_provider.dart
  final paketOpSqlite = ref.watch(paketOpSqliteProvider);
  return await paketOpSqlite.ambilBerdasarkanAktif();
}

/// Provider untuk menyimpan state opsi urutan paket yang dipilih oleh user.
@riverpod
class UrutanPaketState extends _$UrutanPaketState {
  @override
  UrutanPaket build() {
    return UrutanPaket.durasiTerpendek;
  }

  /// Fungsi untuk mengubah status urutan dari UI
  void ubahUrutan(UrutanPaket urutanBaru) {
    state = urutanBaru;
  }
}

@riverpod
Future<PaketModel> detailPaket(DetailPaketRef ref, String id) async {
  Log.info('Mendapatkan detail paket dari SQLite via paketProvider...');
  final paketOpSqlite = ref.watch(paketOpSqliteProvider);
  final paket = await paketOpSqlite.ambilBerdasarkanId(id);
  if (paket == null) {
    throw Exception('Paket dengan id $id tidak ditemukan');
  }
  return paket;
}
