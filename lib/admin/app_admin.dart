// path: lib/admin/app_admin.dart
// REFAKTOR: Menyesuaikan dengan AsyncNotifier untuk tema.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/data/sync/initial_download.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart'
    hide initialDownloadServiceProvider;
import 'package:wifi/shared/services/background_service.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

class AppAdmin extends ConsumerWidget {
  const AppAdmin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    return prefsAsync.when(
      data: (prefs) => const AppInitializer(),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error memuat SharedPreferences: $err')),
        ),
      ),
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  late Future<bool> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeAndNavigate();
  }

  Future<bool> _initializeAndNavigate() async {
    final notifikasiServis = ref.read(notifikasiServisProvider);
    final connectionService = ref.read(internetConnectionServiceProvider);
    final dbHelper = ref.read(databaseHelperProvider);
    try {
      // Inisialisasi Workmanager untuk tugas latar belakang.
      await BackgroundService.init();

      await notifikasiServis.inisialisasi(iconName: 'ic_notification');
      await notifikasiServis.requestPermissions();

      final launchDetails =
          await notifikasiServis.getDetailPeluncuranNotifikasi();
      final prefs = ref.read(sharedPreferencesProvider).requireValue;
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          await prefs.setString('initial_notification_payload', payload);
        } else {
          await prefs.remove('initial_notification_payload');
        }
      } else {
        await prefs.remove('initial_notification_payload');
      }

      await initializeDateFormatting('id_ID');

      // Inisialisasi Database
      await dbHelper.database;

      // Pembersihan: Arsipkan pelanggan yang masa aktifnya sudah habis (Soft Delete)
      final activeCustomerOp = ref.read(activeCustomerOperationProvider);
      await activeCustomerOp.archiveExpiredCustomers();

      // DIUBAH: Menggunakan metode pengecekan internet yang lebih andal.
      final isOnline = await connectionService.isInternetAvailable();
      if (isOnline) {
        Log.info('Perangkat online, melanjutkan dengan unduhan data awal.');
        // Jalankan unduhan awal hanya jika perangkat online
        final initialDownloadService = ref.read(initialDownloadServiceProvider);
        try {
          await initialDownloadService.runInitialDownload().timeout(
                const Duration(seconds: 30),
              );
          Log.info('Initial download berhasil diselesaikan.');
        } on TimeoutException {
          Log.warning(
              'Initial download memakan waktu terlalu lama (timeout). Melanjutkan inisialisasi...');
        }

        final settingsOperation = ref.read(settingsOperationProvider);
        final settingsModel = await settingsOperation.getSettings();
        final retentionDays = settingsModel.autoDeleteArchiveDays;
        final dataCleaningOperation = ref.read(dataCleaningOperationProvider);
        await dataCleaningOperation
            .deleteAllExpiredArchivedData(retentionDays: retentionDays)
            .timeout(const Duration(seconds: 5));
      } else {
        Log.warning(
            'Perangkat offline, melewati proses unduhan data awal dan pembersihan.');
      }

      return isOnline;
    } on Exception catch (e, s) {
      Log.error('Error kritis selama inisialisasi sekunder.', e: e, st: s);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // DIUBAH: Logika lebih sederhana untuk menangani status offline.
          final bool isOffline = !(snapshot.data ?? false);
          if (snapshot.hasError) {
            Log.error('Error pada FutureBuilder inisialisasi',
                e: snapshot.error);
          }
          return AppMaterial(isOffline: isOffline);
        }
        return const MaterialApp(
          home: Scaffold(
              body:
                  Center(child: CircularProgressIndicator())), // Initial splash
        );
      },
    );
  }
}

class AppMaterial extends ConsumerWidget {
  final bool isOffline;
  const AppMaterial({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton AsyncNotifier tema.
    final themeAsync = ref.watch(themeProvider);

    // Gunakan .when untuk menangani state loading/error/data dari tema
    return themeAsync.when(
      data: (themeMode) => ToastificationWrapper(
        child: MaterialApp(
          title: 'Admin Wifi',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: HalamanUtama(isOffline: isOffline),
          navigatorKey: NavigasiServis.navigatorKey,
        ),
      ),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Gagal memuat tema: $err'),
          ),
        ),
      ),
    );
  }
}
