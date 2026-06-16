// path: lib/fitur/versi_apk/service/layanan_cek_update_apk.dart

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/info_perangkat/service/layanan_info_perangkat.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/info_perangkat/service/layanan_info_paket.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_firebase.dart';
import 'package:wifi/fitur/versi_apk/page/update_apk_page_u.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

/// Kelas layanan untuk memeriksa pembaruan aplikasi.
class LayananCekUpdateApk {
  /// Konteks build untuk navigasi.
  final BuildContext? context;

  final SharedPreferences prefs;

  final LayananPenyimpananLokal penyimpananLokal;

  final LayananInfoPaket _layananInfoPaket = LayananInfoPaket();
  final LayananInfoPerangkat _layananInfoPerangkat;
  final VersiApkOpFirebase _versiApkOpFirebase = VersiApkOpFirebase();

  LayananCekUpdateApk({
    this.context,
    required this.prefs,
    required this.penyimpananLokal,
  }) : _layananInfoPerangkat = LayananInfoPerangkat(DeviceInfoPlugin()) {
    Log.info('UpdateCheckService diinisialisasi.');
  }

  /// Memeriksa pembaruan dan mengembalikan semua informasi yang relevan.
  Future<
    ({
      bool perluUpdate,
      VersiApkModel? infoApk,
      InfoPerangkatModel? infoPaket,
      ArsitekturApk? arsitektur,
    })
  >
  ambilInfoUpdate() async {
    Log.info('Memulai pengecekan informasi pembaruan lengkap.');
    try {
      final infoPaket = await _layananInfoPaket.ambilInfoPaket();
      if (infoPaket == null) {
        Log.warning('Gagal mendapatkan info paket lokal.');
        return (
          perluUpdate: false,
          infoApk: null,
          infoPaket: null,
          arsitektur: null,
        );
      }

      final infoPerangkat = await _layananInfoPerangkat
          .ambilArsitekturPerangkat();
      final arsitektur = _tentukanArsitektur(infoPerangkat);
      if (arsitektur == null) {
        Log.warning('Gagal menentukan arsitektur.');
        return (
          perluUpdate: false,
          infoApk: null,
          infoPaket: infoPaket,
          arsitektur: null,
        );
      }

      final apkTerbaru = await _versiApkOpFirebase.ambilVersiTerbaru();
      if (apkTerbaru == null) {
        Log.info('Tidak ada data versi APK di Firebase.');
        return (
          perluUpdate: false,
          infoApk: null,
          infoPaket: infoPaket,
          arsitektur: arsitektur,
        );
      }

      final nomorBuildSekarang = int.tryParse(infoPaket.nomorBuild) ?? 0;
      final nomorBuildTerbaru = apkTerbaru.nomorBuildTerakhir[arsitektur] ?? 0;
      Log.info('Perbandingan versi', {
        'buildSekarang': nomorBuildSekarang,
        'buildTerbaru': nomorBuildTerbaru,
        'arsitektur': arsitektur.name,
      });

      final bool perluUpdate = nomorBuildTerbaru > nomorBuildSekarang;
      return (
        perluUpdate: perluUpdate,
        infoApk: perluUpdate ? apkTerbaru : null,
        infoPaket: infoPaket,
        arsitektur: arsitektur,
      );
    } catch (e, st) {
      Log.error(
        'Terjadi kesalahan saat memeriksa ambilInfoUpdate.',
        e: e,
        s: st,
      );
      return (
        perluUpdate: false,
        infoApk: null,
        infoPaket: null,
        arsitektur: null,
      );
    }
  }

  /// Memeriksa pembaruan dan menavigasi jika perlu.
  Future<void> cekUpdateDanNavigasi() async {
    Log.info('Memulai proses pengecekan pembaruan dan navigasi.');
    if (context == null) {
      Log.error('BuildContext tidak tersedia untuk checkUpdateAndNavigate.');
      return;
    }
    final infoUpdate = await ambilInfoUpdate();
    if (infoUpdate.perluUpdate &&
        infoUpdate.infoApk != null &&
        infoUpdate.infoPaket != null &&
        infoUpdate.arsitektur != null) {
      Log.info('Pembaruan tersedia! Menavigasi ke halaman update.');
      if (context!.mounted) {
        unawaited(
          Navigator.of(context!).pushReplacement(
            MaterialPageRoute<void>(
              builder: (ctx) => UpdateApkPage(
                infoApk: infoUpdate.infoApk!,
                infoPaket: infoUpdate.infoPaket!,
                arsitektur: infoUpdate.arsitektur!,
              ),
            ),
          ),
        );
      }
    } else {
      Log.info('Aplikasi sudah versi terbaru. Tidak ada navigasi.');
    }
  }

  ArsitekturApk? _tentukanArsitektur(final Map<String, dynamic> infoPerangkat) {
    if (infoPerangkat['error'] != null) {
      return null;
    }

    final arsitekturPerangkat = List<String>.from(
      infoPerangkat['supportedAbis'] as Iterable<dynamic>,
    );
    if (arsitekturPerangkat.contains('arm64-v8a')) {
      return ArsitekturApk.bit64;
    } else if (arsitekturPerangkat.contains('armeabi-v7a')) {
      return ArsitekturApk.bit32;
    } else {
      Log.warning('Arsitektur tidak didukung (bukan 64-bit, 32-bit, ).', {
        'supportedAbis': arsitekturPerangkat,
      });
      return ArsitekturApk.universal;
    }
  }
}
