// path: lib/main/main_admin/admin_dev.dart
// Fitur: Entry point untuk aplikasi admin (Development)
// Tujuan: Menginisialisasi Firebase dan layanan lainnya sebelum menjalankan aplikasi admin.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode pengembangan.
///
/// Menginisialisasi [WidgetsFlutterBinding] dan Firebase dengan opsi pengembangan,
/// serta menginisialisasi layanan notifikasi sebelum menjalankan [AppAdmin].
void main() async {
  // ditambah: Memastikan binding Flutter siap sebelum kode asynchronous dijalankan.
  WidgetsFlutterBinding.ensureInitialized();
  // ditambah: Inisialisasi Firebase untuk platform saat ini dengan opsi pengembangan.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ditambah: Inisialisasi servis notifikasi.
  final notifikasiServis = NotifikasiServis();
  await notifikasiServis.inisialisasi();
  // ditambah: Meminta izin notifikasi kepada pengguna.
  await notifikasiServis.requestPermissions();

  // diubah: Menjalankan langsung AppAdmin sebagai root widget, bukan AdminDev.
  runApp(const AppAdmin());
}
