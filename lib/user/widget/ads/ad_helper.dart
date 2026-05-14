// path: lib/user/widget/ads/ad_helper.dart
import 'dart:io';

/// Kelas bantuan untuk mengambil ID unit iklan yang sesuai dengan platform.
class AdHelper {
  /// Mendapatkan ID unit iklan banner berdasarkan platform (Android atau iOS).
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
