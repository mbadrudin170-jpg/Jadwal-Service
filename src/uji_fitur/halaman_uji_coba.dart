// path: src/uji_fitur/halaman_uji_coba.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

class StatistikUjiCobaPage extends StatefulWidget {
  const StatistikUjiCobaPage({super.key});

  @override
  State<StatistikUjiCobaPage> createState() => _StatistikUjiCobaPageState();
}

class _StatistikUjiCobaPageState extends State<StatistikUjiCobaPage> {
  @override
  void initState() {
    super.initState();
    Log.info('Halaman Statistik Uji Coba dimulai');
  }

  @override
  void dispose() {
    Log.info('Halaman Statistik Uji Coba ditutup');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Statistik Uji Coba'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Statistik Mingguan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: bottomTitleWidgets,
                      ),
                    ),
                    rightTitles: AxisTitles(),
                  ),
                  borderData: FlBorderData(
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 2),
                        FlSpot(2, 5),
                        FlSpot(3, 3.1),
                        FlSpot(4, 4),
                        FlSpot(5, 3),
                        FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withAlpha(77),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Statistik Bulanan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (final _) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      getTooltipItem: (
                        final BarChartGroupData group,
                        final int groupIndex,
                        final BarChartRodData rod,
                        final int rodIndex,
                      ) {
                        return BarTooltipItem(
                          rod.toY.round().toString(),
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: const FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: bottomMonthTitleWidgets,
                      ),
                    ),
                    leftTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 8, color: Colors.lightBlueAccent)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 10, color: Colors.lightBlueAccent)
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 14, color: Colors.lightBlueAccent)
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 15, color: Colors.lightBlueAccent)
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget bottomTitleWidgets(final double value, final TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Sen', style: style);
        break;
      case 1:
        text = const Text('Sel', style: style);
        break;
      case 2:
        text = const Text('Rab', style: style);
        break;
      case 3:
        text = const Text('Kam', style: style);
        break;
      case 4:
        text = const Text('Jum', style: style);
        break;
      case 5:
        text = const Text('Sab', style: style);
        break;
      case 6:
        text = const Text('Min', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      meta: meta,
      child: text,
    );
  }

  static Widget bottomMonthTitleWidgets(
      final double value, final TitleMeta meta) {
    final style = TextStyle(
      color: Colors.grey[600],
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }
}
