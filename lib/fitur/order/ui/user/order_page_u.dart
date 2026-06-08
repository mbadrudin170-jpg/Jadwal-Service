// path: lib/fitur/order/ui/user/order_page_u.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderPageU extends ConsumerWidget {
  const OrderPageU({super.key});

bool? _tombolAktif= false

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('[Pembangunan UI] ✅ Membangun UI untuk UserOrderPage, menampilkan daftar pesanan statis.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Column(
        children: [
          const Row(
            children: [],
          ),
          ListView(
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
        ],
      ),
    );
  }
  // Widget _listTombolFilter(){
  //   return const SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: []

  //   );
  // }

  Widget _tomboltipe() {
    return InkWell(
      onTap: () {},
      child: const Row(
        children: [Text('4'), Text('data dumy')],
      ),
    );
  }
}
