// file: lib/fitur/pelanggan/page/admin/detail_pelanggan.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/admin/form_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/poin/page/halaman_poin.dart';
import 'package:wifi/fitur/poin/widget/kartu_total_poin.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class DetailPelanggan extends ConsumerStatefulWidget {
  final String idPelanggan;

  const DetailPelanggan({super.key, required this.idPelanggan});

  @override
  ConsumerState<DetailPelanggan> createState() => _DetailPelangganState();
}

class _DetailPelangganState extends ConsumerState<DetailPelanggan> {
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

  Future<void> _salinSemuaInfo(
    BuildContext context,
    PelangganModel customer,
    int totalPoin,
  ) async {
    Log.info('Menyalin info pelanggan: ${customer.nama}');
    final info =
        '''
Nama : ${customer.nama}
No HP : ${customer.telepon}
Alamat : ${customer.alamat}
Password : ${customer.kataSandi}
MAC : ${customer.macAddress}
Poin: $totalPoin
'''
            .trim();

    await Clipboard.setData(ClipboardData(text: info));
    if (context.mounted) {
      ToastUtil.success(context, 'Informasi pelanggan berhasil disalin.');
    }
  }

  void _editPelanggan(BuildContext context, PelangganModel pelanggan) {
    Log.info('Navigasi ke form edit pelanggan: ${pelanggan.nama}');
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => FormPelanggan(pelanggan: pelanggan),
        ),
      ),
    );
  }

  Future<void> _navigasiKePoin(
    BuildContext context,
    PelangganModel pelanggan,
  ) async {
    Log.info('Navigasi ke halaman poin pelanggan: ${pelanggan.nama}');
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => HalamanPoin(idPelanggan: pelanggan.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(pelangganDetailProvider(widget.idPelanggan));

    // AppBar selalu tampil, body berubah sesuai state AsyncValue
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pelanggan'),
        actions: [
          // Tombol edit tetap tampil hanya jika data tersedia nanti,
          // tapi kita bisa menampilkan tombol yang memanggil fungsi edit
          // setelah data tersedia. Untuk menghindari tombol aktif tanpa data,
          // kita cek detailAsync saat ditekan.
          IconButton(
            icon: const Icon(TIcons.edit),
            tooltip: 'Edit Profil',
            onPressed: () async {
              final data = detailAsync.asData?.value;
              if (data == null) return;
              final (pelanggan, _) = data;
              if (pelanggan == null) return;
              _editPelanggan(context, pelanggan);
            },
          ),
        ],
      ),
      body: detailAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: SizedBox.shrink()),
        error: (e, s) {
          Log.error(
            'Gagal mengambil data pelanggan ID: ${widget.idPelanggan}.',
            e: e,
            s: s,
          );
          return Center(child: Text('Gagal memuat data: $e'));
        },
        data: (data) {
          final (pelanggan, totalPoin) = data;
          if (pelanggan == null) {
            return const Center(child: Text('Pelanggan tidak ditemukan'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KartuTotalPoin(
                  poin: totalPoin,
                  onTap: () => _navigasiKePoin(context, pelanggan),
                ),
                gapH24,
                _buildBagianInformasiPelanggan(pelanggan),
                gapH24,
                if (ref.isAdmin)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _salinSemuaInfo(context, pelanggan, totalPoin),
                    icon: const Icon(Icons.copy_all),
                    label: const Text('Salin Semua Info'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBagianInformasiPelanggan(PelangganModel pelanggan) {
    return Column(
      children: [
        _buildBarisDetail(
          'Nama',
          pelanggan.nama,
          () => _salinInformasi('Nama', pelanggan.nama),
        ),
        _buildBarisDetail(
          'Telepon',
          pelanggan.telepon,
          () => _salinInformasi('No Telepon', pelanggan.telepon),
        ),
        _buildBarisDetail(
          'Alamat',
          pelanggan.alamat,
          () => _salinInformasi('Alamat', pelanggan.alamat),
        ),
        if (ref.isAdmin)
          _buildBarisDetail(
            'Password',
            pelanggan.kataSandi,
            () => _salinInformasi('Password', pelanggan.kataSandi),
          ),
        _buildBarisDetail(
          'MAC Address',
          pelanggan.macAddress,
          () => _salinInformasi('MAC Address', pelanggan.macAddress),
        ),
      ],
    );
  }

  Widget _buildBarisDetail(
    String judul,
    String isiInformasi,
    Future<void> Function() salinInformasi,
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
                onPressed: () async {
                  await salinInformasi();
                },
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
