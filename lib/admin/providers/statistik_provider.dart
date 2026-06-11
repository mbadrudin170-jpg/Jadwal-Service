// path: lib/admin/providers/statistik_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/admin/repository/statistik_repository.dart';
import 'package:wifi/shared/debug/log.dart';

part 'statistik_provider.g.dart';

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
      jumlahLanggananAktif: jumlahLanggananAktif ?? this.jumlahLanggananAktif,
      jumlahFeedbackBaru: jumlahFeedbackBaru ?? this.jumlahFeedbackBaru,
      bestSellingPackages: bestSellingPackages ?? this.bestSellingPackages,
    );
  }
}

@Riverpod(keepAlive: true)
class Statistik extends _$Statistik {
  StatistikRepository get _repository => ref.watch(statistikRepositoryProvider);

  @override
  Future<StatistikState> build() {
    Log.info('[StatistikNotifier] Build dipanggil, memuat data awal.');
    return _muatData();
  }

  // Mengubah _muatData dari Future.wait menjadi await sekuensial
  // Ini memastikan provider gagal-cepat (fail-fast) jika salah satu future gagal,
  // yang akan menyelesaikan masalah timeout pada pengujian.
  Future<StatistikState> _muatData() async {
    try {
      Log.info('[StatistikNotifier] Memulai pemuatan data sekuensial...');
      final pendapatan = await _repository.getPendapatanBulanIni();
      final pelanggan = await _repository.getTotalPelanggan();
      final langgananAktif = await _repository.getJumlahLanggananAktif();
      final feedbackBaru = await _repository.getJumlahFeedbackBaru();
      final paketTerlaris = await _repository.getBestSellingPackages();
      Log.info('[StatistikNotifier] Semua data sekuensial berhasil dimuat.');

      return StatistikState(
        pendapatanBulanIni: pendapatan,
        totalPelanggan: pelanggan,
        jumlahLanggananAktif: langgananAktif,
        jumlahFeedbackBaru: feedbackBaru,
        bestSellingPackages: paketTerlaris,
      );
    } catch (e, st) {
      Log.error(
        '[StatistikNotifier] Gagal memuat data statistik.',
        e: e,
        st: st,
      );
      // Melempar kembali error agar ditangkap oleh AsyncValue.guard atau state provider.
      rethrow;
    }
  }

  Future<void> refresh() async {
    Log.info('[StatistikNotifier] Refresh dipicu oleh UI.');
    state = const AsyncLoading();
    // Menggunakan AsyncValue.guard untuk menangani error secara otomatis.
    state = await AsyncValue.guard(_muatData);
    Log.info('[StatistikNotifier] Refresh selesai.');
  }
}
