// path: lib/user/widget/ads/app_open/app_lifecycle_reactor.dart
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/app_open/app_open_ad_service.dart';

/// Kelas yang mendengarkan perubahan status aplikasi (misal: dari background ke foreground)
/// untuk menampilkan App Open Ad.
class AppLifecycleReactor {
  /// Layanan untuk mengelola iklan App Open.
  final LayananIklanBukaAplikasi appOpenAdService;

  /// Konstruktor untuk [AppLifecycleReactor].
  AppLifecycleReactor({required this.appOpenAdService});

  /// Mulai mendengarkan perubahan status aplikasi.
  void listenToAppStateChanges() {
    // Panggil loadAd() secara langsung karena ini adalah fungsi void.
    appOpenAdService.muatIklan();

    // unawaited() diperlukan karena startListening() adalah Future.
    unawaited(AppStateEventNotifier.startListening());

    // Gunakan .listen pada stream, ini tidak mengembalikan Future.
    AppStateEventNotifier.appStateStream.listen(_onAppStateChanged);
  }

  void _onAppStateChanged(AppState appState) {
    Log.info('[AppLifecycle] Status aplikasi berubah menjadi: \$appState');
    // Coba tampilkan iklan saat aplikasi kembali ke foreground.
    if (appState == AppState.foreground) {
      Log.info(
        '[AppLifecycle] Menunggu 1.5 detik sebelum mencoba menampilkan iklan...',
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        Log.info(
          '[AppLifecycle] Jeda selesai, mencoba menampilkan iklan sekarang.',
        );
        // showAdIfAvailable mengembalikan Future, jadi gunakan unawaited.
        unawaited(appOpenAdService.tampilkanIklan());
      });
    }
  }
}
