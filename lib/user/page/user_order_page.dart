// path: lib/user/page/user_order_page.dart
import 'dart:developer';
import 'package:flutter/material.dart';

/// Halaman untuk menampilkan daftar pesanan pengguna.
class UserOrderPage extends StatelessWidget {
  /// Membuat instance dari [UserOrderPage].
  const UserOrderPage({super.key});

  @override
  Widget build(final BuildContext context) {
    log(
      '[Pembangunan UI] ✅ Membangun UI untuk UserOrderPage, menampilkan daftar pesanan statis.',
      name: 'user_order_page.dart',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Paket Internet 10GB'),
            subtitle: Text('Status: Selesai'),
            trailing: Text('Rp 50.000'),
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Paket Internet 25GB'),
            subtitle: Text('Status: Dalam Proses'),
            trailing: Text('Rp 100.000'),
          ),
        ],
      ),
    );
  }
}
