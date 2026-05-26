// path: lib/user/widget/ads/banner/banner_waterfall_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/banner/id_banner_ads.dart';

/// Widget yang mengimplementasikan strategi waterfall untuk memuat iklan banner.
/// Jika satu unit iklan gagal, widget akan segera mencoba memuat unit berikutnya
/// dalam daftar.
class BannerWaterfallWidget extends StatefulWidget {
  /// Jeda waktu sebelum memulai ulang seluruh siklus waterfall setelah semua
  /// unit iklan gagal dimuat.
  final Duration retryDelay;

  const BannerWaterfallWidget({
    super.key,
    this.retryDelay = const Duration(seconds: 30),
  });

  @override
  State<BannerWaterfallWidget> createState() => _BannerWaterfallWidgetState();
}

class _BannerWaterfallWidgetState extends State<BannerWaterfallWidget> {
  // Mengambil daftar ID langsung dari class IdBannerAds
  final List<String> _adUnitIds = IdBannerAds.bannerAdUnitIds;

  BannerAd? _bannerAd;
  int _currentAdIndex = 0;
  Timer? _retryTimer;
  // [BARU] Melacak apakah satu siklus penuh telah gagal
  bool _isCycleFailed = false;

  @override
  void initState() {
    super.initState();
    // Memuat iklan segera saat widget diinisialisasi
    _loadAd();
  }

  void _loadAd() {
    // 1. Jika sudah ada iklan, jangan load lagi
    if (_bannerAd != null) return;
    if (_adUnitIds.isEmpty) return;

    // 2. Jika sudah mencapai akhir daftar, set cycle failed
    if (_currentAdIndex >= _adUnitIds.length) {
      _currentAdIndex = 0;
      _isCycleFailed = true;
    }

    // 3. Jika siklus gagal, tunggu timer
    if (_isCycleFailed) {
      _retryTimer?.cancel();
      _retryTimer = Timer(widget.retryDelay, () {
        if (mounted) {
          _isCycleFailed = false;
          _loadAd();
        }
      });
      return;
    }

    // 4. Proses Loading
    final adUnitId = _adUnitIds[_currentAdIndex];

    final banner = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (final ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _currentAdIndex = 0; // Reset index saat sukses
          });
        },
        onAdFailedToLoad: (final ad, final error) {
          unawaited(ad.dispose()); // PENTING: Wajib dispose jika gagal
          if (!mounted) return;

          Log.error('Gagal load: $adUnitId. Error: ${error.message}');
          _currentAdIndex++;
          _loadAd(); // Panggil lagi untuk mencoba unit berikutnya
        },
      ),
    );

    unawaited(banner.load());
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    unawaited(_bannerAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    // Gunakan ukuran tetap agar tidak ada layout shift
    return SizedBox(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : const SizedBox
              .shrink(), // Atau bisa tambahkan indikator loading kecil
    );
  }
}
