// path: lib/main/main_admin/admin_dev.dart
// PERBAIKAN: Menghapus inisialisasi Workmanager dari main() untuk
// menghindari inisialisasi ganda.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/shared/debug/log.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode pengembangan.
void main() async {
  // Memastikan binding Flutter siap. Ini wajib ada sebelum runApp().
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Log.info(' Menginisialisasi Google Mobile Ads SDK...');
  await MobileAds.instance.initialize();
  Log.info(' Inisialisasi Google Mobile Ads SDK selesai.');

  Log.info(' Memulai aplikasi admin. Menyerahkan kendali ke AppAdmin...');

  runApp(
    const ProviderScope(
      child: AppAdmin(),
    ),
  );
}
