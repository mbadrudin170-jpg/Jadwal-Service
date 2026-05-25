// path: lib/admin/halaman/tes/halaman_tes.dart
import 'package:flutter/material.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

class HalamanTes extends StatefulWidget {
  const HalamanTes({super.key});

  @override
  State<HalamanTes> createState() => _HalamanTesState();
}

class _HalamanTesState extends State<HalamanTes> {
  bool _showNativeAd = false;

  @override
  void initState() {
    super.initState();
    InterstitialAdService().preloadAd();
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
                InterstitialAdService().showAdIfReady(onAdDismissed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Iklan ditutup atau gagal tampil.')),
                  );
                });
              },
            ),
            const SizedBox(height: 20),
            // Tombol untuk menampilkan/menyembunyikan Iklan Native
            ElevatedButton(
              child: Text(
                  '${_showNativeAd ? 'Sembunyikan' : 'Tampilkan'} Iklan Native'),
              onPressed: () {
                setState(() {
                  _showNativeAd = !_showNativeAd;
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
                        color: InterstitialAdService().isAdReady
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sedang Memuat: ${InterstitialAdService().isAdLoading}',
                      style: TextStyle(
                        color: InterstitialAdService().isAdLoading
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(), // Mendorong widget berikutnya ke bawah
            // Penampung untuk iklan native
          
          ],
        ),
      ),
    );
  }
}
