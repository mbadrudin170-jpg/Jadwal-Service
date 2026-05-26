// path: lib/admin/halaman/tes/halaman_tes.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

class HalamanTes extends StatefulWidget {
  const HalamanTes({super.key});

  @override
  State<HalamanTes> createState() => _HalamanTesState();
}

class _HalamanTesState extends State<HalamanTes> {
  final InterstitialAdService _adService = InterstitialAdService();

  @override
  void initState() {
    super.initState();
    // Memulai pemuatan iklan di awal
    // PERBAIKAN: Gunakan unawaited untuk Future di dalam initState
    unawaited(_adService.preloadAd());
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tes Iklan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              child: const Text('Tampilkan Interstitial Ad'),
              onPressed: () {
                // PERBAIKAN: Gunakan unawaited untuk Future di dalam callback sinkron
                unawaited(_adService.showAdIfReady(onAdDismissed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Iklan ditutup atau gagal tampil.')),
                  );
                  // Tidak perlu memuat ulang secara manual, service sudah menanganinya
                }));
              },
            ),
            const SizedBox(height: 40),
            // [PERBAIKAN] Menampilkan status kesiapan iklan untuk debugging
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (final context, final snapshot) {
                final isReady = _adService.isAdReady;
                return Text(
                  'Iklan Siap: $isReady',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isReady ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
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
