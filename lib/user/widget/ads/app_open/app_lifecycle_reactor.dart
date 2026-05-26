// path: lib/user/widget/ads/app_open/app_lifecycle_reactor.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/user/widget/ads/app_open/app_open_ad_service.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas yang mendengarkan perubahan status aplikasi (misal: dari background ke foreground)
/// untuk menampilkan App Open Ad.
class AppLifecycleReactor {
  final AppOpenAdService appOpenAdService;

  AppLifecycleReactor({required this.appOpenAdService});

  /// Mulai mendengarkan perubahan status aplikasi.
  Future<void> listenToAppStateChanges() async {
    await AppStateEventNotifier.startListening();
    await AppStateEventNotifier.appStateStream.forEach(_onAppStateChanged);
  }

  void _onAppStateChanged(final AppState appState) {
    Log.info('[AppLifecycle] Status aplikasi berubah menjadi: $appState');
    // Coba tampilkan iklan saat aplikasi kembali ke foreground.
    if (appState == AppState.foreground) {
      // Tambahkan jeda yang lebih lama untuk memberi aplikasi cukup waktu
      // untuk pulih sepenuhnya sebelum menampilkan iklan, terutama di perangkat
      // yang lebih lambat untuk menghindari jank parah.
      Log.info(
          '[AppLifecycle] Menunggu 1.5 detik sebelum mencoba menampilkan iklan...');
      Future.delayed(const Duration(milliseconds: 1500), () async {
        Log.info(
            '[AppLifecycle] Jeda selesai, mencoba menampilkan iklan sekarang.');
        await appOpenAdService.showAdIfAvailable();
      });
    }
  }
}
