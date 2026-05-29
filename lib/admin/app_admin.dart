// path: lib/admin/app_admin.dart
// REFAKTOR: Menyesuaikan dengan AsyncNotifier untuk tema.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/admin/providers/app_providers.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/data/sync/initial_download.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/theme/app_theme.dart';

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
  final InternetConnectionService _connectionService =
      InternetConnectionService();

  @override
  void initState() {
    super.initState();
    _initialization = _initializeAndNavigate();
  }

  Future<bool> _initializeAndNavigate() async {
    final notifikasiServis = ref.read(notifikasiServisProvider);
    try {
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
      await DatabaseHelper.instance.database;
      await InitialDownloadService().runInitialDownload();

      final isOnline = await _connectionService.checkConnection();
      if (isOnline) {
        // Gunakan ref.read untuk mengakses provider settings
        final settings = await ref.read(settingsProvider.future);
        final retentionDays = settings.autoDeleteArchiveDays;
        final dataCleaningOperation = DataCleaningOperation();
        await dataCleaningOperation.deleteAllExpiredArchivedData(
            retentionDays: retentionDays);
      } else {
        Log.warning('Melewati proses pembersihan data karena sedang offline.');
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
          if (snapshot.hasError || !(snapshot.data ?? false)) {
            return const AppMaterial(isOffline: true);
          }
          return const AppMaterial(isOffline: false);
        }
        return const MaterialApp(
          home: Scaffold(
              body: Center(child: CircularProgressIndicator())), // Initial splash
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
