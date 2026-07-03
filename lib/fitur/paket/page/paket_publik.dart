// path: lib/fitur/paket/page/paket_publik.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';

class PaketPublik extends ConsumerWidget {
  const PaketPublik({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paketAsync = ref.watch(paketProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Publik')),
      body: paketAsync.when(
        data: (data) {
          final daftarPaket = data.daftarPaket;
          return const Column(children: [Text('data')]);
        },
        error: (error, stackTrace) => Text('$error'),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
