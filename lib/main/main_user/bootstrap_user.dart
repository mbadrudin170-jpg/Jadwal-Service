import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/shared/constant/app_constants.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/app_user.dart';

Future<void> bootstrapUser({
  required FirebaseOptions firebaseOptions,
  required String logPrefix,
}) async {
  // Memastikan binding Flutter siap dan menahan native splash screen.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  Log.info('Memuat variabel lingkungan dari file .env...');
  await dotenv.load();
  Log.info('Variabel lingkungan berhasil dimuat.');

  Log.info('Menginisialisasi Firebase...');
  await Firebase.initializeApp(options: firebaseOptions);

  Log.info('Inisialisasi Firebase selesai.');
  await SharedPreferences.getInstance();

  if (!kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Log.info('Menginisialisasi Supabase...');
  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey]!;
  final supabasePublishableKey =
      dotenv.env[AppConstants.supabasePublishableKey]!;
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  Log.info('Inisialisasi Supabase selesai.');

  Log.info('Menginisialisasi workmanager');
  await LayananLatarBelakang.inisialisasi();

  if (!kIsWeb) {
    Log.info('Menginisialisasi GmaMediationUnity');
    await GmaMediationUnity().setGDPRConsent(true);
    await GmaMediationUnity().setCCPAConsent(true);

    Log.info('Menginisialisasi MobileAds');
    await MobileAds.instance.initialize();
  }
  Intl.defaultLocale = 'id_ID';

  Log.info(
    '$logPrefix Memulai aplikasi user. Menyerahkan kendali ke AppUser...',
  );

  // Native splash akan dihilangkan dari dalam SplashScreenUser.
  runApp(const ProviderScope(child: AppUser()));
}
