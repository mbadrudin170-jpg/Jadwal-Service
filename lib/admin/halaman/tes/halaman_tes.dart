// path: lib/admin/halaman/tes/halaman_tes.dart
// MODIFIED:
// - Implemented the new callbacks (`onAdLoaded`, `onAdFailedToLoad`) for `BannerAdWidget`.
// - Added `ToastUtil` to show notifications for banner ad load status.
// - Imported `ToastUtil` and `LoadAdError`.

import 'package:flutter/material.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/widget/ads/ad_helper.dart';
import 'package:wifi/user/widget/ads/app_open_ad_service.dart';
import 'package:wifi/user/widget/ads/banner_ad_widget.dart';
import 'package:wifi/user/widget/ads/interstitial_ad_service.dart';
import 'package:wifi/user/widget/ads/rewarded_ad_service.dart';

/// A page for testing all types of ads.
class HalamanTes extends StatefulWidget {
  const HalamanTes({super.key});

  @override
  State<HalamanTes> createState() => _HalamanTesState();
}

class _HalamanTesState extends State<HalamanTes> {
  // --- Ad Services ---
  late final RewardedAdService _rewardedAdService;
  late final InterstitialAdService _interstitialAdServiceMediasi;
  late final InterstitialAdService _interstitialAdService1;
  late final AppOpenAdService _appOpenAdService;

  // --- GlobalKeys for Banner Widgets ---
  final GlobalKey<BannerAdWidgetState> _bannerMediasiKey =
      GlobalKey<BannerAdWidgetState>();
  final GlobalKey<BannerAdWidgetState> _bannerUnit1Key =
      GlobalKey<BannerAdWidgetState>();

  @override
  void initState() {
    super.initState();
    _rewardedAdService = RewardedAdService();
    _interstitialAdServiceMediasi = InterstitialAdService();
    _interstitialAdService1 = InterstitialAdService();
    _appOpenAdService = AppOpenAdService();

    _rewardedAdService.loadAd();
    _interstitialAdServiceMediasi.loadAd(
        adUnitId: AdHelper.interstitialAdUnitIdMediasi);
    _interstitialAdService1.loadAd(adUnitId: AdHelper.interstitialAdUnitId1);
    _appOpenAdService.loadAd();
  }

  void _showRewardedAd() {
    _rewardedAdService.showAd(
      onReward: () {
        ToastUtil.success(context, 'Selamat! Anda mendapatkan reward.');
      },
    );
  }

  void _showInterstitialAdMediasi() {
    _interstitialAdServiceMediasi.showAd();
  }

  void _showInterstitialAd1() {
    _interstitialAdService1.showAd();
  }

  void _showAppOpenAd() {
    _appOpenAdService.showAdIfReady();
  }

  void _reloadBannerMediasi() {
    _bannerMediasiKey.currentState?.loadAd();
  }

  void _reloadBannerUnit1() {
    _bannerUnit1Key.currentState?.loadAd();
  }

  @override
  void dispose() {
    _rewardedAdService.dispose();
    _interstitialAdServiceMediasi.dispose();
    _interstitialAdService1.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Uji Iklan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showRewardedAd,
                        icon: const Icon(Icons.movie),
                        label: const Text('Tonton Iklan Hadiah'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _showInterstitialAdMediasi,
                        icon: const Icon(Icons.ad_units_rounded),
                        label: const Text('Interstitial (Mediasi)'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _showInterstitialAd1,
                        icon: const Icon(Icons.ad_units),
                        label: const Text('Interstitial (Unit 1)'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _showAppOpenAd,
                        icon: const Icon(Icons.phone_android),
                        label: const Text('Tampilkan App Open Ad'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 32),
            const Text('Area Iklan Banner',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildBannerContainer(
              'Banner (Mediasi)',
              BannerAdWidget(
                key: _bannerMediasiKey,
                adUnitId: AdHelper.bannerAdUnitIdMediasi,
                onAdLoaded: () {
                  ToastUtil.success(
                      context, 'Banner (Mediasi) berhasil dimuat!');
                },
                onAdFailedToLoad: (error) {
                  ToastUtil.error(context, 'Banner (Mediasi) GAGAL dimuat.',
                      logData: {'error': error.toString()});
                },
              ),
              _reloadBannerMediasi,
            ),
            const SizedBox(height: 16),
            _buildBannerContainer(
              'Banner (Unit 1)',
              BannerAdWidget(
                key: _bannerUnit1Key,
                adUnitId: AdHelper.bannerAdUnitId1,
                onAdLoaded: () {
                  ToastUtil.success(
                      context, 'Banner (Unit 1) berhasil dimuat!');
                },
                onAdFailedToLoad: (error) {
                  ToastUtil.error(context, 'Banner (Unit 1) GAGAL dimuat.',
                      logData: {'error': error.toString()});
                },
              ),
              _reloadBannerUnit1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerContainer(
      String title, Widget bannerWidget, VoidCallback onReload) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onReload,
                tooltip: 'Muat Ulang Iklan',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(child: bannerWidget),
        ],
      ),
    );
  }
}
