// path: lib/shared/services/update_service.dart
// PERUBAHAN:
// - Menambahkan callback `onProgress` untuk melaporkan progres unduhan.
// - Menghapus `BuildContext` dan semua kode UI (showDialog, ToastUtil).
// - Melempar exception jika terjadi error agar bisa ditangani oleh UI.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wifi/shared/debug/log.dart';

/// Service untuk menangani proses pengunduhan dan instalasi pembaruan APK.
class UpdateService {
  final Dio _dio = Dio();

  /// Mengunduh file APK dari [url] dan menginstalnya.
  ///
  /// [onProgress] adalah callback untuk melaporkan progres unduhan (nilai antara 0.0 hingga 1.0).
  /// Melempar exception jika terjadi error.
  Future<void> downloadAndInstallApk({
    required final String url,
    required final String fileName,
    final void Function(double)? onProgress,
  }) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fullPath = '${tempDir.path}/$fileName';
      Log.info('Mulai mengunduh dari: $url ke: $fullPath');

      await _dio.download(
        url,
        fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final double progressValue = received / total;
            onProgress(progressValue);
            Log.info('Progres unduhan: ${progressValue * 100}%',
                {'data: $progressValue'});
          }
        },
      );

      Log.info('Unduhan selesai: $fullPath');

      final File apkFile = File(fullPath);
      if (!apkFile.existsSync()) {
        throw Exception('File APK tidak ditemukan setelah diunduh.');
      }

      Log.info('Membuka file APK untuk instalasi...');
      final result = await OpenFilex.open(fullPath);

      if (result.type != ResultType.done) {
        throw Exception('Gagal memulai instalasi: ${result.message}');
      }
    } on DioException catch (e) {
      Log.error('Error saat mengunduh (Dio)', e: e, s: e.stackTrace);
      throw Exception(
          'Gagal mengunduh pembaruan. Periksa koneksi internet Anda.');
    } on Object catch (e, st) {
      Log.error('Error umum saat proses update', e: e, s: st);
      throw Exception('Terjadi kesalahan saat proses pembaruan: $e');
    }
  }
}
