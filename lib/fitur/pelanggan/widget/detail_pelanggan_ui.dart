// path: lib/fitur/pelanggan/widget/detail_pelanggan_ui.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/poin/widget/kartu_total_poin.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class DetailPelangganUI extends StatefulWidget {
  final PelangganModel pelanggan;
  final int totalPoin;
  final VoidCallback? navigasiKeEdit;
  final VoidCallback? navigasiKePoin;
  final VoidCallback? onCopyAll;

  const DetailPelangganUI({
    super.key,
    required this.pelanggan,
    required this.totalPoin,
    this.navigasiKeEdit,
    this.navigasiKePoin,
    this.onCopyAll,
  });

  @override
  State<DetailPelangganUI> createState() => _DetailPelangganUIState();
}

class _DetailPelangganUIState extends State<DetailPelangganUI> {
  Future<void> _salinInformasi(String label, String data) async {
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
  Widget build(BuildContext context) {
    Log.info(
      'Membangun CustomerDetailUI untuk pelanggan: ${widget.pelanggan.nama}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pelanggan'),
        actions: [
          if (widget.navigasiKeEdit != null)
            IconButton(
              icon: const Icon(TIcons.edit),
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
            _buildKartuPoin(),
            gapH24,
            _buildBagianInformasiPelanggan(),
            gapH24,
            if (widget.onCopyAll != null) _buildTombolSalinSemua(),
          ],
        ),
      ),
    );
  }

  Widget _buildKartuPoin() {
    return KartuTotalPoin(
      poin: widget.totalPoin,
      onTap: () {
        if (widget.navigasiKePoin != null) {
          Log.info('Kartu Poin ditekan, navigasi ke halaman poin.');
          widget.navigasiKePoin!();
        }
      },
    );
  }

  Widget _buildBagianInformasiPelanggan() {
    return Column(
      children: [
        _buildBarisDetail('Nama', widget.pelanggan.nama, () async {
          await _salinInformasi('Nama', widget.pelanggan.nama);
        }),
        _buildBarisDetail('Telepon', widget.pelanggan.telepon, () async {
          await _salinInformasi('No Telepon', widget.pelanggan.telepon);
        }),
        _buildBarisDetail('Alamat', widget.pelanggan.alamat, () async {
          await _salinInformasi('Alamat', widget.pelanggan.alamat);
        }),
        _buildBarisDetail('Password', widget.pelanggan.kataSandi, () async {
          await _salinInformasi('Password', widget.pelanggan.kataSandi);
        }),
        _buildBarisDetail('MAC Address', widget.pelanggan.macAddress, () async {
          await _salinInformasi('MAC Address', widget.pelanggan.macAddress);
        }),
      ],
    );
  }

  Widget _buildTombolSalinSemua() {
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

  Widget _buildBarisDetail(
    final String judul,
    final String isiInformasi,
    final VoidCallback salinInformasi,
  ) {
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
          gapH4,
          Row(
            children: [
              Expanded(
                child: Text(
                  isiInformasi.isEmpty ? '-' : isiInformasi,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: salinInformasi,
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
