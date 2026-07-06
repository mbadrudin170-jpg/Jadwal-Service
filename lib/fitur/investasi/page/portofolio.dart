// path: lib/fitur/investasi/page/portofolio.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unduh_data.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/user/providers/user_provider.dart';

/// Halaman portofolio untuk investor.
class HalamanPortofolio extends ConsumerWidget {
  const HalamanPortofolio({super.key});

  Future<void> _unggahDataDummy(WidgetRef ref) async {
    try {
      await ref.read(layananUnduhDataProvider).unduhSemuaData();
    } on Exception catch (e, s) {
      Log.error('Error di unggahDataDummy: $e', e: e, s: s);
      // Error handling opsional
    }
  }

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

    final userId = ref.watch(userIdProvider).value;
    Log.info('UserId saat ini: $userId');
    if (userId == null || userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Portofolio')),
        body: const Center(child: Text('Silakan login terlebih dahulu.')),
      );
    }

    // ============================================================
    // 1. AMBIL DATA DARI PROVIDER
    // ============================================================
    final investasiAsync = ref.watch(investasiProvider);
    final detailInvestorAsync = ref.watch(
      detailInvestorInvestasiProvider(userId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Portofolio Saya')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(investasiProvider.notifier).refresh();
        },
        child: investasiAsync.when(
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
                  onPressed: () =>
                      ref.read(investasiProvider.notifier).refresh(),
                  icon: const Icon(TIcons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
          data: (state) {
            // ============================================================
            // 2. AMBIL DATA INVESTOR DARI STATE
            // ============================================================
            final daftarInvestasi = state.ambilInvestasiByIdInvestor(userId);
            final daftarDividen = state.ambilDividenByIdInvestor(userId);

            // Hitung total
            final totalModal = daftarInvestasi.fold(
              0.0,
              (sum, i) => sum + i.jumlahModal,
            );
            final totalDividenDiterima = daftarDividen
                .where((d) => d.sudahDibayar)
                .fold(0.0, (sum, d) => sum + d.jumlahDividen);

            // ============================================================
            // 3. CEK APAKAH ADA DATA
            // ============================================================
            if (daftarInvestasi.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      TIcons.warningAmber,
                      size: 60,
                      color: Colors.orange,
                    ),
                    gapH16,
                    const TeksIsiBesar('Belum ada investasi.'),
                    const TeksIsiSedang(
                      'Mulai investasi sekarang untuk melihat portofolio.',
                    ),
                    if (kDebugMode) ...[
                      gapH16,
                      TextButton(
                        onPressed: () {
                          _unggahDataDummy(ref);
                        },
                        child: const Text('DaftarKandataDummy'),
                      ),
                    ],
                  ],
                ),
              );
            }

            // ============================================================
            // 4. TAMPILKAN UI
            // ============================================================
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Ringkasan
                  _buildKartuRingkasan(
                    namaInvestor:
                        'Investor', // Bisa diambil dari data pelanggan
                    totalModal: totalModal,
                    persentase: 0,
                    totalDividenDiterima: totalDividenDiterima,
                  ),
                  gapH24,

                  // Detail Kepemilikan
                  _buildDetailKepemilikan(
                    totalModal: totalModal,
                    persentase: 0,
                    totalDividenDiterima: totalDividenDiterima,
                  ),
                  gapH24,

                  // Daftar Investasi
                  _buildDaftarInvestasi(daftarInvestasi),
                  gapH24,

                  // Riwayat Dividen
                  _buildRiwayatDividen(daftarDividen),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET KARTU RINGKASAN
  // ============================================================

  Widget _buildKartuRingkasan({
    required String namaInvestor,
    required double totalModal,
    required double persentase,
    required double totalDividenDiterima,
  }) {
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
                    TeksJudulSedang(namaInvestor, tebalFont: FontWeight.bold),
                    TeksIsiKecil(
                      'ID Investor: ${DateTime.now().millisecondsSinceEpoch}',
                    ),
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
                        FormatUang.formatMataUang(totalModal),
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
                        '${(persentase * 100).toStringAsFixed(1)}%',
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
                        FormatUang.formatMataUang(totalDividenDiterima),
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

  // ============================================================
  // WIDGET DETAIL KEPEMILIKAN
  // ============================================================

  Widget _buildDetailKepemilikan({
    required double totalModal,
    required double persentase,
    required double totalDividenDiterima,
  }) {
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
            _buildBarisDetail(
              'Modal Disetor',
              FormatUang.formatMataUang(totalModal),
            ),
            _buildBarisDetail(
              'Persentase',
              '${(persentase * 100).toStringAsFixed(1)}%',
            ),
            _buildBarisDetail(
              'Total Dividen',
              FormatUang.formatMataUang(totalDividenDiterima),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET DAFTAR INVESTASI
  // ============================================================

  Widget _buildDaftarInvestasi(List<InvestasiModel> daftarInvestasi) {
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
                Icon(TIcons.money, color: TColors.primaryColor),
                gapW8,
                TeksJudulKecil('Daftar Investasi', tebalFont: FontWeight.bold),
              ],
            ),
            gapH16,
            if (daftarInvestasi.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: TeksIsiSedang(
                    'Belum ada investasi.',
                    warna: Colors.grey,
                  ),
                ),
              )
            else
              ...daftarInvestasi.map(_buildItemInvestasi),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInvestasi(InvestasiModel investasi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksIsiSedang(
                  'ID Transaksi: ${investasi.idTransaksi}',
                  tebalFont: FontWeight.w500,
                ),
                TeksIsiKecil(
                  'Tanggal: ${FormatTanggal.formatDasar(investasi.tanggalInvestasi ?? DateTime.now())}',
                  warna: Colors.grey,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TeksIsiSedang(
                FormatUang.formatMataUang(investasi.jumlahModal),
                tebalFont: FontWeight.bold,
                warna: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET RIWAYAT DIVIDEN
  // ============================================================

  Widget _buildRiwayatDividen(List<DividenModel> daftarDividen) {
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
            if (daftarDividen.isEmpty)
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
              ...daftarDividen.map(_buildItemDividen),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDividen(DividenModel dividen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: dividen.sudahDibayar ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksIsiSedang(
                  dividen.sudahDibayar ? 'Sudah Dibayar' : 'Belum Dibayar',
                  tebalFont: FontWeight.w500,
                  warna: dividen.sudahDibayar ? Colors.green : Colors.orange,
                ),
                TeksIsiKecil(
                  FormatTanggal.formatDasar(dividen.tanggalPembagian),
                  warna: Colors.grey,
                ),
              ],
            ),
          ),
          TeksIsiSedang(
            FormatUang.formatMataUang(dividen.jumlahDividen),
            tebalFont: FontWeight.bold,
            warna: dividen.sudahDibayar ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET HELPER
  // ============================================================

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
