// path: lib/main/main_user/user_prod.dart
// diubah: Logika startup diubah untuk menangani mode offline.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/user/app_user.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_prod.dart';
import 'package:wifi/user/maintenance_page.dart';

void main() async {
  // Memastikan semua binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  Log.info('[main] Memulai aplikasi...');

  // Inisialisasi Firebase, wajib dilakukan di awal
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Aktifkan cache offline Firestore agar aplikasi bisa jalan tanpa internet
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Periksa koneksi internet
  final internetService = InternetConnectionService();
  final isConnected = await internetService.checkConnection();

  // Jika terhubung ke internet, periksa status maintenance dari server
  if (isConnected) {
    Log.info('[main] ✅ Internet terhubung. Memeriksa status pemeliharaan...');
    try {
      final doc = await FirebaseFirestore.instance
          .collection(TableNameValue.get(TableName.settings))
          .doc(globalSettingsId)
          .get(const GetOptions(source: Source.server)); // Paksa ambil dari server

      if (doc.exists && doc.data() != null) {
        final settings = SettingsModel.fromFirebase(doc.data()!);
        if (settings.maintenanceMode) {
          Log.warning('[main] ⚠️ Mode pemeliharaan AKTIF. Menampilkan halaman perbaikan.');
          runApp(
            MaterialApp(
              title: 'Aplikasi dalam Perbaikan',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: MaintenancePage(
                maintenanceInfo: settings.maintenanceInfo,
                onRefresh: () => Log.info('[Maintenance] Pengguna harus memulai ulang aplikasi untuk refresh.'),
                onExit: SystemNavigator.pop,
              ),
            ),
          );
          return; // Hentikan eksekusi
        }
        Log.info('[main] Mode pemeliharaan NONAKTIF.');
      }
    } on Exception catch (e, st) {
      Log.error(
        '[main] ❌ Gagal memeriksa status pemeliharaan. Menampilkan halaman fallback.',
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
            maintenanceInfo: 'Gagal terhubung ke server. Pastikan koneksi Anda stabil dan coba lagi.',
            onRefresh: () => Log.info('[Maintenance] Pengguna harus memulai ulang aplikasi untuk refresh.'),
            onExit: SystemNavigator.pop,
          ),
        ),
      );
      return; // Hentikan eksekusi
    }
  } else {
    // Jika tidak ada internet, lewati pengecekan dan jalankan dari cache
    Log.warning('[main] ❗️ Tidak ada koneksi internet. Aplikasi akan berjalan dalam mode offline.');
  }

  // --- Aplikasi Normal Berjalan Dari Sini (Baik Online maupun Offline) ---
  Log.info('[main] Melanjutkan ke aplikasi utama...');

  final prefs = await SharedPreferences.getInstance();
  // Inisialisasi servis notifikasi menggunakan factory constructor Singleton.
  await NotifikasiServis().inisialisasi(iconName: '@mipmap/launcher_icon');
  await NotifikasiServis().requestPermissions();

  runApp(AppUser(prefs: prefs));
}
