
// path: lib/main/main_admin/admin_dev.dart
// diubah: Mengurutkan impor dan mendaftarkan adapter Hive.
// diubah: Menyuntikkan NotifikasiServis ke AppAdmin untuk menghindari inisialisasi ganda.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode pengembangan.
void main() async {
  // Memastikan binding Flutter siap.
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi servis notifikasi menggunakan factory constructor Singleton.
  await NotifikasiServis().inisialisasi(iconName: '@mipmap/launcher_icon');
  await NotifikasiServis().requestPermissions();

  // Menjalankan AppAdmin.
  runApp(const AppAdmin());
}
