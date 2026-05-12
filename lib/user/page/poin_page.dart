// path: lib/page/poin_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PoinPage extends StatelessWidget {
  const PoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan DefaultTabController untuk mengelola state tab
    return DefaultTabController(
      length: 2, // Jumlah tab: Riwayat dan Tukar Poin
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Poin & Hadiah'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Riwayat Poin'),
              Tab(text: 'Tukar Poin'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header Poin ditampilkan di atas tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildPoinHeader(context, 1250),
            ),
            // Expanded akan mengisi sisa ruang yang tersedia
            Expanded(
              child: TabBarView(
                children: [
                  // Konten untuk Tab "Riwayat Poin"
                  _buildRiwayatPoinListView(context),
                  // Konten untuk Tab "Tukar Poin"
                  _buildTukarPoinListView(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk header total poin
  Widget _buildPoinHeader(BuildContext context, int totalPoin) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Total Poin Anda',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              NumberFormat.decimalPattern('id_ID').format(totalPoin),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tukarkan poin dengan berbagai hadiah menarik!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan daftar riwayat perolehan poin
  Widget _buildRiwayatPoinListView(BuildContext context) {
    final List<Map<String, dynamic>> riwayatList = [
      {
        'namaPaket': 'Paket Gamer',
        'tanggal': DateTime(2023, 10, 26),
        'poin': 150
      },
      {
        'namaPaket': 'Paket Keluarga',
        'tanggal': DateTime(2023, 9, 22),
        'poin': 100
      },
      {
        'namaPaket': 'Paket Streaming',
        'tanggal': DateTime(2023, 8, 15),
        'poin': 120
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: riwayatList.length,
      separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final riwayat = riwayatList[index];
        return ListTile(
          leading: const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          title: Text('Pembelian ${riwayat['namaPaket']}'),
          subtitle: Text(
            DateFormat('d MMMM yyyy', 'id_ID').format(riwayat['tanggal']),
          ),
          trailing: Text(
            '+${riwayat['poin']} Poin',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  // Widget untuk menampilkan daftar hadiah yang bisa ditukar
  Widget _buildTukarPoinListView(BuildContext context) {
    final List<Map<String, dynamic>> daftarHadiah = [
      {'nama': 'Voucher Diskon 50%', 'poin': 500, 'icon': Icons.local_offer},
      {'nama': 'Gratis Langganan 1 Minggu', 'poin': 1000, 'icon': Icons.wifi},
      {'nama': 'Merchandise Eksklusif', 'poin': 2500, 'icon': Icons.card_giftcard},
      {'nama': 'Saldo E-Wallet Rp 25.000', 'poin': 3000, 'icon': Icons.account_balance_wallet},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: daftarHadiah.length,
      itemBuilder: (context, index) {
        final hadiah = daftarHadiah[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: Icon(hadiah['icon'], color: Theme.of(context).primaryColor, size: 40),
            title: Text(hadiah['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${NumberFormat.decimalPattern('id_ID').format(hadiah['poin'])} Poin', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            trailing: ElevatedButton(
              onPressed: () {
                // Nanti logika untuk menukar poin akan ditambahkan di sini
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur penukaran untuk ${hadiah['nama']} belum tersedia.')),
                );
              },
              child: const Text('Tukar'),
            ),
          ),
        );
      },
    );
  }
}
