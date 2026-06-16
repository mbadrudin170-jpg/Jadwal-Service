// path: lib/fitur/versi_apk/service/update_check_service.dart

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/info_perangkat/service/layanan_info_perangkat.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/info_perangkat/service/package_info_service.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_firebase.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

/// Kelas layanan untuk memeriksa pembaruan aplikasi.
class UpdateCheckService {
  /// Konteks build untuk navigasi.
  final BuildContext? context;

  final SharedPreferences prefs;

  final LayananPenyimpananLokal localStorageService;

  final PackageInfoService _packageInfoService = PackageInfoService();
  final LayananInfoPerangkat _deviceInfoService;
  final VersiApkOpFirebase _apkVersionOp = VersiApkOpFirebase();

  UpdateCheckService({
    this.context,
    required this.prefs,
    required this.localStorageService,
  }) : _deviceInfoService = LayananInfoPerangkat(DeviceInfoPlugin()) {
    Log.info('UpdateCheckService diinisialisasi.');
  }

  /// Memeriksa pembaruan dan mengembalikan semua informasi yang relevan.
  Future<
    ({
      bool isUpdateRequired,
      VersiApkModel? apkInfo,
      InfoPerangkatModel? packageInfo,
      ArsitekturApk? architecture,
    })
  >
  getUpdateInfo() async {
    Log.info('Memulai pengecekan informasi pembaruan lengkap.');
    try {
      final packageInfo = await _packageInfoService.getPackageInfo();
      if (packageInfo == null) {
        Log.warning('Gagal mendapatkan info paket lokal.');
        return (
          isUpdateRequired: false,
          apkInfo: null,
          packageInfo: null,
          architecture: null,
        );
      }

      final deviceInfo = await _deviceInfoService.ambilArsitekturPerangkat();
      final architecture = _determineArchitecture(deviceInfo);
      if (architecture == null) {
        Log.warning('Gagal menentukan arsitektur.');
        return (
          isUpdateRequired: false,
          apkInfo: null,
          packageInfo: packageInfo,
          architecture: null,
        );
      }

      final latestApk = await _apkVersionOp.ambilVersiTerbaru();
      if (latestApk == null) {
        Log.info('Tidak ada data versi APK di Firebase.');
        return (
          isUpdateRequired: false,
          apkInfo: null,
          packageInfo: packageInfo,
          architecture: architecture,
        );
      }

      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      final latestBuildNumber = latestApk.nomorBuildTerakhir[architecture] ?? 0;
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
        architecture: architecture,
      );
    } on Exception catch (e, st) {
      Log.error('Terjadi kesalahan saat memeriksa getUpdateInfo.', e: e, s: st);
      return (
        isUpdateRequired: false,
        apkInfo: null,
        packageInfo: null,
        architecture: null,
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
              builder: (ctx) => UpdateApkPage(
                apkInfo: update.apkInfo!,
                packageInfo: update.packageInfo!,
                architecture: update.architecture!,
              ),
            ),
          ),
        );
      }
    } else {
      Log.info('Aplikasi sudah versi terbaru. Tidak ada navigasi.');
    }
  }

  ArsitekturApk? _determineArchitecture(final Map<String, dynamic> deviceInfo) {
    if (deviceInfo['error'] != null) {
      return null;
    }

    final supportedAbis = List<String>.from(
      deviceInfo['supportedAbis'] as Iterable<dynamic>,
    );
    if (supportedAbis.contains('arm64-v8a')) {
      return ArsitekturApk.bit64;
    } else if (supportedAbis.contains('armeabi-v7a')) {
      return ArsitekturApk.bit32;
    } else {
      Log.warning('Arsitektur tidak didukung (bukan 64-bit, 32-bit, ).', {
        'supportedAbis': supportedAbis,
      });
      return ArsitekturApk.universal;
    }
  }
}
