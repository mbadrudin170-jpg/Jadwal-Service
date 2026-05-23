
// path: lib/shared/services/update_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Service untuk menangani proses pengunduhan dan instalasi pembaruan APK.
class UpdateService {
  final Dio _dio = Dio();

  /// Mengunduh file APK dari [url] dan memulai proses instalasi.
  ///
  /// Menampilkan dialog progres selama pengunduhan.
  Future<void> downloadAndInstallApk({
    required BuildContext context,
    required String url,
    required String fileName,
  }) async {
    // 1. Amankan state navigasi dan UI sebelum masuk ke proses asynchronous yang panjang
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    bool isDialogContextMounted = false;

    // Menampilkan dialog progres yang tidak bisa ditutup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (final dialogContext) {
        isDialogContextMounted = true;
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text("Mengunduh pembaruan...")),
            ],
          ),
        );
      },
    );

    try {
      // Menggunakan getTemporaryDirectory sesuai rekomendasi dokumentasi untuk file sekali pakai
      final Directory tempDir = await getTemporaryDirectory();
      final String fullPath = '${tempDir.path}/$fileName';

      Log.info('Mulai mengunduh dari: $url ke: $fullPath');

      // Mulai proses download menggunakan Dio
      await _dio.download(
        url,
        fullPath,
        onReceiveProgress: (final received, final total) {
          if (total != -1) {
            final percentage = (received / total * 100).toStringAsFixed(0);
            Log.info('Progres unduhan: $percentage%');
          }
        },
      );

      Log.info('Unduhan selesai.');

      // 2. Tutup dialog SEGERA setelah proses unduhan selesai secara aman
      if (isDialogContextMounted && navigator.mounted) {
        navigator.pop();
        isDialogContextMounted = false; // Tandai bahwa dialog sudah ditutup
      }

      // Memeriksa apakah file berhasil disimpan sebelum membuka
      final File apkFile = File(fullPath);
      if (await apkFile.exists()) {
        Log.info('Membuka file APK untuk instalasi...');
        
        final result = await OpenFilex.open(fullPath);
        Log.info('Hasil dari OpenFilex: ${result.message}');

        if (result.type != ResultType.done) {
          throw result.message;
        }
      } else {
        throw 'File APK tidak ditemukan setelah diunduh.';
      }
    } on DioException catch (e, st) {
      Log.error('Error saat mengunduh (Dio)', e: e, st: st);
      
      // Tutup dialog HANYA jika dialog masih terbuka di layar
      if (isDialogContextMounted && navigator.mounted) {
        navigator.pop();
      }
      
      if (messenger.mounted) {
        ToastUtil.error(
          context,
          'Gagal mengunduh pembaruan. Periksa koneksi internet Anda.',
        );
      }
    } catch (e, st) {
      Log.error('Error umum saat proses update', e: e, st: st);
      
      // Tutup dialog HANYA jika dialog masih terbuka di layar
      if (isDialogContextMounted && navigator.mounted) {
        navigator.pop();
      }
      
      if (messenger.mounted) {
        ToastUtil.error(context, 'Terjadi kesalahan saat instalasi: $e');
      }
    }
  }
}
