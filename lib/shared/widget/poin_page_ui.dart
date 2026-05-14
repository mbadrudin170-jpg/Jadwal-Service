// path: lib/shared/widget/poin_page_ui.dart
// ditambah: UI yang dapat digunakan kembali untuk halaman poin.

import 'package:flutter/material.dart';
import 'package:wifi/shared/widget/card/point_card.dart';

/// Menu yang tersedia di halaman poin.
enum MenuPoin {
  /// Menu penukaran hadiah.
  penukaran,

  /// Menu riwayat poin.
  riwayat,
}

/// UI halaman poin yang dapat digunakan kembali.
///
/// Menampilkan header total poin, kontrol tersegmentasi untuk memilih
/// antara menu Penukaran dan Riwayat, serta [contentView] yang dinamis.
class PoinPageUi extends StatelessWidget {
  /// Judul yang ditampilkan di AppBar.
  final Widget appBarTitle;

  /// Total poin yang dimiliki pengguna.
  final int totalPoin;

  /// Menu yang sedang dipilih.
  final MenuPoin menuPilihan;

  /// Callback saat pilihan menu berubah.
  final ValueChanged<Set<MenuPoin>> onSelectionChanged;

  /// Konten utama yang ditampilkan di bawah kontrol tersegmentasi.
  final Widget contentView;

  /// Membuat halaman [PoinPageUi].
  ///
  /// Semua parameter wajib diisi.
  const PoinPageUi({
    super.key,
    required this.appBarTitle,
    required this.totalPoin,
    required this.menuPilihan,
    required this.onSelectionChanged,
    required this.contentView,
  });

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildInfoPoinHeader(context),
          _buildSegmentedControl(),
          Expanded(child: contentView),
        ],
      ),
    );
  }

  Widget _buildInfoPoinHeader(final BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Theme.of(context).primaryColor.withAlpha(15),
      child: Center(
        child: TotalPointCard(
          points: totalPoin,
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<MenuPoin>(
        segments: const [
          ButtonSegment<MenuPoin>(
            value: MenuPoin.penukaran,
            label: Text('Tukar Hadiah'),
            icon: Icon(Icons.card_giftcard),
          ),
          ButtonSegment<MenuPoin>(
            value: MenuPoin.riwayat,
            label: Text('Riwayat Poin'),
            icon: Icon(Icons.history),
          ),
        ],
        selected: {menuPilihan},
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}
