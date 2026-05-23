// path: lib/user/widget/ads/ad_helper.dart
// diubah: Secara otomatis beralih antara ID iklan tes dan produksi.
// DITAMBAHKAN: ID Aplikasi AdMob.
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Kelas bantuan untuk mengambil ID unit iklan yang sesuai.
///
/// Kelas ini secara otomatis menggunakan ID tes dalam mode debug
/// dan ID produksi dalam mode rilis.
class AdHelper {
  // Di dalam class AdHelper
  static const String unityGameId = '80000716';
  static const String unityBannerPlacement = 'Banner_Android';
  // --- ID Aplikasi AdMob ---
  static const String appId = 'ca-app-pub-9773465799516929~5575068959';

  // --- ID Iklan Produksi ---
  static const String _prodBannerAd = 'ca-app-pub-9773465799516929/1302679235';
  static const String _prodProfileBannerAd =
      'ca-app-pub-9773465799516929/6555005913';

  // --- ID Iklan Tes (untuk Pengembangan) ---
  // Gunakan ID ini untuk semua banner selama tes.
  static const String _testBannerAd = 'ca-app-pub-3940256099942544/6300978111';

  /// Mendapatkan ID unit iklan banner umum.
  static String get bannerAdUnitId {
    // Gunakan ID tes jika bukan mode rilis, sebaliknya gunakan ID produksi.
    if (kReleaseMode) {
      if (Platform.isAndroid) return _prodBannerAd;
    } else {
      if (Platform.isAndroid) return _testBannerAd;
    }
    // Lemparkan error jika platform bukan Android.
    throw UnsupportedError('Platform ini tidak didukung untuk iklan.');
  }

  /// Mendapatkan ID unit iklan banner untuk Halaman Profil.
  static String get profileBannerAdUnitId {
    // Gunakan ID tes jika bukan mode rilis, sebaliknya gunakan ID produksi.
    if (kReleaseMode) {
      if (Platform.isAndroid) return _prodProfileBannerAd;
    } else {
      if (Platform.isAndroid) return _testBannerAd;
    }
    // Lemparkan error jika platform bukan Android.
    throw UnsupportedError('Platform ini tidak didukung untuk iklan.');
  }
}
