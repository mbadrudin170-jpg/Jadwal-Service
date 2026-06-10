// path: lib/fitur/speedtest/provider/uji_kecepatan_provider.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';

part 'uji_kecepatan_provider.freezed.dart';
part 'uji_kecepatan_provider.g.dart';

/// State untuk menampung hasil uji kecepatan.
@freezed
abstract class UjiKecepatanState with _$UjiKecepatanState {
  const factory UjiKecepatanState({
    @Default(0.0) double kecepatanUnduh,
    @Default(0.0) double kecepatanUnggah,
    @Default(0) int ping,
    @Default(false) bool sedangMenguji,
    @Default('Siap melakukan pengujian') String statusPesan,
  }) = _UjiKecepatanState;
}

@riverpod
class UjiKecepatan extends _$UjiKecepatan {
  @override
  UjiKecepatanState build() {
    /// Menginisialisasi keadaan awal pengujian kecepatan.
    return const UjiKecepatanState();
  }

  /// Memulai proses pengujian kecepatan internet dengan hasil yang dinamis.
  Future<void> mulaiPengujian(BuildContext context) async {
    Log.info('Memulai siklus pengujian kecepatan internet');

    if (!context.mounted) return;

    // Mengatur status awal pengujian
    state = state.copyWith(
      sedangMenguji: true,
      statusPesan: 'Menghubungkan ke server...',
      kecepatanUnduh: 0.0,
      kecepatanUnggah: 0.0,
      ping: 0,
    );

    try {
      final acak = Random();

      /// Melakukan simulasi latency (ping) secara dinamis.
      await Future.delayed(const Duration(seconds: 2));
      final hasilPing = acak.nextInt(45) + 5; // Menghasilkan 5-50 ms
      state = state.copyWith(
        statusPesan: 'Mengukur latency...',
        ping: hasilPing,
      );

      // Simulasi jeda sebelum unduh
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(statusPesan: 'Menguji kecepatan unduh...');

      // Simulasi proses unduh
      await Future.delayed(const Duration(seconds: 3));

      /// Menghasilkan nilai kecepatan unduh dinamis (15-65 Mbps).
      final hasilUnduh = acak.nextDouble() * 50 + 15;
      state = state.copyWith(
        kecepatanUnduh: hasilUnduh,
        statusPesan: 'Menguji kecepatan unggah...',
      );

      // Simulasi proses unggah
      await Future.delayed(const Duration(seconds: 3));

      /// Menghasilkan nilai kecepatan unggah dinamis (5-25 Mbps).
      final hasilUnggah = acak.nextDouble() * 20 + 5;
      state = state.copyWith(
        kecepatanUnggah: hasilUnggah,
        sedangMenguji: false,
        statusPesan: 'Pengujian selesai',
      );

      if (context.mounted) {
        ToastUtil.success(context, 'Uji kecepatan berhasil diselesaikan');
      }
    } on Exception catch (e, st) {
      // Menangani kegagalan dalam proses pengujian
      state = state.copyWith(
        sedangMenguji: false,
        statusPesan: 'Gagal melakukan pengujian',
      );
      Log.error('Gagal saat melakukan uji kecepatan', e: e, st: st);

      if (context.mounted) {
        ToastUtil.error(
          context,
          'Gagal melakukan uji kecepatan. Silakan coba lagi.',
        );
      }
    }
  }
}
