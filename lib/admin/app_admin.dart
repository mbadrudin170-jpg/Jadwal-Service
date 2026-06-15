// path: lib/admin/app_admin.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/background/background_service.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/data/sync/unduhan_awal_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

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
    final notifikasiServis = ref.read(layananNotifikasiProvider);
    final koneksiInternetService = ref.read(koneksiInternetServiceProvider);
    final sqliteDb = ref.read(sqliteDatabaseProvider);
    try {
      await BackgroundService.init();

      await notifikasiServis.inisialisasiNotifikasi(
          iconName: 'ic_notification');
      await notifikasiServis.mintaIzin();

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

      await sqliteDb.database;

      final pelangganAktifOpSqlite = ref.read(pelangganAktifOpSqliteProvider);
      await pelangganAktifOpSqlite.hapusPermanenDataSoftDelete();

      final isOnline = await koneksiInternetService.cekInternet(ref);
      if (isOnline) {
        Log.info('Perangkat online, melanjutkan dengan unduhan data awal.');

        final unduhanAwalService = ref.read(unduhanAwalServiceProvider);
        try {
          await unduhanAwalService.jalankanUnduhanAwal().timeout(
                const Duration(seconds: 30),
              );
          Log.info('Initial download berhasil diselesaikan.');
        } on TimeoutException {
          Log.warning(
              'Initial download memakan waktu terlalu lama (timeout). Melanjutkan inisialisasi...');
        }

        final dataPengaturan =
            await ref.read(settingsOpSqliteProvider).getSettings();
        final retentionDays = dataPengaturan.waktuOtomatisHapusDataArsip;
        final dataCleaningOperation = ref.read(dataCleaningOperationProvider);
        await dataCleaningOperation
            .hapusPermanentDataYangDiarsip(retentionDays: retentionDays)
            .timeout(const Duration(seconds: 5));
      } else {
        Log.warning(
            'Perangkat offline, melewati proses unduhan data awal dan pembersihan.');
      }

      return isOnline;
    } on Exception catch (e, s) {
      Log.error('Error kritis selama inisialisasi sekunder.', e: e, s: s);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
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
    ref.watch(layananNotifikasiProvider);

    final temaAsync = ref.watch(temaProvider);

    return temaAsync.when(
      data: (themeMode) => ToastificationWrapper(
        child: MaterialApp(
          title: 'Admin Wifi',
          theme: AppTheme.modeTerang,
          darkTheme: AppTheme.modeGelap,
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
