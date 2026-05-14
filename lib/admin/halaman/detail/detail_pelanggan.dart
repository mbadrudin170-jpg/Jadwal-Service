// path: lib/admin/halaman/detail/detail_pelanggan.dart
// diubah: Menggunakan PoinPageAdmin dan mengirimkan idPelanggan, serta memperbaiki unawaited future.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan.dart';
import 'package:wifi/admin/halaman/pembantu/halaman_poin_admin.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/detail_pelanggan_ui.dart';

/// Halaman untuk menampilkan detail pelanggan.
class DetailPelangganPage extends StatefulWidget {
  /// ID pelanggan yang akan ditampilkan.
  final String idPelanggan;

  /// Konstruktor untuk DetailPelangganPage.
  const DetailPelangganPage({super.key, required this.idPelanggan});

  @override
  State<DetailPelangganPage> createState() => _DetailPelangganPageState();
}

class _DetailPelangganPageState extends State<DetailPelangganPage> {
  final PelangganOperasi pelangganOperasi = PelangganOperasi();
  final TransaksiOperasi transaksiOperasi = TransaksiOperasi();

  PelangganModel? pelanggan;
  int totalPoin = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai initState pada DetailPelangganPage untuk ID: ${widget.idPelanggan}.',
    );
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    Log.info('Memulai pengambilan data dari SQLite.');
    try {
      if (mounted) {
        setState(() => isLoading = true);
      }

      final hasilPelanggan = await pelangganOperasi.getPelangganById(
        widget.idPelanggan,
      );
      final hasilPoin = await transaksiOperasi.getTotalPoin(widget.idPelanggan);

      if (!mounted) return;

      setState(() {
        pelanggan = hasilPelanggan;
        totalPoin = hasilPoin;
        isLoading = false;
      });

      Log.info(
        'Pengambilan data dari SQLite selesai. Pelanggan: ${pelanggan?.nama}, Poin: $totalPoin',
      );
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil data dari SQLite.', e: e, st: s);
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _editPelanggan() async {
    if (pelanggan == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => FormPelanggan(pelanggan: pelanggan),
      ),
    );
    if (result == true && mounted) {
      Log.info('Kembali dari edit, memuat ulang data dari SQLite.');
      await _loadData();
    }
  }

  Future<void> _salinSemuaInfo(PelangganModel pelanggan) async {
    final info = '''
Nama : ${pelanggan.nama}
No HP : ${pelanggan.telepon}
Alamat : ${pelanggan.alamat}
Password : ${pelanggan.password}
MAC : ${pelanggan.macAddress}
'''
        .trim();

    await Clipboard.setData(ClipboardData(text: info));
    if (!mounted) return;
    SnackBarUtil.showSuccess(context, 'Informasi pelanggan berhasil disalin.');
  }

  Future<void> _navigateToPoin() async {
    if (pelanggan == null) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        // diubah: Menggunakan PoinPageAdmin dan mengirim idPelanggan.
        builder: (context) => PoinPageAdmin(idPelanggan: pelanggan!.id),
      ),
    );
    Log.info('Kembali dari halaman poin, memuat ulang data dari SQLite.');
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat Detail...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (pelanggan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const Center(child: Text('Pelanggan tidak ditemukan')),
      );
    }

    return DetailPelangganUI(
      pelanggan: pelanggan!,
      totalPoin: totalPoin,
      onEdit: _editPelanggan,
      onNavigateToPoin: _navigateToPoin,
      onCopyAll: () => _salinSemuaInfo(pelanggan!),
    );
  }
}
