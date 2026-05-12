// path: lib/user/page/detail_transaksi_user.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/widget/nama_paket.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/debug/log.dart';

class DetailTransaksiPage extends StatelessWidget {
  final TransaksiModel transaksi;

  const DetailTransaksiPage({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun halaman DetailTransaksiPage untuk transaksi ID: ${transaksi.id}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tanggal:', FormatTanggal.formatTanggalDanJam(transaksi.tanggal)),
            _buildInfoRow('Keterangan:', transaksi.keterangan),
            _buildInfoRow('Jumlah:', FormatUang.formatMataUang(transaksi.jumlah)),
            _buildInfoRow('Tipe:', transaksi.tipe.name),
            if (transaksi.idPaket != null)
              _buildInfoRow(
                  'Paket:', NamaPaketWidget(idPaket: transaksi.idPaket!)),
            _buildInfoRow(
                'Status Pembayaran:', transaksi.statusPembayaran.name),
            if (transaksi.tanggalMulai != null)
              _buildInfoRow(
                'Tanggal Mulai:',
                FormatTanggal.formatTanggalBasic(transaksi.tanggalMulai!),
              ),
            if (transaksi.tanggalBerakhir != null)
              _buildInfoRow(
                'Tanggal Berakhir:',
                FormatTanggal.formatTanggalBasic(transaksi.tanggalBerakhir!),
              ),
            _buildInfoRow(
                'Poin didapat:', transaksi.poinYangDihasilkan.toString()),
            _buildInfoRow(
                'Poin digunakan:', transaksi.poinYangDigunakan.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
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
