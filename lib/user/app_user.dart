// path: lib/user/app_user.dart
// PERUBAHAN:
// - REFACTOR: Navigasi ke halaman update sekarang menggunakan pushAndRemoveUntil
//   untuk mencegah build halaman yang tidak perlu di background.
// - Menambahkan parameter `ignoreUpdateCheck` pada `_initializeApp`.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/update_check_service.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/maintenance_page.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Widget utama aplikasi user.
class AppUser extends StatelessWidget {
  /// Konstruktor untuk [AppUser].
  const AppUser({super.key});

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final prefs = snapshot.data!;
        final localStorageService = LocalStorageService(prefs: prefs);

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (final _) =>
                  ThemeProviderImpl(localStorageService: localStorageService),
            ),
            Provider<NotifikasiServis>(
              create: (final _) => NotifikasiServis(),
            ),
          ],
          child: AppInitializer(
            prefs: prefs,
            localStorageService: localStorageService,
          ),
        );
      },
    );
  }
}

/// Enum untuk merepresentasikan status aplikasi saat ini.
enum AppStatus {
  /// Aplikasi sedang dalam proses inisialisasi awal.
  initializing,

  /// Aplikasi dalam mode pemeliharaan (maintenance).
  maintenance,

  /// Aplikasi memerlukan pembaruan.
  needsUpdate,

  /// Aplikasi siap digunakan.
  ready,
}

/// Widget yang menangani seluruh alur inisialisasi aplikasi.
class AppInitializer extends StatefulWidget {
  final SharedPreferences prefs;
  final LocalStorageService localStorageService;

  const AppInitializer({
    super.key,
    required this.prefs,
    required this.localStorageService,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppStatus _status = AppStatus.initializing;
  SettingsModel? _maintenanceSettings;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    unawaited(_initializeApp());
  }

  Future<void> _initializeApp({bool ignoreUpdateCheck = false}) async {
    if (_status != AppStatus.initializing) {
      setState(() {
        _status = AppStatus.initializing;
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    try {
      Log.info('Menginisialisasi Mobile Ads SDK...');
      try {
        await MobileAds.instance.initialize();
        Log.info('Inisialisasi Mobile Ads SDK berhasil.');
      } on Exception catch (e, st) {
        Log.error('Gagal menginisialisasi Mobile Ads SDK.', e: e, st: st);
      }

      Log.info('Mengaktifkan cache Firestore...');
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );

      Log.info('Menginisialisasi Notifikasi...');
      await NotifikasiServis().inisialisasi(iconName: '@mipmap/launcher_icon');
      await NotifikasiServis().requestPermissions();

      Log.info('Menginisialisasi format tanggal...');
      await initializeDateFormatting('id_ID');

      final internetService = InternetConnectionService();
      final isConnected = await internetService.checkConnection();
      Log.info(
          isConnected ? 'Status koneksi: Online' : 'Status koneksi: Offline');

      if (isConnected) {
        // --- LOGIKA PEMERIKSAAN PEMBARUAN ---
        if (!ignoreUpdateCheck) {
          Log.info('Memeriksa pembaruan aplikasi...');
          final updateService = UpdateCheckService();
          final updateInfo = await updateService.getUpdateInfo();

          if (updateInfo.isUpdateRequired) {
            Log.info('Pembaruan diperlukan. Mengalihkan ke halaman update.');

            // Navigasi ke halaman update dan hapus semua halaman sebelumnya.
            final skipped =
                await _navigatorKey.currentState?.pushAndRemoveUntil<bool>(
              MaterialPageRoute(
                builder: (final context) => UpdateApkPage(
                  apkInfo: updateInfo.apkInfo!,
                  packageInfo: updateInfo.packageInfo!,
                  architecture: updateInfo.architecture!,
                ),
              ),
              (route) => false,
            );

            // Logika setelah halaman update ditutup
            if (skipped == true) {
              Log.info(
                  'Pengguna melewati pembaruan opsional. Memulai ulang inisialisasi.');
              // Inisialisasi ulang, tapi kali ini lewati pemeriksaan pembaruan.
              unawaited(_initializeApp(ignoreUpdateCheck: true));
            } else {
              Log.info(
                  'Pembaruan tidak dilewati atau wajib. Menutup aplikasi.');
              // Jika pembaruan wajib, atau pengguna menekan tombol kembali,
              // aplikasi akan ditutup.
              unawaited(SystemNavigator.pop());
            }
            return; // Hentikan eksekusi _initializeApp saat ini.
          }
        }

        // --- LOGIKA PEMERIKSAAN MAINTENANCE ---
        Log.info('Memeriksa status server...');
        final doc = await FirebaseFirestore.instance
            .collection(TableNameValue.get(TableName.settings))
            .doc(globalSettingsId)
            .get(const GetOptions(source: Source.server));

        if (doc.exists && doc.data() != null) {
          final settings = SettingsModel.fromFirebase(doc.data()!);
          if (settings.maintenanceMode) {
            Log.info(
                'Server dalam mode pemeliharaan. Mengalihkan ke halaman maintenance.');
            setState(() {
              _status = AppStatus.maintenance;
              _maintenanceSettings = settings;
            });
            return; // Hentikan eksekusi.
          }
        }
      }

      // Jika semua pemeriksaan online lolos atau jika sedang offline
      Log.info('Inisialisasi selesai. Aplikasi siap.');
      setState(() {
        _status = AppStatus.ready;
      });
    } on Exception catch (e, st) {
      Log.error('Error kritis saat inisialisasi user app', e: e, st: st);
      final context = _navigatorKey.currentContext;
      if (context != null) {
        ToastUtil.error(
          context,
          'Gagal terhubung ke server. Aplikasi berjalan dalam mode offline.',
        );
      }

      setState(() {
        _status = AppStatus.ready;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return ToastificationWrapper(
      child: Consumer<ThemeProvider>(
        builder: (final context, final themeProvider, final child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: _buildHome(),
          );
        },
      ),
    );
  }

  Widget _buildHome() {
    switch (_status) {
      case AppStatus.initializing:
      case AppStatus.needsUpdate:
        // Selama proses atau saat menunggu navigasi update, tampilkan layar kosong.
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AppStatus.maintenance:
        return MaintenancePage(
          maintenanceInfo: _maintenanceSettings?.maintenanceInfo ??
              'Server sedang dalam pemeliharaan. Coba lagi nanti.',
          onRefresh: _initializeApp,
          onExit: SystemNavigator.pop,
        );
      case AppStatus.ready:
        final userId = widget.prefs.getString('userId');
        if (userId != null) {
          return MainPage(
            userId: userId,
            localStorageService: widget.localStorageService,
          );
        } else {
          return const LoginPage();
        }
    }
  }
}
