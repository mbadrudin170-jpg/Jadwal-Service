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
/// serta menginisialisasi layanan notifikasi sebelum menjalankan [AdminApp].
void main() async {
  // ditambah: Memastikan binding Flutter siap sebelum kode asynchronous dijalankan.
  WidgetsFlutterBinding.ensureInitialized();
  // ditambah: Inisialisasi Firebase untuk platform saat ini dengan opsi produksi.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ditambah: Inisialisasi servis notifikasi.
  final notifikasiServis = NotifikasiServis();
  await notifikasiServis.inisialisasi();
  // ditambah: Meminta izin notifikasi kepada pengguna.
  await notifikasiServis.requestPermissions(); 

  // ditambah: Menjalankan aplikasi admin.
  runApp(const AdminApp());
}

/// Widget root untuk aplikasi admin.
///
/// Mengatur [MaterialApp] dengan tema dan halaman utama [MyApp].
class AdminApp extends StatelessWidget {
  /// Membuat instance [AdminApp].
  const AdminApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Wifi Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // diubah: Halaman utama sekarang adalah MyApp dari app_admin.dart
      home: const MyApp(),
    );
  }
}
