// path: lib/admin/halaman/tes/halaman_tes.dart
// DITAMBAHKAN:
// - Tombol untuk menampilkan iklan Interstitial.
// - Inisialisasi InterstitialAdService.
// DIUBAH:
// - Tombol-tombol toast notifikasi dinonaktifkan (dikomentari).
// - Memperbaiki pemanggilan showAd untuk RewardedAdService.

import 'package:flutter/material.dart';
import 'package:wifi/user/widget/ads/interstitial_ad_service.dart';
import 'package:wifi/user/widget/ads/rewarded_ad_service.dart';

/// Halaman untuk melakukan tes, termasuk Toast dan Iklan.
class HalamanTes extends StatefulWidget {
  const HalamanTes({super.key});

  @override
  State<HalamanTes> createState() => _HalamanTesState();
}

class _HalamanTesState extends State<HalamanTes> {
  late final RewardedAdService _rewardedAdService;
  late final InterstitialAdService _interstitialAdService;

  @override
  void initState() {
    super.initState();
    // Inisialisasi service iklan
    _rewardedAdService = RewardedAdService();
    _interstitialAdService = InterstitialAdService();
    // Langsung muat iklan saat halaman dibuka agar siap digunakan
    _rewardedAdService.loadAd();
    _interstitialAdService.loadAd();
  }

  void _showRewardedAd() {
    _rewardedAdService.showAd(
      onReward: () {
        // Callback ini akan dijalankan saat pengguna mendapatkan reward
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selamat! Anda mendapatkan 10 poin.')),
        );
      },
    );
  }

  void _showInterstitialAd() {
    _interstitialAdService.showAd();
  }

  @override
  void dispose() {
    _rewardedAdService.dispose();
    _interstitialAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Uji Fitur'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tombol untuk menampilkan iklan berhadiah
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _showRewardedAd,
                icon: const Icon(Icons.movie),
                label: const Text('Tonton Iklan Hadiah'),
              ),
              const SizedBox(height: 12),
              // Tombol untuk menampilkan iklan interstitial
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _showInterstitialAd,
                icon: const Icon(Icons.ad_units_rounded),
                label: const Text('Tampilkan Iklan Interstitial'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
