// path: lib/shared/widget/page/poin_page_ui.dart
// DIUBAH: Memindahkan bottomWidget ke properti bottomNavigationBar pada Scaffold untuk memastikan iklan selalu terlihat dan tidak tertimpa oleh konten yang di-scroll.

import 'package:flutter/material.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/widget/card/point_card.dart';

/// Menu yang tersedia di halaman poin.
enum MenuPoin {
  /// Menu penukaran hadiah.
  penukaran,

  /// Menu riwayat poin.
  riwayat,
}

/// UI halaman poin yang dapat digunakan kembali.
class PoinPageUi extends StatelessWidget {
  final Widget appBarTitle;
  final int totalPoin;
  final MenuPoin menuPilihan;
  final ValueChanged<Set<MenuPoin>> onSelectionChanged;
  final Widget contentView;
  final Widget? bottomWidget;

  const PoinPageUi({
    super.key,
    required this.appBarTitle,
    required this.totalPoin,
    required this.menuPilihan,
    required this.onSelectionChanged,
    required this.contentView,
    this.bottomWidget,
  });

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildInfoPoinHeader(context),
          _buildSegmentedControl(context),
          Expanded(child: contentView),
        ],
      ),
      // DIUBAH: Widget sekarang ditempatkan di sini.
      bottomNavigationBar: bottomWidget,
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

  Widget _buildSegmentedControl(final BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    Widget buildSegment(
        final MenuPoin menu, final String label, final IconData icon) {
      final bool isSelected = menuPilihan == menu;
      return Expanded(
        child: InkWell(
          onTap: () => onSelectionChanged({menu}),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          splashColor: primaryColor.withAlpha(26),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected ? Colors.white : theme.colorScheme.onSurface,
                ),
gapH8,                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(102),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: menuPilihan == MenuPoin.penukaran
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withAlpha(204)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              buildSegment(MenuPoin.penukaran, 'Tukar Hadiah', TIcons.gift),
              buildSegment(MenuPoin.riwayat, 'Riwayat Poin', TIcons.history),
            ],
          ),
        ],
      ),
    );
  }
}
