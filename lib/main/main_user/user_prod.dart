// path: lib/main/main_user/user_prod.dart
// diubah: Memindahkan semua logika inisialisasi berat ke dalam AppUser.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/app_user.dart';

void main() {
  // Memastikan binding Flutter siap. Ini wajib ada sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  Log.info('[main-prod] Memulai aplikasi user. Menyerahkan kendali ke AppUser...');

  // Langsung jalankan AppUser. Semua inisialisasi akan ditangani di sana
  // sambil menampilkan splash screen yang sesuai.
  runApp(const AppUser());
}
