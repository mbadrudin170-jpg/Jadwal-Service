// path: lib/admin/app_admin.dart
// diubah: Menghapus inisialisasi Firebase karena sudah dipindahkan ke main().

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/admin/data/sqlite.dart';
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

/// Widget utama aplikasi admin.
class AppAdmin extends StatelessWidget {
  /// Konstruktor untuk AppAdmin.
  const AppAdmin({super.key});

  @override
  Widget build(final BuildContext context) {
    Log.info('AppAdmin build: memulai FutureBuilder SharedPreferences');
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(home: SplashScreen());
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
            // Menyediakan instance singleton dari NotifikasiServis
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
///
/// Proses ini berjalan setelah inisialisasi utama di `main()` dan menampilkan
/// [SplashScreen] selama berlangsung.
class AppInitializer extends StatefulWidget {
  /// Membuat instance [AppInitializer].
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
    Log.info('initState: Memulai inisialisasi sekunder aplikasi.');
    _initialization = _initializeAndNavigate();
  }

  Future<bool> _initializeAndNavigate() async {
    Log.info('Memulai urutan inisialisasi sekunder.');
    try {
      // Inisialisasi Firebase sudah dipindahkan ke main() untuk mencegah duplikasi.

      _updateMessage('Menginisialisasi layanan notifikasi...');
      await NotifikasiServis().inisialisasi(iconName: '@mipmap/launcher_icon');
      await NotifikasiServis().requestPermissions();
      Log.info('Layanan notifikasi siap');

      _updateMessage('Mengonfigurasi pengaturan lokal...');
      await initializeDateFormatting('id_ID');
      Log.info('Pengaturan lokal selesai (id_ID).');

      _updateMessage('Mempersiapkan database lokal...');
      await DatabaseHelper.instance.database;
      Log.info('Database lokal siap.');

      _updateMessage('Memeriksa data awal...');
      await InitialDownloadService().runInitialDownload();
      Log.info('Initial download selesai.');

      _updateMessage('Membersihkan data arsip kadaluarsa...');
      final dataCleaningOperation = DataCleaningOperation();
      await dataCleaningOperation.deleteAllExpiredArchivedData(
          retentionDays: 30);
      Log.info('Pembersihan data arsip selesai (retentionDays=30).');

      _updateMessage('Mengecek koneksi internet...');
      final isOnline = await _connectionService.checkConnection();
      Log.info('Status koneksi: ${isOnline ? "online" : "offline"}');

      _updateMessage('Selesai, membuka aplikasi...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      Log.info(
          'Inisialisasi sekunder selesai. Kembali dengan isOnline=$isOnline');

      return isOnline;
    } on Exception catch (e, s) {
      Log.error('Error kritis selama inisialisasi sekunder.', e: e, st: s);
      _updateMessage('Terjadi error: ${e.toString()}');
      return false;
    }
  }

  void _updateMessage(final String message) {
    if (!mounted) return;
    // Log setiap perubahan status inisialisasi
    Log.info('Status inisialisasi: $message');
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
          Log.info(
              'Inisialisasi selesai, menuju AppProviders dengan isOffline=${!isOnline}');
          return AppProviders(isOffline: !isOnline);
        }
        return Consumer<ThemeProvider>(
          builder: (final context, final themeProvider, final child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              home: SplashScreen(loadingMessage: _loadingMessage),
            );
          },
        );
      },
    );
  }
}

/// Widget yang menyediakan provider-provider penting untuk aplikasi.
///
/// Provider yang disediakan di sini akan tersedia untuk semua halaman
/// setelah proses inisialisasi selesai.
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
///
/// Ini adalah akar dari hierarki widget aplikasi setelah semua
/// inisialisasi dan penyediaan provider selesai.
class AppMaterial extends StatelessWidget {
  /// Menandakan apakah aplikasi sedang dalam mode offline.
  final bool isOffline;

  /// Membuat instance [AppMaterial].
  const AppMaterial({super.key, required this.isOffline});

  @override
  Widget build(final BuildContext context) {
    Log.info('AppMaterial build, isOffline=$isOffline');
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
