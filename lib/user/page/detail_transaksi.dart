// path: lib/user/page/detail_transaksi.dart
// diubah: Mengimpor dan menggunakan fungsi hitungStatusMasaAktif yang telah diperbarui.
import 'package:flutter/material.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/user/core/utils/format_tanggal.dart';
import 'package:wifi/user/hooks/hitung_masa_aktif.dart';

class DetailTransaksiPage extends StatelessWidget {
  final TransaksiModel riwayat; // diubah
  final PelangganModel pelanggan;

  const DetailTransaksiPage({
    super.key,
    required this.riwayat,
    required this.pelanggan,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailTransaksiView(
      riwayat: riwayat,
      pelanggan: pelanggan,
    );
  }
}

class _DetailTransaksiView extends StatefulWidget {
  final TransaksiModel riwayat; // diubah
  final PelangganModel pelanggan;

  const _DetailTransaksiView({
    required this.riwayat,
    required this.pelanggan,
  });

  @override
  State<_DetailTransaksiView> createState() => _DetailTransaksiViewState();
}

class _DetailTransaksiViewState extends State<_DetailTransaksiView> {
  @override
  Widget build(BuildContext context) {
    // diubah: Logika untuk mendapatkan status dan warna masa aktif dipindahkan ke sini.
    final statusMasaAktif =
        hitungStatusMasaAktif(widget.riwayat.tanggalBerakhir);
    final String teksMasaAktif = statusMasaAktif['teks'];
    final Color warnaMasaAktif = statusMasaAktif['warna'];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Transaksi'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, 'Nama Pelanggan', widget.pelanggan.nama),
              const SizedBox(height: 12),
              _buildInfoRow(
                  context, 'Nama Paket', widget.riwayat.namaPaket), // diubah
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Status Pembayaran',
                  widget.riwayat.status.toString().split('.').last),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Tanggal Pembelian',
                  formatShortDateTime(widget.riwayat.tanggalMulai)),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Tanggal Berakhir',
                  formatShortDateTime(widget.riwayat.tanggalBerakhir)),
              const SizedBox(height: 12),
              // diubah: Memanggil _buildInfoRow dengan menyertakan warna.
              _buildInfoRow(context, 'Masa Aktif', teksMasaAktif,
                  valueColor: warnaMasaAktif),
            ],
          ),
        ));
  }

  // diubah: Menambahkan parameter opsional `valueColor` untuk mewarnai teks nilai.
  Widget _buildInfoRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
        ),
        const Text(": "),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor, // diubah: Menerapkan warna jika ada.
                ),
          ),
        ),
      ],
    );
  }
}
