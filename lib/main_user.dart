// path: lib/main_user.dart
// diubah: Menggunakan UserApp dari app_user.dart untuk menampilkan SplashScreen terlebih dahulu.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wifi/user/app_user.dart'; // diubah: Impor app_user.dart
import 'package:wifi/user/firebase_option/firebase_option_user_dev.dart';

// This is the entry point for the User version of the app.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // diubah: Menjalankan UserApp yang sekarang akan menampilkan SplashScreen.
  runApp(const UserApp());
}

// diubah: Definisi kelas UserApp telah dipindahkan ke lib/user/app_user.dart
