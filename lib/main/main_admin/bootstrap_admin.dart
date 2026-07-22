// path: lib/main/main_admin/bootstrap_admin.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/fitur/background/layanan_peluncuran.dart';
import 'package:wifi/shared/constant/app_constants.dart';
import 'package:wifi/shared/debug/log.dart';

Future<void> bootstrapAdmin({
  required FirebaseOptions firebaseOptions,
  required bool debugSupabase,
  required String logPrefix,
}) async {
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

  Log.info('Menginisialisasi Supabase...');
  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey] ?? '';
  final supabasePublishableKey =
      dotenv.env[AppConstants.supabasePublishableKey] ?? '';

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_role', AppRole.admin.name);

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  Log.info('Inisialisasi Supabase selesai.');

  if (debugSupabase) {
    Log.info('DEBUG URL: $supabaseUrl');
    Log.info('DEBUG PUBLISHABLE KEY LENGTH: ${supabasePublishableKey.length}');
  }

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    Log.error('❌ ERROR KRUSIAL: Nilai di file .env kosong atau tidak terbaca!');
  }

  Log.info('Menginisialisasi Background Services...');
  await LayananLatarBelakang.inisialisasi();
  Log.info('Inisialisasi Background Services selesai.');

  final container = ProviderContainer();
  try {
    Log.info('Menjadwalkan tugas pengarsipan pelanggan kedaluwarsa...');
    await LayananPeluncuran().jadwalkanTugasArsipPeriodik(container);
    Log.info('Tugas pengarsipan berhasil dijadwalkan.');
  } finally {
    container.dispose();
  }

  if (!kIsWeb) {
    Log.info('Menginisialisasi Google Mobile Ads SDK...');
    await MobileAds.instance.initialize();
    Log.info('Inisialisasi Google Mobile Ads SDK selesai.');
  } else {
    Log.warning('Google Mobile Ads SDK tidak diinisialisasi di platform web.');
  }

  Intl.defaultLocale = 'id_ID';

  Log.info(
    '$logPrefix Memulai aplikasi admin. Menyerahkan kendali ke AppAdmin...',
  );

  runApp(
    ProviderScope(
      overrides: [appRoleProvider.overrideWithValue(AppRole.admin)],
      child: const AppAdmin(),
    ),
  );
}
