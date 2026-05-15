// path: lib/admin/app_admin.dart
// diubah: Menghapus definisi tema lokal dan mengimpor dari AppTheme terpusat.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/admin/splash_screen_admin.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/data/sync/unduhan_awal.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/pembersihan_data_service.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

/// Widget utama aplikasi.
class AppAdmin extends StatelessWidget {
  /// Konstruktor untuk MyApp.
  const AppAdmin({super.key});

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider(
      create: (final _) => ThemeProvider(),
      child: const AppInitializer(),
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
  final KoneksiInternetService _koneksiService = KoneksiInternetService();

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
      await UnduhanAwalService().jalankanUnduhanAwal();
      await PembersihanDataService().jalankanJikaPerlu();

      _updateMessage('Mengecek koneksi internet...');
      final isOnline = await _koneksiService.cekKoneksi();

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
          theme: AppTheme.lightTheme, // diubah: Menggunakan tema dari AppTheme
          darkTheme:
              AppTheme.darkTheme, // diubah: Menggunakan tema dari AppTheme
          themeMode: themeProvider.themeMode,
          home: HalamanUtama(isOffline: isOffline),
          navigatorKey: NavigasiServis.navigatorKey,
        );
      },
    );
  }
}
