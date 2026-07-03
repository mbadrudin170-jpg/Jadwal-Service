# Dokumentasi Fitur: speedtest

## Daftar file

- [lib/fitur/speedtest/page/uji_kecepatan_page.dart](lib/fitur/speedtest/page/uji_kecepatan_page.dart)
- [lib/fitur/speedtest/provider/ping_provider.dart](lib/fitur/speedtest/provider/ping_provider.dart)
- [lib/fitur/speedtest/provider/uji_kecepatan_provider.dart](lib/fitur/speedtest/provider/uji_kecepatan_provider.dart)

## Isi file

### File: `lib/fitur/speedtest/page/uji_kecepatan_page.dart`
```dart
// path lib/fitur/speedtest/page/uji_kecepatan_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/speedtest/provider/uji_kecepatan_provider.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';

class HalamanUjiKecepatan extends ConsumerStatefulWidget {
  const HalamanUjiKecepatan({super.key});

  @override
  ConsumerState<HalamanUjiKecepatan> createState() =>
      _HalamanUjiKecepatanState();
}

class _HalamanUjiKecepatanState extends ConsumerState<HalamanUjiKecepatan> {
  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman uji kecepatan');
  }

  @override
  void dispose() {
    Log.info('Menutup halaman uji kecepatan');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusUji = ref.watch(ujiKecepatanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Uji Kecepatan Internet')),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _KartuHasilUji(
              label: 'Kecepatan Unduh',
              nilai: statusUji.kecepatanUnduh.toStringAsFixed(1),
              satuan: 'Mbps',
              ikon: TIcons.download,
            ),
            gapH16,
            _KartuHasilUji(
              label: 'Kecepatan Unggah',
              nilai: statusUji.kecepatanUnggah.toStringAsFixed(1),
              satuan: 'Mbps',
              ikon: TIcons.upload,
            ),
            gapH16,
            _KartuHasilUji(
              label: 'Ping',
              nilai: statusUji.ping == 0 ? '' : statusUji.ping.toString(),
              satuan: 'ms',
              ikon: TIcons.timer,
            ),
            const Spacer(),
            Center(
              child: Text(
                statusUji
                    .statusPesan, // Menggunakan Text biasa karena style sudah diatur di sini
                textAlign: TextAlign.center,
              ),
            ),
            gapH24,
            if (statusUji.sedangMenguji)
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(ujiKecepatanProvider.notifier).batalkanPengujian();
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(ujiKecepatanProvider.notifier)
                      .mulaiPengujian(context);
                },
                icon: const Icon(TIcons.play),
                label: const Text('Mulai'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            gapH32,
          ],
        ),
      ),
    );
  }
}

/// Widget kartu kecil untuk menampilkan hasil pengujian.
class _KartuHasilUji extends StatelessWidget {
  final String label;
  final String nilai;
  final String satuan;
  final IconData ikon;

  const _KartuHasilUji({
    required this.label,
    required this.nilai,
    required this.satuan,
    required this.ikon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(ikon, size: 40, color: Theme.of(context).primaryColor),
            gapW20,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksIsiKecil(label, warna: Colors.grey),
                TeksJudulKecil(
                  '$nilai $satuan',
                  tebalFont: FontWeight.bold,
                ), // Menggunakan TeksJudulKecil untuk ukuran 24
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/speedtest/provider/ping_provider.dart`
```dart
// path: lib/fitur/speedtest/provider/ping_provider.dart
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ping_provider.g.dart';

@riverpod
Future<int> httpPing(Ref ref) async {
  final stopwatch = Stopwatch()..start();
  try {
    final response = await http
        .head(Uri.parse('https://www.google.com'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return stopwatch.elapsedMilliseconds;
    } else {
      throw Exception('HTTP status ${response.statusCode}');
    }
  } catch (e) {
    // Fallback ke host lain jika google.com gagal
    try {
      final response = await http
          .head(Uri.parse('https://www.cloudflare.com'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return stopwatch.elapsedMilliseconds;
      }
    } catch (_) {}
    rethrow; // Gagal semua host
  } finally {
    stopwatch.stop();
  }
}
```

### File: `lib/fitur/speedtest/provider/uji_kecepatan_provider.dart`
```dart
// path: lib/fitur/speedtest/provider/uji_kecepatan_provider.dart

import 'dart:async';
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
  FlutterInternetSpeedTest? _alatUji;
  Timer? _timer;
  bool _isFinished = false;

  @override
  UjiKecepatanState build() {
    return const UjiKecepatanState();
  }

  Future<void> mulaiPengujian(
    BuildContext context, {
    FlutterInternetSpeedTest? alatUjiManual,
  }) async {
    Log.info('Memulai siklus pengujian kecepatan internet');
    _timer?.cancel();
    _isFinished = false;
    _alatUji = alatUjiManual ?? FlutterInternetSpeedTest();

    if (!context.mounted) return;

    state = state.copyWith(
      sedangMenguji: true,
      statusPesan: 'Menghubungkan ke server...',
      kecepatanUnduh: 0.0,
      kecepatanUnggah: 0.0,
      ping: 0,
    );

    try {
      state = state.copyWith(statusPesan: 'Mengukur ping...');
      final pingTime = await ref.read(httpPingProvider.future);
      state = state.copyWith(ping: pingTime);
    } catch (e) {
      Log.warning('Gagal mendapatkan ping: $e');
      state = state.copyWith(ping: -1);
    }

    unawaited(
      _alatUji!.startTesting(
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
          var kecepatanDalamMbps = dataUji.transferRate;
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
          _timer?.cancel(); // Batalkan timer
          if (_isFinished) return;
          _isFinished = true;
          var hasilUnduhDalamMbps = unduh.transferRate;
          if (unduh.unit == SpeedUnit.kbps) hasilUnduhDalamMbps /= 1000;
          var hasilUnggahDalamMbps = unggah.transferRate;
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
        onCancel: () {
          _timer?.cancel();
          if (_isFinished) return;
          _isFinished = true;
          state = state.copyWith(
            sedangMenguji: false,
            statusPesan: 'Pengujian dibatalkan',
          );
          if (context.mounted) {
            ToastUtil.info(context, 'Pengujian dibatalkan');
          }
        },
        onError: (e, s) {
          _timer?.cancel(); // Batalkan timer
          if (_isFinished) return;
          _isFinished = true;
          state = state.copyWith(
            sedangMenguji: false,
            statusPesan: 'Gagal melakukan pengujian',
          );
          Log.error('Gagal saat melakukan uji kecepatan: $e (Kode: $s)');
          if (context.mounted) {
            ToastUtil.error(context, 'Gagal melakukan uji kecepatan: $e');
          }
        },
      ),
    );

    // Perbaikan: Durasi timeout diubah ke 30 detik agar tes tidak mati di tengah jalan
    _timer = Timer(const Duration(seconds: 60), () {
      if (_isFinished) return;
      _isFinished = true;
      _alatUji?.cancelTest();
      state = state.copyWith(
        sedangMenguji: false,
        statusPesan: 'Pengujian dihentikan (batas waktu)',
      );
      if (context.mounted) {
        ToastUtil.info(context, 'Pengujian dihentikan karena batas waktu');
      }
    });
  }

  /// Membatalkan pengujian yang sedang berjalan
  Future<void> batalkanPengujian() async {
    if (_alatUji != null && state.sedangMenguji) {
      await _alatUji!.cancelTest();
    }
  }
}
```

