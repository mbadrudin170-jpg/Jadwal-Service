// path: lib/user/app_user.dart
import 'package:flutter/material.dart';
import 'package:wifi/user/page/splash_screen.dart';

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wifi User',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // diubah: Halaman utama sekarang adalah SplashScreen, yang akan menangani navigasi.
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
