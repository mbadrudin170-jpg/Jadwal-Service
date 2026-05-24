// path: lib/user/widget/ads/rewarded_ad_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/ad_helper.dart';

/// Kelas untuk mengelola Iklan Berhadiah (Rewarded Ad).
/// Pengguna menonton iklan untuk mendapatkan hadiah dalam aplikasi.
class RewardedAdService {
  RewardedAd? _rewardedAd;

  // Getter untuk memeriksa apakah iklan sudah dimuat dan siap ditampilkan.
  bool get isAdLoaded => _rewardedAd != null;

  /// Memuat iklan Rewarded.
  /// Panggil ini di `initState` atau sebelum Anda berencana menampilkan iklan.
  void loadAd() {
    // Mencegah pemuatan berulang jika iklan sudah ada atau sedang dimuat.
    if (_rewardedAd != null) {
      Log.info('Rewarded ad is already loaded or loading.');
      return;
    }

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId, // Pastikan ID ini benar
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Log.info('Rewarded ad loaded successfully.');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          Log.error('Failed to load rewarded ad', data: {'error': error.message, 'code': error.code});
        },
      ),
    );
  }

  /// Menampilkan iklan jika siap dan memberikan hadiah setelah selesai.
  /// [onReward] akan dipanggil HANYA jika pengguna menyelesaikan iklan.
  /// [onAdDismissed] (opsional) akan dipanggil saat iklan ditutup, baik pengguna menyelesaikan maupun tidak.
  void showAd({
    required VoidCallback onReward,
    VoidCallback? onAdDismissed,
  }) {
    if (!isAdLoaded) {
      Log.warning('Tried to show Rewarded ad, but it is not ready yet.');
      // Jika iklan tidak siap, panggil onAdDismissed agar alur tidak berhenti.
      onAdDismissed?.call();
      // Coba muat lagi untuk kesempatan berikutnya.
      loadAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        Log.info('Rewarded ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (ad) {
        Log.info('Rewarded ad dismissed.');
        // Jalankan callback umum saat iklan ditutup.
        onAdDismissed?.call();
        // Buang resource iklan.
        ad.dispose();
        _rewardedAd = null;
        // Muat iklan baru untuk pemakaian berikutnya.
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error(
          'Failed to show rewarded ad',
          data: {'error': error.message, 'code': error.code},
        );
        // Jalankan callback umum agar UI tidak macet.
        onAdDismissed?.call();
        // Buang resource iklan.
        ad.dispose();
        _rewardedAd = null;
        // Muat iklan baru.
        loadAd();
      },
    );

    // Tampilkan iklan dan tentukan apa yang terjadi saat pengguna berhak mendapat hadiah.
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        Log.info(
          'User earned reward: amount=${reward.amount}, type=${reward.type}',
        );
        // Ini adalah momen krusial untuk memberikan hadiah ke pengguna.
        onReward();
      },
    );
  }

  /// Membersihkan resource iklan untuk mencegah memory leak.
  /// Wajib dipanggil di metode `dispose()` dari StatefulWidget Anda.
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    Log.info('RewardedAdService disposed.');
  }
}
