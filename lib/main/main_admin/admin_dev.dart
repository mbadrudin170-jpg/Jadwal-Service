// path: lib/main/main_admin/admin_dev.dart
// diubah: Mengurutkan impor dan mendaftarkan adapter Hive.
// diubah: Menyuntikkan NotifikasiServis ke AppAdmin untuk menghindari inisialisasi ganda.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode pengembangan.
void main() async {
  Log.info('Memulai aplikasi admin mode pengembangan');
  // Memastikan binding Flutter siap.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inisialisasi Firebase.
    Log.info('Menginisialisasi Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Log.info('Firebase berhasil diinisialisasi');

    // Inisialisasi servis notifikasi menggunakan factory constructor Singleton.
    Log.info('Menginisialisasi layanan notifikasi');
    await NotifikasiServis().inisialisasi(iconName: '@mipmap/launcher_icon');
    await NotifikasiServis().requestPermissions();
    Log.info('Layanan notifikasi siap');

    // Menjalankan AppAdmin.
    Log.info('Menjalankan AppAdmin');
    runApp(const AppAdmin());
  } on Exception catch (e, st) {
    Log.error(
      'Gagal menginisialisasi aplikasi admin (dev)',
      e: e,
      st: st,
    );
    // SnackBar tidak tersedia karena BuildContext belum ada di main().
  }
}
