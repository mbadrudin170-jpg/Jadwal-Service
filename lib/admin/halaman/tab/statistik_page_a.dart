// path : lib/admin/halaman/tab/statistik_page_a.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Halaman untuk menampilkan statistik aplikasi.
class StatistikPageA extends StatefulWidget {
  /// Halaman untuk menampilkan statistik aplikasi.
  const StatistikPageA({super.key});

  @override
  State<StatistikPageA> createState() => _StatistikPageAState();
}

class _StatistikPageAState extends State<StatistikPageA> {
  @override
  void initState() {
    super.initState();
    // Log saat halaman pertama kali dimuat.
    Log.info('StatistikPageA initState');
  }

  @override
  void dispose() {
    // Log saat halaman ditutup.
    Log.info('StatistikPageA dispose');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    // Log saat widget di-build.
    Log.info('Membangun tampilan StatistikPageA');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      body: const Center(
        child: Text('Konten Statistik Akan Tampil di Sini'),
      ),
    );
  }
}
