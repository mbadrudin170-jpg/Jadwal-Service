// path: lib/user/page/pesan_page.dart
import 'dart:developer';
import 'package:flutter/material.dart';

/// Halaman untuk menampilkan daftar pesan.
///
/// Saat ini, halaman ini menampilkan daftar pesan statis.
class PesanPage extends StatelessWidget {
  /// Membuat instance dari [PesanPage].
  const PesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    log(
      '[Pembangunan UI] ✅ Membangun UI untuk PesanPage, menampilkan daftar pesan statis.',
      name: 'pesan_page.dart',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(
              child: Text('A'),
            ),
            title: Text('Admin'),
            subtitle: Text('Selamat datang di aplikasi kami!'),
            trailing: Text('10:00'),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text('S'),
            ),
            title: Text('Support'),
            subtitle: Text('Ada yang bisa kami bantu?'),
            trailing: Text('11:30'),
          ),
        ],
      ),
    );
  }
}
