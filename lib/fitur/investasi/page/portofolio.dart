// path: lib/fitur/investasi/page/portofolio.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/user/providers/user_provider.dart';

/// Model data portofolio investor.
class InvestorPortofolio {
  final String id;
  final String userId;
  final String namaInvestor;
  final double persentase; // 0.0 - 1.0
  final double totalModal;
  final double totalDividenDiterima;
  final List<DividenHistory> riwayatDividen;

  InvestorPortofolio({
    required this.id,
    required this.userId,
    required this.namaInvestor,
    required this.persentase,
    required this.totalModal,
    this.totalDividenDiterima = 0,
    this.riwayatDividen = const [],
  });
}

/// Model riwayat dividen.
class DividenHistory {
  final String id;
  final DateTime tanggal;
  final double jumlah;
  final String keterangan;

  DividenHistory({
    required this.id,
    required this.tanggal,
    required this.jumlah,
    required this.keterangan,
  });
}

/// Provider untuk mengambil data portofolio investor yang sedang login.
final investorPortofolioProvider = FutureProvider<InvestorPortofolio?>((
  ref,
) async {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null || userId.isEmpty) {
    Log.warning('UserId tidak ditemukan untuk mengambil portofolio investor.');
    return null;
  }

  // TODO: Ambil data dari SQLite atau Firebase sesuai kebutuhan.
  // Karena ini masih contoh, kita akan kembalikan data dummy.
  // Nanti bisa diganti dengan query ke database yang sebenarnya.
  Log.info('Mengambil data portofolio untuk investor ID: $userId');

  // Data dummy untuk demonstrasi
  return InvestorPortofolio(
    id: 'portofolio_1',
    userId: userId,
    namaInvestor: 'Budi Investor',
    persentase: 0.4, // 40%
    totalModal: 5000000,
    totalDividenDiterima: 1200000,
    riwayatDividen: [
      DividenHistory(
        id: 'div_1',
        tanggal: DateTime(2025, 6, 1),
        jumlah: 600000,
        keterangan: 'Dividen Q2 2025',
      ),
      DividenHistory(
        id: 'div_2',
        tanggal: DateTime(2025, 3, 1),
        jumlah: 600000,
        keterangan: 'Dividen Q1 2025',
      ),
    ],
  );
});

/// Halaman portofolio untuk investor (read-only).
class HalamanPortofolio extends ConsumerWidget {
  const HalamanPortofolio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInvestor = ref.isInvestor;
    if (!isInvestor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Portofolio')),
        body: const Center(
          child: Text('Anda tidak memiliki akses ke halaman ini.'),
        ),
      );
    }

    final portofolioAsync = ref.watch(investorPortofolioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Portofolio Saya')),
      body: portofolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TIcons.errorOutlined, size: 60, color: Colors.red),
              gapH16,
              const TeksIsiBesar(
                'Gagal memuat data portofolio.',
                warna: Colors.red,
              ),
              gapH8,
              TeksIsiSedang('Error: $err'),
              gapH16,
              ElevatedButton.icon(
                onPressed: () => ref.refresh(investorPortofolioProvider),
                icon: const Icon(TIcons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (portofolio) {
          if (portofolio == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(TIcons.warningAmber, size: 60, color: Colors.orange),
                  gapH16,
                  TeksIsiBesar('Data portofolio tidak ditemukan.'),
                  TeksIsiSedang('Hubungi admin untuk informasi lebih lanjut.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(investorPortofolioProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Ringkasan
                  _buildKartuRingkasan(portofolio),
                  gapH24,

                  // Detail Kepemilikan
                  _buildDetailKepemilikan(portofolio),
                  gapH24,

                  // Riwayat Dividen
                  _buildRiwayatDividen(portofolio),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKartuRingkasan(InvestorPortofolio portofolio) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: TColors.primaryColor.withAlpha(25),
                  radius: 28,
                  child: const Icon(
                    TIcons.person,
                    size: 32,
                    color: TColors.primaryColor,
                  ),
                ),
                gapW16,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeksJudulSedang(
                      portofolio.namaInvestor,
                      tebalFont: FontWeight.bold,
                    ),
                    TeksIsiKecil('ID Investor: ${portofolio.id}'),
                  ],
                ),
              ],
            ),
            gapH16,
            const Divider(),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksIsiKecil('Total Modal', warna: Colors.grey),
                      TeksJudulSedang(
                        FormatUang.formatMataUang(portofolio.totalModal),
                        tebalFont: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const TeksIsiKecil('Persentase', warna: Colors.grey),
                      TeksJudulSedang(
                        '${(portofolio.persentase * 100).toStringAsFixed(1)}%',
                        tebalFont: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH12,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksIsiKecil(
                        'Dividen Diterima',
                        warna: Colors.grey,
                      ),
                      TeksJudulSedang(
                        FormatUang.formatMataUang(
                          portofolio.totalDividenDiterima,
                        ),
                        tebalFont: FontWeight.bold,
                        warna: Colors.green,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TeksIsiKecil('Dividen Berikutnya', warna: Colors.grey),
                      TeksJudulSedang(
                        'Belum ditentukan',
                        tebalFont: FontWeight.bold,
                        warna: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailKepemilikan(InvestorPortofolio portofolio) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(TIcons.points, color: TColors.primaryColor),
                gapW8,
                TeksJudulKecil(
                  'Detail Kepemilikan',
                  tebalFont: FontWeight.bold,
                ),
              ],
            ),
            gapH16,
            _buildBarisDetail('Nama', portofolio.namaInvestor),
            _buildBarisDetail(
              'Modal Disetor',
              FormatUang.formatMataUang(portofolio.totalModal),
            ),
            _buildBarisDetail(
              'Persentase',
              '${(portofolio.persentase * 100).toStringAsFixed(1)}%',
            ),
            _buildBarisDetail(
              'Total Dividen',
              FormatUang.formatMataUang(portofolio.totalDividenDiterima),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatDividen(InvestorPortofolio portofolio) {
    final riwayat = portofolio.riwayatDividen;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(TIcons.history, color: TColors.primaryColor),
                gapW8,
                TeksJudulKecil('Riwayat Dividen', tebalFont: FontWeight.bold),
              ],
            ),
            gapH16,
            if (riwayat.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: TeksIsiSedang(
                    'Belum ada riwayat dividen.',
                    warna: Colors.grey,
                  ),
                ),
              )
            else
              ...riwayat.map(_buildItemDividen),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDividen(DividenHistory dividen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksIsiSedang(dividen.keterangan, tebalFont: FontWeight.w500),
                TeksIsiKecil(
                  FormatTanggal.formatDasar(dividen.tanggal),
                  warna: Colors.grey,
                ),
              ],
            ),
          ),
          TeksIsiSedang(
            FormatUang.formatMataUang(dividen.jumlah),
            tebalFont: FontWeight.bold,
            warna: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBarisDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TeksIsiSedang(label, warna: Colors.grey.shade700),
          TeksIsiSedang(value, tebalFont: FontWeight.w500),
        ],
      ),
    );
  }
}
