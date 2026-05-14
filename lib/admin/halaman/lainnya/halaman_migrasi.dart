// path: lib/admin/halaman/lainnya/halaman_migrasi.dart
import 'package:flutter/material.dart';

/// Halaman untuk alat migrasi data.
///
/// Halaman ini akan berisi alat untuk membantu proses migrasi data,
/// seperti dari database lama ke database baru atau antar format data.
/// Saat ini, halaman ini masih dalam tahap pengembangan.
class HalamanMigrasi extends StatelessWidget {
  /// Membuat instance dari [HalamanMigrasi].
  const HalamanMigrasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alat Migrasi Data'),
      ),
      body: const Center(
        child: Text('Halaman ini dalam pengembangan.'),
      ),
    );
  }
}
