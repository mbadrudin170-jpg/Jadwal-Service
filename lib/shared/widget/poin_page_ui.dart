// path: lib/shared/widget/poin_page_ui.dart
// ditambah: UI yang dapat digunakan kembali untuk halaman poin.

import 'package:flutter/material.dart';
import 'package:wifi/shared/widget/card/point_card.dart';

enum MenuPoin { penukaran, riwayat }

class PoinPageUi extends StatelessWidget {
  final Widget appBarTitle;
  final int totalPoin;
  final MenuPoin menuPilihan;
  final ValueChanged<Set<MenuPoin>> onSelectionChanged;
  final Widget contentView;

  const PoinPageUi({
    super.key,
    required this.appBarTitle,
    required this.totalPoin,
    required this.menuPilihan,
    required this.onSelectionChanged,
    required this.contentView,
  });

  @override
  Widget build(BuildContext context) {
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

  Widget _buildInfoPoinHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Theme.of(context).primaryColor.withAlpha(15),
      child: Center(
        child: TotalPointCard(
          points: totalPoin,
          icon: Icons.stars_rounded,
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
