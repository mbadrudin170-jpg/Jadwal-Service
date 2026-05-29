// path: lib/main/main_admin/admin_prod.dart
// PERBAIKAN: Menambahkan inisialisasi Supabase sebelum runApp().
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';
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

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://zptfgbvloodkgioyeaix.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwdGZnYnZsb29ka2dpb3llYWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNzU3NDgsImV4cCI6MjA5NTY1MTc0OH0.YuvZ7zH6iyk8DuFVhBZhDCT-82VBomJSoCgrFPanfns',
  );
  Log.info('Inisialisasi Supabase selesai.');

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
