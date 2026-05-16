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
import 'package:wifi/shared/data/sync/initial_download.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/data_cleaning_operation.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
// === ANALISIS FILE DAN RELASI MENDALAM (TRACE BERANTAI) ===
//
// Saya ingin kamu menganalisis file berikut secara MENDALAM dan MENYELURUH:
//
// --- FILE UTAMA ---
// Nama file: app_admin.dart
// Path: ~/myapp/lib/admin/app_admin.dart
//
// Isi file:
// ```dart
// [{
	"resource": "/home/user/myapp/lib/admin/app_admin.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "uri_does_not_exist",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/uri_does_not_exist",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Target of URI doesn't exist: 'package:wifi/shared/services/cek_koneksi_internet.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 19,
	"startColumn": 8,
	"endLineNumber": 19,
	"endColumn": 64
},{
	"resource": "/home/user/myapp/lib/admin/app_admin.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "undefined_class",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_class",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined class 'KoneksiInternetService'.\nTry changing the name to the name of an existing class, or creating a class with the name 'KoneksiInternetService'.",
	"source": "dart",
	"startLineNumber": 52,
	"startColumn": 9,
	"endLineNumber": 52,
	"endColumn": 31
},{
	"resource": "/home/user/myapp/lib/admin/app_admin.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'KoneksiInternetService' isn't defined for the type '_AppInitializerState'.\nTry correcting the name to the name of an existing method, or defining a method named 'KoneksiInternetService'.",
	"source": "dart",
	"startLineNumber": 52,
	"startColumn": 50,
	"endLineNumber": 52,
	"endColumn": 72
},{
	"resource": "/home/user/myapp/lib/admin/app_admin.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'UnduhanAwalService' isn't defined for the type '_AppInitializerState'.\nTry correcting the name to the name of an existing method, or defining a method named 'UnduhanAwalService'.",
	"source": "dart",
	"startLineNumber": 85,
	"startColumn": 13,
	"endLineNumber": 85,
	"endColumn": 31
},{
	"resource": "/home/user/myapp/lib/admin/app_admin.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'PembersihanDataService' isn't defined for the type '_AppInitializerState'.\nTry correcting the name to the name of an existing method, or defining a method named 'PembersihanDataService'.",
	"source": "dart",
	"startLineNumber": 86,
	"startColumn": 13,
	"endLineNumber": 86,
	"endColumn": 35
},{
	"resource": "/home/user/myapp/lib/admin/app_admin.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "directives_ordering",
		"target": {
			"$mid": 1,
			"path": "/lints/directives_ordering",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 4,
	"message": "Sort directive sections alphabetically.\nTry sorting the directives.",
	"source": "dart",
	"startLineNumber": 21,
	"startColumn": 1,
	"endLineNumber": 21,
	"endColumn": 68
}]
// ```
//
// --- ATURAN PENTING (WAJIB DIPATUHI) ---
//
// ATURAN TRACE BERANTAI:
// - Jika file ini import/reference/memanggil file B, kamu WAJIB menanyakan isi file B
// - Jika file B ternyata juga import/reference/memanggil file C, kamu WAJIB menanyakan isi file C
// - Jika file C import file D, tanyakan file D, begitu seterusnya sampai AKAR
// - Jangan berhenti sebelum SEMUA rantai dependency terlacak
// - Jangan berspekulasi atau menebak isi file lain, WAJIB minta isinya padaku
// - Kalau kamu butuh isi file terkait, TANYAKAN dengan format: 'Tolong paste isi file [nama_file]'
//
// ATURAN DUA ARAH:
// - Selain file yang di-import, kamu juga WAJIB menanyakan file yang meng-import file utama ini
// - Trace dua arah: ke atas (parent/caller) dan ke bawah (child/dependency)
//
// --- TUGAS KAMU ---
//
// 1. IDENTIFIKASI SEMUA IMPORT & DEPENDENCY
//    - Sebutkan SATU PER SATU import yang ada di file ini
//    - Untuk SETIAP import, sebutkan nama file dan path-nya
//    - Jelaskan kegunaan masing-masing import
//
// 2. TRACE BERANTAI KE BAWAH (FILE YANG DI-IMPORT)
//    - Untuk SETIAP file yang di-import, WAJIB minta isinya padaku
//    - Format: 'Tolong paste isi file [nama_file] di path [path_file]'
//    - Kalau di file import itu ada import lagi, ulangi terus sampai ke akar
//    - Tampilkan dependency chain lengkap: File A → File B → File C → ... → File Akar
//
// 3. TRACE BERANTAI KE ATAS (FILE YANG MENG-IMPORT FILE INI)
//    - WAJIB tanyakan file-file yang meng-import file utama ini
//    - Format: 'Apakah ada file lain yang meng-import app_admin.dart? Tolong paste isinya'
//    - Kalau ada, trace terus ke atas: File X → File Y → ... → File Utama
//
// 4. ANALISIS MASALAH DI SETIAP LEVEL RANTAI
//    - Di setiap file dalam rantai, analisis potensi error
//    - Cek apakah error di file utama disebabkan oleh file import
//    - Cek sampai ke akar penyebab, jangan cuma di permukaan
//    - Siapa yang pertama kali menyebabkan masalah di rantai ini?
//
// 5. DAMPAK PERUBAHAN SEPANJANG RANTAI
//    - Kalau file utama diubah, trace dampaknya ke SEMUA file di rantai
//    - Kalau file akar diubah, trace dampaknya ke file utama
//    - Di setiap level, sebutkan apa yang akan error/terpengaruh
//
// 6. VISUALISASI RANTAI DEPENDENCY
//    - Gambarkan diagram rantai lengkap: File A → File B → File C → File D
//    - Tandai file mana yang bermasalah
//    - Tandai arah aliran data/dependency
//
// 7. KONTEKS PROJECT
//    - Di folder mana file ini berada?
//    - Apa peran file ini dalam arsitektur project?
//    - File apa saja yang satu folder/feature?
//
// 8. POTENSI MASALAH DI SELURUH RANTAI
//    - Circular dependency?
//    - Import tidak digunakan?
//    - Best practice dilanggar?
//    - Potensi bug dari relasi?
//
// 9. REKOMENDASI PERBAIKAN
//    - Perbaikan untuk file utama
//    - Perbaikan untuk file-file di rantai (kalau perlu)
//    - Saran restruktur dependency kalau diperlukan
//
// --- FORMAT JAWABAN ---
// 1. Mulai dengan identifikasi import file utama
// 2. TANYAKAN padaku SATU PER SATU file yang dibutuhkan
// 3. Tunggu aku berikan isinya, baru lanjut analisis
// 4. JANGAN LANGSUNG menyimpulkan sebelum SEMUA file di rantai diperiksa
// 5. Tampilkan dependency chain lengkap di akhir
// Setelah melakukan perbaikan list semua file yang telah diperbaiki dari awal kita mualai hingga saat ini
// Setelah melakukan pekerjaan beritahukan ke saya sisa tokok AI yang belum terpakai agar proses kita tidak terpotong
// ubah nama class, file variabel, parameter ke dalam bahasa inggris untuk menjaga konsistensi projek tapi untuk komentar wajib indonesia
// tambahkan inofrmasi didalam file file ini digunakan oleh file apa saja dan bungkus dengan komentar
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
