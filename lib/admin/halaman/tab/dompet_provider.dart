// path: lib/admin/halaman/tab/dompet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';

/// Provider untuk instance DompetOperasi.
final dompetOperasiProvider = Provider<DompetOperasi>((final ref) {
  return DompetOperasi();
});

/// Provider untuk instance TransaksiOperasi.
final transaksiOperasiProvider = Provider<TransaksiOperasi>((final ref) {
  return TransaksiOperasi();
});

/// FutureProvider untuk mendapatkan daftar dompet.
/// Provider ini akan secara otomatis mengambil data dompet terbaru.
final daftarDompetProvider = FutureProvider<List<DompetModel>>((final ref) {
  // watch provider lain untuk mendapatkan instance-nya
  final dompetOperasi = ref.watch(dompetOperasiProvider);
  return dompetOperasi.getDompet();
});

/// FutureProvider untuk mendapatkan ringkasan keuangan.
/// Provider ini akan menghitung total pemasukan, pengeluaran, dan saldo.
final ringkasanKeuanganProvider = FutureProvider<List<double>>((final ref) {
  final dompetOperasi = ref.watch(dompetOperasiProvider);
  // Menggunakan Future.wait untuk menjalankan semua future secara bersamaan.
  return Future.wait([
    dompetOperasi.getTotalSaldoPositif(),
    dompetOperasi.getTotalSaldoNegatif(),
    dompetOperasi.getTotalSaldo(),
  ]);
});
