// path: lib/admin/app_admin.dart
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/admin/splash_screen_admin.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/data/sync/unduhan_awal.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/pembersihan_data_service.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_text_style.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

// diubah: Dibungkus dengan ChangeNotifierProvider untuk menyediakan ThemeProvider
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const AppInitializer(),
    );
  }
}

// baru: Widget untuk menangani logika inisialisasi
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<bool> _initialization;
  String _loadingMessage = "Memulai aplikasi...";
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
      // Langkah 1: Inisialisasi Firebase
      _updateMessage("Menginisialisasi layanan Google...");
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Langkah 2: Pengaturan Lokal
      _updateMessage("Mengonfigurasi pengaturan lokal...");
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      await initializeDateFormatting('id_ID', null);

      // Langkah 3: Layanan Notifikasi
      _updateMessage("Mempersiapkan layanan notifikasi...");
      final notifikasiServis = NotifikasiServis();
      await notifikasiServis.inisialisasi();
      await notifikasiServis.requestPermissions();

      // Langkah 4: Database Lokal
      _updateMessage("Mempersiapkan database lokal...");
      await DatabaseHelper.instance.database;

      // Langkah 5: Data Awal & Pembersihan
      _updateMessage("Memeriksa data awal...");
      await UnduhanAwalService().jalankanUnduhanAwal();
      await PembersihanDataService().jalankanJikaPerlu();

      // Langkah 6: Cek Koneksi Internet
      _updateMessage("Mengecek koneksi internet...");
      final isOnline = await _koneksiService.cekKoneksi();

      _updateMessage("Selesai, membuka aplikasi...");
      await Future.delayed(const Duration(milliseconds: 500));

      return isOnline;
    } catch (e, s) {
      Log.error('Error kritis selama inisialisasi.', error: e, stackTrace: s);
      _updateMessage("Terjadi error: ${e.toString()}");
      return false;
    }
  }

  void _updateMessage(String message) {
    if (!mounted) return;
    setState(() {
      _loadingMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final isOnline = snapshot.data ?? false;
          return AppProviders(isOffline: !isOnline);
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(loadingMessage: _loadingMessage),
        );
      },
    );
  }
}

class AppProviders extends StatelessWidget {
  final bool isOffline;
  const AppProviders({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SyncManager>(
          create: (_) => SyncManager(),
        ),
      ],
      child: AppMaterial(isOffline: isOffline),
    );
  }
}

// diubah: Menggunakan Consumer untuk mendapatkan status tema
class AppMaterial extends StatelessWidget {
  final bool isOffline;
  const AppMaterial({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    // Tema Terang
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor, brightness: Brightness.light),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.secondaryColor,
          backgroundColor: AppColors.primaryColor,
        ),
      ),
    );

    // baru: Tema Gelap
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor, brightness: Brightness.dark),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.primaryColor.shade200,
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Admin Wifi',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: HalamanUtama(isOffline: isOffline),
          navigatorKey: NavigasiServis.navigatorKey,
        );
      },
    );
  }
}