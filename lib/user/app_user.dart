// path: lib/user/app_user.dart
// diubah: Memperbaiki semua masalah dari flutter analyze dan menghubungkan SnackBar global.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/update_check_service.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_dev.dart';
import 'package:wifi/user/maintenance_page.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Widget utama aplikasi user.
class AppUser extends StatelessWidget {
  /// Konstruktor untuk [AppUser].
  const AppUser({super.key});

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: SplashScreenUser(loadingMessage: 'Mempersiapkan...'),
          );
        }

        final prefs = snapshot.data!;
        final localStorageService = LocalStorageService(prefs: prefs);

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
          child: AppInitializer(
            prefs: prefs,
            localStorageService: localStorageService,
          ),
        );
      },
    );
  }
}

/// Enum untuk merepresentasikan status aplikasi saat ini.
enum AppStatus {
  /// Aplikasi sedang dalam proses inisialisasi awal.
  initializing,

  /// Aplikasi dalam mode pemeliharaan (maintenance).
  maintenance,

  /// Aplikasi memerlukan pembaruan.
  needsUpdate,

  /// Aplikasi siap digunakan.
  ready,
}

/// Widget yang menangani seluruh alur inisialisasi aplikasi.
///
/// Widget ini menggunakan state machine untuk menentukan halaman mana yang harus ditampilkan.
class AppInitializer extends StatefulWidget {
  /// Instance dari [SharedPreferences].
  final SharedPreferences prefs;

  /// Instance dari [LocalStorageService] untuk akses penyimpanan lokal.
  final LocalStorageService localStorageService;

  /// Membuat instance [AppInitializer].
  const AppInitializer({
    super.key,
    required this.prefs,
    required this.localStorageService,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppStatus _status = AppStatus.initializing;
  String _loadingMessage = 'Memulai aplikasi...';
  SettingsModel? _maintenanceSettings;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeApp());
  }

  /// Fungsi utama yang menjalankan seluruh proses inisialisasi.
  /// Dapat dipanggil kembali untuk mencoba lagi (misalnya dari MaintenancePage).
  Future<void> _initializeApp() async {
    if (_status != AppStatus.initializing) {
      setState(() {
        _status = AppStatus.initializing;
        _loadingMessage = 'Mencoba terhubung kembali...';
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    try {
      _updateMessage('Menginisialisasi Firebase...');
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _updateMessage('Mengaktifkan cache Firestore...');
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );

      _updateMessage('Menginisialisasi Notifikasi...');
      await NotifikasiServis().inisialisasi(iconName: '@mipmap/ic_launcher');
      await NotifikasiServis().requestPermissions();

      _updateMessage('Menginisialisasi format tanggal...');
      await initializeDateFormatting('id_ID');

      final internetService = InternetConnectionService();
      final isConnected = await internetService.checkConnection();
      _updateMessage(isConnected ? 'Online' : 'Offline');

      if (isConnected) {
        _updateMessage('Memeriksa pembaruan aplikasi...');
        final updateService = UpdateCheckService();
        if (await updateService.isUpdateRequired()) {
          _updateMessage('Pembaruan ditemukan!');
          setState(() {
            _status = AppStatus.needsUpdate;
          });
          return;
        }

        _updateMessage('Memeriksa status server...');
        final doc = await FirebaseFirestore.instance
            .collection(TableNameValue.get(TableName.settings))
            .doc(globalSettingsId)
            .get(const GetOptions(source: Source.server));

        if (doc.exists && doc.data() != null) {
          final settings = SettingsModel.fromFirebase(doc.data()!);
          if (settings.maintenanceMode) {
            _updateMessage('Server dalam perbaikan.');
            setState(() {
              _status = AppStatus.maintenance;
              _maintenanceSettings = settings;
            });
            return;
          }
        }
      }

      _updateMessage('Pemeriksaan selesai.');
      setState(() {
        _status = AppStatus.ready;
      });
    } on Exception catch (e, st) {
      Log.error('Error kritis saat inisialisasi user app', e: e, st: st);
      _updateMessage('Terjadi error. Silakan coba lagi.');

      // Menggunakan SnackBar global untuk menampilkan error
      SnackBarUtil.globalError(
        'Gagal terhubung ke server. Aplikasi berjalan dalam mode offline.',
      );

      // Lanjutkan ke status siap agar pengguna bisa mencoba login atau melihat data cache
      setState(() {
        _status = AppStatus.ready;
      });
    }
  }

  void _updateMessage(final String message) {
    if (mounted && _status == AppStatus.initializing) {
      Log.info('Status Inisialisasi User: $message');
      setState(() {
        _loadingMessage = message;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (final context, final themeProvider, final child) {
        return MaterialApp(
          scaffoldMessengerKey: SnackBarUtil.key, // Menghubungkan GlobalKey
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: _buildHome(),
        );
      },
    );
  }

  /// Membangun halaman utama berdasarkan status aplikasi saat ini.
  Widget _buildHome() {
    switch (_status) {
      case AppStatus.initializing:
        return SplashScreenUser(loadingMessage: _loadingMessage);
      case AppStatus.maintenance:
        return MaintenancePage(
          maintenanceInfo: _maintenanceSettings?.maintenanceInfo ??
              'Server sedang dalam pemeliharaan. Coba lagi nanti.',
          onRefresh: _initializeApp,
          onExit: SystemNavigator.pop,
        );
      case AppStatus.needsUpdate:
        return const UpdateApkPage();
      case AppStatus.ready:
        final userId = widget.prefs.getString('userId');
        if (userId != null) {
          return MainPage(
            userId: userId,
            localStorageService: widget.localStorageService,
          );
        } else {
          return const LoginPage();
        }
    }
  }
}
