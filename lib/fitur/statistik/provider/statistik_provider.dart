// path: lib/fitur/statistik/provider/statistik_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/statistik/operasi/statistik_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';

part 'statistik_provider.g.dart';

class StatistikState {
  final int totalPelanggan;
  final int totalFeedback;

  StatistikState({
    this.totalPelanggan = 0,
    this.totalFeedback = 0,
  });

  StatistikState copyWith({
    int? totalPelanggan,
    int? jumlahFeedbackBaru,
  }) {
    return StatistikState(
      totalPelanggan: totalPelanggan ?? this.totalPelanggan,
      totalFeedback: jumlahFeedbackBaru ?? totalFeedback,
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
      final pelanggan = await _statistikOpSlite.ambilTotalPelanggan();
      final feedbackBaru = await _statistikOpSlite.ambilTotalFeedback();
      Log.info('[StatistikNotifier] Semua data sekuensial berhasil dimuat.');
      return StatistikState(
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
