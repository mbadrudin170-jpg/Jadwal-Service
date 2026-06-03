// path: lib/user/page/splash_screen_user.dart
// DIUBAH: Menghapus ConsentManager dan semua logika terkait GDPR.
// Mobile Ads SDK sekarang diinisialisasi secara langsung.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/model/package_info_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/settings_op_firebase.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/update_check_service.dart';
import 'package:wifi/shared/services/user_activity_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/maintenance_page.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

/// Record yang berisi informasi tentang pembaruan aplikasi.
typedef UpdateInfoRecord = ({
  bool isUpdateRequired,
  ApkVersionModel? apkInfo,
  PackageInfoModel? packageInfo,
  ApkArchitectureEnum? architecture
});

/// Halaman splash screen yang ditampilkan saat aplikasi pengguna pertama kali dibuka.
class SplashScreenUser extends StatefulWidget {
  final SharedPreferences prefs;
  final LocalStorageService localStorageService;

  const SplashScreenUser({
    super.key,
    required this.prefs,
    required this.localStorageService,
  });

  @override
  State<SplashScreenUser> createState() => _SplashScreenUserState();
}

class _SplashScreenUserState extends State<SplashScreenUser> {
  final SettingsOpFirebase _settingsOp = SettingsOpFirebase();
  final adUnitId = IdInterstitialAds.interstitialAdUnitIds[0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      unawaited(_initializeApp());
    });
  }

  Future<void> _initializeApp() async {
    try {
      Log.info('Memulai inisialisasi dari Splash Screen...');
      // Pindahkan inisialisasi layanan inti yang tidak memerlukan internet ke atas
      await _initializeOfflineServices();

      final internetService = InternetConnectionService();
      final isConnected = await internetService.isInternetAvailable();
      Log.info(
          isConnected ? 'Status koneksi: Online' : 'Status koneksi: Offline');

      if (isConnected) {
        // Hanya jalankan layanan yang butuh internet jika koneksi tersedia
        await _initializeOnlineServices();

        final updateInfo = await _checkAppUpdate();
        if (updateInfo != null) {
          if (!mounted) return;
          unawaited(Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (final context) => UpdateApkPage(
                apkInfo: updateInfo.apkInfo!,
                packageInfo: updateInfo.packageInfo!,
                architecture: updateInfo.architecture!,
                prefs: widget.prefs,
                localStorageService: widget.localStorageService,
              ),
            ),
          ));
          return;
        }

        final maintenanceSettings = await _checkMaintenanceMode();
        if (maintenanceSettings != null) {
          if (!mounted) return;
          unawaited(Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (final context) => MaintenancePage(
                maintenanceInfo: maintenanceSettings.maintenanceInfo,
                onRefresh: _initializeApp,
                onExit: SystemNavigator.pop,
              ),
            ),
          ));
          return;
        }
      } else {
        // Beri tahu pengguna bahwa mereka offline
        if (mounted) {
          ToastUtil.info(context,
              'Anda sedang offline. Beberapa fitur mungkin tidak tersedia.');
        }
      }

      Log.info('Inisialisasi selesai. Menavigasi ke halaman yang sesuai.');
      await _navigateToNextPage();
    } on Exception catch (e, st) {
      Log.error('Error kritis saat inisialisasi', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context,
            'Gagal terhubung ke server. Aplikasi berjalan dalam mode offline.');
      }
      // Tetap navigasi meskipun ada error agar pengguna tidak terjebak
      await _navigateToNextPage();
    }
  }

  /// Inisialisasi layanan yang bisa berjalan tanpa koneksi internet.
  Future<void> _initializeOfflineServices() async {
    Log.info('Memulai inisialisasi layanan offline...');
    await NotifikasiServis().inisialisasi(iconName: 'ic_notification');
    await NotifikasiServis().requestPermissions();
    await initializeDateFormatting('id_ID');
    Log.info('Inisialisasi layanan offline selesai.');
  }

  /// Inisialisasi layanan yang membutuhkan koneksi internet.
  Future<void> _initializeOnlineServices() async {
    Log.info('Memulai inisialisasi layanan online...');
    try {
      Log.info('Menginisialisasi Mobile Ads SDK...');
      await MobileAds.instance.initialize();

      Log.info('Mobile Ads SDK berhasil diinisialisasi.');
    } on Exception catch (e, st) {
      Log.error('Gagal inisialisasi Mobile Ads', e: e, st: st);
    }

    try {
      Log.info('Mengkonfigurasi persistensi Firestore...');
      FirebaseFirestore.instance.settings =
          const Settings(persistenceEnabled: true);
      Log.info('Persistensi Firestore berhasil dikonfigurasi.');
    } on Exception catch (e, st) {
      Log.error('Gagal mengkonfigurasi persistensi Firestore', e: e, st: st);
    }

    Log.info('Inisialisasi layanan online selesai.');
  }

  Future<UpdateInfoRecord?> _checkAppUpdate() async {
    Log.info('Memeriksa pembaruan aplikasi...');
    if (!mounted) return null;
    final updateService = UpdateCheckService(
      prefs: widget.prefs,
      localStorageService: widget.localStorageService,
      context: context,
    );
    final updateInfo = await updateService.getUpdateInfo();
    if (updateInfo.isUpdateRequired) {
      Log.info('Pembaruan diperlukan.');
      return updateInfo;
    }
    Log.info('Aplikasi sudah versi terbaru.');
    return null;
  }

  Future<SettingsModel?> _checkMaintenanceMode() async {
    Log.info('Memeriksa status server...');
    try {
      final settingsMap = await _settingsOp.getSettings();
      final settings = SettingsModel.fromFirebase(settingsMap);
      if (settings.maintenanceMode) {
        Log.info('Server dalam mode pemeliharaan.');
        return settings;
      }
      Log.info('Server tidak dalam mode pemeliharaan.');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal memeriksa mode pemeliharaan', e: e, st: st);
      return null;
    }
  }

  Future<void> _navigateToNextPage() async {
    if (!mounted) {
      Log.warning(
          'Navigasi dibatalkan karena widget sudah tidak terpasang (unmounted).');
      return;
    }
    final userId = widget.prefs.getString('userId');
    if (userId != null) {
      Log.info('Pengguna sudah login. Mengalihkan ke MainPage.');
      // Pindahkan pingActivity ke dalam blok online jika memungkinkan
      final isConnected = await InternetConnectionService().isInternetAvailable();
      if (isConnected) {
        unawaited(UserActivityService().pingActivity(userId)); // Diubah
      }
      if (!mounted) return;
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (final context) => MainPage(
            userId: userId,
            localStorageService: widget.localStorageService,
          ),
        ),
      ));
    } else {
      Log.info('Pengguna belum login. Mengalihkan ke LoginPage.');
      if (!mounted) return;
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (final context) => const LoginPage()),
      ));
    }
  }

  @override
  Widget build(final BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat aplikasi...'),
          ],
        ),
      ),
    );
  }
}
