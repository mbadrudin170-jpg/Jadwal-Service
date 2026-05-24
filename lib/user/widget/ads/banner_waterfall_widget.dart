// path: lib/user/widget/ads/banner_waterfall_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';

/// Sebuah widget yang mencoba memuat beberapa unit iklan banner secara siklus dan berurutan.
/// Jika satu gagal, ia akan mencoba memuat yang berikutnya setelah jeda waktu.
/// Jika sudah di akhir daftar, ia akan kembali ke awal.
class BannerWaterfallWidget extends StatefulWidget {
  /// Daftar ID unit iklan yang akan dicoba secara berurutan.
  final List<String> adUnitIds;

  /// Jeda waktu sebelum mencoba memuat unit iklan berikutnya setelah kegagalan.
  final Duration retryDelay;

  const BannerWaterfallWidget({
    super.key,
    required this.adUnitIds,
    this.retryDelay = const Duration(seconds: 30),
  }) : assert(adUnitIds.length > 0, 'adUnitIds tidak boleh kosong');

  @override
  State<BannerWaterfallWidget> createState() => _BannerWaterfallWidgetState();
}

class _BannerWaterfallWidgetState extends State<BannerWaterfallWidget> {
  BannerAd? _bannerAd;
  int _currentAdIndex = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Hentikan proses jika ada iklan yang sudah berhasil dimuat
    if (_bannerAd != null) return;

    final adUnitId = widget.adUnitIds[_currentAdIndex];
    Log.info(
        '[Waterfall] Mencoba memuat banner #${_currentAdIndex}: $adUnitId');

    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Log.info('[Waterfall] Banner #${_currentAdIndex} BERHASIL dimuat.');
          // Pastikan widget masih ada di tree sebelum update state
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          Log.error(
            '[Waterfall] Banner #${_currentAdIndex} GAGAL dimuat.',
            data: {'code': error.code, 'message': error.message},
          );
          ad.dispose();

          // Pindah ke indeks berikutnya, kembali ke 0 jika sudah di akhir
          _currentAdIndex = (_currentAdIndex + 1) % widget.adUnitIds.length;

          // Jadwalkan percobaan berikutnya setelah jeda
          _retryTimer = Timer(widget.retryDelay, () {
            if (mounted) {
              _loadAd();
            }
          });
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
      // Tampilkan placeholder atau kosongkan saat loading atau jika semua gagal
      return const SizedBox.shrink();
    }
  }
}
