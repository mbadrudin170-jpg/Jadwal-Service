import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GrafikKeuangan extends StatelessWidget {
  final Map<DateTime, double> dataPemasukan;

  const GrafikKeuangan({super.key, required this.dataPemasukan});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: dataPemasukan.length.toDouble() - 1,
        minY: 0,
        maxY: _calculateMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _createSpots() {
    List<FlSpot> spots = [];
    List<DateTime> sortedKeys = dataPemasukan.keys.toList()..sort();
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataPemasukan[sortedKeys[i]]!));
    }
    return spots;
  }

  double _calculateMaxY() {
    if (dataPemasukan.isEmpty) return 0;
    return dataPemasukan.values.reduce((a, b) => a > b ? a : b) * 1.2;
  }
}
