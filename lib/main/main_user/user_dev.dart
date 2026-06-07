// path: lib/main/main_user/user_dev.dart
// PERBAIKAN:
// - Menambahkan ProviderScope untuk mengaktifkan Riverpod di seluruh aplikasi.
// - Menambahkan `flutter_native_splash` untuk menahan splash screen
//   hingga inisialisasi di Flutter selesai.
// - Memperbaiki pemanggilan `setGDPRConsent`.
// - Menambahkan pemanggilan `setCCPAConsent`.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/shared/constant/app_constants.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:wifi/user/app_user.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_dev.dart';

void main() async {
  // Memastikan binding Flutter siap dan menahan native splash screen.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Log.info('Memuat variabel lingkungan dari file .env...');
  await dotenv.load();
  Log.info('Variabel lingkungan berhasil dimuat.');

  Log.info('Menginisialisasi Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Log.info('Inisialisasi Firebase selesai.');

  Log.info('Menginisialisasi Supabase...');
  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey]!;
  final supabasePublishableKey =
      dotenv.env[AppConstants.supabasePublishableKey]!;
  await Supabase.initialize(
      url: supabaseUrl, publishableKey: supabasePublishableKey);
  Log.info('Inisialisasi Supabase selesai.');

  Log.info('Menginisialisasi workmanager');
  await BackgroundService.init();

  Log.info('Menginisialisasi GmaMediationUnity');
  // Konfigurasi consent GDPR dan CCPA untuk Unity Ads Mediation.
  await GmaMediationUnity().setGDPRConsent(true);
  await GmaMediationUnity().setCCPAConsent(true);

  Log.info('Menginisialisasi MobileAds');
  await MobileAds.instance.initialize();

  Log.info(
      '[main-dev] Memulai aplikasi user. Menyerahkan kendali ke AppUser...');

  // Native splash akan dihilangkan dari dalam SplashScreenUser.
  runApp(
    ProviderScope(
      overrides: [
        appRoleProvider.overrideWithValue(AppRole.user),
      ],
      child: const AppUser(),
    ),
  );
}
