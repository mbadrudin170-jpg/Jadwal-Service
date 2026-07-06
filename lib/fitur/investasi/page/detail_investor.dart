// path: lib/fitur/investasi/page/detail_investor.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class DetailInvestor extends ConsumerWidget {
  final String idInvestor;
  const DetailInvestor({super.key, required this.idInvestor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    final pelangganAsync = ref.watch(pelangganProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Investor')),
      body: investasiAsync.when(
        data: (investasi) {
          return pelangganAsync.when(
            data: (listPelanggan) {
              final investor = listPelanggan.ambilBerdasarkanId(idInvestor);
              if (investor == null) {
                return const Center(child: Text('Investor tidak ditemukan'));
              }
              final totalLembar = investasi.getTotalLembarInvestor(
                investor.id,
              );
              final totalModal = investasi.getTotalModalInvestor(investor.id);
              final totalDividen = investasi.getTotalDividenDiterimaInvestor(
                investor.id,
              );
              final returnPersentase = totalModal > 0
                  ? (totalDividen / totalModal) * 100
                  : 0.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profil Investor
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child: Text(
                                investor.nama.isNotEmpty
                                    ? investor.nama[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            gapH12,
                            Text(
                              investor.nama,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            gapH4,
                            Text(
                              investor.telepon,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            gapH4,
                            Text(
                              investor.alamat,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    gapH16,

                    // Ringkasan Investasi
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
                              'Ringkasan Investasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            gapH12,
                            _buildInfoRow(
                              'Total Modal',
                              FormatUang.formatMataUang(totalModal),
                              icon: TIcons.money,
                            ),
                            gapH8,
                            _buildInfoRow(
                              'Total Lembar',
                              totalLembar.toString(),
                              icon: TIcons.points,
                            ),
                            gapH8,
                            _buildInfoRow(
                              'Total Dividen',
                              FormatUang.formatMataUang(totalDividen),
                              icon: TIcons.success,
                              color: Colors.green,
                            ),
                            gapH8,
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

                    // Daftar Investasi
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
                              'Daftar Investasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            gapH12,
                            _buildDaftarInvestasi(
                              investasi.ambilInvestasiByIdInvestor(
                                investor.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(TIcons.error, size: 60, color: Colors.red),
                  gapH16,
                  Text('Error: $error', textAlign: TextAlign.center),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
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

  Widget _buildDaftarInvestasi(List<InvestasiModel> daftarInvestasi) {
    if (daftarInvestasi.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Belum ada investasi'),
        ),
      );
    }

    return Column(
      children: daftarInvestasi.map((investasi) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investasi.idTransaksi,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    investasi.tanggalInvestasi != null
                        ? FormatTanggal.formatDasar(
                            investasi.tanggalInvestasi!,
                          )
                        : '-',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    FormatUang.formatMataUang(investasi.jumlahModal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${investasi.jumlahLembar} lembar',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}