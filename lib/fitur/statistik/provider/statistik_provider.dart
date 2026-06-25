// path: lib/fitur/statistik/provider/statistik_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';
import 'package:wifi/fitur/statistik/operasi/statistik_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';

part 'statistik_provider.g.dart';

class StatistikState {
  final double totalPendaptanPerbulan;
  final int totalPelanggan;
  final int totalFeedback;
  final List<PaketTerlarisModel> paketTerlaris;

  StatistikState({
    this.totalPendaptanPerbulan = 0.0,
    this.totalPelanggan = 0,
    this.totalFeedback = 0,
    this.paketTerlaris = const [],
  });

  StatistikState copyWith({
    double? totalPendaptanPerbulan,
    int? totalPelanggan,
    int? jumlahFeedbackBaru,
    List<PaketTerlarisModel>? paketTerlaris,
  }) {
    return StatistikState(
      totalPendaptanPerbulan:
          totalPendaptanPerbulan ?? this.totalPendaptanPerbulan,
      totalPelanggan: totalPelanggan ?? this.totalPelanggan,
      totalFeedback: jumlahFeedbackBaru ?? totalFeedback,
      paketTerlaris: paketTerlaris ?? this.paketTerlaris,
    );
  }
}

@Riverpod(keepAlive: true)
class Statistik extends _$Statistik {
  StatistikOpSqlite get _statistikOpSlite =>
      ref.watch(statistikOpSliteProvider);

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
      final pendapatan = await _statistikOpSlite.ambilTotalPendapatan();
      final pelanggan = await _statistikOpSlite.ambilTotalPelanggan();
      final feedbackBaru = await _statistikOpSlite.ambilTotalFeedback();
      Log.info('[StatistikNotifier] Semua data sekuensial berhasil dimuat.');
      return StatistikState(
        totalPendaptanPerbulan: pendapatan,
        totalPelanggan: pelanggan,
        totalFeedback: feedbackBaru,
      );
    } catch (e, st) {
      Log.error(
        '[StatistikNotifier] Gagal memuat data statistik.',
        e: e,
        s: st,
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
