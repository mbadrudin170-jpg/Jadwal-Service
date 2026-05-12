// path: lib/main_admin.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wifi/admin/halaman/dashboard_page.dart';
// Mengubah import untuk menggunakan file konfigurasi khusus admin
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';

// This is the entry point for the Admin version of the app.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Menggunakan DefaultFirebaseOptions dari file konfigurasi admin
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

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
      home: const AdminDashboardPage(),
    );
  }
}
