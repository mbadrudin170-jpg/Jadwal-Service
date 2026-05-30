
// path: lib/main/main_admin/admin_dev.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/boot_service.dart';
import 'package:wifi/shared/services/expired_subscription_check_service.dart';

/// Callback untuk alarm kedaluwarsa langganan.
@pragma('vm:entry-point')
void _callbackAlarm() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Log.info("ALARM TERPICU: Memulai proses pengecekan langganan kedaluwarsa...");
  await ExpiredSubscriptionCheckService().processExpiredSubscriptions();
  Log.info("ALARM SELESAI: Proses pengecekan langganan kedaluwarsa selesai.");
}

/// Callback yang dipicu setelah perangkat boot ulang.
@pragma('vm:entry-point')
void _rescheduleOnBoot() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Log.info("BOOT DETECTED: Menjalankan BootService untuk penjadwalan ulang...");
  await BootService().rescheduleAlarmsOnBoot();
}

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode pengembangan.
void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Log.info('Menginisialisasi Android Alarm Manager...');
  await AndroidAlarmManager.initialize();
  Log.info('Inisialisasi Android Alarm Manager selesai.');


  Log.info(' Menginisialisasi Google Mobile Ads SDK...');
  await MobileAds.instance.initialize();
  Log.info(' Inisialisasi Google Mobile Ads SDK selesai.');
  Log.info(' Memulai aplikasi admin. Menyerahkan kendali ke AppAdmin...');
  runApp(
    const ProviderScope(
      child: AppAdmin(),
    ),
  );

  // Daftarkan alarm yang akan aktif saat boot.
  // ID harus unik. Menggunakan nilai int besar yang acak.
  const int rebootAlarmId = 9999;
  await AndroidAlarmManager.periodic(
    const Duration(days: 1), // Durasi tidak relevan, ini hanya untuk mengaktifkan receiver
    rebootAlarmId,
    _rescheduleOnBoot,
    startAt: DateTime.now(),
    wakeup: true,
    rescheduleOnReboot: true, // Ini adalah kunci utamanya!
  );
  Log.info("Receiver untuk penjadwalan ulang saat boot telah diaktifkan dengan ID: $rebootAlarmId");
}
