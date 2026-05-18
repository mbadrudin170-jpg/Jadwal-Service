// path: lib/main/main_user/user_prod.dart
// diubah: Mengirim instance notifikasiServis ke AppUser.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/user/app_user.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_prod.dart';
import 'package:wifi/user/maintenance_page.dart';

void main() async {
  // ditambah: Memastikan semua binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  // ditambah: inisialisasi firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Aktifkan cache offline Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // ditambah: Pengecekan mode pemeliharaan sebelum menjalankan aplikasi utama
  try {
    Log.info('[main] Memeriksa status mode pemeliharaan dari Firestore...');
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('global_config')
        .get(
          const GetOptions(source: Source.server),
        ); // Paksa ambil dari server

    if (doc.exists && doc.data() != null) {
      final settings = SettingsModel.fromFirebase(doc.data()!);
      if (settings.maintenanceMode) {
        Log.warning(
          '[main] ⚠️ Mode pemeliharaan AKTIF. Menjalankan MaintenanceApp.',
        );
        runApp(
          MaterialApp(
            title: 'Aplikasi dalam Perbaikan',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: MaintenancePage(
              maintenanceInfo: settings.maintenanceInfo,
              onRefresh: () {
                Log.info(
                  '[Maintenance] Tombol refresh ditekan. Pengguna harus memulai ulang aplikasi untuk memeriksa status terbaru.',
                );
              },
              onExit: SystemNavigator.pop,
            ),
          ),
        );
        return; // Hentikan eksekusi lebih lanjut
      }
      Log.info('[main] ✅ Mode pemeliharaan NONAKTIF.');
    } else {
      Log.info('[main] Dokumen pengaturan tidak ditemukan di server.');
    }
  } on Exception catch (e, st) {
    Log.error(
      '[main] ❌ Gagal memeriksa status pemeliharaan. Menampilkan halaman maintenance sebagai fallback.',
      e: e,
      st: st,
    );
    runApp(
      MaterialApp(
        title: 'Gagal Terhubung',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: MaintenancePage(
          maintenanceInfo:
              'Gagal terhubung ke server untuk memeriksa status. Pastikan koneksi internet Anda stabil dan coba mulai ulang aplikasi.',
          onRefresh: () {
            Log.info(
              '[Maintenance] Tombol refresh ditekan. Pengguna harus memulai ulang aplikasi.',
            );
          },
          onExit: SystemNavigator.pop,
        ),
      ),
    );
    return; // Hentikan eksekusi
  }

  // --- Aplikasi Normal Berjalan Dari Sini ---
  Log.info('[main] Melanjutkan alur startup aplikasi normal.');

  // 1. Inisialisasi servis notifikasi lokal
  final notifikasiServis = NotifikasiServis();
  await notifikasiServis.inisialisasi(iconName: '@mipmap/launcher_icon'); // diperbaiki: Nama ikon disesuaikan
  await notifikasiServis.requestPermissions(); // Meminta izin

  final prefs = await SharedPreferences.getInstance();
  runApp(AppUser(prefs: prefs, notifikasiServis: notifikasiServis));
}
