// path: lib/admin/halaman/tab/statistik_page_a.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/fitur/feedback/page/feedback_page.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart';
import 'package:wifi/fitur/paket/widget/nama_paket_widget.dart';
import 'package:wifi/fitur/pelanggan/page/admin/pelanggan_page.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart';
import 'package:wifi/fitur/transaksi/page/transaksi_a.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

enum ChartRange { harian, mingguan, bulanan }

class StatistikPageA extends ConsumerStatefulWidget {
  const StatistikPageA({super.key});

  @override
  ConsumerState<StatistikPageA> createState() => _StatistikPageAState();
}

class _StatistikPageAState extends ConsumerState<StatistikPageA> {
  ChartRange _selectedRange = ChartRange.bulanan;

  List<FlSpot> _buatSpots(List<double> data) {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  List<FlSpot> _getCurrentSpots(TransaksiState data) {
    switch (_selectedRange) {
      case ChartRange.harian:
        return _buatSpots(data.pendapatanHarian);
      case ChartRange.mingguan:
        return _buatSpots(data.pendapatanMingguan);
      case ChartRange.bulanan:
        return _buatSpots(data.pendapatanBulanan);
    }
  }

  double _getMaxX(TransaksiState data) {
    switch (_selectedRange) {
      case ChartRange.harian:
        return (data.pendapatanHarian.length - 1).toDouble();
      case ChartRange.mingguan:
        return (data.pendapatanMingguan.length - 1).toDouble();
      case ChartRange.bulanan:
        return (data.pendapatanBulanan.length - 1).toDouble();
    }
  }

  double _getMaxY(TransaksiState data) {
    final spots = _getCurrentSpots(data);
    if (spots.isEmpty) return 1.0;
    final maxValue = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).clamp(1.0, double.infinity);
  }

  double _getMinY(TransaksiState data) {
    final spots = _getCurrentSpots(data);
    if (spots.isEmpty) return 0.0;
    final minValue = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    return minValue < 0 ? minValue * 1.2 : 0.0;
  }

  Future<void> _invalidateProvider() {
    ref
      ..invalidate(pelangganProvider)
      ..invalidate(pelangganAktifProvider)
      ..invalidate(feedbackProvider);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedback = ref.watch(feedbackProvider);
    final transaksi = ref.watch(transaksiProvider);
    final pelangganAktif = ref.watch(pelangganAktifProvider);
    final pelanggan = ref.watch(pelangganProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dasbor Statistik')),
      body: RefreshIndicator(
        onRefresh: _invalidateProvider,
        child: transaksi.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
          data: (data) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Cepat',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH12,
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 12.0) / 2;
                      return Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: [
                          _buildStatCardWrapper(
                            width: cardWidth,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const PelangganPage(),
                              ),
                            ),
                            title: 'Total Pelanggan',
                            value:
                                pelanggan.value?.jumlahPelanggan.toString() ??
                                '0',
                            icon: TIcons.customers,
                            color: Colors.blue,
                          ),
                          _buildStatCardWrapper(
                            width: cardWidth,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const PelangganAktifPage(),
                              ),
                            ),
                            title: 'Pelanggan Aktif',
                            value:
                                pelangganAktif.value?.jumlahPelangganAktif
                                    .toString() ??
                                '0',
                            icon: TIcons.wifi,
                            color: Colors.green,
                          ),
                          _buildStatCardWrapper(
                            width: cardWidth,

                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const TransaksiA(),
                              ),
                            ),
                            title: 'Pendapatan Bulan Ini',
                            value: FormatUang.formatMataUang(
                              data.pendapatanBulanIni,
                            ),
                            icon: TIcons.money,
                            color: data.pendapatanBulanIni < 0
                                ? Colors.red
                                : Colors.orange,
                          ),
                          _buildStatCardWrapper(
                            width: cardWidth,

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const FeedbackPage(),
                                ),
                              );
                            },
                            title: 'Total Feedback',
                            value:
                                feedback.value?.jumlahFeedback.toString() ??
                                '0',
                            icon: TIcons.feedback,
                            color: Colors.purple,
                          ),
                        ],
                      );
                    },
                  ),
                  gapH24,
                  Text(
                    'Analisis Pertumbuhan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH12,
                  _buildChartToggleButtons(theme),
                  gapH16,
                  _buildLineChartCard(data),
                  gapH24,
                  Text(
                    'Paket Terlaris',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH12,
                  _buildPaketTerlaris(theme, data.paketTerlaris),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCardWrapper({
    required VoidCallback onTap,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width, // 1. Tambahkan parameter width di sini
  }) {
    return SizedBox(
      width: width, // 2. Gunakan width hasil kalkulasi dinamis
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(25),
                  radius: 16,
                  child: Icon(icon, color: color, size: 20),
                ),
                gapH8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartToggleButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          isSelected: [
            _selectedRange == ChartRange.harian,
            _selectedRange == ChartRange.mingguan,
            _selectedRange == ChartRange.bulanan,
          ],
          onPressed: (index) =>
              setState(() => _selectedRange = ChartRange.values[index]),
          borderRadius: BorderRadius.circular(8),
          selectedBorderColor: theme.colorScheme.primary,
          selectedColor: Colors.white,
          fillColor: theme.colorScheme.primary,
          color: theme.colorScheme.primary,
          constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
          children: const [Text('Harian'), Text('Mingguan'), Text('Bulanan')],
        ),
      ],
    );
  }

  Widget _buildLineChartCard(TransaksiState data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 250,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: LineChart(_mainLineChartData(data)),
      ),
    );
  }

  Widget _buildPaketTerlaris(ThemeData theme, List<PaketTerlarisMentah> paket) {
    if (paket.isEmpty) {
      return const Card(
        elevation: 2,
        child: ListTile(title: Text('Belum ada data penjualan paket.')),
      );
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: List.generate(paket.length, (index) {
          final item = paket[index];
          return ListTile(
            leading: CircleAvatar(child: Text('#${index + 1}')),
            title: NamaPaketWidget(idPaket: item.id),
            trailing: Text(
              '${item.totalTerjual} terjual',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ),
    );
  }

  LineChartData _mainLineChartData(TransaksiState data) {
    final spots = _getCurrentSpots(data);
    final maxX = _getMaxX(data);
    final maxY = _getMaxY(data);
    final minY = _getMinY(data);

    if (spots.isEmpty) {
      return LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxY - minY) / 4,
              getTitlesWidget: ((value, meta) =>
                  _leftTitleWidgets(value, meta, maxY)),
              reservedSize: 45,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 1,
        lineBarsData: [],
      );
    }
    return LineChartData(
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        horizontalInterval: (maxY - minY) / 4,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) =>
                _bottomTitleWidgets(value, meta, data),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, meta) =>
                _leftTitleWidgets(value, meta, maxY),
            reservedSize: 45,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(80),
              Theme.of(context).colorScheme.primary,
            ],
          ),
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withAlpha(20),
                Theme.of(context).colorScheme.primary.withAlpha(50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomTitleWidgets(
    double value,
    TitleMeta meta,
    TransaksiState data,
  ) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    final index = value.toInt();

    // Validasi indeks
    if (index < 0) return const SizedBox.shrink();

    var label = '';

    switch (_selectedRange) {
      case ChartRange.harian:
        if (index < data.pendapatanHarian.length) {
          final now = DateTime.now();
          final daysAgo = data.pendapatanHarian.length - 1 - index;
          final date = now.subtract(Duration(days: daysAgo));
          label = DateFormat('E', 'id_ID').format(date); // Sen, Sel, Rab, ...
        }
        break;

      case ChartRange.mingguan:
        if (index < data.pendapatanMingguan.length) {
          final weeksAgo = data.pendapatanMingguan.length - 1 - index;
          label = 'M-${weeksAgo + 1}';
        }
        break;

      case ChartRange.bulanan:
        if (index < data.pendapatanBulanan.length) {
          final monthsAgo = data.pendapatanBulanan.length - 1 - index;
          final now = DateTime.now();
          final date = DateTime(now.year, now.month - monthsAgo);
          // Pastikan bulan dalam rentang 1-12
          final monthIndex = ((date.month - 1) % 12).toInt();
          final bulan = [
            'JAN',
            'FEB',
            'MAR',
            'APR',
            'MEI',
            'JUN',
            'JUL',
            'AGT',
            'SEP',
            'OKT',
            'NOV',
            'DES',
          ];
          label = bulan[monthIndex];
        }
        break;
    }

    // Jika label kosong, kembalikan SizedBox.shrink() agar tidak tampil placeholder
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(label, style: style),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta, double maxY) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    String text;
    if (maxY >= 100) {
      text = '${(value / 1000).toStringAsFixed(1)}M';
    } else if (maxY >= 1) {
      text = '${value.toStringAsFixed(1)}Jt';
    } else {
      text = '${(value * 1000).toStringAsFixed(1)}K';
    }
    return SideTitleWidget(
      meta: meta,
      space: 0,
      fitInside: const SideTitleFitInsideData(
        enabled: true,
        axisPosition: 0,
        parentAxisSize: 0,
        distanceFromEdge: 0,
      ),
      child: SizedBox(
        width: 45,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: style,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.right,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
    );
  }
}
