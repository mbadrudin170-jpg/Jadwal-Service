// path: lib/admin/app_admin.dart
// diubah: Import ThemeProvider dari shared/theme/theme_provider.dart (global),
//         menggunakan ThemeProviderImpl dengan LocalStorageService.
// diubah: Memperbaiki import path dan nama class.
// diubah: Mengurutkan import directives.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/admin/splash_screen_admin.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/data/sync/initial_download.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/main/main_admin/admin_dev.dart (AdminDev)
//   - lib/main/main_admin/admin_prod.dart (AdminProd)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/data/sqlite.dart (DatabaseHelper)
//   - lib/admin/firebase_option/firebase_option_admin_dev.dart (DefaultFirebaseOptions)
//   - lib/admin/halaman_utama.dart (HalamanUtama)
//   - lib/admin/splash_screen_admin.dart (SplashScreen)
//   - lib/shared/data/services/navigasi_servis.dart (NavigasiServis)
//   - lib/shared/data/sync/initial_download.dart (InitialDownloadService)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/operasi/data_cleaning_operation.dart (DataCleaningOperation)
//   - lib/shared/services/internet_connection_check.dart (InternetConnectionService)
//   - lib/shared/services/notifikasi/notifikasi_servis.dart (NotifikasiServis)
//   - lib/shared/theme/app_theme.dart (AppTheme)
//   - lib/shared/theme/theme_provider.dart (ThemeProvider)
//   - lib/shared/utils/sync_manager.dart (SyncManager)
//   - lib/user/services/storage/local_storage_service.dart (LocalStorageService)

/// Widget utama aplikasi admin.
class AppAdmin extends StatelessWidget {
  /// Konstruktor untuk AppAdmin.
  const AppAdmin({super.key});

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: SplashScreen(loadingMessage: 'Memuat...'),
          );
        }
        final prefs = snapshot.data!;
        final localStorageService = LocalStorageService(prefs: prefs);
        return ChangeNotifierProvider<ThemeProvider>(
          create: (final _) =>
              ThemeProviderImpl(localStorageService: localStorageService),
          child: const AppInitializer(),
        );
      },
    );
  }
}

/// Widget yang melakukan inisialisasi aplikasi.
class AppInitializer extends StatefulWidget {
  /// Konstruktor untuk AppInitializer.
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<bool> _initialization;
  String _loadingMessage = 'Memulai aplikasi...';

  final InternetConnectionService _connectionService =
      InternetConnectionService();

  @override
  void initState() {
    super.initState();
    Log.info('initState: Memulai inisialisasi aplikasi terpusat.');
    _initialization = _initializeAndNavigate();
  }

  Future<bool> _initializeAndNavigate() async {
    Log.info('Memulai urutan inisialisasi aplikasi.');
    try {
      _updateMessage('Menginisialisasi layanan Google...');
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _updateMessage('Mengonfigurasi pengaturan lokal...');
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      await initializeDateFormatting('id_ID');

      _updateMessage('Mempersiapkan layanan notifikasi...');
      final notifikasiServis = NotifikasiServis();
      await notifikasiServis.inisialisasi();
      await notifikasiServis.requestPermissions();

      _updateMessage('Mempersiapkan database lokal...');
      await DatabaseHelper.instance.database;

      _updateMessage('Memeriksa data awal...');
      await InitialDownloadService().runInitialDownload();

      _updateMessage('Membersihkan data arsip kadaluarsa...');
      final dataCleaningOperation = DataCleaningOperation();
      await dataCleaningOperation.deleteAllExpiredArchivedData(
          retentionDays: 30);

      _updateMessage('Mengecek koneksi internet...');
      final isOnline = await _connectionService.checkConnection();

      _updateMessage('Selesai, membuka aplikasi...');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      return isOnline;
    } on Exception catch (e, s) {
      Log.error('Error kritis selama inisialisasi.', e: e, st: s);
      _updateMessage('Terjadi error: ${e.toString()}');
      return false;
    }
  }

  void _updateMessage(final String message) {
    if (!mounted) return;
    setState(() {
      _loadingMessage = message;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final isOnline = snapshot.data ?? false;
          return AppProviders(isOffline: !isOnline);
        }
        return MaterialApp(
          home: SplashScreen(loadingMessage: _loadingMessage),
        );
      },
    );
  }
}

/// Widget yang menyediakan provider untuk aplikasi.
class AppProviders extends StatelessWidget {
  /// Status offline.
  final bool isOffline;

  /// Konstruktor untuk AppProviders.
  const AppProviders({super.key, required this.isOffline});

  @override
  Widget build(final BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SyncManager>(
          create: (final _) => SyncManager(),
        ),
      ],
      child: AppMaterial(isOffline: isOffline),
    );
  }
}

/// Widget yang membangun MaterialApp.
class AppMaterial extends StatelessWidget {
  /// Status offline.
  final bool isOffline;

  /// Konstruktor untuk AppMaterial.
  const AppMaterial({super.key, required this.isOffline});

  @override
  Widget build(final BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (final context, final themeProvider, final child) {
        return MaterialApp(
          title: 'Admin Wifi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: HalamanUtama(isOffline: isOffline),
          navigatorKey: NavigasiServis.navigatorKey,
        );
      },
    );
  }
}
