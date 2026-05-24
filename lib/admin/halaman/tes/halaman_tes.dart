// path: lib/admin/halaman/tes/halaman_tes.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/widget/ads/ad_helper.dart';
import 'package:wifi/user/widget/ads/app_open_ad_service.dart';
import 'package:wifi/user/widget/ads/banner_ad_widget.dart';
import 'package:wifi/user/widget/ads/banner_waterfall_widget.dart';
import 'package:wifi/user/widget/ads/interstitial_ad_service.dart';
import 'package:wifi/user/widget/ads/rewarded_ad_service.dart';

/// Halaman untuk menguji semua jenis iklan.
class HalamanTes extends StatefulWidget {
  const HalamanTes({super.key});

  @override
  State<HalamanTes> createState() => _HalamanTesState();
}

class _HalamanTesState extends State<HalamanTes> {
  // --- Servis Iklan ---
  late final RewardedAdService _rewardedAdService;
  late final InterstitialAdService _interstitialAdServiceMediasi;
  late final InterstitialAdService _interstitialAdService1;
  late final AppOpenAdService _appOpenAdService;

  // --- Variabel State ---
  bool _isRewardedAdLoading = false;

  // --- Kunci Global untuk Banner (Hanya untuk banner statis) ---
  final GlobalKey<BannerAdWidgetState> _bannerUnit1Key =
      GlobalKey<BannerAdWidgetState>();

  @override
  void initState() {
    super.initState();
    _rewardedAdService = RewardedAdService();
    _interstitialAdServiceMediasi = InterstitialAdService();
    _interstitialAdService1 = InterstitialAdService();
    _appOpenAdService = AppOpenAdService();

    _loadAllAds();
  }

  void _loadAllAds() {
    _loadRewardedAd();
    _interstitialAdServiceMediasi.loadAd(
        adUnitId: AdHelper.interstitialAdUnitIdMediasi);
    _interstitialAdService1.loadAd(adUnitId: AdHelper.interstitialAdUnitId1);
    _appOpenAdService.loadAd();
  }

  void _loadRewardedAd() {
    setState(() {
      _isRewardedAdLoading = true;
    });
    _rewardedAdService.loadAd(
      onAdLoaded: () {
        setState(() {
          _isRewardedAdLoading = false;
        });
        ToastUtil.success(context, 'Iklan Hadiah siap ditonton!');
      },
      onAdFailedToLoad: (error) {
        setState(() {
          _isRewardedAdLoading = false;
        });
        ToastUtil.error(context, 'Iklan Hadiah gagal dimuat.', logData: {
          'code': error.code,
          'message': error.message,
        });
      },
    );
  }

  void _showRewardedAd() {
    if (_rewardedAdService.isAdLoaded) {
      _rewardedAdService.showAd(
        onReward: () {
          ToastUtil.success(context, 'Selamat! Anda mendapatkan reward.');
        },
        onAdDismissed: _loadRewardedAd,
      );
    } else {
      ToastUtil.info(context, 'Sedang memuat iklan, silakan coba lagi sesaat.');
      if (!_isRewardedAdLoading) {
        _loadRewardedAd();
      }
    }
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
                        onPressed:
                            _isRewardedAdLoading ? null : _showRewardedAd,
                        icon: _isRewardedAdLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.movie),
                        label: Text(_isRewardedAdLoading
                            ? 'Memuat Iklan...'
                            : 'Tonton Iklan Hadiah'),
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

            // --- PENGGUNAAN WIDGET BARU ---
            _buildBannerContainer(
              title: 'Banner Waterfall (A -> B -> C)',
              bannerWidget: 
              // Widget baru kita yang akan menangani logika fallback dan siklus
              BannerWaterfallWidget(
                adUnitIds: [
                  AdHelper.bannerAdUnitId1,       // Akan coba ini dulu (dibuat gagal)
                  AdHelper.bannerAdUnitIdMediasi, // Lalu coba ini (dibuat gagal)
                  AdHelper.bannerAdUnitId2,       // Terakhir ini (akan berhasil)
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // --- BANNER LAMA (TETAP ADA SEBAGAI PEMBANDING) ---
            _buildBannerContainer(
              title: 'Banner Statis Gagal (Unit 1)',
              bannerWidget: BannerAdWidget(
                key: _bannerUnit1Key,
                adUnitId: AdHelper.bannerAdUnitId1, // Ini sengaja dibuat gagal
                onAdFailedToLoad: (error) {
                   // Tidak perlu toast di sini karena kegagalan diharapkan
                },
              ),
              onReload: _reloadBannerUnit1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerContainer({
    required String title, 
    required Widget bannerWidget, 
    VoidCallback? onReload
  }) {
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
              if (onReload != null)
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
