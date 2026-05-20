// path: lib/main/main_user/user_dev.dart
// diubah: Memindahkan semua logika inisialisasi berat ke dalam AppUser.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/app_user.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_dev.dart';

void main() async {
  // Memastikan binding Flutter siap. Ini wajib ada sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Log.info('[main-dev] Memulai aplikasi user. Menyerahkan kendali ke AppUser...');

  // Langsung jalankan AppUser. Semua inisialisasi akan ditangani di sana
  // sambil menampilkan splash screen yang sesuai.
  runApp(const AppUser());
}
