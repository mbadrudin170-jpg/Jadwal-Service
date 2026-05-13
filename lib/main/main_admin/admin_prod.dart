// path: lib/main_admin.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

// This is the entry point for the Admin version of the app.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Menggunakan DefaultFirebaseOptions dari file konfigurasi admin
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Inisialisasi servis notifikasi lokal
  final notifikasiServis = NotifikasiServis();
  await notifikasiServis.inisialisasi();
  await notifikasiServis.requestPermissions(); // Meminta izin

  // 2. Inisialisasi servis FCM dan berikan notifikasiServis padanya  await fcmServis.inisialisasi();

  runApp(const AdminApp());
}

// ditambah: Mengembalikan kelas AdminApp yang hilang
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wifi Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyApp(), // Memanggil MyApp dari app_admin.dart
    );
  }
}
