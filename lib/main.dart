import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wifi/firebase_options_switcher.dart';

void main() async {
  // ditambah: Pastikan Flutter Engine sudah siap.
  WidgetsFlutterBinding.ensureInitialized();

  // ditambah: Inisialisasi Firebase menggunakan 'switcher' yang telah kita buat.
  await Firebase.initializeApp(
    options: getFirebaseOptions(),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Aplikasi WiFi Admin'),
        ),
      ),
    );
  }
}
