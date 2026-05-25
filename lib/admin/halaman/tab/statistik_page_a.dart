// path: lib/admin/halaman/tab/statistik_page_a.dart
// PERBAIKAN: Mengganti `late Future` menjadi `Future?` untuk mencegah LateInitializationError.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/tab/transaction_page_a.dart';
import 'package:wifi/admin/repository/statistik_repository.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Enum untuk merepresentasikan rentang waktu yang dipilih.
enum ChartRange {
  harian,
  mingguan,
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
  // State untuk rentang waktu chart
  ChartRange _selectedRange = ChartRange.bulanan;

  // Repository untuk mengambil data dari Firestore
  final StatistikRepository _repository = StatistikRepository();
  // Dijadikan nullable untuk menghindari error saat hot-reload
  Future<double>? _pendapatanFuture;

  // Data dummy lainnya (akan diganti nanti)
  final int _totalPelanggan = 125;
  final int _langgananAktif = 85;
  final int _feedbackBaru = 3;

  final List<Map<String, dynamic>> _paketTerlaris = [
    {'nama': 'Paket Kencang 30 Hari', 'terjual': 58},
    {'nama': 'Paket Hemat Seminggu', 'terjual': 32},
    {'nama': 'Paket Malam Full Speed', 'terjual': 15},
    {'nama': 'Paket Gaming Pro', 'terjual': 8},
  ];

  // Data Dummy untuk Chart
  final List<FlSpot> _monthlySpots = [
    const FlSpot(0, 3.5), const FlSpot(1, 4.2), const FlSpot(2, 3.8),
    const FlSpot(3, 5.1), const FlSpot(4, 4.5),
  ];
  final List<FlSpot> _weeklySpots = [
    const FlSpot(0, 1.2), const FlSpot(1, 1.5), const FlSpot(2, 1.1), const FlSpot(3, 1.8),
  ];
  final List<FlSpot> _dailySpots = [
    const FlSpot(0, 0.2), const FlSpot(1, 0.5), const FlSpot(2, 0.4),
    const FlSpot(3, 0.8), const FlSpot(4, 0.6), const FlSpot(5, 1.1), const FlSpot(6, 1.0),
  ];

  @override
  void initState() {
    super.initState();
    Log.info('StatistikPageA initState');
    // Memulai pengambilan data pendapatan saat halaman dimuat
    _pendapatanFuture = _repository.getPendapatanBulanIni();
  }

  @override
  void dispose() {
    Log.info('StatistikPageA dispose');
    super.dispose();
  }

  List<FlSpot> get _currentSpots {
    switch (_selectedRange) {
      case ChartRange.harian: return _dailySpots;
      case ChartRange.mingguan: return _weeklySpots;
      case ChartRange.bulanan: return _monthlySpots;
    }
  }

  double get _maxX {
    switch (_selectedRange) {
      case ChartRange.harian: return 6;
      case ChartRange.mingguan: return 3;
      case ChartRange.bulanan: return 4;
    }
  }

  double get _maxY {
    switch (_selectedRange) {
      case ChartRange.harian: return 2;
      case ChartRange.mingguan: return 3;
      case ChartRange.bulanan: return 6;
    }
  }

  @override
  Widget build(final BuildContext context) {
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
            Text(
              'Ringkasan Cepat',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                _buildStatCard(
                  title: 'Total Pelanggan',
                  value: _totalPelanggan.toString(),
                  icon: AppIcons.customers,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Langganan Aktif',
                  value: _langgananAktif.toString(),
                  icon: AppIcons.wifi,
                  color: Colors.green,
                ),
                // Kartu Pendapatan kini menggunakan FutureBuilder
                FutureBuilder<double>(
                  future: _pendapatanFuture,
                  builder: (context, snapshot) {
                    Widget valueWidget;
                    Color cardColor = Colors.orange;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Tampilkan loading indicator kecil saat data dimuat
                      valueWidget = const SizedBox(
                        height: 24, // Sesuaikan tinggi agar sejajar
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    } else if (snapshot.hasError) {
                      // Tampilkan pesan error jika gagal mengambil data
                      Log.error('Gagal memuat pendapatan', e: snapshot.error, st: snapshot.stackTrace);
                      valueWidget = const Text(
                        'Error',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      );
                      cardColor = Colors.red;
                    } else if (snapshot.hasData) {
                      // Tampilkan data jika berhasil
                      final pendapatan = snapshot.data!;
                      valueWidget = Text(
                        CurrencyFormat.formatCurrency(pendapatan),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      );
                      cardColor = pendapatan < 0 ? Colors.red : Colors.orange;
                    } else {
                      // Fallback jika tidak ada data (misal, future masih null)
                      valueWidget = const Text('-');
                    }

                    // Membungkus _buildStatCard asli dengan GestureDetector dan data dinamis
                    return GestureDetector(
                      onTap: () {
                        Log.info('Navigasi ke halaman transaksi dari kartu statistik');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TransactionPage()),
                        );
                      },
                      child: _buildStatCard(
                        title: 'Pendapatan Bulan Ini',
                        value: '', // Kosongkan karena kita akan override child
                        icon: AppIcons.money,
                        color: cardColor,
                        // Override child untuk menampilkan widget dinamis (loading/error/data)
                        customValueWidget: valueWidget,
                      ),
                    );
                  },
                ),
                _buildStatCard(
                  title: 'Feedback Baru',
                  value: _feedbackBaru.toString(),
                  icon: AppIcons.feedback,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sisa UI tetap sama
            Text(
              'Analisis Pertumbuhan',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  onPressed: (index) {
                    setState(() {
                      _selectedRange = ChartRange.values[index];
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedBorderColor: theme.colorScheme.primary,
                  selectedColor: Colors.white,
                  fillColor: theme.colorScheme.primary,
                  color: theme.colorScheme.primary,
                  constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
                  children: const [Text('Harian'), Text('Mingguan'), Text('Bulanan')],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                height: 250,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: LineChart(_mainLineChartData()),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Paket Terlaris',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: List.generate(_paketTerlaris.length, (final index) {
                  final item = _paketTerlaris[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('#${index + 1}')),
                    title: Text(item['nama'] as String),
                    trailing: Text(
                      '${item['terjual']} terjual',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildStatCard({
    required final String title,
    required final String value,
    required final IconData icon,
    required final Color color,
    final Widget? customValueWidget, // Tambahkan parameter opsional
  }) {
    return LayoutBuilder(builder: (final context, final constraints) {
      final cardWidth = (constraints.maxWidth > 400)
          ? (constraints.maxWidth / 2 - 12)
          : double.infinity;
      return SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      // Gunakan customValueWidget jika ada, jika tidak, gunakan Text biasa
                      customValueWidget ?? Text(
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

  LineChartData _mainLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
        getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
      borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d))),
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
      gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withAlpha(80), Theme.of(context).colorScheme.primary]),
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withAlpha(20), Theme.of(context).colorScheme.primary.withAlpha(50)]),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    Widget text;
    switch (_selectedRange) {
      case ChartRange.harian:
        switch (value.toInt()) {
          case 0: text = const Text('Sen', style: style); break;
          case 1: text = const Text('Sel', style: style); break;
          case 2: text = const Text('Rab', style: style); break;
          case 3: text = const Text('Kam', style: style); break;
          case 4: text = const Text('Jum', style: style); break;
          case 5: text = const Text('Sab', style: style); break;
          case 6: text = const Text('Min', style: style); break;
          default: text = const Text('', style: style); break;
        }
        break;
      case ChartRange.mingguan:
        switch (value.toInt()) {
          case 0: text = const Text('M1', style: style); break;
          case 1: text = const Text('M2', style: style); break;
          case 2: text = const Text('M3', style: style); break;
          case 3: text = const Text('M4', style: style); break;
          default: text = const Text('', style: style); break;
        }
        break;
      case ChartRange.bulanan:
        switch (value.toInt()) {
          case 0: text = const Text('JAN', style: style); break;
          case 1: text = const Text('FEB', style: style); break;
          case 2: text = const Text('MAR', style: style); break;
          case 3: text = const Text('APR', style: style); break;
          case 4: text = const Text('MEI', style: style); break;
          default: text = const Text('', style: style); break;
        }
        break;
    }
    return SideTitleWidget(meta: meta, child: text);
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    String text;
    switch (_selectedRange) {
      case ChartRange.harian:
        if (value % 1 == 0 && value != 0) { text = '${value.toInt()}k'; } else { return Container(); }
        break;
      case ChartRange.mingguan:
        if (value % 1 == 0 && value != 0) { text = '${value.toInt()}JT'; } else { return Container(); }
        break;
      case ChartRange.bulanan:
        switch (value.toInt()) {
          case 1: text = '1JT'; break;
          case 3: text = '3JT'; break;
          case 5: text = '5JT'; break;
          default: return Container();
        }
        break;
    }
    return SideTitleWidget(meta: meta, child: Text(text, style: style, textAlign: TextAlign.left));
  }
}
