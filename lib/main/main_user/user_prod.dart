// path: lib/main/main_user/user_prod.dart
// PERBAIKAN:
// - Menambahkan ProviderScope untuk mengaktifkan Riverpod di seluruh aplikasi.
// - Menambahkan `flutter_native_splash` untuk menahan splash screen
//   hingga inisialisasi di Flutter selesai.
// - Menambahkan dan memperbaiki pemanggilan `setGDPRConsent` untuk Unity Mediation.
// - Menambahkan pemanggilan `setCCPAConsent`.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:wifi/user/app_user.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_prod.dart';

void main() async {
  // Memastikan binding Flutter siap dan menahan native splash screen.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Log.info('Menginisialisasi workmanager');
  await BackgroundService.init();

  Log.info('Menginisialisasi GmaMediationUnity');
  // Konfigurasi consent GDPR dan CCPA untuk Unity Ads Mediation.
  await GmaMediationUnity().setGDPRConsent(true);
  await GmaMediationUnity().setCCPAConsent(true);

  Log.info('Menginisialisasi MobileAds');
  await MobileAds.instance.initialize();

  Log.info(
      '[main-prod] Memulai aplikasi user. Menyerahkan kendali ke AppUser...');

  // Langsung jalankan AppUser.
  // Native splash akan dihilangkan dari dalam SplashScreenUser.
  runApp(
    const ProviderScope(
      child: AppUser(),
    ),
  );
}
