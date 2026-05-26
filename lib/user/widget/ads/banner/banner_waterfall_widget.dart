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
    // Jangan lakukan apa-apa jika sudah ada iklan atau daftar ID kosong
    if (_bannerAd != null || _adUnitIds.isEmpty) return;

    // Jika kita sudah melewati semua ID, reset indeks dan tandai siklus gagal
    if (_currentAdIndex >= _adUnitIds.length) {
      _currentAdIndex = 0;
      _isCycleFailed = true; // Tandai bahwa seluruh siklus telah gagal
    }

    // Jika siklus baru saja gagal, terapkan jeda sebelum memulai lagi
    if (_isCycleFailed) {
      Log.warning(
          '[Waterfall] Semua unit iklan gagal. Menunggu ${widget.retryDelay.inSeconds} detik sebelum mencoba lagi.');
      _retryTimer?.cancel();
      _retryTimer = Timer(widget.retryDelay, () {
        if (mounted) {
          _isCycleFailed = false; // Reset status gagal sebelum mencoba lagi
          _loadAd();
        }
      });
      return; // Hentikan eksekusi untuk menunggu timer
    }

    final adUnitId = _adUnitIds[_currentAdIndex];
    Log.info(
        '[Waterfall] Mencoba memuat banner #${_currentAdIndex}: $adUnitId');

    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Log.info('[Waterfall] Banner #${_currentAdIndex} BERHASIL dimuat.');
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
            // Reset indeks jika suatu saat diperlukan untuk memuat ulang
            _currentAdIndex = 0;
            _isCycleFailed = false;
          }
        },
        onAdFailedToLoad: (ad, error) {
          Log.error(
            '[Waterfall] Banner #${_currentAdIndex} GAGAL dimuat.',
            data: {'code': error.code, 'message': error.message},
          );
          ad.dispose();

          // [PERBAIKAN] Langsung coba unit iklan berikutnya
          _currentAdIndex++;
          _loadAd(); // Panggil _loadAd() secara rekursif untuk mencoba ID berikutnya
        },
        onAdOpened: (Ad ad) {
          Log.info('[Waterfall] Iklan banner dibuka.');
        },
        onAdImpression: (Ad ad) {
          Log.info('[Waterfall] Impressi iklan banner tercatat.');
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      // Tampilkan kontainer kosong saat iklan sedang dimuat atau gagal
      return const SizedBox.shrink();
    }
  }
}
