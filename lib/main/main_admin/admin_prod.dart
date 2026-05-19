// path: lib/main/main_admin/admin_prod.dart
// diubah: Memindahkan semua logika inisialisasi berat ke dalam AppAdmin.

import 'package:flutter/material.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/shared/debug/log.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode produksi.
void main() {
  // Memastikan binding Flutter siap. Ini wajib ada sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  Log.info('[main-prod] Memulai aplikasi. Menyerahkan kendali ke AppAdmin...');

  // Langsung jalankan AppAdmin. Semua inisialisasi akan ditangani di sana
  // sambil menampilkan splash screen yang sesuai.
  runApp(const AppAdmin());
}
