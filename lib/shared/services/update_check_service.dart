// path: lib/shared/services/update_check_service.dart
// Bertanggung jawab untuk memeriksa ketersediaan pembaruan aplikasi.

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/apk_version_op_firebase.dart';
import 'package:wifi/shared/services/device_info_service.dart';
import 'package:wifi/shared/services/package_info_service.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';

/// Kelas layanan untuk memeriksa pembaruan aplikasi.
class UpdateCheckService {
  /// [BuildContext] diperlukan untuk navigasi. Bisa null jika tidak untuk navigasi.
  final BuildContext? context;
  final PackageInfoService _packageInfoService = PackageInfoService();
  final DeviceInfoService _deviceInfoService;
  final ApkVersionOpFirebase _apkVersionOp = ApkVersionOpFirebase();

  /// Konstruktor untuk UpdateCheckService.
  UpdateCheckService({this.context})
      : _deviceInfoService = DeviceInfoService(DeviceInfoPlugin()) {
    Log.info('UpdateCheckService diinisialisasi.');
  }

  /// Memeriksa apakah ada pembaruan yang diperlukan.
  ///
  /// Mengembalikan `true` jika versi di Firebase lebih tinggi,
  /// sebaliknya `false`.
  Future<bool> isUpdateRequired() async {
    Log.info('Memulai pengecekan apakah pembaruan diperlukan.');
    try {
      final packageInfo = await _packageInfoService.getPackageInfo();
      if (packageInfo == null) {
        Log.warning('Gagal mendapatkan info paket lokal. Anggap tidak ada update.');
        return false;
      }

      final deviceInfo = await _deviceInfoService.getDeviceArchitecture();
      final architecture = _determineArchitecture(deviceInfo);
      if (architecture == null) {
        Log.warning('Gagal menentukan arsitektur. Anggap tidak ada update.');
        return false;
      }

      final latestApk = await _apkVersionOp.getLatestApkVersion();
      if (latestApk == null) {
        Log.info('Tidak ada data versi APK di Firebase. Anggap tidak ada update.');
        return false;
      }

      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      final latestBuildNumber = latestApk.latestBuildNumber[architecture] ?? 0;

      Log.info('Perbandingan versi', {
        'currentBuild': currentBuildNumber,
        'latestBuild': latestBuildNumber,
        'architecture': architecture.name,
      });

      return latestBuildNumber > currentBuildNumber;
    } on Exception catch (e, st) {
      Log.error(
        'Terjadi kesalahan saat memeriksa isUpdateRequired.',
        e: e,
        st: st,
      );
      return false; // Jika error, anggap tidak ada update untuk mencegah blok.
    }
  }

  /// Memeriksa pembaruan dan menavigasi jika perlu.
  ///
  /// Metode ini memerlukan [context] untuk disediakan saat inisialisasi.
  Future<void> checkUpdateAndNavigate() async {
    Log.info('Memulai proses pengecekan pembaruan dan navigasi.');
    if (context == null) {
      Log.error('BuildContext tidak tersedia untuk checkUpdateAndNavigate.');
      return;
    }

    final bool isRequired = await isUpdateRequired();

    if (isRequired) {
      Log.info('Pembaruan tersedia! Menavigasi ke halaman update.');
      if (context!.mounted) {
        unawaited(
          Navigator.of(context!).pushReplacement(
            MaterialPageRoute<void>(
                builder: (final ctx) => const UpdateApkPage()),
          ),
        );
      }
    } else {
      Log.info('Aplikasi sudah versi terbaru. Tidak ada navigasi.');
    }
  }

  ApkArchitectureEnum? _determineArchitecture(
    final Map<String, dynamic> deviceInfo,
  ) {
    if (deviceInfo['error'] != null) {
      return null;
    }

    final supportedAbis =
        List<String>.from(deviceInfo['supportedAbis'] as Iterable<dynamic>);
    if (supportedAbis.contains('arm64-v8a')) {
      return ApkArchitectureEnum.bit64;
    } else if (supportedAbis.contains('armeabi-v7a')) {
      return ApkArchitectureEnum.bit32;
    } else {
      Log.warning('Arsitektur tidak didukung (bukan 64-bit atau 32-bit).', {
        'supportedAbis': supportedAbis,
      });
      // Fallback ke universal jika arsitektur spesifik tidak ditemukan.
      // Ini asumsi, mungkin perlu penyesuaian.
      return ApkArchitectureEnum.universal;
    }
  }
}
