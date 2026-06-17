// path: lib/admin/halaman/detail/subscription_history_detail.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/pelanggan/page/admin/detail_pelanggan_a.dart';
import 'package:wifi/fitur/riwayat_aktivasi/page/form_riwayat_aktivasi.dart';
import 'package:wifi/admin/providers/detail_langganan_provider.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';

class DetailRiwayatAktivasiPage extends ConsumerWidget {
  final String transactionId;
  const DetailRiwayatAktivasiPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch data gabungan langsung dari provider
    final detailAsync = ref.watch(ambilDetailLanggananProvider(transactionId));

    return detailAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (data) {
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('Transaksi tidak ditemukan')),
          );
        }

        final transaction = data.transaction;
        final customer = data.customer;
        final package = data.package;
        final paymentStatusColor =
            transaction?.statusPembayaran == StatusPembayaran.paid
            ? Colors.green
            : Colors.red;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Langganan'),
            actions: [
              IconButton(
                icon: const Icon(TIcons.edit),
                onPressed: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FromRiwayatAktivasi(transaksi: transaction!),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(ambilDetailLanggananProvider(transactionId)),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // CARD 1: INFORMASI PELANGGAN
                _buildCard(
                  title: 'Informasi Pelanggan',
                  onTap: customer == null
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                DetailPelanggan(idPelanggan: customer.id),
                          ),
                        ),
                  children: [
                    _buildRow(
                      'Nama Pelanggan',
                      customer?.nama ?? 'Tidak Diketahui',
                    ),
                  ],
                ),
                gapH16,

                // CARD 2: INFORMASI PAKET
                _buildCard(
                  title: 'Informasi Paket',
                  onTap: package == null
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                DetailPaketPage(paket: package),
                          ),
                        ),
                  children: [
                    _buildRow('Nama Paket', package?.nama ?? 'Tidak Diketahui'),
                    _buildRow(
                      'Harga',
                      FormatUang.formatMataUang(
                        (package?.harga ?? 0).toDouble(),
                      ),
                    ),
                    _buildRow(
                      'Durasi',
                      '${package?.durasi ?? 0} ${package?.tipe.displayName ?? ""}',
                    ),
                  ],
                ),
                gapH16,
                // CARD 3: POIN TRANSAKSI
                if (transaction!.poinDidapat > 0 ||
                    transaction.poinDigunakan > 0) ...[
                  _buildCard(
                    title: 'Informasi Poin',
                    children: [
                      _buildRow(
                        'Poin Dihasilkan',
                        '+${transaction.poinDidapat} Poin',
                        color: Colors.green,
                      ),
                      _buildRow(
                        'Poin Digunakan',
                        '-${transaction.poinDigunakan} Poin',
                        color: Colors.red,
                      ),
                    ],
                  ),
                  gapH16,
                ],

                // CARD 4: WAKTU & STATUS
                _buildCard(
                  title: 'Waktu & Status',
                  children: [
                    if (transaction.tanggalMulai != null)
                      _buildRow(
                        'Tanggal Mulai',
                        FormatWaktuLengkap.formatSingkat(
                          transaction.tanggalMulai!,
                        ),
                      ),
                    if (transaction.tanggalBerakhir != null)
                      _buildRow(
                        'Tanggal Berakhir',
                        FormatWaktuLengkap.formatSingkat(
                          transaction.tanggalBerakhir!,
                        ),
                      ),
                    _buildRow(
                      'Status Pembayaran',
                      transaction.statusPembayaran.displayName.toUpperCase(),
                      color: paymentStatusColor,
                      isBold: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget sederhana untuk memangkas boilerplate code
  Widget _buildCard({
    required String title,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
