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
import 'package:wifi/shared/data/sqlite.dart';
import 'package:wifi/shared/data/sync/unduhan_awal.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/pembersihan_data_service.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_text_style.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      Log.info('Memeriksa instance Firebase yang ada...');
      if (Firebase.apps.isEmpty) {
        Log.info('Tidak ada instance Firebase, memulai inisialisasi baru.');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        Log.info('Instance Firebase [DEFAULT] sudah ada, akan menggunakannya.');
      }

      // Langkah 2: Pengaturan Lokal
      _updateMessage("Mengonfigurasi pengaturan lokal...");
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      await initializeDateFormatting('id_ID', null);
      Log.info('Konfigurasi zona waktu dan format tanggal selesai.');

      // Langkah 3: Layanan Notifikasi
      _updateMessage("Mempersiapkan layanan notifikasi...");
      final notifikasiServis = NotifikasiServis();
      await notifikasiServis.inisialisasi();
      await notifikasiServis.requestPermissions();
      Log.info('Layanan notifikasi siap.');

      // Langkah 4: Database Lokal
      _updateMessage("Mempersiapkan database lokal...");
      await DatabaseHelper.instance.database;
      Log.info('Database lokal siap.');

      // Langkah 5: Data Awal & Pembersihan
      _updateMessage("Memeriksa data awal...");
      await UnduhanAwalService().jalankanUnduhanAwal();
      await PembersihanDataService().jalankanJikaPerlu();
      Log.info('Pemeriksaan data awal dan pembersihan selesai.');

      // Langkah 6: Cek Koneksi Internet
      _updateMessage("Mengecek koneksi internet...");
      final isOnline = await _koneksiService.cekKoneksi();
      Log.info('Pengecekan koneksi selesai. Status online: $isOnline');

      // Selesai
      _updateMessage("Selesai, membuka aplikasi...");
      await Future.delayed(const Duration(milliseconds: 500));

      return isOnline;
    } catch (e, s) {
      Log.error(
        'Terjadi error kritis selama inisialisasi.',
        error: e,
        stackTrace: s,
      );
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
    Log.info('Build: Membangun UI utama dengan FutureBuilder.');
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final isOnline = snapshot.data ?? false;
          Log.info(
              'Inisialisasi selesai. Membangun aplikasi utama. Status Online: $isOnline');
          return AppProviders(isOffline: !isOnline);
        }

        Log.info('Inisialisasi sedang berjalan, menampilkan SplashScreen.');
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(
            loadingMessage: _loadingMessage,
          ),
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
    Log.info('Membangun widget AppProviders, menyiapkan MultiProvider.');
    return MultiProvider(
      providers: [
        Provider<SyncManager>(
          create: (_) {
            Log.info('Membuat dan menyediakan instance SyncManager.');
            return SyncManager();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          Log.info('Membangun child dari MultiProvider, yaitu AppMaterial.');
          return AppMaterial(
            isOffline: isOffline,
          );
        },
      ),
    );
  }
}

class AppMaterial extends StatelessWidget {
  final bool isOffline;
  const AppMaterial({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun struktur tema dan MaterialApp.');
    AppColors.logColorInitialization();
    logTextThemeCreation();

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(
          color: AppColors.secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.secondaryColor,
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: appTextTheme.labelLarge,
        ),
      ),
    );
    Log.info('Membuat objek ThemeData untuk mode terang (light theme).');

    Log.info('Mengembalikan widget MaterialApp sebagai root UI.');
    return MaterialApp(
      title: 'Admin Wifi',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      home: HalamanUtama(
        isOffline: isOffline,
      ),
      navigatorKey: NavigasiServis.navigatorKey,
    );
  }
}
