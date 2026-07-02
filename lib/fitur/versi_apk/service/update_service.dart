// path: lib/fitur/versi_apk/service/update_service.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wifi/shared/debug/log.dart';

class UpdateService {
  final Dio _dio = Dio();

  Future<void> downloadDanInstallApk({
    required final String url,
    required final String namaFile,
    final void Function(double)? onProgress,
  }) async {
    try {
      final temporaryDirectory = await getTemporaryDirectory();
      final apkFilePath = '${temporaryDirectory.path}/$namaFile';
      Log.info('Mulai mengunduh dari: $url ke: $apkFilePath');

      await _dio.download(
        url,
        apkFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progressValue = received / total;
            onProgress(progressValue);
            Log.info('Progres unduhan: ${progressValue * 100}%', {
              'data: $progressValue',
            });
          }
        },
      );

      Log.info('Unduhan selesai: $apkFilePath');

      final apkFile = File(apkFilePath);
      if (!apkFile.existsSync()) {
        throw Exception('File APK tidak ditemukan setelah diunduh.');
      }

      Log.info('Membuka file APK untuk instalasi...');
      final hasilInstall = await OpenFilex.open(apkFilePath);

      if (hasilInstall.type != ResultType.done) {
        throw Exception('Gagal memulai instalasi: ${hasilInstall.message}');
      }
    } catch (e, s) {
      Log.error('Error saat mengunduh (Dio)', e: e, s: s);
      throw Exception(
        'Gagal mengunduh pembaruan. Periksa koneksi internet Anda.',
      );
    }
  }
}
