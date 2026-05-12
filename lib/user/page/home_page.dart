// path: lib/user/page/home_page.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/user/services/firestore_service.dart';
import 'package:wifi/shared/services/info_perangkat_service.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/user/page/detail_transaksi_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/ads/banner_ad_widget.dart';
import 'package:wifi/shared/widget/nama_paket.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final LocalStorageService localStorageService;
  const HomePage(
      {super.key, required this.userId, required this.localStorageService});

  @override
  Widget build(BuildContext context) {
    Log.info(
        'Membangun HomePage, meneruskan userId dan localStorageService ke _TampilanBeranda.');
    return _TampilanBeranda(userId: userId);
  }
}

class _TampilanBeranda extends StatefulWidget {
  final String userId;
  const _TampilanBeranda({required this.userId});

  @override
  State<_TampilanBeranda> createState() => _TampilanBerandaState();
}

class _TampilanBerandaState extends State<_TampilanBeranda> {
  final FirestoreService _firestoreService = FirestoreService();
  final InfoPerangkatService _infoPerangkatService = InfoPerangkatService();

  @override
  void initState() {
    super.initState();
    Log.info('Memulai inisialisasi state untuk _TampilanBeranda.');
    _cekArsitekturPerangkat();
    Log.info('Memulai proses sinkronisasi jadwal notifikasi.', {
      'userId': widget.userId,
    });
    _firestoreService.sinkronkanJadwalNotifikasi(widget.userId);
  }

  @override
  void dispose() {
    Log.info(
        'Membersihkan state _TampilanBeranda dan menghentikan sinkronisasi jadwal.');
    _firestoreService.hentikanSinkronisasiJadwal();
    super.dispose();
  }

  void _cekArsitekturPerangkat() async {
    Log.info('Memulai pengecekan arsitektur perangkat.');
    try {
      final arsitektur =
          await _infoPerangkatService.dapatkanArsitekturPerangkat();
      Log.info('Arsitektur Perangkat Terdeteksi.', arsitektur);
    } catch (e, st) {
      Log.error(
        'Gagal mendapatkan arsitektur perangkat.',
        e: e,
        st: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
        'Membangun UI _TampilanBeranda dengan Scaffold dan StreamBuilder.');
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        title: const Text('Beranda'),
      ),
      body: StreamBuilder<PelangganModel?>(
        stream: _firestoreService.ambilPelangganStream(widget.userId),
        builder: (context, snapshotPelanggan) {
          Log.info('Menerima update status koneksi StreamBuilder Pelanggan.', {
            'connectionState': snapshotPelanggan.connectionState.toString(),
          });

          if (snapshotPelanggan.connectionState == ConnectionState.waiting) {
            Log.info(
                'Status: Menunggu data pelanggan. Menampilkan CircularProgressIndicator.');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshotPelanggan.hasError) {
            Log.error(
              'Terjadi error saat mengambil data pelanggan.',
              e: snapshotPelanggan.error,
              st: snapshotPelanggan.stackTrace,
            );
            return Center(child: Text('Error: ${snapshotPelanggan.error}'));
          }

          if (!snapshotPelanggan.hasData || snapshotPelanggan.data == null) {
            Log.info(
                'Status: Koneksi selesai tetapi tidak ada data pelanggan.');
            return const Center(child: Text('Data pelanggan tidak ditemukan.'));
          }

          final pelanggan = snapshotPelanggan.data!;
          Log.info('Data pelanggan berhasil didapatkan.', {
            'nama': pelanggan.nama,
            'id': pelanggan.id,
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _firestoreService
                      .ambilRiwayatLanggananLengkap(pelanggan.id),
                  builder: (context, snapshotRiwayat) {
                    Log.info(
                        'Menerima update status koneksi FutureBuilder Riwayat.',
                        {
                          'connectionState':
                              snapshotRiwayat.connectionState.toString(),
                        });

                    if (snapshotRiwayat.connectionState ==
                        ConnectionState.waiting) {
                      Log.info(
                          'Status: Menunggu data riwayat langganan. Menampilkan CircularProgressIndicator.');
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshotRiwayat.hasError) {
                      Log.error(
                        'Gagal memuat riwayat langganan.',
                        e: snapshotRiwayat.error,
                        st: snapshotRiwayat.stackTrace,
                      );
                      return Center(
                          child: Text(
                              'Gagal memuat riwayat: ${snapshotRiwayat.error}'));
                    }

                    if (!snapshotRiwayat.hasData ||
                        snapshotRiwayat.data!.isEmpty) {
                      Log.info(
                          'Status: Koneksi selesai tetapi tidak ada riwayat.');
                      return const Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                              child: Text("Tidak ada riwayat transaksi.")),
                        ),
                      );
                    }

                    final riwayat =
                        snapshotRiwayat.data! as List<TransaksiModel>;
                    Log.info('Data riwayat berhasil didapatkan.', {
                      'jumlah_item': riwayat.length,
                    });

                    return ListView.builder(
                      itemCount: riwayat.length,
                      itemBuilder: (context, index) {
                        final tx = riwayat[index];
                        final String teksMasaAktif;
                        final Color warnaMasaAktif;

                        if (tx.tanggalBerakhir != null) {
                          teksMasaAktif = PerhitunganUtil.getTeksSisaMasaAktif(
                              tx.tanggalBerakhir!);
                          warnaMasaAktif =
                              PerhitunganUtil.getWarnaSisaMasaAktif(
                                  tx.tanggalBerakhir!);
                        } else {
                          teksMasaAktif = 'N/A';
                          warnaMasaAktif = Colors.grey;
                        }

                        Log.info('Membangun item riwayat.', {
                          'index': index,
                          'idPaket': tx.idPaket,
                          'status': tx.statusPembayaran.name,
                          'masa_aktif': teksMasaAktif,
                        });

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 4.0),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long),
                            title: tx.idPaket != null
                                ? NamaPaketWidget(idPaket: tx.idPaket!)
                                : const Text('-'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tx.tanggalBerakhir != null)
                                  Text(
                                      "Berakhir - ${FormatTanggal.formatTanggalDanJam(tx.tanggalBerakhir!)}"),
                                const SizedBox(height: 4),
                                Text(
                                  "Status: ${tx.statusPembayaran.name}",
                                  style: TextStyle(
                                    color: tx.statusPembayaran.name
                                                .toLowerCase() ==
                                            'lunas'
                                        ? AppColors.primaryColor
                                        : AppColors.primaryColor,
                                  ),
                                ),
                                Text(
                                  'Masa Aktif: $teksMasaAktif',
                                  style: TextStyle(color: warnaMasaAktif),
                                )
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Log.info('Navigasi ke DetailTransaksiPage.', {
                                'index': index,
                                'idPaket': tx.idPaket,
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailTransaksiPage(
                                    transaksi: tx,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: const BannerAdWidget(
                    adUnitId: 'ca-app-pub-3940256099942544/6300978111'),
              ),
            ],
          );
        },
      ),
    );
  }
}
