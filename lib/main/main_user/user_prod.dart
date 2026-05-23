// path: lib/main/main_user/user_prod.dart
// PERUBAHAN:
// - Menambahkan `flutter_native_splash` untuk menahan splash screen
//   hingga inisialisasi di Flutter selesai.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/app_user.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_prod.dart';

void main() async {
  // Memastikan binding Flutter siap dan menahan native splash screen.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize();

  Log.info(
      '[main-prod] Memulai aplikasi user. Menyerahkan kendali ke AppUser...');

  // Langsung jalankan AppUser.
  // Native splash akan dihilangkan dari dalam SplashScreenUser.
  runApp(const AppUser());
}
