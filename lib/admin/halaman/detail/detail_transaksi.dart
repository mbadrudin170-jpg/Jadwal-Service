// path: lib/admin/halaman/detail/detail_transaksi.dart// Halaman ini menampilkan detail dari satu transaksi.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/form/form_transaksi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/wallet_operasi.dart';
import 'package:wifi/shared/operasi/category_operasi.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/sub_category_operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Halaman untuk menampilkan detail dari sebuah transaksi.
class DetailTransaksiPage extends StatefulWidget {
  /// Model transaksi yang akan ditampilkan.
  final TransactionModel transaksi;

  /// Konstruktor untuk DetailTransaksiPage.
  const DetailTransaksiPage({super.key, required this.transaksi});

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  final WalletOperation _dompetOperasi = WalletOperation();
  final CategoryOperation _kategoriOperasi = CategoryOperation();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final SubCategoryOperation _subKategoriOperasi = SubCategoryOperation();

  late TransactionModel
      _transaksiSaatIni; // ditambah: Variabel state untuk menampung data transaksi

  @override
  void initState() {
    super.initState();
    _transaksiSaatIni =
        widget.transaksi; // ditambah: Inisialisasi dengan data awal
    Log.info('Membuka halaman Detail Transaksi ID: ${_transaksiSaatIni.id}');
    Log.info(
      'Ringkasan transaksi - Tipe: ${_transaksiSaatIni.type.name}, Jumlah: ${_transaksiSaatIni.amount}, Tanggal: ${_transaksiSaatIni.date.toIso8601String()}, Status: ${_transaksiSaatIni.paymentStatus.name}',
    );
    Log.info(
      'Relasi transaksi - Dompet: ${_transaksiSaatIni.walletId}, Kategori: ${_transaksiSaatIni.categoryId}, SubKategori: ${_transaksiSaatIni.subCategoryId ?? "N/A"}, Pelanggan: ${_transaksiSaatIni.customerId ?? "N/A"}, Paket: ${_transaksiSaatIni.packageId ?? "N/A"}',
    );
  }

  // DIUBAH: Logika diperkuat dengan pengecekan tipe eksplisit untuk mencegah error.
  Future<String?> _getNama(
    final Future<dynamic> Function(String) getModel,
    final String id,
    final String konteks,
  ) async {
    if (id.isEmpty) {
      Log.info('ID $konteks kosong, mengembalikan null');
      return null;
    }

    try {
      Log.info('Mengambil data $konteks dengan ID: $id');
      final model = await getModel(id);

      if (model != null) {
        String? nama;
        // diubah: Menggunakan pengecekan tipe eksplisit (is) untuk keamanan akses properti.
        if (model is WalletModel) {
          nama = model.name;
        } else if (model is CategoryModel) {
          nama = model.name;
        } else if (model is SubCategoryModel) {
          nama = model.name;
        } else if (model is PelangganModel) {
          nama = model.nama;
        } else if (model is PaketModel) {
          nama = model.nama;
        }

        if (nama != null) {
          Log.info('Data $konteks ID: $id ditemukan: $nama');
          return nama;
        } else {
          Log.warning(
            'Model untuk $konteks ID: $id ditemukan, tetapi properti nama yang relevan tidak dapat diakses atau null. Tipe model: ${model.runtimeType}',
          );
          return 'Nama tidak tersedia';
        }
      }

      Log.warning('Data $konteks dengan ID: $id tidak ditemukan di database');
      return 'Data tidak ditemukan';
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil data $konteks dengan ID: $id',
        e: e,
        st: st,
      );
      return 'Error Memuat';
    }
  }

  // diubah: me-refresh data transaksi setelah kembali dari halaman edit
  Future<void> _bukaFormEdit() async {
    Log.info(
      'Navigasi ke FormTransaksiPage mode edit untuk ID: ${_transaksiSaatIni.id}',
    );
    final transaksiYangDiperbarui = await Navigator.push<TransactionModel?>(
      context,
      MaterialPageRoute<TransactionModel?>(
        builder: (final context) =>
            FormTransaksiPage(transaksi: _transaksiSaatIni),
      ),
    );
    if (transaksiYangDiperbarui != null) {
      Log.info('Kembali dari form edit, data telah berubah. Memperbarui UI.');
      setState(() {
        _transaksiSaatIni = transaksiYangDiperbarui;
      });
    } else {
      Log.info('Kembali dari form edit, tidak ada perubahan data.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    final TransactionModel transaksi =
        _transaksiSaatIni; // diubah: Menggunakan data dari state
    Log.info('Membangun UI Detail Transaksi ID: ${transaksi.id}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'Kembali ke halaman sebelumnya dari Detail Transaksi ID: ${transaksi.id}',
            );
            Navigator.pop(context);
          },
        ),
        // ditambah: tombol aksi untuk edit
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _bukaFormEdit,
            tooltip: 'Edit Transaksi',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Keterangan', transaksi.description),
            _buildDetailRow(
              'Tanggal',
              FormatTanggal.formatTanggalDanJam(transaksi.date),
            ),
            _buildDetailRow(
              'Jumlah',
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
              ).format(transaksi.amount),
            ),
            _buildDetailRow('Tipe', transaksi.type.name.toUpperCase()),
            _buildFutureDetailRow(
              'Dompet',
              _getNama(
                _dompetOperasi.getDompetById,
                transaksi.walletId,
                'Dompet',
              ),
            ),
            if (transaksi.destinationWalletId != null &&
                transaksi.destinationWalletId!.isNotEmpty)
              _buildFutureDetailRow(
                'Dompet Tujuan',
                _getNama(
                  _dompetOperasi.getDompetById,
                  transaksi.destinationWalletId!,
                  'Dompet Tujuan',
                ),
              ),
            _buildFutureDetailRow(
              'Kategori',
              _getNama(
                _kategoriOperasi.getKategoriById,
                transaksi.categoryId,
                'Kategori',
              ),
            ),
            if (transaksi.subCategoryId != null &&
                transaksi.subCategoryId!.isNotEmpty)
              _buildFutureDetailRow(
                'Sub Kategori',
                _getNama(
                  _subKategoriOperasi.getSubKategoriById,
                  transaksi.subCategoryId!,
                  'Sub-Kategori',
                ),
              ),
            if (transaksi.customerId != null &&
                transaksi.customerId!.isNotEmpty)
              _buildFutureDetailRow(
                'Pelanggan',
                _getNama(
                  _pelangganOperasi.getPelangganById,
                  transaksi.customerId!,
                  'Pelanggan',
                ),
              ),
            if (transaksi.packageId != null && transaksi.packageId!.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getNama(
                  _paketOperasi.getPaketById,
                  transaksi.packageId!,
                  'Paket',
                ),
              ),
            _buildDetailRow(
              'Status Pembayaran',
              transaksi.paymentStatus.name.toUpperCase(),
            ),
            _buildDetailRow(
              'Poin Dihasilkan',
              transaksi.earnedPoints.toString(),
            ),
            _buildDetailRow(
              'Poin Digunakan',
              transaksi.usedPoints.toString(),
            ),
            if (transaksi.startDate != null)
              _buildDetailRow(
                'Masa Aktif Mulai',
                FormatTanggal.formatTanggalDanJam(transaksi.startDate!),
              ),
            if (transaksi.endDate != null)
              _buildDetailRow(
                'Masa Aktif Berakhir',
                FormatTanggal.formatTanggalDanJam(transaksi.endDate!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(final String label, final String value) {
    Log.info('Membangun baris detail - $label: $value');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildFutureDetailRow(
      final String label, final Future<String?> future) {
    Log.info('Membangun FutureBuilder untuk: $label');
    return FutureBuilder<String?>(
      future: future,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('FutureBuilder $label: masih loading');
          return _buildDetailRow(label, 'Memuat...');
        }
        if (snapshot.hasError) {
          Log.error(
            'FutureBuilder $label: error',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return _buildDetailRow(label, 'Error Data');
        }
        final data = snapshot.data ?? '-';
        Log.info('FutureBuilder $label: selesai dengan data "$data"');
        return _buildDetailRow(label, data);
      },
    );
  }
}
