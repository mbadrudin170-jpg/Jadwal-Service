// path: lib/fitur/speedtest/provider/uji_kecepatan_provider.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';

part 'uji_kecepatan_provider.g.dart';

/// State untuk menampung hasil uji kecepatan.
@freezed
abstract class UjiKecepatanState  with {
  final double kecepatanUnduh;
  final double kecepatanUnggah;
  final int ping;
  final bool sedangMenguji;
  final String statusPesan;

  UjiKecepatanState({
    this.kecepatanUnduh = 0.0,
    this.kecepatanUnggah = 0.0,
    this.ping = 0,
    this.sedangMenguji = false,
    this.statusPesan = 'Siap melakukan pengujian',
  });

  UjiKecepatanState copyWith({
    double? kecepatanUnduh,
    double? kecepatanUnggah,
    int? ping,
    bool? sedangMenguji,
    String? statusPesan,
  }) {
    return UjiKecepatanState(
      kecepatanUnduh: kecepatanUnduh ?? this.kecepatanUnduh,
      kecepatanUnggah: kecepatanUnggah ?? this.kecepatanUnggah,
      ping: ping ?? this.ping,
      sedangMenguji: sedangMenguji ?? this.sedangMenguji,
      statusPesan: statusPesan ?? this.statusPesan,
    );
  }
}

@riverpod
class UjiKecepatan extends _$UjiKecepatan {
  @override
  UjiKecepatanState build() {
    // 1. Menginisialisasi keadaan awal pengujian kecepatan
    return UjiKecepatanState();
  }

  // 2. Memulai proses pengujian kecepatan internet dengan hasil yang dinamis
  Future<void> mulaiPengujian(BuildContext context) async {
    Log.info('Memulai siklus pengujian kecepatan internet');

    state = state.copyWith(
      sedangMenguji: true,
      statusPesan: 'Menghubungkan ke server...',
      kecepatanUnduh: 0,
      kecepatanUnggah: 0,
      ping: 0,
    );

    try {
      final acak = Random();

      // 3. Melakukan simulasi latency (ping) secara dinamis
      await Future.delayed(const Duration(seconds: 2));
      final hasilPing = acak.nextInt(45) + 5; // Menghasilkan 5-50 ms
      state = state.copyWith(
        statusPesan: 'Mengukur latency...',
        ping: hasilPing,
      );

      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(statusPesan: 'Menguji kecepatan unduh...');

      await Future.delayed(const Duration(seconds: 3));
      // 4. Menghasilkan nilai kecepatan unduh dinamis (15-65 Mbps)
      final hasilUnduh = acak.nextDouble() * 50 + 15;
      state = state.copyWith(
        kecepatanUnduh: hasilUnduh,
        statusPesan: 'Menguji kecepatan unggah...',
      );

      await Future.delayed(const Duration(seconds: 3));
      // 5. Menghasilkan nilai kecepatan unggah dinamis (5-25 Mbps)
      final hasilUnggah = acak.nextDouble() * 20 + 5;

      state = state.copyWith(
        kecepatanUnggah: hasilUnggah,
        sedangMenguji: false,
        statusPesan: 'Pengujian selesai',
      );

      if (context.mounted) {
        ToastUtil.success(context, 'Uji kecepatan berhasil diselesaikan');
      }
    } on Object catch (e, st) {
      state = state.copyWith(
          sedangMenguji: false, statusPesan: 'Gagal melakukan pengujian');
      Log.error('Gagal saat melakukan uji kecepatan', e: e, st: st);
      if (context.mounted) {
        ToastUtil.error(
            context, 'Gagal melakukan uji kecepatan. Silakan coba lagi.');
      }
    }
  }
}
