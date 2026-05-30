// path: lib/admin/providers/statistik_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/admin/repository/statistik_repository.dart';
import 'package:wifi/shared/debug/log.dart';

// 1. Definisikan State untuk Statistik
// State ini akan menampung semua data yang dibutuhkan oleh UI StatistikPage.
class StatistikState {
  final double pendapatanBulanIni;
  final int totalPelanggan;
  final int jumlahLanggananAktif;
  final int jumlahFeedbackBaru;
  final List<BestSellingPackage> bestSellingPackages;

  StatistikState({
    this.pendapatanBulanIni = 0.0,
    this.totalPelanggan = 0,
    this.jumlahLanggananAktif = 0,
    this.jumlahFeedbackBaru = 0,
    this.bestSellingPackages = const [],
  });

  // copyWith tidak wajib tapi sangat membantu untuk mutasi state
  StatistikState copyWith({
    double? pendapatanBulanIni,
    int? totalPelanggan,
    int? jumlahLanggananAktif,
    int? jumlahFeedbackBaru,
    List<BestSellingPackage>? bestSellingPackages,
  }) {
    return StatistikState(
      pendapatanBulanIni: pendapatanBulanIni ?? this.pendapatanBulanIni,
      totalPelanggan: totalPelanggan ?? this.totalPelanggan,
      jumlahLanggananAktif:
          jumlahLanggananAktif ?? this.jumlahLanggananAktif,
      jumlahFeedbackBaru: jumlahFeedbackBaru ?? this.jumlahFeedbackBaru,
      bestSellingPackages: bestSellingPackages ?? this.bestSellingPackages,
    );
  }
}

// 2. Buat AsyncNotifierProvider
final statistikProvider =
    AsyncNotifierProvider<StatistikNotifier, StatistikState>(
  StatistikNotifier.new,
);

// 3. Buat Class Notifier
class StatistikNotifier extends AsyncNotifier<StatistikState> {
  // Method ini akan dipanggil otomatis saat provider pertama kali digunakan.
  @override
  Future<StatistikState> build() {
    Log.info('[StatistikNotifier] Build dipanggil, memuat data awal.');
    return _loadData();
  }

  // Helper untuk mengambil semua data statistik dalam satu operasi.
  Future<StatistikState> _loadData() async {
    Log.info('[StatistikNotifier] Memulai _loadData.');
    final repository = StatistikRepository();

    // Menggunakan Future.wait untuk menjalankan semua query secara paralel
    final results = await Future.wait([
      repository.getPendapatanBulanIni(),
      repository.getTotalPelanggan(),
      repository.getJumlahLanggananAktif(),
      repository.getJumlahFeedbackBaru(),
      repository.getBestSellingPackages(),
    ]);
    Log.info('[StatistikNotifier] Semua future dari repository selesai.');

    // Memetakan hasil ke dalam state
    return StatistikState(
      pendapatanBulanIni: results[0] as double,
      totalPelanggan: results[1] as int,
      jumlahLanggananAktif: results[2] as int,
      jumlahFeedbackBaru: results[3] as int,
      bestSellingPackages: results[4] as List<BestSellingPackage>,
    );
  }

  // Method untuk me-refresh data dari UI
  Future<void> refresh() async {
    Log.info('[StatistikNotifier] Refresh dipicu oleh UI.');
    // Set state ke loading untuk menampilkan indicator
    state = const AsyncLoading();
    // Muat ulang data dan perbarui state, tangani jika ada error
    state = await AsyncValue.guard(_loadData);
    Log.info('[StatistikNotifier] Refresh selesai.');
  }
}
