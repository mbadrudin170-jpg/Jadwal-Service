// path: lib/fitur/speedtest/provider/uji_kecepatan_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
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

  /// Memulai proses pengujian kecepatan internet menggunakan data server yang sebenarnya.
  Future<void> mulaiPengujian(BuildContext context) async {
    Log.info('Memulai siklus pengujian kecepatan internet');
    final penguji = FlutterInternetSpeedTest();

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
      await penguji.startTesting(
        onStarted: () {
          state = state.copyWith(statusPesan: 'Memulai pengujian...');
        },
        onDefaultServerSelectionInProgress: () {
          state = state.copyWith(statusPesan: 'Mencari server terbaik...');
        },
        onDefaultServerSelectionDone: (client) {
          state = state.copyWith(
            statusPesan: 'Server terhubung: ${client?.isp ?? "Otomatis"}',
          );
        },
        onProgress: (persentase, data) {
          // Konversi kecepatan ke Mbps.
          double kecepatanMbps = data.transferRate;
          if (data.unit == SpeedUnit.kbps) kecepatanMbps /= 1000;
          if (data.unit == SpeedUnit.mbps) kecepatanMbps /= 1000000;

          if (data.type == TestType.download) {
            state = state.copyWith(
              kecepatanUnduh: kecepatanMbps,
              statusPesan: 'Menguji unduh: ${persentase.toStringAsFixed(0)}%',
            );
          } else {
            state = state.copyWith(
              kecepatanUnggah: kecepatanMbps,
              statusPesan: 'Menguji unggah: ${persentase.toStringAsFixed(0)}%',
            );
          }
        },
        onCompleted: (unduh, unggah) {
          double hasilUnduhMbps = unduh.transferRate;
          if (unduh.unit == SpeedUnit.kbps) hasilUnduhMbps /= 1000;
          if (unduh.unit == SpeedUnit.mbps) hasilUnduhMbps /= 1000000;

          double hasilUnggahMbps = unggah.transferRate;
          if (unggah.unit == SpeedUnit.kbps) hasilUnggahMbps /= 1000;
          if (unggah.unit == SpeedUnit.mbps) hasilUnggahMbps /= 1000000;

          state = state.copyWith(
            kecepatanUnduh: hasilUnduhMbps,
            kecepatanUnggah: hasilUnggahMbps,
            sedangMenguji: false,
            statusPesan: 'Pengujian selesai',
          );

          if (context.mounted) {
            ToastUtil.success(context, 'Uji kecepatan berhasil diselesaikan');
          }
        },
        onError: (pesanError, kodeError) {
          state = state.copyWith(
            sedangMenguji: false,
            statusPesan: 'Gagal melakukan pengujian',
          );
          Log.error('Gagal saat melakukan uji kecepatan: $pesanError');
          if (context.mounted) {
            ToastUtil.error(context, 'Gagal melakukan uji kecepatan.');
          }
        },
      );
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
