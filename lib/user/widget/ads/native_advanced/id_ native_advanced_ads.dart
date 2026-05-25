// path: lib/user/widget/ads/ native_advanced/id_ native_advanced_ads.dart
import 'package:flutter/foundation.dart';

/// Class khusus untuk mengelola ID unit iklan yang berhubungan dengan Native Advanced.
class IdNativeAdvancedAds {
  // --- ID Iklan Native Advanced Produksi ---
  static const String _prodNativeAdvancedAd1 =
      'ca-app-pub-9773465799516929/8014132674';
  static const String _prodNativeAdvancedAd2 =
      'ca-app-pub-9773465799516929/4266459352';

  // --- ID Iklan Native Advanced Tes ---
  static const String _testNativeAdvancedAd =
      'ca-app-pub-3940256099942544/2247696110';

  /// ID unit iklan untuk Native Advanced.
  static String get nativeAdvancedAdUnitId {
    if (kDebugMode) {
      return _testNativeAdvancedAd;
    }
    // Menggunakan salah satu ID produksi, bisa diganti sesuai logika yang diinginkan.
    return _prodNativeAdvancedAd1;
  }

  /// Daftar ID unit iklan Native Advanced untuk waterfall (jika diperlukan).
  static List<String> get nativeAdvancedAdUnitIds {
    if (kDebugMode) {
      // Contoh urutan untuk pengujian.
      return [
        _testNativeAdvancedAd,
      ];
    }
    // Urutan produksi
    return [
      _prodNativeAdvancedAd1,
      _prodNativeAdvancedAd2,
    ];
  }
}
