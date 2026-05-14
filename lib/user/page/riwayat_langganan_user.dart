// path: lib/user/page/riwayat_langganan_user.dart
// diubah: Memperbaiki tipe Future yang ambigu saat idPaket null.
// Future.value() diubah menjadi Future<PaketModel?>.value(null) untuk kejelasan tipe.
// diubah: Memperbaiki penggunaan NamaPaketWidget dan navigasi ke DetailTransaksiPage.
// diubah: Mengganti unawaited dengan ignore comment untuk mengatasi lint error.
// diubah: Menambahkan await pada pemanggilan Future dan menghapus const yang tidak perlu.
// diubah: Memperbaiki error lint dan inference failure.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/services/info_perangkat_service.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/widget/nama_paket.dart';
import 'package:wifi/user/page/detail_transaksi_user.dart';
import 'package:wifi/user/services/firestore_service.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/ads/banner_ad_widget.dart';

/// Enum untuk mode pengurutan riwayat langganan.
enum SortMode {
  /// Mengurutkan berdasarkan tanggal berakhir terbaru.
  tanggalBerakhirTerbaru,

  /// Mengurutkan berdasarkan tanggal berakhir terlama.
  tanggalBerakhirTerlama,

  /// Mengurutkan berdasarkan status lunas.
  statusLunas,

  /// Mengurutkan berdasarkan status belum lunas.
  statusBelumLunas,
}

/// Halaman untuk menampilkan riwayat langganan pengguna.
class RiwayatLanggananPage extends StatelessWidget {
  /// ID pengguna yang sedang login.
  final String userId;

  /// Service untuk mengakses penyimpanan lokal.
  final LocalStorageService localStorageService;

  /// Membuat instance dari [RiwayatLanggananPage].
  const RiwayatLanggananPage({
    super.key,
    required this.userId,
    required this.localStorageService,
  });

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun RiwayatLanggananPage, meneruskan userId dan localStorageService ke _TampilanRiwayatLangganan.',
    );
    return _TampilanRiwayatLangganan(userId: userId);
  }
}

class _TampilanRiwayatLangganan extends StatefulWidget {
  final String userId;
  const _TampilanRiwayatLangganan({required this.userId});

  @override
  State<_TampilanRiwayatLangganan> createState() =>
      _TampilanRiwayatLanggananState();
}

class _TampilanRiwayatLanggananState extends State<_TampilanRiwayatLangganan> {
  final FirestoreService _firestoreService = FirestoreService();
  final InfoPerangkatService _infoPerangkatService = InfoPerangkatService();
  SortMode _sortMode = SortMode.tanggalBerakhirTerbaru;

  @override
  void initState() {
    super.initState();
    Log.info('Memulai inisialisasi state untuk _TampilanRiwayatLangganan.');
    // Future-returning calls in a non-async function should be handled.
    // ignore: discarded_futures
    _cekArsitekturPerangkat();
    Log.info('Memulai proses sinkronisasi jadwal notifikasi.', {
      'userId': widget.userId,
    });
    // Future-returning calls in a non-async function should be handled.
    // ignore: discarded_futures
    _firestoreService.sinkronkanJadwalNotifikasi(widget.userId);
  }

  @override
  Future<void> dispose() async {
    Log.info(
      'Membersihkan state _TampilanRiwayatLangganan dan menghentikan sinkronisasi jadwal.',
    );
    await _firestoreService.hentikanSinkronisasiJadwal();
    super.dispose();
  }

  Future<void> _cekArsitekturPerangkat() async {
    Log.info('Memulai pengecekan arsitektur perangkat.');
    try {
      final arsitektur =
          await _infoPerangkatService.dapatkanArsitekturPerangkat();
      Log.info('Arsitektur Perangkat Terdeteksi.', arsitektur);
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mendapatkan arsitektur perangkat.',
        e: e,
        st: st,
      );
    }
  }

  List<TransaksiModel> _urutkanRiwayat(List<TransaksiModel> riwayat) {
    switch (_sortMode) {
      case SortMode.tanggalBerakhirTerbaru:
        riwayat.sort((a, b) {
          if (a.tanggalBerakhir == null && b.tanggalBerakhir == null) return 0;
          if (a.tanggalBerakhir == null) return 1;
          if (b.tanggalBerakhir == null) return -1;
          return b.tanggalBerakhir!.compareTo(a.tanggalBerakhir!);
        });
        break;
      case SortMode.tanggalBerakhirTerlama:
        riwayat.sort((a, b) {
          if (a.tanggalBerakhir == null && b.tanggalBerakhir == null) return 0;
          if (a.tanggalBerakhir == null) return 1;
          if (b.tanggalBerakhir == null) return -1;
          return a.tanggalBerakhir!.compareTo(b.tanggalBerakhir!);
        });
        break;
      case SortMode.statusLunas:
        riwayat.sort((a, b) {
          final statusA =
              a.statusPembayaran.name.toLowerCase() == 'lunas' ? 0 : 1;
          final statusB =
              b.statusPembayaran.name.toLowerCase() == 'lunas' ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
      case SortMode.statusBelumLunas:
        riwayat.sort((a, b) {
          final statusA =
              a.statusPembayaran.name.toLowerCase() == 'belum lunas' ? 0 : 1;
          final statusB =
              b.statusPembayaran.name.toLowerCase() == 'belum lunas' ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
    }
    return riwayat;
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI _TampilanRiwayatLangganan dengan Scaffold dan StreamBuilder.',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          PopupMenuButton<SortMode>(
            onSelected: (SortMode result) {
              setState(() {
                _sortMode = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortMode>>[
              const PopupMenuItem<SortMode>(
                value: SortMode.tanggalBerakhirTerbaru,
                child: Text('Tanggal Berakhir (Terbaru)'),
              ),
              const PopupMenuItem<SortMode>(
                value: SortMode.tanggalBerakhirTerlama,
                child: Text('Tanggal Berakhir (Terlama)'),
              ),
              const PopupMenuItem<SortMode>(
                value: SortMode.statusLunas,
                child: Text('Status: Lunas'),
              ),
              const PopupMenuItem<SortMode>(
                value: SortMode.statusBelumLunas,
                child: Text('Status: Belum Lunas'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: StreamBuilder<PelangganModel?>(
        stream: _firestoreService.ambilPelangganStream(widget.userId),
        builder: (context, snapshotPelanggan) {
          Log.info('Menerima update status koneksi StreamBuilder Pelanggan.', {
            'connectionState': snapshotPelanggan.connectionState.toString(),
          });

          if (snapshotPelanggan.connectionState == ConnectionState.waiting) {
            Log.info(
              'Status: Menunggu data pelanggan. Menampilkan CircularProgressIndicator.',
            );
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
              'Status: Koneksi selesai tetapi tidak ada data pelanggan.',
            );
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
                        'Status: Menunggu data riwayat langganan. Menampilkan CircularProgressIndicator.',
                      );
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
                          'Gagal memuat riwayat: ${snapshotRiwayat.error}',
                        ),
                      );
                    }

                    if (!snapshotRiwayat.hasData ||
                        snapshotRiwayat.data!.isEmpty) {
                      Log.info(
                        'Status: Koneksi selesai tetapi tidak ada riwayat.',
                      );
                      return const Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text('Tidak ada riwayat transaksi.'),
                          ),
                        ),
                      );
                    }

                    final riwayat = snapshotRiwayat.data!;
                    Log.info('Data riwayat berhasil didapatkan.', {
                      'jumlah_item': riwayat.length,
                    });

                    final riwayatUrut = _urutkanRiwayat(List.from(riwayat));

                    return ListView.builder(
                      itemCount: riwayatUrut.length,
                      itemBuilder: (context, index) {
                        final tx = riwayatUrut[index];
                        final String teksMasaAktif;
                        final Color warnaMasaAktif;

                        final paketFuture = tx.idPaket != null
                            ? _firestoreService.ambilPaketModelById(tx.idPaket!)
                            : Future<PaketModel?>.value();

                        if (tx.tanggalBerakhir != null) {
                          teksMasaAktif = PerhitunganUtil.getTeksSisaMasaAktif(
                            tx.tanggalBerakhir!,
                          );
                          warnaMasaAktif =
                              PerhitunganUtil.getWarnaSisaMasaAktif(
                            tx.tanggalBerakhir!,
                          );
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
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long),
                            title: NamaPaketWidget(paketFuture: paketFuture),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tx.tanggalBerakhir != null)
                                  Text(
                                    'Berakhir - ${FormatTanggal.formatTanggalDanJam(tx.tanggalBerakhir!)}',
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${tx.statusPembayaran.name}',
                                  style: TextStyle(
                                    color: tx.statusPembayaran.name
                                                .toLowerCase() ==
                                            'lunas'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  'Masa Aktif: $teksMasaAktif',
                                  style: TextStyle(color: warnaMasaAktif),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              Log.info('Navigasi ke DetailTransaksiPage.', {
                                'index': index,
                                'idPaket': tx.idPaket,
                              });
                              final paket = await paketFuture;
                              if (context.mounted) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => DetailTransaksiPage(
                                      transaksi: tx,
                                      paket: paket,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Center(
                child: BannerAdWidget(
                  adUnitId: 'ca-app-pub-3940256099942544/6300978111',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
