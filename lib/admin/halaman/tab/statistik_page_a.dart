// path: lib/admin/halaman/tab/statistik_page_a.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/lainnya/customer.dart';
import 'package:wifi/admin/halaman/tab/active_customer_tab.dart';
import 'package:wifi/admin/halaman/tab/transaction_page_a.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/admin/providers/statistik_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

enum ChartRange {
  harian,
  mingguan,
  bulanan,
}

class StatistikPageA extends ConsumerStatefulWidget {
  const StatistikPageA({super.key});

  @override
  ConsumerState<StatistikPageA> createState() => _StatistikPageAState();
}

class _StatistikPageAState extends ConsumerState<StatistikPageA> {
  ChartRange _selectedRange = ChartRange.bulanan;

  final List<FlSpot> _monthlySpots = [
    const FlSpot(0, 3.5),
    const FlSpot(1, 4.2),
    const FlSpot(2, 3.8),
    const FlSpot(3, 5.1),
    const FlSpot(4, 4.5),
  ];
  final List<FlSpot> _weeklySpots = [
    const FlSpot(0, 1.2),
    const FlSpot(1, 1.5),
    const FlSpot(2, 1.1),
    const FlSpot(3, 1.8),
  ];
  final List<FlSpot> _dailySpots = [
    const FlSpot(0, 0.2),
    const FlSpot(1, 0.5),
    const FlSpot(2, 0.4),
    const FlSpot(3, 0.8),
    const FlSpot(4, 0.6),
    const FlSpot(5, 1.1),
    const FlSpot(6, 1.0),
  ];

  List<FlSpot> get _currentSpots => switch (_selectedRange) {
        ChartRange.harian => _dailySpots,
        ChartRange.mingguan => _weeklySpots,
        ChartRange.bulanan => _monthlySpots,
      };

  double get _maxX => switch (_selectedRange) {
        ChartRange.harian => 6,
        ChartRange.mingguan => 3,
        ChartRange.bulanan => 4,
      };

  double get _maxY => switch (_selectedRange) {
        ChartRange.harian => 2,
        ChartRange.mingguan => 3,
        ChartRange.bulanan => 6,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statistikStateAsync = ref.watch(statistikProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Statistik'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(statistikProvider.notifier).refresh(),
        child: statistikStateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
              child: Text(
                  'Error: ${err.toString()}')), // Penanganan error sederhana
          data: (data) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Cepat',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  gapH12,
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      _buildStatCardWrapper(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CustomerPage())),
                        title: 'Total Pelanggan',
                        value: data.totalPelanggan.toString(),
                        icon: TIcons.customers,
                        color: Colors.blue,
                      ),
                      _buildStatCardWrapper(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ActiveCustomerPage())),
                        title: 'Langganan Aktif',
                        value: data.jumlahLanggananAktif.toString(),
                        icon: TIcons.wifi,
                        color: Colors.green,
                      ),
                      _buildStatCardWrapper(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TransactionPageA())),
                        title: 'Pendapatan Bulan Ini',
                        value: CurrencyFormat.formatCurrency(
                            data.pendapatanBulanIni),
                        icon: TIcons.money,
                        color: data.pendapatanBulanIni < 0
                            ? Colors.red
                            : Colors.orange,
                      ),
                      _buildStatCardWrapper(
                        onTap: () {/* Navigasi ke halaman feedback */},
                        title: 'Feedback Baru',
                        value: data.jumlahFeedbackBaru.toString(),
                        icon: TIcons.feedback,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  gapH24,
                  Text(
                    'Analisis Pertumbuhan',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  gapH12,
                  _buildChartToggleButtons(theme),
                  gapH16,
                  _buildLineChartCard(),
                  gapH24,
                  Text(
                    'Paket Terlaris',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  gapH12,
                  _buildBestSellingPackages(theme, data.bestSellingPackages),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child:
          _buildStatCard(title: title, value: value, icon: icon, color: color),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final theme = Theme.of(context);
      final cardWidth = (constraints.maxWidth > 400)
          ? (constraints.maxWidth / 2 - 12)
          : double.infinity;
      return SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(25),
                  radius: 20,
                  child: Icon(icon, color: color, size: 24),
                ),
                gapH12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis),
                      Text(value,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
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

  Widget _buildLineChartCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 250,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: LineChart(_mainLineChartData()),
      ),
    );
  }

  Widget _buildBestSellingPackages(
      ThemeData theme, List<BestSellingPackage> packages) {
    if (packages.isEmpty) {
      return const Card(
        elevation: 2,
        child: ListTile(title: Text('Belum ada data penjualan paket.')),
      );
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: List.generate(packages.length, (index) {
          final item = packages[index];
          return ListTile(
            leading: CircleAvatar(child: Text('#${index + 1}')),
            title: Text(item.package.name),
            trailing: Text('${item.totalSold} terjual',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          );
        }),
      ),
    );
  }

  LineChartData _mainLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: 1,
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
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: _bottomTitleWidgets)),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: _leftTitleWidgets,
                reservedSize: 42)),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: const Color(0xff37434d))),
      minX: 0,
      maxX: _maxX,
      minY: 0,
      maxY: _maxY,
      lineBarsData: [_mainLineBarData()],
    );
  }

  LineChartBarData _mainLineBarData() {
    return LineChartBarData(
      spots: _currentSpots,
      isCurved: true,
      gradient: LinearGradient(colors: [
        Theme.of(context).colorScheme.primary.withAlpha(80),
        Theme.of(context).colorScheme.primary
      ]),
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary.withAlpha(20),
            Theme.of(context).colorScheme.primary.withAlpha(50)
          ])),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    Widget text = const Text('', style: style);
    switch (_selectedRange) {
      case ChartRange.harian:
        text = switch (value.toInt()) {
          0 => const Text('Sen', style: style),
          1 => const Text('Sel', style: style),
          2 => const Text('Rab', style: style),
          3 => const Text('Kam', style: style),
          4 => const Text('Jum', style: style),
          5 => const Text('Sab', style: style),
          6 => const Text('Min', style: style),
          _ => const Text('', style: style)
        };
        break;
      case ChartRange.mingguan:
        text = switch (value.toInt()) {
          0 => const Text('M1', style: style),
          1 => const Text('M2', style: style),
          2 => const Text('M3', style: style),
          3 => const Text('M4', style: style),
          _ => const Text('', style: style)
        };
        break;
      case ChartRange.bulanan:
        text = switch (value.toInt()) {
          0 => const Text('JAN', style: style),
          1 => const Text('FEB', style: style),
          2 => const Text('MAR', style: style),
          3 => const Text('APR', style: style),
          4 => const Text('MEI', style: style),
          _ => const Text('', style: style)
        };
        break;
    }
    return SideTitleWidget(meta: meta, child: text);
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    String text;
    switch (_selectedRange) {
      case ChartRange.harian:
        text = (value % 1 == 0 && value != 0) ? '${value.toInt()}k' : '';
        break;
      case ChartRange.mingguan:
        text = (value % 1 == 0 && value != 0) ? '${value.toInt()}JT' : '';
        break;
      case ChartRange.bulanan:
        text = switch (value.toInt()) {
          1 => '1JT',
          3 => '3JT',
          5 => '5JT',
          _ => ''
        };
        break;
    }
    if (text.isEmpty) return Container();
    return SideTitleWidget(
        meta: meta, child: Text(text, style: style, textAlign: TextAlign.left));
  }
}
