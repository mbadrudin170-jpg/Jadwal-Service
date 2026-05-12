

// path: lib/admin/halaman/detail/detail_riwayat_langganan.dart
//// diubah: File ini sekarang menampilkan detail transaksi langganan dari TransaksiModel.
// ditambahkan: Widget untuk menampilkan informasi poin yang dihasilkan dan digunakan.

import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:flutter/material.dart';

class DetailLanggananTransaksiPage extends StatefulWidget {
  final String idTransaksi;

  const DetailLanggananTransaksiPage({super.key, required this.idTransaksi});

  @override
  State<DetailLanggananTransaksiPage> createState() =>
      _DetailLanggananTransaksiPageState();
}

class _DetailLanggananTransaksiPageState
    extends State<DetailLanggananTransaksiPage> {
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  late Future<TransaksiModel?> _transaksiFuture;

  @override
  void initState() {
    super.initState();

    Log.info(
      'Memulai inisialisasi halaman detail langganan untuk ID transaksi: ${widget.idTransaksi}.',
    );

    _transaksiFuture = _transaksiOperasi.getTransaksiById(widget.idTransaksi);

    Log.info(
      'Future transaksi berhasil dibuat untuk proses pengambilan data transaksi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman detail langganan transaksi.');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Langganan')),
      body: FutureBuilder<TransaksiModel?>(
        future: _transaksiFuture,
        builder: (context, snapshot) {
          Log.info(
            'FutureBuilder transaksi dijalankan dengan state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info('Data transaksi masih dalam proses loading.');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            Log.error(
              'Terjadi kesalahan saat mengambil data transaksi.',
              error: snapshot.error,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transaksi = snapshot.data;

          if (transaksi == null) {
            Log.warning('Data transaksi tidak ditemukan di database.');
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }

          Log.info(
            'Berhasil memuat data transaksi dengan ID: ${transaksi.id}.',
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                if (transaksi.idPelanggan != null)
                  _buildFutureInfoCard<PelangganModel>(
                    'Informasi Pelanggan',
                    _pelangganOperasi.getPelangganById(transaksi.idPelanggan!),
                    'Pelanggan',
                    (pelanggan) => [
                      _buildDetailRow(
                        'Nama Pelanggan',
                        pelanggan?.nama ?? 'Tidak Diketahui',
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (transaksi.idPaket != null)
                  _buildFutureInfoCard<PaketModel>(
                    'Informasi Paket',
                    _paketOperasi.getPaketById(transaksi.idPaket!),
                    'Paket',
                    (paket) => [
                      _buildDetailRow(
                        'Nama Paket',
                        paket?.nama ?? 'Tidak Diketahui',
                      ),
                      _buildDetailRow(
                        'Harga',
                        FormatUang.formatMataUang(paket?.harga.toDouble() ?? 0),
                      ),
                      _buildDetailRow(
                        'Durasi',
                        '${paket?.durasi ?? 0} ${paket?.tipe.name ?? ""}',
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // ditambahkan: Widget informasi poin
                _buildInfoPoin(transaksi),
                const SizedBox(height: 16),
                if (transaksi.tanggalMulai != null &&
                    transaksi.tanggalBerakhir != null)
                  _buildInfoCard('Waktu Langganan', [
                    _buildDetailRow(
                      'Tanggal Mulai',
                      FormatTanggal.formatTanggalDanJam(
                        transaksi.tanggalMulai!,
                      ),
                    ),
                    _buildDetailRow(
                      'Tanggal Berakhir',
                      FormatTanggal.formatTanggalDanJam(
                        transaksi.tanggalBerakhir!,
                      ),
                    ),
                  ]),
                const SizedBox(height: 16),
                _buildInfoCard('Status', [
                  _buildDetailRow(
                    'Status Pembayaran',
                    transaksi.statusPembayaran.name.toUpperCase(),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ditambahkan: Widget untuk menampilkan informasi poin
  Widget _buildInfoPoin(TransaksiModel transaksi) {
    Log.info('Membangun widget informasi poin transaksi.');

    // Jika tidak ada perubahan poin, tidak perlu menampilkan widget
    if (transaksi.poinYangDihasilkan == 0 && transaksi.poinYangDigunakan == 0) {
      Log.info('Tidak ada perubahan poin pada transaksi ini.');
      return const SizedBox.shrink();
    }

    final isPenambahan =
        transaksi.poinYangDihasilkan > transaksi.poinYangDigunakan;
    final selisihPoin =
        transaksi.poinYangDihasilkan - transaksi.poinYangDigunakan;

    Log.info(
      'Poin dihasilkan: ${transaksi.poinYangDihasilkan}, '
      'Poin digunakan: ${transaksi.poinYangDigunakan}, '
      'Selisih: $selisihPoin poin (${isPenambahan ? "PENAMBAHAN" : "PENGURANGAN"}).',
    );

    return _buildInfoCard('Informasi Poin', [
      // Poin yang dihasilkan
      _buildDetailRowWithColor(
        'Poin Dihasilkan',
        '+${transaksi.poinYangDihasilkan} Poin',
        transaksi.poinYangDihasilkan > 0 ? Colors.green : null,
        transaksi.poinYangDihasilkan > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      // Poin yang digunakan
      _buildDetailRowWithColor(
        'Poin Digunakan',
        '-${transaksi.poinYangDigunakan} Poin',
        transaksi.poinYangDigunakan > 0 ? Colors.red : null,
        transaksi.poinYangDigunakan > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      const Divider(height: 16),
      // Total perubahan poin
      _buildDetailRowWithColor(
        isPenambahan ? 'Total Poin Bertambah' : 'Total Poin Berkurang',
        '${selisihPoin >= 0 ? "+" : ""}$selisihPoin Poin',
        isPenambahan ? Colors.green : Colors.red,
        FontWeight.bold,
        fontSize: 16,
      ),
    ]);
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    Log.info('Membangun info card dengan judul: $title.');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFutureInfoCard<T>(
    String title,
    Future<T?> future,
    String tag,
    List<Widget> Function(T? data) builder,
  ) {
    Log.info('Membangun Future info card untuk data $tag.');

    return FutureBuilder<T?>(
      future: future,
      builder: (context, snapshot) {
        Log.info(
          'FutureBuilder $tag dijalankan dengan state: ${snapshot.connectionState}.',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Data $tag masih dalam proses loading.');
          return _buildInfoCard(title, [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ]);
        }

        if (snapshot.hasError) {
          Log.error('Gagal memuat data $tag.', error: snapshot.error);
          return _buildInfoCard(title, [const Text('Gagal memuat data')]);
        }

        if (snapshot.hasData) {
          Log.info('Data $tag berhasil dimuat secara asynchronous.');
        } else {
          Log.warning('Data $tag tidak ditemukan.');
        }

        return _buildInfoCard(title, builder(snapshot.data));
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    Log.info('Membangun detail row dengan label: $label dan value: $value.');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ditambahkan: Widget detail row dengan kustomisasi warna dan style
  Widget _buildDetailRowWithColor(
    String label,
    String value,
    Color? valueColor,
    FontWeight fontWeight, {
    double fontSize = 14,
  }) {
    Log.info(
      'Membangun detail row berwarna dengan label: $label dan value: $value.',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: fontWeight,
                color: valueColor,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
