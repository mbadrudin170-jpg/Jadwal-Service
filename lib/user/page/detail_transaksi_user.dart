// path: lib/user/page/detail_transaksi_user.dart
// diubah: Konstruktor diubah untuk menerima objek PaketModel.
// diubah: Menampilkan nama paket langsung dari model, bukan dari widget.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Halaman untuk menampilkan detail lengkap dari sebuah transaksi.
///
/// Menampilkan semua informasi yang relevan dari [TransaksiModel] dan
/// [PaketModel] yang terkait.
class DetailTransaksiPage extends StatelessWidget {
  /// Data transaksi yang akan ditampilkan.
  final TransaksiModel transaksi;

  /// Data paket yang terkait dengan transaksi (jika ada).
  // diubah: Menerima PaketModel yang bisa null.
  final PaketModel? paket;

  /// Membuat instance dari [DetailTransaksiPage].
  const DetailTransaksiPage({super.key, required this.transaksi, this.paket});

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun halaman DetailTransaksiPage untuk transaksi ID: ${transaksi.id}',
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
              FormatTanggal.formatTanggalDanJam(transaksi.tanggal),
            ),
            _buildInfoRow('Keterangan:', transaksi.keterangan),
            _buildInfoRow(
              'Jumlah:',
              FormatUang.formatMataUang(transaksi.jumlah),
            ),
            _buildInfoRow('Tipe:', transaksi.tipe.name),
            // diubah: Menampilkan nama paket dari objek yang diterima.
            if (paket != null)
              _buildInfoRow('Paket:', paket!.nama)
            else if (transaksi.idPaket != null)
              _buildInfoRow('Paket:', 'Memuat...'),
            _buildInfoRow(
              'Status Pembayaran:',
              transaksi.statusPembayaran.name,
            ),
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
              'Poin didapat:',
              transaksi.poinYangDihasilkan.toString(),
            ),
            _buildInfoRow(
              'Poin digunakan:',
              transaksi.poinYangDigunakan.toString(),
            ),
          ],
        ),
      ),
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
