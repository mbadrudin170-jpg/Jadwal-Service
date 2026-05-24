// path: lib/admin/halaman/tes/halaman_tes.dart
import 'package:flutter/material.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

class HalamanTes extends StatefulWidget {
  const HalamanTes({super.key});

  @override
  State<HalamanTes> createState() => _HalamanTesState();
}

class _HalamanTesState extends State<HalamanTes> {
  // Service adalah singleton, tidak perlu di-instantiate atau di-dispose di sini.

  @override
  void initState() {
    super.initState();
    // Pemuatan iklan sudah di-handle secara global oleh service.
    // Kita bisa panggil preload di sini jika ingin memastikan, tapi idealnya di main.dart
    InterstitialAdService().preloadAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tes Iklan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Tampilkan Interstitial Ad'),
              onPressed: () {
                InterstitialAdService().showAdIfReady(onAdDismissed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Iklan ditutup atau gagal tampil.')),
                  );
                });
              },
            ),
            const SizedBox(height: 20),
            // Menampilkan status untuk debugging
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Text(
                      'Iklan Siap: ${InterstitialAdService().isAdReady}',
                      style: TextStyle(
                        color: InterstitialAdService().isAdReady ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sedang Memuat: ${InterstitialAdService().isAdLoading}',
                       style: TextStyle(
                        color: InterstitialAdService().isAdLoading ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
