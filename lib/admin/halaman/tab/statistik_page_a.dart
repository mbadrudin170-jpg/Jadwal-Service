// path: lib/admin/halaman/tab/statistik_page_a.dart
// PERBAIKAN: Memperbaiki typo comtext -> context.
// DIUBAH: Mengganti data statis paket terlaris dengan data dinamis dari repository.

import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/lainnya/customer.dart';
import 'package:wifi/admin/halaman/tab/active_customer_tab.dart';
import 'package:wifi/admin/halaman/tab/transaction_page_a.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/admin/repository/statistik_repository.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/custom_future_builder.dart';

/// Enum untuk merepresentasikan rentang waktu yang dipilih.
enum ChartRange {
  /// Rentang harian.
  harian,

  /// Rentang mingguan.
  mingguan,

  /// Rentang bulanan.
  bulanan,
}

/// Halaman untuk menampilkan statistik aplikasi dalam bentuk dasbor.
class StatistikPageA extends StatefulWidget {
  /// Halaman untuk menampilkan statistik aplikasi.
  const StatistikPageA({super.key});

  @override
  State<StatistikPageA> createState() => _StatistikPageAState();
}

class _StatistikPageAState extends State<StatistikPageA> {
  ChartRange _selectedRange = ChartRange.bulanan;
  final StatistikRepository _repository = StatistikRepository();
  Future<double>? _pendapatanFuture;
  Future<int>? _totalPelangganFuture;
  Future<int>? _langgananAktifFuture;
  Future<int>? _feedbackBaruFuture;
  Future<List<BestSellingPackage>>? _bestSellingPackagesFuture;

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

  @override
  void initState() {
    super.initState();
    Log.info('StatistikPageA initState');
    _loadData();
  }

  void _loadData() {
    setState(() {
      _pendapatanFuture = _repository.getPendapatanBulanIni();
      _totalPelangganFuture = _repository.getTotalPelanggan();
      _langgananAktifFuture = _repository.getJumlahLanggananAktif();
      _feedbackBaruFuture = _repository.getJumlahFeedbackBaru();
      _bestSellingPackagesFuture = _repository.getBestSellingPackages();
    });
  }

  Future<void> _handleRefresh() async {
    Log.info('Pull-to-refresh dipicu, memuat ulang semua data statistik.');
    _loadData();
    // PERBAIKAN: Await Future.wait agar RefreshIndicator menunggu semua data dimuat ulang.
    // Error pada masing-masing Future akan ditangani oleh CustomFutureBuilder,
    // jadi di sini kita bisa menggunakan catchError untuk memastikan Future.wait tidak gagal.
    await Future.wait([
      if (_pendapatanFuture != null)
        _pendapatanFuture!.catchError((final _) => 0.0),
      if (_totalPelangganFuture != null)
        _totalPelangganFuture!.catchError((final _) => 0),
      if (_langgananAktifFuture != null)
        _langgananAktifFuture!.catchError((final _) => 0),
      if (_feedbackBaruFuture != null)
        _feedbackBaruFuture!.catchError((final _) => 0),
      if (_bestSellingPackagesFuture != null)
        _bestSellingPackagesFuture!
            .catchError((final _) => <BestSellingPackage>[]),
    ]);
  }

  @override
  void dispose() {
    Log.info('StatistikPageA dispose');
    super.dispose();
  }

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
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Statistik'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  CustomFutureBuilder<int>(
                    future: _totalPelangganFuture,
                    dataBuilder: (final context, final totalPelanggan) {
                      return GestureDetector(
                        onTap: () {
                          Log.info(
                              'Navigasi ke halaman pelanggan dari kartu statistik');
                          unawaited(Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (final context) =>
                                    const CustomerPage()),
                          ));
                        },
                        child: _buildStatCard(
                          title: 'Total Pelanggan',
                          value: totalPelanggan.toString(),
                          icon: TIcons.customers,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                  CustomFutureBuilder<int>(
                    future: _langgananAktifFuture,
                    dataBuilder: (final context, final langgananAktif) {
                      return GestureDetector(
                        onTap: () {
                          Log.info(
                              'Navigasi ke halaman langganan aktif dari kartu statistik');
                          unawaited(Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (final context) =>
                                    const ActiveCustomerPage()),
                          ));
                        },
                        child: _buildStatCard(
                          title: 'Langganan Aktif',
                          value: langgananAktif.toString(),
                          icon: TIcons.wifi,
                          color: Colors.green,
                        ),
                      );
                    },
                  ),
                  CustomFutureBuilder<double>(
                    future: _pendapatanFuture,
                    dataBuilder: (final context, final pendapatan) {
                      final cardColor =
                          pendapatan < 0 ? Colors.red : Colors.orange;
                      final valueWidget = Text(
                        CurrencyFormat.formatCurrency(pendapatan),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      );

                      return GestureDetector(
                        onTap: () {
                          Log.info(
                              'Navigasi ke halaman transaksi dari kartu statistik');
                          unawaited(Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (final context) =>
                                    const TransactionPage()),
                          ));
                        },
                        child: _buildStatCard(
                          title: 'Pendapatan Bulan Ini',
                          value: '', // Kosongkan
                          icon: TIcons.money,
                          color: cardColor,
                          customValueWidget: valueWidget,
                        ),
                      );
                    },
                  ),
                  CustomFutureBuilder<int>(
                    future: _feedbackBaruFuture,
                    dataBuilder: (final context, final feedbackBaru) {
                      return GestureDetector(
                        onTap: () {
                          Log.info(
                              'Navigasi ke halaman feedback dari kartu statistik (belum diimplementasikan).');
                          // TODO: Implement navigation to feedback page
                        },
                        child: _buildStatCard(
                          title: 'Feedback Baru',
                          value: feedbackBaru.toString(),
                          icon: TIcons.feedback,
                          color: Colors.purple,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Analisis Pertumbuhan',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    isSelected: [
                      _selectedRange == ChartRange.harian,
                      _selectedRange == ChartRange.mingguan,
                      _selectedRange == ChartRange.bulanan,
                    ],
                    onPressed: (final index) {
                      setState(() {
                        _selectedRange = ChartRange.values[index];
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedBorderColor: theme.colorScheme.primary,
                    selectedColor: Colors.white,
                    fillColor: theme.colorScheme.primary,
                    color: theme.colorScheme.primary,
                    constraints:
                        const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
                    children: const [
                      Text('Harian'),
                      Text('Mingguan'),
                      Text('Bulanan')
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16),
                  child: LineChart(_mainLineChartData()),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Paket Terlaris',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CustomFutureBuilder<List<BestSellingPackage>>(
                future: _bestSellingPackagesFuture,
                dataBuilder: (final context, final packages) {
                  if (packages.isEmpty) {
                    return const Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text('Belum ada data penjualan paket.'),
                      ),
                    );
                  }
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: List.generate(packages.length, (final index) {
                        final item = packages[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text('#${index + 1}')),
                          title: Text(item.package.name),
                          trailing: Text(
                            '${item.totalSold} terjual',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required final String title,
    required final String value,
    required final IconData icon,
    required final Color color,
    final Widget? customValueWidget,
  }) {
    return LayoutBuilder(builder: (final context, final constraints) {
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
                      customValueWidget ??
                          Text(
                            value,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
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

  LineChartData _mainLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (final value) =>
            FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
        getDrawingVerticalLine: (final value) =>
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
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
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
      dotData: const FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.primary.withAlpha(20),
          Theme.of(context).colorScheme.primary.withAlpha(50)
        ]),
      ),
    );
  }

  Widget _bottomTitleWidgets(final double value, final TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    Widget text;
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
          _ => const Text('', style: style),
        };
        break;
      case ChartRange.mingguan:
        text = switch (value.toInt()) {
          0 => const Text('M1', style: style),
          1 => const Text('M2', style: style),
          2 => const Text('M3', style: style),
          3 => const Text('M4', style: style),
          _ => const Text('', style: style),
        };
        break;
      case ChartRange.bulanan:
        text = switch (value.toInt()) {
          0 => const Text('JAN', style: style),
          1 => const Text('FEB', style: style),
          2 => const Text('MAR', style: style),
          3 => const Text('APR', style: style),
          4 => const Text('MEI', style: style),
          _ => const Text('', style: style),
        };
        break;
    }
    return SideTitleWidget(meta: meta, child: text);
  }

  Widget _leftTitleWidgets(final double value, final TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    String text;
    switch (_selectedRange) {
      case ChartRange.harian:
        if (value % 1 == 0 && value != 0) {
          text = '${value.toInt()}k';
        } else {
          return Container();
        }
        break;
      case ChartRange.mingguan:
        if (value % 1 == 0 && value != 0) {
          text = '${value.toInt()}JT';
        } else {
          return Container();
        }
        break;
      case ChartRange.bulanan:
        text = switch (value.toInt()) {
          1 => '1JT',
          3 => '3JT',
          5 => '5JT',
          _ => '',
        };
        if (text.isEmpty) return Container();
        break;
    }
    return SideTitleWidget(
        meta: meta, child: Text(text, style: style, textAlign: TextAlign.left));
  }
}
