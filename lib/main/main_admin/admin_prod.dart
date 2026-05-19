// path: lib/main/main_admin/admin_prod.dart
// diubah: Memindahkan inisialisasi Firebase ke main() untuk mencegah duplikasi.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/shared/debug/log.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode produksi.
void main() async {
  // Memastikan binding Flutter siap. Ini wajib ada sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase HANYA SEKALI di sini untuk mencegah error duplikasi.
  try {
    // `initializeApp` akan menggunakan `DefaultFirebaseOptions.currentPlatform`
    // yang secara otomatis disediakan oleh konfigurasi build flavor FlutterFire.
    await Firebase.initializeApp();
    Log.info('[main-prod] Firebase berhasil diinisialisasi.');
  } on FirebaseException catch (e, st) {
    // Mencatat error jika inisialisasi gagal, tetapi tetap melanjutkan
    // agar aplikasi bisa berjalan dalam mode offline.
    Log.error('[main-prod] Gagal menginisialisasi Firebase.', e: e, st: st);
  }

  Log.info('[main-prod] Memulai aplikasi. Menyerahkan kendali ke AppAdmin...');

  // Langsung jalankan AppAdmin. Semua inisialisasi sekunder akan ditangani di sana.
  runApp(const AppAdmin());
}
