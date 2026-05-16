// path: lib/user/page/profil_page.dart
// diubah: Menghapus impor yang tidak perlu.
// refactor: Menghapus ketergantungan pada FirestoreService dan menggunakan kelas operasi yang sesuai.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paket_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/pelanggan_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaksi_op_firebase.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/user/page/detail_pelanggan_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Halaman profil pengguna yang menampilkan informasi pribadi dan paket aktif.
class ProfilPage extends StatefulWidget {
  /// ID pengguna yang sedang login.
  final String userId;

  /// Service untuk mengakses penyimpanan lokal.
  final LocalStorageService localStorageService;

  /// Membuat instance dari [ProfilPage].
  const ProfilPage({
    super.key,
    required this.userId,
    required this.localStorageService,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final PelangganOpFirebase _pelangganOp = PelangganOpFirebase();
  final TransaksiOpFirebase _transaksiOp = TransaksiOpFirebase();
  final PaketOpFirebase _paketOp = PaketOpFirebase(FirebaseFirestore.instance);

  Future<PelangganModel?>? _futurePelanggan;
  Future<List<TransactionModel>>? _riwayatLanggananFuture;

  Future<String>? _futureNamaPaket;
  String? _cacheIdPaket;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai inisialisasi state untuk ProfilPage, userId: ${widget.userId}',
    );
    unawaited(_inisialisasiData());
  }

  Future<void> _inisialisasiData() async {
    Log.info('Memulai pengambilan data awal untuk userId: ${widget.userId}.');
    if (!mounted) return;

    setState(() {
      _futurePelanggan = _pelangganOp.ambilPelangganSekali(widget.userId);
    });

    try {
      final pelanggan = await _futurePelanggan;
      if (pelanggan != null) {
        Log.info(
          'Data pelanggan berhasil diambil: ${pelanggan.nama}. Mengambil riwayat langganan...',
        );
        if (!mounted) return;
        setState(() {
          _riwayatLanggananFuture =
              _transaksiOp.ambilRiwayatLangganan(pelanggan.id);
        });
      } else {
        Log.warning(
          'Pelanggan dengan userId: ${widget.userId} tidak ditemukan di Firestore.',
        );
      }
    } on Exception catch (e, st) {
      Log.error('Gagal memuat data awal profil.', e: e, st: st);
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal memuat data profil: $e');
      }
    }
  }

  Future<void> _muatUlangData() async {
    Log.info('Memuat ulang semua data profil via onRefresh.');
    SnackBarUtil.info(context, 'Memperbarui data...');

    // Inisialisasi ulang semua future untuk memicu state loading di FutureBuilder
    setState(() {
      _futurePelanggan = _pelangganOp.ambilPelangganSekali(widget.userId);
    });

    try {
      final pelanggan = await _futurePelanggan;
      if (pelanggan != null) {
        setState(() {
          // Reset juga future-future dependen
          _riwayatLanggananFuture =
              _transaksiOp.ambilRiwayatLangganan(pelanggan.id);
          _futureNamaPaket = null;
          _cacheIdPaket = null;
        });
        // Tunggu hingga data dependen juga selesai dimuat
        await _riwayatLanggananFuture;
      }

      if (mounted) {
        Log.info('Data profil berhasil diperbarui.');
        SnackBarUtil.success(context, 'Data berhasil diperbarui.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal saat memuat ulang data profil.', e: e, st: st);
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal memperbarui data: $e');
      }
    }
  }

  Future<void> _navigasiKeDetail(final String userId) async {
    Log.info('Menavigasi ke DetailPelangganUserPage untuk userId: $userId');
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (final context) => DetailPelangganUserPage(userId: userId),
      ),
    ).then((final _) {
      Log.info(
        'Kembali dari DetailPelangganUserPage, memuat ulang data jika ada perubahan.',
      );
      unawaited(_muatUlangData());
    });
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk ProfilPage.');
    if (_futurePelanggan == null) {
      Log.info(
        'Future pelanggan masih null, menampilkan indikator loading awal.',
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat Profil...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PelangganModel?>(
      future: _futurePelanggan,
      builder: (final context, final snapshot) {
        Log.info(
          'FutureBuilder<Pelanggan>: Menerima status koneksi: ${snapshot.connectionState}.',
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Memuat Profil...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          Log.error(
            'FutureBuilder<Pelanggan> mendeteksi error: ${snapshot.error}.',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Terjadi Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          Log.warning(
            'FutureBuilder<Pelanggan>: Tidak ada data pelanggan yang ditemukan untuk ID: ${widget.userId}.',
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Profil Tidak Ditemukan')),
            body: Center(
              child: Text('Gagal memuat data untuk ID: ${widget.userId}'),
            ),
          );
        }

        final pelanggan = snapshot.data;
        Log.info(
          'Data pelanggan berhasil dimuat untuk: ${pelanggan.nama}. Merender UI utama.',
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil Pelanggan'),
          ),
          body: RefreshIndicator(
            onRefresh: _muatUlangData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _bangunKartuInformasi(
                  context,
                  title: 'Informasi Pribadi',
                  icon: Icons.person,
                  children: [
                    _bangunInfoItem(
                      Icons.person_outline,
                      'Nama Lengkap',
                      pelanggan.nama,
                      trailingIcon: Icons.chevron_right,
                      onTap: () => unawaited(_navigasiKeDetail(pelanggan.id)),
                    ),
                    FutureBuilder<List<TransactionModel>>(
                      future: _riwayatLanggananFuture,
                      builder: (final context, final snapshotRiwayat) {
                        Log.info(
                          'FutureBuilder<Riwayat>: Status koneksi: ${snapshotRiwayat.connectionState}.',
                        );
                        if (snapshotRiwayat.connectionState ==
                            ConnectionState.waiting) {
                          return _bangunInfoItem(
                            Icons.point_of_sale,
                            'Poin',
                            'Menghitung...',
                          );
                        }

                        if (snapshotRiwayat.hasError) {
                          Log.error(
                            'FutureBuilder<Riwayat>: Gagal menghitung poin.',
                            e: snapshotRiwayat.error,
                            st: snapshotRiwayat.stackTrace,
                          );
                          return _bangunInfoItem(
                            Icons.point_of_sale,
                            'Poin',
                            'Gagal memuat',
                          );
                        }

                        if (!snapshotRiwayat.hasData ||
                            snapshotRiwayat.data!.isEmpty) {
                          Log.warning(
                            'FutureBuilder<Riwayat>: Tidak ada riwayat transaksi ditemukan.',
                          );
                          return _bangunInfoItem(
                            Icons.point_of_sale,
                            'Poin',
                            '0',
                          );
                        }

                        final riwayat = snapshotRiwayat.data!;
                        Log.info(
                          'Menghitung total poin dari ${riwayat.length} transaksi.',
                        );
                        final int poinDihasilkan = riwayat.fold(
                          0,
                          (final total, final item) =>
                              total + item.poinYangDihasilkan,
                        );
                        final int poinDigunakan = riwayat.fold(
                          0,
                          (final total, final item) =>
                              total + item.poinYangDigunakan,
                        );

                        final int totalPoin = poinDihasilkan - poinDigunakan;
                        Log.info('Total poin dihitung: $totalPoin.');

                        return _bangunInfoItem(
                          Icons.point_of_sale,
                          'Poin',
                          totalPoin.toString(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _bangunKartuInformasi(
                  context,
                  title: 'Informasi Paket Aktif',
                  icon: Icons.wifi,
                  children: [
                    FutureBuilder<List<TransactionModel>>(
                      future: _riwayatLanggananFuture,
                      builder: (final context, final snapshotRiwayat) {
                        // Log sudah ada di FutureBuilder sebelumnya, tidak perlu diulang
                        if (snapshotRiwayat.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 120,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        if (snapshotRiwayat.hasError) {
                          return _bangunInfoItem(
                            Icons.error_outline,
                            'Error',
                            'Gagal memuat riwayat langganan.',
                          );
                        }

                        if (!snapshotRiwayat.hasData ||
                            snapshotRiwayat.data!.isEmpty) {
                          return _bangunInfoItem(
                            Icons.wifi_off,
                            'Paket Aktif',
                            'Paket aktif telah berakhir.',
                          );
                        }

                        final now = DateTime.now();
                        final langgananAktif = snapshotRiwayat.data!
                            .where(
                              (final langganan) =>
                                  langganan.tanggalBerakhir != null &&
                                  langganan.tanggalBerakhir!.isAfter(now),
                            )
                            .toList();

                        final TransactionModel? langgananTerakhir;
                        if (langgananAktif.isNotEmpty) {
                          langgananTerakhir = langgananAktif.reduce(
                            (final a, final b) =>
                                a.tanggalBerakhir!.isAfter(b.tanggalBerakhir!)
                                    ? a
                                    : b,
                          );
                          Log.info(
                            'Langganan aktif terakhir ditemukan, berakhir pada: ${FormatTanggal.formatTanggalDanJam(langgananTerakhir.tanggalBerakhir!)}.',
                          );
                        } else {
                          langgananTerakhir = null;
                          Log.info(
                            'Tidak ada langganan aktif yang ditemukan.',
                          );
                        }

                        if (langgananTerakhir == null ||
                            langgananTerakhir.tanggalBerakhir == null) {
                          return _bangunInfoItem(
                            Icons.wifi_off,
                            'Paket Aktif',
                            'Tidak ada paket aktif.',
                          );
                        }

                        final String teksMasaAktif =
                            PerhitunganUtil.getTeksSisaMasaAktif(
                          langgananTerakhir.tanggalBerakhir!,
                        );
                        final Color warnaMasaAktif =
                            PerhitunganUtil.getWarnaSisaMasaAktif(
                          langgananTerakhir.tanggalBerakhir!,
                        );

                        final Color statusPembayaranColor =
                            langgananTerakhir.statusPembayaran ==
                                    StatusPembayaranEnum.lunas
                                ? Colors.green
                                : Colors.red;

                        if (langgananTerakhir.idPaket != null &&
                            _cacheIdPaket != langgananTerakhir.idPaket) {
                          Log.info(
                            'ID Paket berubah. Mengambil nama paket baru untuk ID: ${langgananTerakhir.idPaket!}.',
                          );
                          _futureNamaPaket = _paketOp.ambilNamaPaket(
                            langgananTerakhir.idPaket!,
                          );
                          _cacheIdPaket = langgananTerakhir.idPaket;
                        }

                        return Column(
                          children: [
                            FutureBuilder<String>(
                              future: _futureNamaPaket,
                              builder: (final context, final snapshotPaket) {
                                String namaPaket;
                                if (snapshotPaket.connectionState ==
                                    ConnectionState.waiting) {
                                  namaPaket = 'Memuat...';
                                } else if (snapshotPaket.hasError) {
                                  namaPaket = 'Gagal memuat';
                                  Log.error(
                                    'FutureBuilder<NamaPaket>: Gagal mengambil nama paket: ${snapshotPaket.error}',
                                    e: snapshotPaket.error,
                                    st: snapshotPaket.stackTrace,
                                  );
                                } else {
                                  namaPaket =
                                      snapshotPaket.data ?? 'Tidak tersedia';
                                  Log.info(
                                    'Nama paket berhasil dimuat: $namaPaket',
                                  );
                                }
                                return _bangunInfoItem(
                                  Icons.wifi,
                                  'Paket',
                                  namaPaket,
                                );
                              },
                            ),
                            if (langgananTerakhir.tanggalMulai != null)
                              _bangunInfoItem(
                                Icons.date_range_outlined,
                                'Aktif Sejak',
                                FormatTanggal.formatTanggalDanJam(
                                  langgananTerakhir.tanggalMulai!,
                                ),
                              ),
                            _bangunInfoItem(
                              Icons.date_range_outlined,
                              'Berakhir Pada',
                              FormatTanggal.formatTanggalDanJam(
                                langgananTerakhir.tanggalBerakhir!,
                              ),
                            ),
                            _bangunInfoItem(
                              Icons.hourglass_bottom,
                              'Masa Aktif',
                              teksMasaAktif,
                              valueColor: warnaMasaAktif,
                            ),
                            _bangunInfoItem(
                              Icons.check_circle_outline,
                              'Status Pembayaran',
                              langgananTerakhir.statusPembayaran.name
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              valueColor: statusPembayaranColor,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bangunKartuInformasi(
    final BuildContext context, {
    required final String title,
    required final IconData icon,
    required final List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _bangunInfoItem(
    final IconData icon,
    final String label,
    final String value, {
    final Color? valueColor,
    final IconData? trailingIcon,
    final VoidCallback? onTap,
  }) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: Colors.grey.shade600, size: 20),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
