// path: lib/main/main_admin/admin_prod.dart
// diubah: Memindahkan inisialisasi Firebase ke main() untuk mencegah duplikasi.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';
import 'package:wifi/shared/debug/log.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode produksi.
void main() async {
  // Memastikan binding Flutter siap. Ini wajib ada sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase HANYA SEKALI di sini untuk mencegah error duplikasi.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Log.info(
      '[main-prod] Memulai aplikasi admin. Menyerahkan kendali ke AppAdmin...');

  // Langsung jalankan AppAdmin. Semua inisialisasi sekunder akan ditangani di sana.
  runApp(const AppAdmin());
}
