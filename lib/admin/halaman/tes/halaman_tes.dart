// path: lib/admin/halaman/tes/halaman_tes.dart
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
    _adService.preloadAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tes Iklan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              child: const Text('Tampilkan Interstitial Ad'),
              onPressed: () {
                // Panggil service untuk menampilkan iklan
                _adService.showAdIfReady(onAdDismissed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Iklan ditutup atau gagal tampil.')),
                  );
                  // Tidak perlu memuat ulang secara manual, service sudah menanganinya
                });
              },
            ),
            const SizedBox(height: 40),
            // [PERBAIKAN] Menampilkan status kesiapan iklan untuk debugging
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
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
