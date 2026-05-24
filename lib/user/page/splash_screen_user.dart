// path: lib/user/page/splash_screen_user.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/model/package_info_model.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/update_check_service.dart';
import 'package:wifi/shared/services/user_activity_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/maintenance_page.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';
import 'package:wifi/user/providers/app_readiness_provider.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

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
      await _initializeCoreServices();

      final internetService = InternetConnectionService();
      final isConnected = await internetService.checkConnection();
      Log.info(
          isConnected ? 'Status koneksi: Online' : 'Status koneksi: Offline');

      if (isConnected) {
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
          _setAppReady(); // Tandai aplikasi siap bahkan saat update
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
          _setAppReady(); // Tandai aplikasi siap bahkan saat maintenance
          return;
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
      await _navigateToNextPage();
    }
  }

  Future<void> _initializeCoreServices() async {
    Log.info('Menginisialisasi Mobile Ads, Notifikasi, dan lainnya...');
    try {
      await MobileAds.instance.initialize();
    } on Exception catch (e, st) {
      Log.error('Gagal inisialisasi Mobile Ads', e: e, st: st);
    }
    await NotifikasiServis().inisialisasi(iconName: 'launcher_icon');
    await NotifikasiServis().requestPermissions();
    await initializeDateFormatting('id_ID');

    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
    Log.info('Inisialisasi service inti selesai.');
  }

  Future<UpdateInfoRecord?> _checkAppUpdate() async {
    Log.info('Memeriksa pembaruan aplikasi...');
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
    final doc = await FirebaseFirestore.instance
        .collection(TableNameValue.get(TableName.settings))
        .doc(globalSettingsId)
        .get(const GetOptions(source: Source.server));

    if (doc.exists && doc.data() != null) {
      final settings = SettingsModel.fromFirebase(doc.data()!);
      if (settings.maintenanceMode) {
        Log.info('Server dalam mode pemeliharaan.');
        return settings;
      }
    }
    Log.info('Server tidak dalam mode pemeliharaan.');
    return null;
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
      // Panggil pingActivity untuk memperbarui waktu aktif terakhir
      Log.info('Memperbarui waktu aktif terakhir untuk pengguna: $userId');
      await UserActivityService().pingActivity(userId);
      
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
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (final context) => const LoginPage()),
      ));
    }
    // SETELAH NAVIGASI, TANDAI APLIKASI SIAP
    _setAppReady();
  }

  void _setAppReady() {
    // Menggunakan `context.read` untuk memanggil method dari provider
    context.read<AppReadinessProvider>().setAppReady();
  }

  @override
  Widget build(final BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
