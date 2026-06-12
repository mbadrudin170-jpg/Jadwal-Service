// path: lib/fitur/speedtest/provider/uji_kecepatan_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/speedtest/provider/ping_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';

part 'uji_kecepatan_provider.freezed.dart';
part 'uji_kecepatan_provider.g.dart';

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
    return const UjiKecepatanState();
  }

  /// Memulai proses pengujian kecepatan internet menggunakan data server yang sebenarnya.
  Future<void> mulaiPengujian(
    BuildContext context, {
    FlutterInternetSpeedTest? alatUjiManual,
  }) async {
    Log.info('Memulai siklus pengujian kecepatan internet');
    final alatUji = alatUjiManual ?? FlutterInternetSpeedTest();

    if (!context.mounted) return;

    // Mengatur status awal pengujian
    state = state.copyWith(
      sedangMenguji: true,
      statusPesan: 'Menghubungkan ke server...',
      kecepatanUnduh: 0.0,
      kecepatanUnggah: 0.0,
      ping: 0,
    );

    // Get Ping
    try {
      state = state.copyWith(statusPesan: 'Mengukur ping...');
      final pingAsync = await ref.read(pingProvider.future);
      final pingTime = pingAsync.response?.time?.inMilliseconds;
      if (pingTime != null) {
        state = state.copyWith(ping: pingTime);
      }
    } catch (e) {
      Log.warning('Gagal mendapatkan ping: $e');
      state = state.copyWith(ping: -1); // Indicate error
    }

    try {
      await alatUji.startTesting(
        onStarted: () {
          state = state.copyWith(statusPesan: 'Memulai pengujian...');
        },
        onDefaultServerSelectionInProgress: () {
          state = state.copyWith(statusPesan: 'Mencari server terbaik...');
        },
        onDefaultServerSelectionDone: (klien) {
          state = state.copyWith(
            statusPesan: 'Server terhubung: ${klien?.isp ?? "Otomatis"}',
          );
        },
        onProgress: (persentase, dataUji) {
          double kecepatanDalamMbps = dataUji.transferRate;
          if (dataUji.unit == SpeedUnit.kbps) kecepatanDalamMbps /= 1000;

          if (dataUji.type == TestType.download) {
            state = state.copyWith(
              kecepatanUnduh: kecepatanDalamMbps,
              statusPesan: 'Menguji unduh: ${persentase.toStringAsFixed(0)}%',
            );
          } else {
            state = state.copyWith(
              kecepatanUnggah: kecepatanDalamMbps,
              statusPesan: 'Menguji unggah: ${persentase.toStringAsFixed(0)}%',
            );
          }
        },
        onCompleted: (unduh, unggah) {
          /// Menghitung hasil akhir dalam Mbps.
          double hasilUnduhDalamMbps = unduh.transferRate;
          if (unduh.unit == SpeedUnit.kbps) hasilUnduhDalamMbps /= 1000;

          double hasilUnggahDalamMbps = unggah.transferRate;
          if (unggah.unit == SpeedUnit.kbps) hasilUnggahDalamMbps /= 1000;

          state = state.copyWith(
            kecepatanUnduh: hasilUnduhDalamMbps,
            kecepatanUnggah: hasilUnggahDalamMbps,
            sedangMenguji: false,
            statusPesan: 'Pengujian selesai',
          );

          if (context.mounted) {
            ToastUtil.success(context, 'Uji kecepatan berhasil diselesaikan');
          }
        },
        onError: (e, s) {
          state = state.copyWith(
            sedangMenguji: false,
            statusPesan: 'Gagal melakukan pengujian',
          );
          Log.error('Gagal saat melakukan uji kecepatan: $e (Kode: $s)');
          if (context.mounted) {
            ToastUtil.error(context, 'Gagal melakukan uji kecepatan: $e');
          }
        },
      );
    } catch (e, st) {
      state = state.copyWith(
        sedangMenguji: false,
        statusPesan: 'Gagal melakukan pengujian',
      );
      Log.error('Gagal saat melakukan uji kecepatan', e: e, s: st);

      if (context.mounted) {
        ToastUtil.error(
          context,
          'Gagal melakukan uji kecepatan. Silakan coba lagi.',
        );
      }
    }
  }
}
