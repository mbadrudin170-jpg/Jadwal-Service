// path: lib/fitur/speedtest/provider/uji_kecepatan_provider.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';

part 'uji_kecepatan_provider.g.dart';

/// State untuk menampung hasil uji kecepatan.
class UjiKecepatanState {
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
    return UjiKecepatanState();
  }

  // 1. Fungsi untuk memulai pengujian kecepatan internet
  Future<void> mulaiPengujian(BuildContext konteks) async {
    Log.info('Memulai uji kecepatan internet');

    state = state.copyWith(
      sedangMenguji: true,
      statusPesan: 'Menghubungkan ke server...',
      kecepatanUnduh: 0,
      kecepatanUnggah: 0,
    );

    try {
      // Simulasi proses uji kecepatan (Dalam realita, gunakan library speedtest)
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(statusPesan: 'Menguji kecepatan unduh...');

      await Future.delayed(const Duration(seconds: 3));
      const hasilUnduh = 25.5; // Contoh 25.5 Mbps
      state = state.copyWith(
        kecepatanUnduh: hasilUnduh,
        statusPesan: 'Menguji kecepatan unggah...',
      );

      await Future.delayed(const Duration(seconds: 3));
      const hasilUnggah = 10.2; // Contoh 10.2 Mbps

      state = state.copyWith(
        kecepatanUnggah: hasilUnggah,
        sedangMenguji: false,
        statusPesan: 'Pengujian selesai',
      );

      if (konteks.mounted) {
        ToastUtil.success(konteks, 'Uji kecepatan berhasil diselesaikan');
      }
    } on Object catch (e, st) {
      state = state.copyWith(
          sedangMenguji: false, statusPesan: 'Gagal melakukan pengujian');
      Log.error('Gagal saat melakukan uji kecepatan', e: e, st: st);
      if (konteks.mounted) {
        ToastUtil.error(
            konteks, 'Gagal melakukan uji kecepatan. Silakan coba lagi.');
      }
    }
  }
}
