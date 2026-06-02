// path: lib/main/main_admin/admin_prod.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/boot_service.dart';
import 'package:wifi/shared/services/expired_subscription_check_service.dart';

/// Callback untuk alarm kedaluwarsa langganan.
@pragma('vm:entry-point')
Future<void> _callbackAlarm() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Log.info('ALARM TERPICU: Memulai proses pengecekan langganan kedaluwarsa...');

  final container = ProviderContainer();
  try {
    final service = container.read(expiredSubscriptionCheckServiceProvider);
    await service.processExpiredSubscriptions();
  } finally {
    container.dispose();
  }
  Log.info('ALARM SELESAI: Proses pengecekan langganan kedaluwarsa selesai.');
}

/// Callback yang dipicu setelah perangkat boot ulang.
@pragma('vm:entry-point')
Future<void> _rescheduleOnBoot() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase dengan opsi prod
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Log.info('BOOT DETECTED: Menjalankan BootService untuk penjadwalan ulang...');

  // Penting: Gunakan ProviderContainer di isolate background untuk akses Operation
  final container = ProviderContainer();
  try {
    // Panggil service yang mengambil semua pelanggan aktif dan menjadwalkan ulang notifikasinya
    await container.read(bootServiceProvider).rescheduleAlarmsOnBoot(container);
  } finally {
    container.dispose();
  }
}

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode produksi.
void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Log.info('Memuat variabel lingkungan (dotenv)...');
  await dotenv.load();
  Log.info('Dotenv berhasil dimuat.');

  Log.info('Menginisialisasi Supabase...');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  Log.info('Inisialisasi Supabase selesai.');

  Log.info('Menginisialisasi Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Log.info('Inisialisasi Firebase selesai.');

  Log.info('Menginisialisasi Android Alarm Manager...');
  await AndroidAlarmManager.initialize();
  Log.info('Inisialisasi Android Alarm Manager selesai.');

  Log.info('Menginisialisasi Google Mobile Ads SDK...');
  await MobileAds.instance.initialize();
  Log.info('Inisialisasi Google Mobile Ads SDK selesai.');

  Log.info('Memulai aplikasi admin. Menyerahkan kendali ke AppAdmin...');

  runApp(
    const ProviderScope(
      child: AppAdmin(),
    ),
  );

  Log.info('Mendaftarkan alarm...');
  // Daftarkan alarm yang akan aktif saat boot.

  // 1. Alarm berkala untuk cek langganan (Misal: setiap 1 jam)
  const int subscriptionCheckAlarmId = 1000;
  await AndroidAlarmManager.periodic(
    const Duration(hours: 1),
    subscriptionCheckAlarmId,
    _callbackAlarm,
    exact: true,
    wakeup: true,
  );
  Log.info('Alarm pengecekan langganan berkala telah didaftarkan.');

  // ID harus unik. Menggunakan nilai int besar yang acak.
  const int rebootAlarmId = 9999;
  await AndroidAlarmManager.periodic(
    const Duration(
        days:
            365), // Interval lama tidak masalah karena kita mengandalkan flag rescheduleOnReboot
    rebootAlarmId,
    _rescheduleOnBoot,
    startAt: DateTime.now(),
    wakeup: true,
    rescheduleOnReboot: true, // Ini adalah kunci utamanya!
  );
  Log.info(
      'Receiver untuk penjadwalan ulang saat boot telah diaktifkan dengan ID: \$rebootAlarmId');
}
