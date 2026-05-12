// path: lib/user/page/detail_transaksi.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/widget/nama_paket.dart';
import 'package:wifi/user/core/utils/format_tanggal.dart';

class DetailTransaksiPage extends StatelessWidget {
  final TransaksiModel transaksi;

  const DetailTransaksiPage({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID Transaksi:', transaksi.id),
            _buildInfoRow('Tanggal:', formatDate(transaksi.tanggal)),
            _buildInfoRow('Keterangan:', transaksi.keterangan),
            _buildInfoRow('Jumlah:', 'Rp \${transaksi.jumlah.toStringAsFixed(2)}'),
            _buildInfoRow('Tipe:', transaksi.tipe.name),
            if (transaksi.idPaket != null)
              _buildInfoRow('Paket:', NamaPaket(idPaket: transaksi.idPaket!)),
            _buildInfoRow('Status Pembayaran:', transaksi.statusPembayaran.name),
            if (transaksi.tanggalMulai != null)
              _buildInfoRow(
                'Tanggal Mulai:',
                formatDate(transaksi.tanggalMulai!),
              ),
            if (transaksi.tanggalBerakhir != null)
              _buildInfoRow(
                'Tanggal Berakhir:',
                formatDate(transaksi.tanggalBerakhir!),
              ),
            _buildInfoRow('Poin didapat:', transaksi.poinYangDihasilkan.toString()),
            _buildInfoRow('Poin digunakan:', transaksi.poinYangDigunakan.toString()),
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
