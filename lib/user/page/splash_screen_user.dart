// path: lib/user/page/splash_screen_user.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/fitur/sinkronisasi/update_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/package_info_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/settings_op_firebase.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/maintenance_page.dart';
import 'package:wifi/user/page/event_page_u.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';
import 'package:wifi/user/providers/user_providers.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

/// Record yang berisi informasi tentang pembaruan aplikasi.
typedef UpdateInfoRecord = ({
  bool isUpdateRequired,
  ApkVersionModel? apkInfo,
  PackageInfoModel? packageInfo,
  ApkArchitectureEnum? architecture
});

/// Halaman splash screen yang ditampilkan saat aplikasi pengguna pertama kali dibuka.
class SplashScreenUser extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final LayananPenyimpananLokal localStorageService;

  const SplashScreenUser({
    super.key,
    required this.prefs,
    required this.localStorageService,
  });

  @override
  ConsumerState<SplashScreenUser> createState() => _SplashScreenUserState();
}

class _SplashScreenUserState extends ConsumerState<SplashScreenUser> {
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
      await _initializeOfflineServices();

      final internetService = InternetConnectionService();
      final isConnected = await internetService.isInternetAvailable();

      if (isConnected) {
        await _initializeOnlineServices();

        final eventInfo = await _cekEvent();
        if (eventInfo != null) {
          if (mounted) {
            Log.info('menuju ke halaman event');
            // Tampilkan halaman event di atas splash screen dan tunggu sampai selesai.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (final context) => EventPageU(event: eventInfo),
              ),
            );
          }
        }

        // Setelah halaman event selesai, lanjutkan alur inisialisasi.
        await _continueInitialization();
      } else {
        if (mounted) {
          ToastUtil.info(context, 'Anda sedang offline.');
        }
        await _navigateToNextPage();
      }
    } on Exception catch (e, st) {
      Log.error('Error kritis saat inisialisasi', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal terhubung ke server.');
      }
      await _navigateToNextPage();
    }
  }

  Future<void> _continueInitialization() async {
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
    await _navigateToNextPage();
  }

  Future<void> _initializeOfflineServices() async {
    await NotifikasiServis().inisialisasi(iconName: 'ic_notification');
    await NotifikasiServis().requestPermissions();
    await initializeDateFormatting('id_ID');
  }

  Future<void> _initializeOnlineServices() async {
    try {
      await MobileAds.instance.initialize();
      FirebaseFirestore.instance.settings =
          const Settings(persistenceEnabled: true);
    } on Exception catch (e, st) {
      Log.error('Gagal inisialisasi layanan online', e: e, st: st);
    }
  }

  Future<EventModel?> _cekEvent() async {
    final eventOpSupabase = ref.read(eventOpSupabaseProvider);
    final infoEvent = await eventOpSupabase.getActive();
    return infoEvent;
  }

  Future<UpdateInfoRecord?> _checkAppUpdate() async {
    if (!mounted) return null;
    final updateService = UpdateCheckService(
      prefs: widget.prefs,
      localStorageService: widget.localStorageService,
      context: context,
    );
    final updateInfo = await updateService.getUpdateInfo();
    if (updateInfo.isUpdateRequired) {
      return updateInfo;
    }
    return null;
  }

  Future<SettingsModel?> _checkMaintenanceMode() async {
    try {
      final settingsMap = await _settingsOp.getSettings();
      final settings = SettingsModel.fromFirebase(settingsMap);
      if (settings.maintenanceMode) {
        return settings;
      }
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal memeriksa mode pemeliharaan', e: e, st: st);
      return null;
    }
  }

  Future<void> _navigateToNextPage() async {
    if (!mounted) return;
    final userId = widget.prefs.getString('userId');
    if (userId != null) {
      final isConnected =
          await InternetConnectionService().isInternetAvailable();
      if (isConnected) {
        final userActivityService =
            await ref.read(userActivityServiceProvider.future);
        unawaited(userActivityService.pingActivity(userId));
      }
      if (!mounted) return;
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (final context) => const MainPage(),
        ),
      ));
    } else {
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
            gapH16,
            Text('Memuat aplikasi...'),
          ],
        ),
      ),
    );
  }
}
