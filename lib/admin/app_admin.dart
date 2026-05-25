// path: lib/admin/app_admin.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/data/sync/initial_download.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Widget utama aplikasi admin.
class AppAdmin extends StatelessWidget {
  /// Konstruktor untuk [AppAdmin].
  const AppAdmin({super.key});

  @override
  Widget build(final BuildContext context) {
    Log.info('AppAdmin build: memulai FutureBuilder SharedPreferences');
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final prefs = snapshot.data!;
        final localStorageService = LocalStorageService(prefs: prefs);
        Log.info('SharedPreferences tersedia, membangun MultiProvider');

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
          child: const AppInitializer(),
        );
      },
    );
  }
}

/// Widget yang menangani proses inisialisasi sekunder aplikasi.
class AppInitializer extends StatefulWidget {
  /// Membuat instance [AppInitializer].
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<bool> _initialization;
  final InternetConnectionService _connectionService =
      InternetConnectionService();

  @override
  void initState() {
    super.initState();
    Log.info('initState: Memulai inisialisasi sekunder aplikasi.');
    _initialization = _initializeAndNavigate();
  }

  Future<bool> _initializeAndNavigate() async {
    Log.info('Memulai urutan inisialisasi sekunder.');
    try {
      // Menggunakan BackgroundService untuk inisialisasi yang terpusat.
      Log.info('Menginisialisasi Workmanager di dalam AppInitializer...');
      await BackgroundService.init();
      
      final notifikasiServis = context.read<NotifikasiServis>();

      Log.info('Menginisialisasi layanan notifikasi...');
      await notifikasiServis.inisialisasi(iconName: 'launcher_icon');
      await notifikasiServis.requestPermissions();
      Log.info('Inisialisasi notifikasi dan permintaan izin telah selesai.');

      final launchDetails =
          await notifikasiServis.getDetailPeluncuranNotifikasi();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        Log.info(
            'Aplikasi dibuka dari notifikasi (terminated) dengan payload: $payload');
        final prefs = await SharedPreferences.getInstance();
        if (payload != null && payload.isNotEmpty) {
          await prefs.setString('initial_notification_payload', payload);
        } else {
          await prefs.remove('initial_notification_payload');
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('initial_notification_payload');
      }
      Log.info('Mengonfigurasi pengaturan lokal...');
      await initializeDateFormatting('id_ID');

      Log.info('Mempersiapkan database lokal...');
      await DatabaseHelper.instance.database;

      Log.info('Memeriksa data awal...');
      await InitialDownloadService().runInitialDownload();

      Log.info('Mengecek koneksi internet untuk pembersihan data...');
      final isOnline = await _connectionService.checkConnection();
      Log.info('Status koneksi: ${isOnline ? "online" : "offline"}');

      if (isOnline) {
        final settings = await SettingsOperation().getSettings();
        final retentionDays = settings.autoDeleteArchiveDays;

        Log.info(
            'Membersihkan data arsip kadaluarsa (SQLite & Firestore) dengan retensi $retentionDays hari...');
        final dataCleaningOperation = DataCleaningOperation();
        await dataCleaningOperation.deleteAllExpiredArchivedData(
            retentionDays: retentionDays);
      } else {
        Log.warning('Melewati proses pembersihan data karena sedang offline.');
      }

      Log.info('Native splash screen dihapus. Aplikasi siap.');

      return isOnline;
    } on Exception catch (e, s) {
      Log.error('Error kritis selama inisialisasi sekunder.', e: e, st: s);
      return false;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final isOnline = snapshot.data ?? false;
          Log.info(
              'Inisialisasi selesai, menuju AppProviders dengan isOffline=${!isOnline}');
          return AppProviders(isOffline: !isOnline);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Widget yang menyediakan provider-provider penting untuk aplikasi.
class AppProviders extends StatelessWidget {
  /// Menandakan apakah aplikasi sedang dalam mode offline.
  final bool isOffline;

  /// Membuat instance [AppProviders].
  const AppProviders({super.key, required this.isOffline});

  @override
  Widget build(final BuildContext context) {
    Log.info('AppProviders build, isOffline=$isOffline');
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

/// Widget yang membangun [MaterialApp] utama aplikasi.
class AppMaterial extends StatelessWidget {
  /// Menandakan apakah aplikasi sedang dalam mode offline.
  final bool isOffline;

  /// Membuat instance [AppMaterial].
  const AppMaterial({super.key, required this.isOffline});

  @override
  Widget build(final BuildContext context) {
    Log.info('AppMaterial build, isOffline=$isOffline');
    return ToastificationWrapper(
      child: Consumer<ThemeProvider>(
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
      ),
    );
  }
}
