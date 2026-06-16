// path: lib/shared/widget/page/customer_detail_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/card/point_card.dart';

class CustomerDetailUI extends StatefulWidget {
  final PelangganModel pelanggan;
  final int totalPoin;
  final VoidCallback? navigasiKeEdit;
  final VoidCallback? navigasiKePoin;
  final VoidCallback? onCopyAll;

  const CustomerDetailUI({
    super.key,
    required this.pelanggan,
    required this.totalPoin,
    this.navigasiKeEdit,
    this.navigasiKePoin,
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
      'Membangun CustomerDetailUI untuk pelanggan: ${widget.pelanggan.nama}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pelanggan'),
        actions: [
          if (widget.navigasiKeEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profil',
              onPressed: () {
                Log.info('Tombol Edit ditekan.');
                widget.navigasiKeEdit!();
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

  Widget _buildPointCard() {
    return TotalPointCard(
      points: widget.totalPoin,
      onTap: () {
        if (widget.navigasiKePoin != null) {
          Log.info('Kartu Poin ditekan, navigasi ke halaman poin.');
          widget.navigasiKePoin!();
        }
      },
    );
  }

  Widget _buildCustomerInfoSection() {
    return Column(
      children: [
        _buildDetailRow('Nama', widget.pelanggan.nama, () async {
          await _copyData('Nama', widget.pelanggan.nama);
        }),
        _buildDetailRow('Telepon', widget.pelanggan.telepon, () async {
          await _copyData('No Telepon', widget.pelanggan.telepon);
        }),
        _buildDetailRow('Alamat', widget.pelanggan.alamat, () async {
          await _copyData('Alamat', widget.pelanggan.alamat);
        }),
        _buildDetailRow('Password', widget.pelanggan.kataSandi, () async {
          await _copyData('Password', widget.pelanggan.kataSandi);
        }),
        _buildDetailRow('MAC Address', widget.pelanggan.macAddress, () async {
          await _copyData('MAC Address', widget.pelanggan.macAddress);
        }),
      ],
    );
  }

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
