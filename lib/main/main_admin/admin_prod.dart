// path: lib/main/main_admin/admin_prod.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';
import 'package:wifi/shared/constant/app_constants.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/fitur/background/background_service.dart';
import 'package:wifi/fitur/background/boot_service.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode produksi (prod).
void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Muat variabel lingkungan dari file .env
  Log.info('Memuat variabel lingkungan dari file .env...');
  await dotenv.load();
  Log.info('Variabel lingkungan berhasil dimuat.');

  Log.info('Menginisialisasi Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Log.info('Inisialisasi Firebase selesai.');

  Log.info('Menginisialisasi Supabase...');
  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey] ?? '';
  final supabasePublishableKey =
      dotenv.env[AppConstants.supabasePublishableKey] ?? '';
  await Supabase.initialize(
      url: supabaseUrl, publishableKey: supabasePublishableKey);
  Log.info('Inisialisasi Supabase selesai.');

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    Log.error('❌ ERROR KRUSIAL: Nilai di file .env kosong atau tidak terbaca!');
  }

  // Inisialisasi semua service background
  Log.info('Menginisialisasi Background Services...');
  await BackgroundService.init();
  Log.info('Inisialisasi Background Services selesai.');

  // Buat container sementara untuk tugas startup
  final container = ProviderContainer();
  try {
    // Menjadwalkan tugas pengarsipan periodik
    Log.info('Menjadwalkan tugas pengarsipan pelanggan kedaluwarsa...');
    await BootService().schedulePeriodicArchiveTask(container);
    Log.info('Tugas pengarsipan berhasil dijadwalkan.');
  } finally {
    // Pastikan untuk membuang container sementara setelah digunakan
    container.dispose();
  }

  Log.info('Menginisialisasi Google Mobile Ads SDK...');
  await MobileAds.instance.initialize();
  Log.info('Inisialisasi Google Mobile Ads SDK selesai.');

  Log.info('Memulai aplikasi admin. Menyerahkan kendali ke AppAdmin...');

  runApp(
    ProviderScope(
      overrides: [
        appRoleProvider.overrideWithValue(AppRole.admin),
      ],
      child: const AppAdmin(),
    ),
  );
}
