// path: lib/main/main_admin/admin_dev.dart
// diubah: Memindahkan semua logika inisialisasi berat ke dalam AppAdmin.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/shared/debug/log.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode pengembangan.
void main() async {
  // Memastikan binding Flutter siap. Ini wajib ada sebelum runApp().
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Log.info(
      '[main-dev] Memulai aplikasi admin. Menyerahkan kendali ke AppAdmin...');

  runApp(const AppAdmin());
}
