// path: lib/fitur/investasi/page/ringkasan_saham.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/investasi/page/daftar_investor.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class RingkasanSaham extends ConsumerWidget {
  const RingkasanSaham({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    final pelangganAsync = ref.watch(pelangganProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Saham')),
      body: investasiAsync.when(
        data: (investasi) {
          final totalLembar = investasi.getTotalLembarBeredar();
          final totalAset = investasi.getTotalAsetPerusahaan();
          final totalDividenDiterima = investasi.totalDividenDiterima;
          final totalDividenBelumDibayar = investasi.totalDividenBelumDibayar;
          final returnPersentase = totalAset > 0
              ? (totalDividenDiterima / totalAset) * 100
              : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Perusahaan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH16,
                        _buildInfoRow(
                          'Total Aset',
                          FormatUang.formatMataUang(totalAset),
                          icon: TIcons.money,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Total Lembar Saham',
                          totalLembar.toString(),
                          icon: TIcons.points,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Dividen Diterima',
                          FormatUang.formatMataUang(totalDividenDiterima),
                          icon: TIcons.success,
                          color: Colors.green,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Dividen Belum Dibayar',
                          FormatUang.formatMataUang(totalDividenBelumDibayar),
                          icon: TIcons.warning,
                          color: Colors.orange,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Return (%)',
                          '${returnPersentase.toStringAsFixed(2)}%',
                          icon: TIcons.star,
                          color: returnPersentase >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),

                // path: lib/fitur/investasi/page/ringkasan_saham.dart

                // Di dalam build method, setelah Card Statistik Tambahan, tambahkan:
                gapH16,

                // Grafik Distribusi Kepemilikan
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Distribusi Kepemilikan Saham',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH12,
                        pelangganAsync.when(
                          data: (listInvestor) => _buildPieChartKepemilikan(
                            investasi,
                            listInvestor.daftarPelanggan,
                          ),
                          error: (error, stackTrace) =>
                              const Text('Gagal memuat data investor'),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    ),
                  ),
                ),

                gapH16,

                // Informasi Tambahan
                _buildRingkasanTambahan(investasi),

                gapH16,

                // Grafik Pertumbuhan Aset
                _buildGrafikPertumbuhanAset(investasi),

                gapH16,

                // Daftar Investor (yang sudah ada)
                gapH16,

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistik Tambahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH12,
                        _buildInfoRow(
                          'Jumlah Investasi',
                          investasi.jumlahInvestasi.toString(),
                          icon: TIcons.listAlt,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Jumlah Dividen',
                          investasi.jumlahDividen.toString(),
                          icon: TIcons.history,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Rata-rata Modal per Investasi',
                          FormatUang.formatMataUang(
                            investasi.jumlahInvestasi > 0
                                ? totalAset / investasi.jumlahInvestasi
                                : 0,
                          ),
                          icon: TIcons.info,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const DaftarInvestor(),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: pelangganAsync.when(
                        data: (listInvestor) {
                          final daftarInvestor =
                              listInvestor.ambilBerdasarkanRole(
                                AppRole.investor,
                              )..sort((a, b) {
                                final lembarA = investasi
                                    .getTotalLembarInvestor(a.id);
                                final lembarB = investasi
                                    .getTotalLembarInvestor(b.id);
                                return lembarB.compareTo(
                                  lembarA,
                                ); // descending (terbanyak ke terkecil)
                              });

                          if (daftarInvestor.isEmpty) {
                            return const Center(
                              child: Text('Belum ada investor'),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daftar Investor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              gapH12,
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: daftarInvestor.length > 5
                                    ? 5
                                    : daftarInvestor.length,
                                itemBuilder: (context, index) {
                                  final investor = daftarInvestor[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(investor.nama),
                                        Text(
                                          investasi
                                              .getTotalLembarInvestor(
                                                investor.id,
                                              )
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                        error: (error, stackTrace) =>
                            Center(child: Text('Error: $error')),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TIcons.error, size: 60, color: Colors.red),
              gapH16,
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildRingkasanTambahan(InvestasiState investasi) {
    final totalLembar = investasi.getTotalLembarBeredar();
    final totalAset = investasi.getTotalAsetPerusahaan();
    final hargaPerLembar = totalLembar > 0 ? totalAset / totalLembar : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Tambahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            gapH12,
            // path: lib/fitur/investasi/page/ringkasan_saham.dart

            // Di dalam _buildRingkasanTambahan
            _buildInfoRow(
              'Harga per Lembar',
              FormatUang.formatMataUang(hargaPerLembar),
              icon: TIcons.money,
              color: Colors.blue, // Tambahkan warna
            ),
            _buildInfoRow(
              'Kapitalisasi Pasar',
              FormatUang.formatMataUang(totalAset),
              icon: TIcons.points,
              color: Colors.purple, // Tambahkan warna
            ),
          ],
        ),
      ),
    );
  }
  // path: lib/fitur/investasi/page/ringkasan_saham.dart

  // Tambahkan method ini untuk grafik pertumbuhan aset
  Widget _buildGrafikPertumbuhanAset(InvestasiState investasi) {
    // Ambil data investasi yang sudah ada
    final daftarInvestasi = investasi.daftarInvestasi;

    if (daftarInvestasi.isEmpty) {
      return const SizedBox.shrink();
    }

    // Kelompokkan investasi per bulan
    final asetPerBulan = <DateTime, double>{};
    for (final inv in daftarInvestasi) {
      final bulan = DateTime(
        inv.tanggalInvestasi!.year,
        inv.tanggalInvestasi!.month,
      );
      asetPerBulan[bulan] = (asetPerBulan[bulan] ?? 0) + inv.jumlahModal;
    }

    // Ambil 6 bulan terakhir
    final sortedKeys = asetPerBulan.keys.toList()..sort();
    final last6Months = sortedKeys.length > 6
        ? sortedKeys.sublist(sortedKeys.length - 6)
        : sortedKeys;

    if (last6Months.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = last6Months.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), asetPerBulan[entry.value]!);
    }).toList();

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = maxY * 0.8; // Tampilkan dari 80% dari nilai maks

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pertumbuhan Aset (6 Bulan Terakhir)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            gapH12,
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY * 1.05,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < last6Months.length) {
                            return Text(
                              '${last6Months[index].month}/${last6Months[index].year.toString().substring(2)}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            (value / 1000000).toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 35,
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withAlpha(50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // Tambahkan method ini di dalam class RingkasanSaham

  Widget _buildPieChartKepemilikan(
    InvestasiState investasi,
    List<PelangganModel> daftarInvestor,
  ) {
    final totalLembar = investasi.getTotalLembarBeredar();
    if (totalLembar == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Belum ada data kepemilikan saham.')),
      );
    }

    final dataInvestor = daftarInvestor
        .where(
          (p) =>
              p.role == AppRole.investor &&
              investasi.getTotalLembarInvestor(p.id) > 0,
        )
        .map(
          (p) => (nama: p.nama, lembar: investasi.getTotalLembarInvestor(p.id)),
        )
        .toList();

    final totalLembarValid = dataInvestor.fold<int>(
      0,
      (sum, item) => sum + item.lembar,
    );

    if (totalLembarValid == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Belum ada investor yang memiliki saham.')),
      );
    }

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: PieChart(
        PieChartData(
          sections: dataInvestor.map((item) {
            final persentase = (item.lembar / totalLembarValid) * 100;
            return PieChartSectionData(
              title: '${persentase.toStringAsFixed(1)}%',
              value: item.lembar.toDouble(),
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              color:
                  Colors.primaries[dataInvestor.indexOf(item) %
                      Colors.primaries.length],
              radius: 80,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, size: 20, color: Colors.grey.shade600),
            gapW8,
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
