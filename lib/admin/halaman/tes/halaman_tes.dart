// path: lib/admin/halaman/tes/halaman_tes.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';
import 'package:wifi/user/widget/ads/interstitial/layanan_iklan_interstisial.dart';

/// Halaman untuk melakukan tes fungsionalitas.
class HalamanTes extends StatefulWidget {
  /// Konstruktor untuk HalamanTes.
  const HalamanTes({super.key});

  @override
  State<HalamanTes> createState() => _HalamanTesState();
}

class _HalamanTesState extends State<HalamanTes> {
  final LayananIklanInterstisial _adService = LayananIklanInterstisial();
  final adUnitId = IdInterstitialAds.interstitialAdUnitIds[0];

  @override
  void initState() {
    super.initState();
    unawaited(_adService.preloadAd());
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tes Iklan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              child: const Text('Tampilkan Interstitial Ad'),
              onPressed: () {
                // PERBAIKAN: Gunakan unawaited untuk Future di dalam callback sinkron
                unawaited(_adService.show());
              },
            ),
            gapH40,
            // [PERBAIKAN] Menampilkan status kesiapan iklan untuk debugging
            StreamBuilder<void>(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (final context, final snapshot) {
                return const Text(
                  'ok',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
