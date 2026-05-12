// path: lib/user/page/profil_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/user/page/edit_profil_page.dart';
import 'package:wifi/user/page/pengaturan_user.dart';
import 'package:wifi/user/services/firestore_service.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';

class ProfilPage extends StatefulWidget {
  final String userId;
  final LocalStorageService localStorageService;
  const ProfilPage({
    super.key,
    required this.userId,
    required this.localStorageService,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _apakahPasswordTerlihat = false;

  Future<PelangganModel?>? _futurePelanggan;
  Future<List<TransaksiModel>>? _riwayatLanggananFuture;

  Future<String>? _futureNamaPaket;
  String? _cacheIdPaket;

  @override
  void initState() {
    super.initState();
    Log.info('Memulai inisialisasi state untuk ProfilPage.');
    _inisialisasiData();
  }

  Future<void> _inisialisasiData() async {
    Log.info('Memulai pengambilan data profil untuk userId: ${widget.userId}.');
    setState(() {
      _futurePelanggan = _firestoreService.ambilPelangganSekali(widget.userId);
    });

    try {
      final pelanggan = await _futurePelanggan;
      if (pelanggan != null) {
        Log.info(
            'Data pelanggan berhasil diambil, mengambil riwayat langganan.');
        setState(() {
          _riwayatLanggananFuture =
              _firestoreService.ambilRiwayatLangganan(pelanggan.id);
        });
      }
    } catch (e, st) {
      Log.error('Gagal memuat data awal profil.', e: e, st: st);
    }
  }

  void _muatUlangData() {
    Log.info('Memuat ulang semua data profil.');
    setState(() {
      _futurePelanggan = null;
      _riwayatLanggananFuture = null;
      _futureNamaPaket = null;
      _cacheIdPaket = null;
      _inisialisasiData();
      Log.info('State di-reset untuk memuat ulang data.');
    });
  }

  Future<void> _navigasiKeEdit(PelangganModel pelanggan) async {
    Log.info('Menavigasi ke EditProfilPage.');
    final bool? hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfilPage(pelanggan: pelanggan, userId: widget.userId),
      ),
    );
    if (hasil == true) {
      Log.info(
          'Kembali dari EditProfilPage dengan perubahan, memuat ulang data.');
      _muatUlangData();
    } else {
      Log.info('Kembali dari EditProfilPage tanpa perubahan.');
    }
  }

  void _navigasiKePengaturan() {
    Log.info('Menavigasi ke PengaturanPage.');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PengaturanPage(
          userId: widget.userId,
          localStorageService: widget.localStorageService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk ProfilPage.');
    if (_futurePelanggan == null) {
      Log.info(
          'Future pelanggan masih null, menampilkan indikator loading awal.');
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat Profil...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PelangganModel?>(
      future: _futurePelanggan,
      builder: (context, snapshot) {
        Log.info(
            'Menerima update status koneksi: ${snapshot.connectionState}.');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Memuat Profil...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          Log.error(
            'Terjadi error: ${snapshot.error}.',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Terjadi Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          Log.info(
              'Data pelanggan tidak ditemukan untuk ID: ${widget.userId}.');
          return Scaffold(
            appBar: AppBar(title: const Text('Profil Tidak Ditemukan')),
            body: Center(
              child: Text('Gagal memuat data untuk ID: ${widget.userId}'),
            ),
          );
        }

        final pelanggan = snapshot.data!;
        Log.info('Data pelanggan berhasil dimuat untuk: ${pelanggan.nama}.');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil Pelanggan'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigasiKeEdit(pelanggan),
                tooltip: 'Edit Profil',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _navigasiKePengaturan,
                tooltip: 'Pengaturan',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _muatUlangData(),
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
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _bangunInfoItem(
                            Icons.phone_outlined,
                            'No. HP',
                            pelanggan.telepon,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.content_copy, size: 20),
                          tooltip: 'Salin Nomor HP',
                          onPressed: () {
                            Log.info('Menyalin nomor HP ke clipboard.');
                            Clipboard.setData(
                              ClipboardData(text: pelanggan.telepon),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nomor HP disalin ke clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _bangunInfoItem(
                            Icons.lock,
                            'Password',
                            _apakahPasswordTerlihat
                                ? pelanggan.password
                                : '••••••••••',
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _apakahPasswordTerlihat
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: _apakahPasswordTerlihat
                              ? 'Sembunyikan'
                              : 'Tampilkan',
                          onPressed: () {
                            Log.info('Mengubah visibilitas password.');
                            setState(() {
                              _apakahPasswordTerlihat =
                                  !_apakahPasswordTerlihat;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _bangunKartuInformasi(
                  context,
                  title: 'Informasi Paket Aktif',
                  icon: Icons.wifi,
                  children: [
                    FutureBuilder<List<TransaksiModel>>(
                      future: _riwayatLanggananFuture,
                      builder: (context, snapshotRiwayat) {
                        Log.info(
                          'Status koneksi riwayat: ${snapshotRiwayat.connectionState}.',
                        );
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
                          Log.error(
                            'Gagal memuat riwayat langganan.',
                            e: snapshotRiwayat.error,
                            st: snapshotRiwayat.stackTrace,
                          );
                          return _bangunInfoItem(
                            Icons.error_outline,
                            'Error',
                            'Gagal memuat riwayat langganan.',
                          );
                        }

                        if (!snapshotRiwayat.hasData ||
                            snapshotRiwayat.data!.isEmpty) {
                          Log.info(
                            'Tidak ada data riwayat langganan ditemukan.',
                          );
                          return _bangunInfoItem(
                            Icons.wifi_off,
                            'Paket Aktif',
                            'Paket aktif telah berakhir.',
                          );
                        }

                        final now = DateTime.now();
                        final langgananAktif = snapshotRiwayat.data!
                            .where(
                              (langganan) =>
                                  langganan.tanggalBerakhir != null &&
                                  langganan.tanggalBerakhir!.isAfter(now),
                            )
                            .toList();

                        final TransaksiModel? langgananTerakhir;
                        if (langgananAktif.isNotEmpty) {
                          langgananTerakhir = langgananAktif.reduce(
                            (a, b) =>
                                a.tanggalBerakhir!.isAfter(b.tanggalBerakhir!)
                                    ? a
                                    : b,
                          );
                          Log.info(
                            'Langganan aktif terakhir ditemukan, berakhir pada: ${langgananTerakhir.tanggalBerakhir}.',
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
                            'Paket baru terdeteksi. Mengambil nama paket untuk ID: ${langgananTerakhir.idPaket!}.',
                          );
                          _futureNamaPaket = _firestoreService.ambilNamaPaket(
                            langgananTerakhir.idPaket!,
                          );
                          _cacheIdPaket = langgananTerakhir.idPaket;
                        }

                        return Column(
                          children: [
                            FutureBuilder<String>(
                              future: _futureNamaPaket,
                              builder: (context, snapshotPaket) {
                                String namaPaket;
                                if (snapshotPaket.connectionState ==
                                    ConnectionState.waiting) {
                                  namaPaket = 'Memuat...';
                                } else if (snapshotPaket.hasError) {
                                  namaPaket = 'Gagal memuat';
                                  Log.error(
                                    'Gagal mengambil nama paket: ${snapshotPaket.error}',
                                    error: snapshotPaket.error,
                                    stackTrace: snapshotPaket.stackTrace,
                                  );
                                } else {
                                  namaPaket =
                                      snapshotPaket.data ?? 'Tidak tersedia';
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
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
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
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
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
        ],
      ),
    );
  }
}
