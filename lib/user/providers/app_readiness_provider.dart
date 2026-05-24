// path: lib/user/providers/app_readiness_provider.dart
import 'package:flutter/material.dart';

/// Provider untuk menandai kapan aplikasi telah melewati proses inisialisasi awal
/// (seperti splash screen) dan siap untuk menampilkan UI/iklan fullscreen.
class AppReadinessProvider with ChangeNotifier {
  bool _isReady = false;

  /// Apakah aplikasi sudah siap?
  bool get isReady => _isReady;

  /// Menandai bahwa aplikasi sekarang sudah siap.
  /// Mencegah notifikasi berulang jika sudah disetel.
  void setAppReady() {
    if (_isReady) return; // Hanya jalankan sekali
    _isReady = true;
    notifyListeners();
    debugPrint('[AppReadinessProvider] Aplikasi sekarang siap untuk iklan fullscreen.');
  }
}
