// path: lib/fitur/transaksi/page/detail_transaksi_u.dart

import 'package:flutter/material.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart'; // DIUBAH

class DetailTransaksiU extends StatelessWidget {
  final TransaksiModel transaksi;
  final PaketModel? paket;

  const DetailTransaksiU({super.key, required this.transaksi, this.paket});

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun halaman TransactionDetailPage untuk transaksi ID: ${transaksi.id}',
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
              FormatWaktuLengkap.formatSingkat(transaksi.tanggal),
            ),
            _buildInfoRow('Keterangan:', transaksi.deskripsi),
            _buildInfoRow(
              'Jumlah:',
              FormatUang.formatMataUang(transaksi.jumlah),
            ),
            _buildInfoRow('Tipe:', transaksi.tipe.displayName),
            if (paket != null)
              _buildInfoRow('Paket:', paket!.nama)
            else if (transaksi.idPaket != null)
              _buildInfoRow('Paket:', 'Memuat...'),
            _buildInfoRow(
              'Status Pembayaran:',
              transaksi.statusPembayaran.displayName,
            ),
            if (transaksi.tanggalMulai != null)
              _buildInfoRow(
                'Tanggal Mulai:',
                FormatWaktuLengkap.formatSingkat(transaksi.tanggalMulai!),
              ),
            if (transaksi.tanggalBerakhir != null)
              _buildInfoRow(
                'Tanggal Berakhir:',
                FormatWaktuLengkap.formatSingkat(transaksi.tanggalBerakhir!),
              ),
            _buildInfoRow(
              'Poin didapat:',
              transaksi.poinDidapat.toString(),
            ),
            _buildInfoRow(
              'Poin digunakan:',
              transaksi.poinDigunakan.toString(),
            ),
            if (transaksi.durasiBonus > 0 && transaksi.tipeDurasiBonus != null)
              _buildInfoRow('Bonus',
                  '${transaksi.durasiBonus} ${transaksi.tipeDurasiBonus!.displayName}')
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
