// path: lib/admin/halaman/detail/detail_riwayat_langganan.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Halaman untuk menampilkan detail transaksi langganan.
class DetailLanggananTransaksiPage extends StatefulWidget {
  /// ID transaksi yang akan ditampilkan.
  final String idTransaksi;

  /// Konstruktor untuk DetailLanggananTransaksiPage.
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
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman detail langganan transaksi.');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Langganan')), // TODO: rencana selanjutnya adalah menambahkan tombol edit
      body: FutureBuilder<TransaksiModel?>(
        future: _transaksiFuture,
        builder: (final context, final snapshot) {
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
              e: snapshot.error,
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
                    (final pelanggan) => [
                      _buildDetailRow(
                        'Nama Pelanggan',
                        pelanggan?.nama ?? 'Tidak Diketahui',
                      ),
                    ],
                    onTap: (final pelanggan) {
                      if (pelanggan != null) {
                        unawaited(Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (final context) => DetailPelangganPage(
                              idPelanggan: pelanggan.id,
                            ),
                          ),
                        ));
                      }
                    },
                  ),
                const SizedBox(height: 16),
                if (transaksi.idPaket != null)
                  _buildFutureInfoCard<PaketModel>(
                    'Informasi Paket',
                    _paketOperasi.getPaketById(transaksi.idPaket!),
                    'Paket',
                    (final paket) => [
                      _buildDetailRow(
                        'Nama Paket',
                        paket?.nama ?? 'Tidak Diketahui',
                      ),// Info nama paket
                      _buildDetailRow(
                        'Harga',
                        FormatUang.formatMataUang(paket?.harga.toDouble() ?? 0),
                      ), // info harga paket
                      _buildDetailRow(
                        'Durasi',
                        '${paket?.durasi ?? 0} ${paket?.tipe.name ?? ""}',
                      ),
                    ], // info durasi paket
                    onTap: (final paket) {
                      if (paket != null) {
                        unawaited(Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (final context) => DetailPaketPage(
                              paket: paket,
                            ),
                          ),
                        ));
                      }
                    },
                  ),
                const SizedBox(height: 16),
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

  Widget _buildInfoPoin(final TransaksiModel transaksi) {
    Log.info('Membangun widget informasi poin transaksi.');

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
      _buildDetailRowWithColor(
        'Poin Dihasilkan',
        '+${transaksi.poinYangDihasilkan} Poin',
        transaksi.poinYangDihasilkan > 0 ? Colors.green : null,
        transaksi.poinYangDihasilkan > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      _buildDetailRowWithColor(
        'Poin Digunakan',
        '-${transaksi.poinYangDigunakan} Poin',
        transaksi.poinYangDigunakan > 0 ? Colors.red : null,
        transaksi.poinYangDigunakan > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      const Divider(height: 16),
      _buildDetailRowWithColor(
        isPenambahan ? 'Total Poin Bertambah' : 'Total Poin Berkurang',
        '${selisihPoin >= 0 ? "+" : ""}$selisihPoin Poin',
        isPenambahan ? Colors.green : Colors.red,
        FontWeight.bold,
        fontSize: 16,
      ),
    ]);
  }

  Widget _buildInfoCard(final String title, final List<Widget> children,
      {final VoidCallback? onTap}) {
    Log.info('Membangun info card dengan judul: $title.');

    final cardContent = Card(
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

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }

  Widget _buildFutureInfoCard<T>(
    final String title,
    final Future<T?> future,
    final String tag,
    final List<Widget> Function(T? data) builder, {
    final void Function(T? data)? onTap,
  }) {
    Log.info('Membangun Future info card untuk data $tag.');

    return FutureBuilder<T?>(
      future: future,
      builder: (final context, final snapshot) {
        Log.info(
          'FutureBuilder $tag dijalankan dengan state: ${snapshot.connectionState}.',
        );

        VoidCallback? resolvedOnTap;
        if (onTap != null &&
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            snapshot.hasData) {
          resolvedOnTap = () => onTap(snapshot.data);
        }

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
          Log.error('Gagal memuat data $tag.', e: snapshot.error);
          return _buildInfoCard(title, [const Text('Gagal memuat data')]);
        }

        if (snapshot.hasData) {
          Log.info('Data $tag berhasil dimuat secara asynchronous.');
        } else {
          Log.warning('Data $tag tidak ditemukan.');
        }

        return _buildInfoCard(title, builder(snapshot.data),
            onTap: resolvedOnTap);
      },
    );
  }

  Widget _buildDetailRow(final String label, final String value) {
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

  Widget _buildDetailRowWithColor(
    final String label,
    final String value,
    final Color? valueColor,
    final FontWeight fontWeight, {
    final double fontSize = 14,
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
