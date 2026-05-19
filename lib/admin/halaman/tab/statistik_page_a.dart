// path: lib/admin/halaman/tab/statistik_page_a.dart
// diubah: Memperbaiki semua error dan warning dari analyzer.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/debug/log.dart';

/// Halaman untuk menampilkan statistik aplikasi dalam bentuk dasbor.
class StatistikPageA extends StatefulWidget {
  /// Halaman untuk menampilkan statistik aplikasi.
  const StatistikPageA({super.key});

  @override
  State<StatistikPageA> createState() => _StatistikPageAState();
}

class _StatistikPageAState extends State<StatistikPageA> {
  // Data dummy untuk layout
  final int _totalPelanggan = 125;
  final int _langgananAktif = 85;
  final double _pendapatanBulanIni = 5575000;
  final int _feedbackBaru = 3;

  final List<Map<String, dynamic>> _paketTerlaris = [
    {'nama': 'Paket Kencang 30 Hari', 'terjual': 58},
    {'nama': 'Paket Hemat Seminggu', 'terjual': 32},
    {'nama': 'Paket Malam Full Speed', 'terjual': 15},
    {'nama': 'Paket Gaming Pro', 'terjual': 8},
  ];

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Statistik'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Kartu Ringkasan ---
            Text(
              'Ringkasan Cepat',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                _buildStatCard(
                  title: 'Total Pelanggan',
                  value: _totalPelanggan.toString(),
                  icon: Icons.people_outline,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Langganan Aktif',
                  value: _langgananAktif.toString(),
                  icon: Icons.wifi_tethering_rounded,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: 'Pendapatan Bulan Ini',
                  value: NumberFormat.compactCurrency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                  ).format(_pendapatanBulanIni),
                  icon: Icons.monetization_on_outlined,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Feedback Baru',
                  value: _feedbackBaru.toString(),
                  icon: Icons.feedback_outlined,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Bagian Grafik ---
            Text(
              'Analisis Pertumbuhan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'Placeholder untuk Grafik\n(Akan diimplementasikan dengan fl_chart)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Bagian Daftar Peringkat ---
            Text(
              'Paket Terlaris',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: List.generate(_paketTerlaris.length, (final index) {
                  final item = _paketTerlaris[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('#${index + 1}'),
                    ),
                    title: Text(item['nama']
                        as String), // diperbaiki: Tipe data diperjelas
                    trailing: Text(
                      '${item['terjual']} terjual',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pembantu untuk membangun kartu statistik.
  Widget _buildStatCard({
    required final String title,
    required final String value,
    required final IconData icon,
    required final Color color,
  }) {
    return LayoutBuilder(builder: (final context, final constraints) {
      final cardWidth = (constraints.maxWidth > 400)
          ? (constraints.maxWidth / 2 - 12)
          : double.infinity;
      return SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      color.withAlpha(25), // diperbaiki: Mengganti withOpacity
                  radius: 20,
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
