// path: lib/shared/services/update_check_service.dart
// PERUBAHAN:
// - Constructor sekarang memerlukan SharedPreferences dan LocalStorageService.
// - Meneruskan parameter yang diperlukan saat membuat UpdateApkPage.

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/model/package_info_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/apk_version_op_firebase.dart';
import 'package:wifi/shared/services/device_info_service.dart';
import 'package:wifi/shared/services/package_info_service.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Kelas layanan untuk memeriksa pembaruan aplikasi.
class UpdateCheckService {
  final BuildContext? context;
  final SharedPreferences prefs;
  final LocalStorageService localStorageService;

  final PackageInfoService _packageInfoService = PackageInfoService();
  final DeviceInfoService _deviceInfoService;
  final ApkVersionOpFirebase _apkVersionOp = ApkVersionOpFirebase();

  /// Konstruktor untuk UpdateCheckService.
  UpdateCheckService({
    this.context,
    required this.prefs,
    required this.localStorageService,
  }) : _deviceInfoService = DeviceInfoService(DeviceInfoPlugin()) {
    Log.info('UpdateCheckService diinisialisasi.');
  }

  /// Memeriksa pembaruan dan mengembalikan semua informasi yang relevan.
  Future<({
    bool isUpdateRequired,
    ApkVersionModel? apkInfo,
    PackageInfoModel? packageInfo,
    ApkArchitectureEnum? architecture
  })> getUpdateInfo() async {
    Log.info('Memulai pengecekan informasi pembaruan lengkap.');
    try {
      final packageInfo = await _packageInfoService.getPackageInfo();
      if (packageInfo == null) {
        Log.warning('Gagal mendapatkan info paket lokal.');
        return (
          isUpdateRequired: false,
          apkInfo: null,
          packageInfo: null,
          architecture: null
        );
      }

      final deviceInfo = await _deviceInfoService.getDeviceArchitecture();
      final architecture = _determineArchitecture(deviceInfo);
      if (architecture == null) {
        Log.warning('Gagal menentukan arsitektur.');
        return (
          isUpdateRequired: false,
          apkInfo: null,
          packageInfo: packageInfo,
          architecture: null
        );
      }

      final latestApk = await _apkVersionOp.getLatestApkVersion();
      if (latestApk == null) {
        Log.info('Tidak ada data versi APK di Firebase.');
        return (
          isUpdateRequired: false,
          apkInfo: null,
          packageInfo: packageInfo,
          architecture: architecture
        );
      }

      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      final latestBuildNumber = latestApk.latestBuildNumber[architecture] ?? 0;

      Log.info('Perbandingan versi', {
        'currentBuild': currentBuildNumber,
        'latestBuild': latestBuildNumber,
        'architecture': architecture.name,
      });

      final bool isRequired = latestBuildNumber > currentBuildNumber;
      return (
        isUpdateRequired: isRequired,
        apkInfo: isRequired ? latestApk : null,
        packageInfo: packageInfo,
        architecture: architecture
      );
    } on Exception catch (e, st) {
      Log.error(
        'Terjadi kesalahan saat memeriksa getUpdateInfo.',
        e: e,
        st: st,
      );
      return (
        isUpdateRequired: false,
        apkInfo: null,
        packageInfo: null,
        architecture: null
      );
    }
  }

  /// Memeriksa pembaruan dan menavigasi jika perlu.
  Future<void> checkUpdateAndNavigate() async {
    Log.info('Memulai proses pengecekan pembaruan dan navigasi.');
    if (context == null) {
      Log.error('BuildContext tidak tersedia untuk checkUpdateAndNavigate.');
      return;
    }

    final update = await getUpdateInfo();

    if (update.isUpdateRequired &&
        update.apkInfo != null &&
        update.packageInfo != null &&
        update.architecture != null) {
      Log.info('Pembaruan tersedia! Menavigasi ke halaman update.');
      if (context!.mounted) {
        unawaited(
          Navigator.of(context!).pushReplacement(
            MaterialPageRoute<void>(
              builder: (final ctx) => UpdateApkPage(
                apkInfo: update.apkInfo!,
                packageInfo: update.packageInfo!,
                architecture: update.architecture!,
                prefs: prefs, // Diteruskan ke UpdateApkPage
                localStorageService:
                    localStorageService, // Diteruskan ke UpdateApkPage
              ),
            ),
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
      return ApkArchitectureEnum.universal;
    }
  }
}
