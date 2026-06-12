// path: lib/shared/widget/page/customer_detail_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/card/point_card.dart';

/// Halaman UI untuk menampilkan detail profil pelanggan.
///
/// Menampilkan informasi lengkap pelanggan seperti nama, telepon, alamat,
/// password, MAC address, dan total poin. Setiap informasi dapat disalin
/// ke clipboard.
class CustomerDetailUI extends StatefulWidget {
  /// Data pelanggan yang akan ditampilkan.
  final PelangganModel pelanggan;

  /// Total poin yang dimiliki pelanggan.
  final int totalPoin;

  /// Callback saat tombol edit ditekan.
  final VoidCallback? onEdit;

  /// Callback saat kartu poin ditekan untuk navigasi.
  final VoidCallback? onNavigateToPoints;

  /// Callback saat tombol salin semua info ditekan.
  final VoidCallback? onCopyAll;

  /// Membuat halaman [CustomerDetailUI].
  const CustomerDetailUI({
    super.key,
    required this.pelanggan,
    required this.totalPoin,
    this.onEdit,
    this.onNavigateToPoints,
    this.onCopyAll,
  });

  @override
  State<CustomerDetailUI> createState() => _CustomerDetailUIState();
}

class _CustomerDetailUIState extends State<CustomerDetailUI> {
  Future<void> _copyData(final String label, final String data) async {
    if (!mounted) return;

    if (data.isEmpty) {
      Log.warning('Tidak ada data untuk disalin pada label: $label');
      ToastUtil.warning(context, 'Tidak ada data untuk disalin.');
      return;
    }
    Log.info('Menyalin data untuk label: $label');
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    ToastUtil.success(context, '$label berhasil disalin');
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun CustomerDetailUI untuk pelanggan: ${widget.pelanggan.name}',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPointCard(),
            gapH24,
            _buildCustomerInfoSection(),
            gapH24,
            if (widget.onCopyAll != null) _buildCopyAllButton(),
          ],
        ),
      ),
    );
  }

  /// Membangun kartu yang menampilkan total poin pelanggan.
  Widget _buildPointCard() {
    return TotalPointCard(
      points: widget.totalPoin,
      onTap: () {
        if (widget.onNavigateToPoints != null) {
          Log.info('Kartu Poin ditekan, navigasi ke halaman poin.');
          widget.onNavigateToPoints!();
        }
      },
    );
  }

  /// Membangun bagian yang menampilkan semua detail informasi pelanggan.
  Widget _buildCustomerInfoSection() {
    return Column(
      children: [
        _buildDetailRow('Nama', widget.pelanggan.name, () async {
          await _copyData('Nama', widget.pelanggan.name);
        }),
        _buildDetailRow('Telepon', widget.pelanggan.phone, () async {
          await _copyData('No Telepon', widget.pelanggan.phone);
        }),
        _buildDetailRow('Alamat', widget.pelanggan.address, () async {
          await _copyData('Alamat', widget.pelanggan.address);
        }),
        _buildDetailRow('Password', widget.pelanggan.password, () async {
          await _copyData('Password', widget.pelanggan.password);
        }),
        _buildDetailRow('MAC Address', widget.pelanggan.macAddress, () async {
          await _copyData('MAC Address', widget.pelanggan.macAddress);
        }),
      ],
    );
  }

  /// Membangun tombol untuk menyalin semua informasi pelanggan.
  Widget _buildCopyAllButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Log.info('Tombol Salin Semua Info ditekan.');
        widget.onCopyAll!();
      },
      icon: const Icon(Icons.copy_all),
      label: const Text('Salin Semua Info'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 45),
      ),
    );
  }

  /// Membangun baris detail individu (misal: Nama, Telepon).
  Widget _buildDetailRow(
    final String title,
    final String detail,
    final VoidCallback onCopy,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blueGrey,
            ),
          ),
          gapH4,
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.isEmpty ? '-' : detail,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.content_copy, size: 20),
                color: Colors.grey,
                tooltip: 'Salin $title',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
