// path: lib/admin/halaman/detail/detail_transaksi.dart// Halaman ini menampilkan detail dari satu transaksi.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/form/form_transaksi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/kategori_operasi.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/sub_kategori_operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Halaman untuk menampilkan detail dari sebuah transaksi.
class DetailTransaksiPage extends StatefulWidget {
  /// Model transaksi yang akan ditampilkan.
  final TransaksiModel transaksi;

  /// Konstruktor untuk DetailTransaksiPage.
  const DetailTransaksiPage({super.key, required this.transaksi});

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final SubKategoriOperasi _subKategoriOperasi = SubKategoriOperasi();

  late TransaksiModel
      _transaksiSaatIni; // ditambah: Variabel state untuk menampung data transaksi

  @override
  void initState() {
    super.initState();
    _transaksiSaatIni =
        widget.transaksi; // ditambah: Inisialisasi dengan data awal
    Log.info('Membuka halaman Detail Transaksi ID: ${_transaksiSaatIni.id}');
    Log.info(
      'Ringkasan transaksi - Tipe: ${_transaksiSaatIni.tipe.name}, Jumlah: ${_transaksiSaatIni.jumlah}, Tanggal: ${_transaksiSaatIni.tanggal.toIso8601String()}, Status: ${_transaksiSaatIni.statusPembayaran.name}',
    );
    Log.info(
      'Relasi transaksi - Dompet: ${_transaksiSaatIni.idDompet}, Kategori: ${_transaksiSaatIni.idKategori}, SubKategori: ${_transaksiSaatIni.idSubKategori ?? "N/A"}, Pelanggan: ${_transaksiSaatIni.idPelanggan ?? "N/A"}, Paket: ${_transaksiSaatIni.idPaket ?? "N/A"}',
    );
  }

  // DIUBAH: Logika diperkuat dengan pengecekan tipe eksplisit untuk mencegah error.
  Future<String?> _getNama(
    Future<dynamic> Function(String) getModel,
    String id,
    String konteks,
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
        if (model is DompetModel) {
          nama = model.namaDompet;
        } else if (model is KategoriModel) {
          nama = model.nama;
        } else if (model is SubKategoriModel) {
          nama = model.nama;
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
    final transaksiYangDiperbarui = await Navigator.push<TransaksiModel?>(
      context,
      MaterialPageRoute<TransaksiModel?>(
        builder: (context) => FormTransaksiPage(transaksi: _transaksiSaatIni),
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
  Widget build(BuildContext context) {
    final TransaksiModel transaksi =
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
            _buildDetailRow('Keterangan', transaksi.keterangan),
            _buildDetailRow(
              'Tanggal',
              FormatTanggal.formatTanggalDanJam(transaksi.tanggal),
            ),
            _buildDetailRow(
              'Jumlah',
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
              ).format(transaksi.jumlah),
            ),
            _buildDetailRow('Tipe', transaksi.tipe.name.toUpperCase()),
            _buildFutureDetailRow(
              'Dompet',
              _getNama(
                _dompetOperasi.getDompetById,
                transaksi.idDompet,
                'Dompet',
              ),
            ),
            if (transaksi.idDompetTujuan != null &&
                transaksi.idDompetTujuan!.isNotEmpty)
              _buildFutureDetailRow(
                'Dompet Tujuan',
                _getNama(
                  _dompetOperasi.getDompetById,
                  transaksi.idDompetTujuan!,
                  'Dompet Tujuan',
                ),
              ),
            _buildFutureDetailRow(
              'Kategori',
              _getNama(
                _kategoriOperasi.getKategoriById,
                transaksi.idKategori,
                'Kategori',
              ),
            ),
            if (transaksi.idSubKategori != null &&
                transaksi.idSubKategori!.isNotEmpty)
              _buildFutureDetailRow(
                'Sub Kategori',
                _getNama(
                  _subKategoriOperasi.getSubKategoriById,
                  transaksi.idSubKategori!,
                  'Sub-Kategori',
                ),
              ),
            if (transaksi.idPelanggan != null &&
                transaksi.idPelanggan!.isNotEmpty)
              _buildFutureDetailRow(
                'Pelanggan',
                _getNama(
                  _pelangganOperasi.getPelangganById,
                  transaksi.idPelanggan!,
                  'Pelanggan',
                ),
              ),
            if (transaksi.idPaket != null && transaksi.idPaket!.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getNama(
                  _paketOperasi.getPaketById,
                  transaksi.idPaket!,
                  'Paket',
                ),
              ),
            _buildDetailRow(
              'Status Pembayaran',
              transaksi.statusPembayaran.name.toUpperCase(),
            ),
            _buildDetailRow(
              'Poin Dihasilkan',
              transaksi.poinYangDihasilkan.toString(),
            ),
            _buildDetailRow(
              'Poin Digunakan',
              transaksi.poinYangDigunakan.toString(),
            ),
            if (transaksi.tanggalMulai != null)
              _buildDetailRow(
                'Masa Aktif Mulai',
                FormatTanggal.formatTanggalDanJam(transaksi.tanggalMulai!),
              ),
            if (transaksi.tanggalBerakhir != null)
              _buildDetailRow(
                'Masa Aktif Berakhir',
                FormatTanggal.formatTanggalDanJam(transaksi.tanggalBerakhir!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildFutureDetailRow(String label, Future<String?> future) {
    Log.info('Membangun FutureBuilder untuk: $label');
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
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
