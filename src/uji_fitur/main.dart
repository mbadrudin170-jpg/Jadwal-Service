// path: src/uji_fitur/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'halaman_uji_coba.dart';

void main() {
  runApp(const UjiFiturApp());
}

class UjiFiturApp extends StatelessWidget {
  const UjiFiturApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Uji Fitur',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UjiFiturHomePage(),
    );
  }
}

class UjiFiturHomePage extends StatefulWidget {
  const UjiFiturHomePage({super.key});

  @override
  State<UjiFiturHomePage> createState() => _UjiFiturHomePageState();
}

class _UjiFiturHomePageState extends State<UjiFiturHomePage> {
  @override
  void initState() {
    super.initState();
    Log.info('Halaman Uji Fitur dimulai');
  }

  @override
  void dispose() {
    Log.info('Halaman Uji Fitur ditutup');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uji Fitur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selamat datang di Halaman Uji Fitur!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (final context) => const StatistikUjiCobaPage(),
                    ),
                  ),
                );
              },
              child: const Text('Buka Halaman Statistik'),
            ),
          ],
        ),
      ),
    );
  }
}
