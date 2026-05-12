import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/user/core/app_colors.dart';
import 'package:wifi/user/core/utils/format_tanggal.dart';
import 'package:wifi/user/hooks/hitung_masa_aktif.dart';
import 'package:wifi/user/page/detail_transaksi.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/ads/banner_ad_widget.dart';

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
        error: e,
        stackTrace: st,
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
        backgroundColor: AppColors.primary,
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
              error: snapshotPelanggan.error,
              stackTrace: snapshotPelanggan.stackTrace,
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
                child: FutureBuilder<List<TransaksiModel>>(
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
                        error: snapshotRiwayat.error,
                        stackTrace: snapshotRiwayat.stackTrace,
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

                    final riwayat = snapshotRiwayat.data!;
                    Log.info('Data riwayat berhasil didapatkan.', {
                      'jumlah_item': riwayat.length,
                    });

                    return ListView.builder(
                      itemCount: riwayat.length,
                      itemBuilder: (context, index) {
                        final tx = riwayat[index];
                        final statusMasaAktif =
                            hitungStatusMasaAktif(tx.tanggalBerakhir);
                        final String teksMasaAktif = statusMasaAktif['teks'];
                        final Color warnaMasaAktif = statusMasaAktif['warna'];

                        Log.info('Membangun item riwayat.', {
                          'index': index,
                          'paket': tx.namaPaket,
                          'status': tx.status.name,
                          'masa_aktif': teksMasaAktif,
                        });

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 4.0),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long),
                            title: Text('Paket: ${tx.namaPaket}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Berakhir - ${formatDateTimeWithMonthName(tx.tanggalBerakhir)}"),
                                const SizedBox(height: 4),
                                Text(
                                  "Status: ${tx.status.name}",
                                  style: TextStyle(
                                    color:
                                        tx.status.name.toLowerCase() == 'lunas'
                                            ? AppColors.success
                                            : AppColors.error,
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
                                'paket': tx.namaPaket,
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailTransaksiPage(
                                    riwayat: tx,
                                    pelanggan: pelanggan,
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
                child: BannerAdWidget(
                  adUnitId: AdHelper.bannerAdUnitId,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
