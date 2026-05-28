// path: lib/user/providers/ad_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

part 'ad_provider.g.dart';

@Riverpod(keepAlive: true)
InterstitialAdService interstitialAdService(ref) {
  // Menggunakan keepAlive: true agar service tidak di-dispose saat tidak ada
  // yang mendengarkan. Ini penting agar iklan bisa terus dimuat di latar belakang
  // saat pengguna bernavigasi antar halaman.
  final service = InterstitialAdService();

  // Menambahkan onDispose untuk memastikan service (dan iklan di dalamnya)
  // dibersihkan dengan benar saat aplikasi ditutup.
  ref.onDispose(() => service.dispose());

  return service;
}
