// path: lib/fitur/investasi/page/ringkasan_saham.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: pelangganAsync.when(
                      data: (listInvestor) {
                        final daftarInvestor =
                            listInvestor.ambilBerdasarkanRole(AppRole.investor)
                              ..sort((a, b) {
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
                                            .getTotalLembarInvestor(investor.id)
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
