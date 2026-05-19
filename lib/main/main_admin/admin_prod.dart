// path: lib/main/main_admin/admin_prod.dart
// Fitur: Entry point untuk aplikasi admin (Production)
// Tujuan: Menginisialisasi Firebase dan layanan lainnya sebelum menjalankan aplikasi admin.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode produksi.
///
/// Menginisialisasi [WidgetsFlutterBinding] dan Firebase dengan opsi produksi,
/// serta menginisialisasi layanan notifikasi sebelum menjalankan [AppAdmin].
void main() async {
  // ditambah: Memastikan binding Flutter siap sebelum kode asynchronous dijalankan.
  WidgetsFlutterBinding.ensureInitialized();
  // ditambah: Inisialisasi Firebase untuk platform saat ini dengan opsi produksi.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi servis notifikasi menggunakan factory constructor Singleton.
  await NotifikasiServis().inisialisasi(iconName: '@mipmap/launcher_icon');
  // ditambah: Meminta izin notifikasi kepada pengguna.
  await NotifikasiServis().requestPermissions();

  // diubah: Menjalankan AppAdmin.
  runApp(const AppAdmin());
}
