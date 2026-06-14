// path: lib/user/page/transaction_detail_user.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart'; // DIUBAH

class TransactionDetailPage extends StatelessWidget {
  final TransaksiModel transaction;
  final PaketModel? package;

  const TransactionDetailPage(
      {super.key, required this.transaction, this.package});

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun halaman TransactionDetailPage untuk transaksi ID: ${transaction.id}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Tanggal:',
              FormatWaktuLengkap.formatSingkat(transaction.tanggal),
            ),
            _buildInfoRow('Keterangan:', transaction.deskripsi),
            _buildInfoRow(
              'Jumlah:',
              FormatUang.formatMataUang(transaction.jumlah),
            ),
            _buildInfoRow('Tipe:', transaction.tipe.displayName),
            if (package != null)
              _buildInfoRow('Paket:', package!.nama)
            else if (transaction.idPaket != null)
              _buildInfoRow('Paket:', 'Memuat...'),
            _buildInfoRow(
              'Status Pembayaran:',
              transaction.statusPembayaran.displayName,
            ),
            if (transaction.tanggalMulai != null)
              _buildInfoRow(
                'Tanggal Mulai:',
                FormatWaktuLengkap.formatSingkat(transaction.tanggalMulai!),
              ),
            if (transaction.tangglberakhir != null)
              _buildInfoRow(
                'Tanggal Berakhir:',
                FormatWaktuLengkap.formatSingkat(transaction.tangglberakhir!),
              ),
            _buildInfoRow(
              'Poin didapat:',
              transaction.poinDidapat.toString(),
            ),
            _buildInfoRow(
              'Poin digunakan:',
              transaction.poinDigunakan.toString(),
            ),
            if (transaction.durasiBonus! > 0 &&
                transaction.tipeDurasiBonus != null)
              _buildInfoRow('Bonus',
                  '${transaction.durasiBonus} ${transaction.tipeDurasiBonus!.displayName}')
          ],
        ),
      ),
      // DIUBAH
      bottomNavigationBar: const BannerAdsWidget(),
    );
  }

  Widget _buildInfoRow(final String label, final dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: value is Widget ? value : Text(value.toString()),
          ),
        ],
      ),
    );
  }
}
