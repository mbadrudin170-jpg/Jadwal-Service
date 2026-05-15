// path: lib/shared/widget/detail_pelanggan_ui.dart
// diubah: Menghapus BuildContext dari parameter _salinData.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/card/point_card.dart';

/// Halaman UI untuk menampilkan detail profil pelanggan.
///
/// Menampilkan informasi lengkap pelanggan seperti nama, telepon, alamat,
/// password, MAC address, dan total poin. Setiap informasi dapat disalin
/// ke clipboard.
class DetailPelangganUI extends StatefulWidget {
  /// Data pelanggan yang akan ditampilkan.
  final PelangganModel pelanggan;

  /// Total poin yang dimiliki pelanggan.
  final int totalPoin;

  /// Callback saat tombol edit ditekan.
  final VoidCallback? onEdit;

  /// Callback saat kartu poin ditekan untuk navigasi.
  final VoidCallback? onNavigateToPoin;

  /// Callback saat tombol salin semua info ditekan.
  final VoidCallback? onCopyAll;

  /// Membuat halaman [DetailPelangganUI].
  ///
  /// [pelanggan] dan [totalPoin] wajib diisi.
  const DetailPelangganUI({
    super.key,
    required this.pelanggan,
    required this.totalPoin,
    this.onEdit,
    this.onNavigateToPoin,
    this.onCopyAll,
  });

  @override
  State<DetailPelangganUI> createState() => _DetailPelangganUIState();
}

class _DetailPelangganUIState extends State<DetailPelangganUI> {
  // diubah: Hapus parameter BuildContext, gunakan context dari State
  Future<void> _salinData(final String label, final String data) async {
    if (!mounted) return;

    if (data.isEmpty) {
      Log.warning('Tidak ada data untuk disalin pada label: $label');
      SnackBarUtil.warning(context, 'Tidak ada data untuk disalin.');
      return;
    }
    Log.info('Menyalin data untuk label: $label, data: $data');
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    SnackBarUtil.success(context, '$label berhasil disalin');
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun DetailPelangganUI untuk pelanggan: ${widget.pelanggan.nama}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pelanggan'),
        actions: [
          if (widget.onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profil',
              onPressed: () {
                Log.info('Tombol Edit ditekan.');
                widget.onEdit!();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TotalPointCard(
              points: widget.totalPoin,
              onTap: () {
                if (widget.onNavigateToPoin != null) {
                  Log.info('Kartu Poin ditekan, navigasi ke halaman poin.');
                  widget.onNavigateToPoin!();
                }
              },
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Nama', widget.pelanggan.nama, () async {
              await _salinData('Nama', widget.pelanggan.nama);
            }),
            const Divider(),
            _buildDetailRow('Telepon', widget.pelanggan.telepon, () async {
              await _salinData('No Telepon', widget.pelanggan.telepon);
            }),
            const Divider(),
            _buildDetailRow('Alamat', widget.pelanggan.alamat, () async {
              await _salinData('Alamat', widget.pelanggan.alamat);
            }),
            const Divider(),
            _buildDetailRow('Password', widget.pelanggan.password, () async {
              await _salinData('Password', widget.pelanggan.password);
            }),
            const Divider(),
            _buildDetailRow('MAC Address', widget.pelanggan.macAddress, () async {
              await _salinData('MAC Address', widget.pelanggan.macAddress);
            }),
            const SizedBox(height: 24),
            if (widget.onCopyAll != null)
              ElevatedButton.icon(
                onPressed: () {
                  Log.info('Tombol Salin Semua Info ditekan.');
                  widget.onCopyAll!();
                },
                icon: const Icon(Icons.copy_all),
                label: const Text('Salin Semua Info'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    final String judul,
    final String detail,
    final VoidCallback salinData,
  ) {
    Log.info('Membangun baris detail untuk: $judul');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.isEmpty ? '-' : detail,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: salinData,
                icon: const Icon(Icons.content_copy, size: 20),
                color: Colors.grey,
                tooltip: 'Salin $judul',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
