// path: lib/fitur/investasi/page/ringkasan_saham.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class RingkasanSaham extends ConsumerWidget {
  const RingkasanSaham({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Saham')),
      body: investasiAsync.when(
        data: (data) {
          final totalLembar = data.getTotalLembarBeredar();
          final totalAset = data.getTotalAsetPerusahaan();
          final totalDividenDiterima = data.totalDividenDiterima;
          final totalDividenBelumDibayar = data.totalDividenBelumDibayar;

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
                          data.jumlahInvestasi.toString(),
                          icon: TIcons.listAlt,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Jumlah Dividen',
                          data.jumlahDividen.toString(),
                          icon: TIcons.history,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Rata-rata Modal per Investasi',
                          FormatUang.formatMataUang(
                            data.jumlahInvestasi > 0
                                ? totalAset / data.jumlahInvestasi
                                : 0,
                          ),
                          icon: TIcons.info,
                        ),
                      ],
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
