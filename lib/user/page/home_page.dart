
import 'dart:math';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final LocalStorageService localStorageService;
  const HomePage(
      {super.key, required this.userId, required this.localStorageService});

  @override
  Widget build(BuildContext context) {
    log(
      '[Pembangunan Widget] ✅ Membangun HomePage, meneruskan userId dan localStorageService ke _TampilanBeranda.',
    );
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
    log(
      '[Inisialisasi State] ✅ Memulai inisialisasi state untuk _TampilanBeranda.',
      name: 'home_page.dart',
    );
    _cekArsitekturPerangkat();
    log(
      '[Sinkronisasi Notifikasi] ✅ Memulai proses sinkronisasi jadwal notifikasi untuk userId: ${widget.userId}.',
      name: 'home_page.dart',
    );
    _firestoreService.sinkronkanJadwalNotifikasi(widget.userId);
  }

  @override
  void dispose() {
    log(
      '[Pembersihan State] ✅ Membersihkan state _TampilanBeranda dan menghentikan sinkronisasi jadwal.',
      name: 'home_page.dart',
    );
    _firestoreService.hentikanSinkronisasiJadwal();
    super.dispose();
  }

  void _cekArsitekturPerangkat() async {
    log(
      '[Pengecekan Arsitektur] ✅ Memulai pengecekan arsitektur perangkat.',
      name: 'home_page.dart',
    );
    try {
      final arsitektur =
          await _infoPerangkatService.dapatkanArsitekturPerangkat();
      log(
        '[Info Arsitektur] ✅ Arsitektur Perangkat Terdeteksi: $arsitektur.',
        name: 'home_page.dart',
      );
    } catch (e, st) {
      log(
        '[Error Pengecekan Arsitektur] ❌ Gagal mendapatkan arsitektur perangkat.',
        name: 'home_page.dart',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    log(
      '[Pembangunan UI] ✅ Membangun UI _TampilanBeranda dengan Scaffold dan StreamBuilder.',
      name: 'home_page.dart',
    );
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        title: const Text('Beranda'),
      ),
      body: StreamBuilder<PelangganModel?>(
        stream: _firestoreService.ambilPelangganStream(widget.userId),
        builder: (context, snapshotPelanggan) {
          log(
            '[StreamBuilder Pelanggan] ✅ Menerima update status koneksi: ${snapshotPelanggan.connectionState}.',
            name: 'home_page.dart',
          );
          if (snapshotPelanggan.connectionState == ConnectionState.waiting) {
            log(
              '[StreamBuilder Pelanggan] ✅ Status: Menunggu data pelanggan. Menampilkan CircularProgressIndicator.',
              name: 'home_page.dart',
            );
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotPelanggan.hasError) {
            log(
              '[StreamBuilder Pelanggan] ❌ Terjadi error saat mengambil data pelanggan.',
              name: 'home_page.dart',
              error: snapshotPelanggan.error,
              stackTrace: snapshotPelanggan.stackTrace,
            );
            return Center(child: Text('Error: ${snapshotPelanggan.error}'));
          }
          if (!snapshotPelanggan.hasData || snapshotPelanggan.data == null) {
            log(
              '[StreamBuilder Pelanggan] ✅ Status: Koneksi selesai tetapi tidak ada data pelanggan. Menampilkan pesan.',
              name: 'home_page.dart',
            );
            return const Center(child: Text('Data pelanggan tidak ditemukan.'));
          }

          final pelanggan = snapshotPelanggan.data!;
          log(
            '[StreamBuilder Pelanggan] ✅ Data pelanggan berhasil didapatkan untuk: ${pelanggan.nama}.',
            name: 'home_page.dart',
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<RiwayatLanggananModel>>(
                  future: _firestoreService.ambilRiwayatLanggananLengkap(
                      pelanggan.id), // diubah
                  builder: (context, snapshotRiwayat) {
                    log(
                      '[FutureBuilder Riwayat] ✅ Menerima update status koneksi: ${snapshotRiwayat.connectionState}.',
                      name: 'home_page.dart',
                    );
                    if (snapshotRiwayat.connectionState ==
                        ConnectionState.waiting) {
                      log(
                        '[FutureBuilder Riwayat] ✅ Status: Menunggu data riwayat langganan. Menampilkan CircularProgressIndicator.',
                        name: 'home_page.dart',
                      );
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshotRiwayat.hasError) {
                      log(
                        '[FutureBuilder Riwayat] ❌ Gagal memuat riwayat langganan.',
                        name: 'home_page.dart',
                        error: snapshotRiwayat.error,
                        stackTrace: snapshotRiwayat.stackTrace,
                      );
                      return Center(
                          child: Text(
                              'Gagal memuat riwayat: ${snapshotRiwayat.error}'));
                    }
                    if (!snapshotRiwayat.hasData ||
                        snapshotRiwayat.data!.isEmpty) {
                      log(
                        '[FutureBuilder Riwayat] ✅ Status: Koneksi selesai tetapi tidak ada riwayat. Menampilkan pesan.',
                        name: 'home_page.dart',
                      );
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
                    log(
                      '[FutureBuilder Riwayat] ✅ Data riwayat berhasil didapatkan sejumlah: ${riwayat.length} item.',
                      name: 'home_page.dart',
                    );

                    return ListView.builder(
                      itemCount: riwayat.length,
                      itemBuilder: (context, index) {
                        final tx = riwayat[index];
                        final statusMasaAktif =
                            hitungStatusMasaAktif(tx.tanggalBerakhir);
                        final String teksMasaAktif = statusMasaAktif['teks'];
                        final Color warnaMasaAktif = statusMasaAktif['warna'];

                        log(
                          '[ListView Riwayat] ✅ Membangun item ke-$index untuk paket: ${tx.namaPaket}.',
                          name: 'home_page.dart',
                        );

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
                                    "Berakhir - ${formatDateWithMonthName(tx.tanggalBerakhir)}"),
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
                                  style: TextStyle(
                                    color: warnaMasaAktif,
                                  ),
                                )
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              log(
                                '[Aksi Navigasi] ✅ Pengguna menekan item riwayat ke-$index, navigasi ke DetailTransaksiPage.',
                                name: 'home_page.dart',
                              );
                              // Halaman detail tetap menggunakan RiwayatLanggananModel
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
