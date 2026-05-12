// path: lib/user/app_user.dart
// diubah: Menerjemahkan semua pesan log ke dalam Bahasa Indonesia.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';
import 'package:wifi/user/maintenance_page.dart';
import 'package:wifi/user/page/home_page.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/user/provider/theme_provider.dart';
import 'package:wifi/user/services/firestore_service.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

class AppUser extends StatefulWidget {
  final SharedPreferences prefs;
  const AppUser({super.key, required this.prefs});

  @override
  State<AppUser> createState() => _AppUserState();
}

class _AppUserState extends State<AppUser> {
  late Future<DocumentSnapshot?> _pengaturanFuture;

  @override
  void initState() {
    super.initState();
    _pengaturanFuture = _getPengaturanFromFirestore();
  }

  Future<DocumentSnapshot?> _getPengaturanFromFirestore() async {
    final koneksiService = KoneksiInternetService();
    final isOnline = await koneksiService.cekKoneksi();

    if (!isOnline) {
      Log.warning(
          'Tidak ada koneksi internet. Melewatkan pemeriksaan Firestore.');
      return null;
    }

    try {
      await Firebase.initializeApp();
      Log.info('Firebase berhasil diinisialisasi.');
      final snapshot = await FirebaseFirestore.instance
          .collection('pengaturan')
          .doc('konfigurasi_global')
          .get();
      Log.info('Snapshot pengaturan berhasil diambil dari Firestore.');
      return snapshot;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil pengaturan dari Firestore.',
        e: e,
        st: s,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localStorageService = LocalStorageService(prefs: widget.prefs);
    final userId = widget.prefs.getString('userId');

    return FutureBuilder<DocumentSnapshot?>(
      future: _pengaturanFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Memeriksa koneksi dan menunggu pengaturan dari server...');
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreenUser(),
          );
        }

        if (snapshot.hasError ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          Log.warning(
            'Tidak ada pengaturan dari server (offline/error). Melanjutkan ke aplikasi.',
            snapshot.error,
          );
          return _buildMainApp(userId, localStorageService);
        }

        Log.info('Data Firestore diterima, memeriksa mode pemeliharaan.');
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final pengaturan = data != null
            ? PengaturanModel.fromFirebase(data)
            : PengaturanModel();

        if (pengaturan.modePemeliharaan) {
          Log.warning(
              'Mode pemeliharaan AKTIF. Menampilkan halaman pemeliharaan.');
          return MaterialApp(
            title: 'Aplikasi dalam Perbaikan',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: MaintenancePage(maintenanceInfo: pengaturan.infoPemeliharaan),
          );
        } else {
          Log.info(
              'Mode pemeliharaan NONAKTIF. Melanjutkan ke aplikasi utama.');
          return _buildMainApp(userId, localStorageService);
        }
      },
    );
  }

  Widget _buildMainApp(
      String? userId, LocalStorageService localStorageService) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProviderImpl(),
        ),
        Provider<FirestoreService>(
          create: (context) => FirestoreService(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Aplikasi User',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.tema,
            home: const SplashScreenUser(),
            routes: {
              '/home': (context) => HomePage(
                    userId: userId ?? '',
                    localStorageService: localStorageService,
                  ),
              '/login': (context) => const LoginPage(),
            },
          );
        },
      ),
    );
  }
}
