// path: lib/page/profil_page.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pelanggan_wifi/hooks/hitung_masa_aktif.dart';
import 'package:pelanggan_wifi/page/edit_profil_page.dart';
import 'package:pelanggan_wifi/models/enum/status_pembayaran.dart';
import 'package:pelanggan_wifi/models/pelanggan_model.dart';
import 'package:pelanggan_wifi/models/paket_aktif_model.dart';
import 'package:pelanggan_wifi/page/pengaturan_page.dart';
import 'package:pelanggan_wifi/services/firebase/firestore_service.dart';
import 'package:pelanggan_wifi/core/utils/format_tanggal.dart';
import 'package:pelanggan_wifi/services/storage/local_storage_service.dart';

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
  Future<List<PaketAktif>>? _riwayatLanggananFuture;

  Future<String>? _futureNamaPaket;
  String? _cacheIdPaket;

  @override
  void initState() {
    super.initState();
    log(
      '[Inisialisasi State] ✅ Memulai inisialisasi state untuk ProfilPage.',
      name: 'profil_page.dart',
    );
    _inisialisasiData();
  }

  Future<void> _inisialisasiData() async {
    log(
      '[Inisialisasi Data] ✅ Memulai pengambilan data profil untuk userId: ${widget.userId}.',
      name: 'profil_page.dart',
    );
    try {
      final pelanggan = await _firestoreService.ambilPelangganSekali(
        widget.userId,
      );
      if (!mounted) return;
      if (pelanggan != null) {
        log(
          '[Inisialisasi Data] ✅ Data pelanggan berhasil diambil.',
          name: 'profil_page.dart',
        );
        setState(() {
          _futurePelanggan = Future.value(pelanggan);
          _riwayatLanggananFuture = _firestoreService.ambilRiwayatLangganan(
            pelanggan.id,
          );
          log(
            '[Pembaruan State] ✅ State diperbarui dengan future untuk data pelanggan dan riwayat.',
            name: 'profil_page.dart',
          );
        });
      } else {
        log(
          '[Inisialisasi Data] ❌ Gagal mengambil data pelanggan, data null.',
          name: 'profil_page.dart',
        );
        setState(() {
          _futurePelanggan = Future.value(null);
        });
      }
    } catch (e, st) {
      log(
        '[Inisialisasi Data] ❌ Terjadi error saat mengambil data pelanggan.',
        name: 'profil_page.dart',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      setState(() {
        _futurePelanggan = Future.error(e, st);
      });
    }
  }

  void _muatUlangData() {
    log(
      '[Muat Ulang Data] ✅ Memuat ulang semua data profil.',
      name: 'profil_page.dart',
    );
    setState(() {
      _futurePelanggan = null;
      _riwayatLanggananFuture = null;
      _futureNamaPaket = null;
      _cacheIdPaket = null;
      _inisialisasiData();
      log(
        '[Pembaruan State] ✅ State di-reset untuk memuat ulang data.',
        name: 'profil_page.dart',
      );
    });
  }

  Future<void> _navigasiKeEdit(PelangganModel pelanggan) async {
    log(
      '[Aksi Navigasi] ✅ Menavigasi ke EditProfilPage.',
      name: 'profil_page.dart',
    );
    final bool? hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfilPage(pelanggan: pelanggan, userId: widget.userId),
      ),
    );
    if (hasil == true) {
      log(
        '[Aksi Navigasi] ✅ Kembali dari EditProfilPage dengan perubahan, memuat ulang data.',
        name: 'profil_page.dart',
      );
      _muatUlangData();
    } else {
      log(
        '[Aksi Navigasi] ✅ Kembali dari EditProfilPage tanpa perubahan.',
        name: 'profil_page.dart',
      );
    }
  }

  void _navigasiKePengaturan() {
    log(
      '[Aksi Navigasi] ✅ Menavigasi ke PengaturanPage.',
      name: 'profil_page.dart',
    );
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
    log(
      '[Pembangunan UI] ✅ Membangun UI untuk ProfilPage.',
      name: 'profil_page.dart',
    );
    if (_futurePelanggan == null) {
      log(
        '[Pembangunan UI] ✅ Future pelanggan masih null, menampilkan indikator loading awal.',
        name: 'profil_page.dart',
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat Profil...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PelangganModel?>(
      future: _futurePelanggan,
      builder: (context, snapshot) {
        log(
          '[FutureBuilder Pelanggan] ✅ Menerima update status koneksi: ${snapshot.connectionState}.',
          name: 'profil_page.dart',
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Memuat Profil...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          log(
            '[FutureBuilder Pelanggan] ❌ Terjadi error: ${snapshot.error}.',
            name: 'profil_page.dart',
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Terjadi Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          log(
            '[FutureBuilder Pelanggan] ✅ Data pelanggan tidak ditemukan untuk ID: ${widget.userId}.',
            name: 'profil_page.dart',
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Profil Tidak Ditemukan')),
            body: Center(
              child: Text('Gagal memuat data untuk ID: ${widget.userId}'),
            ),
          );
        }

        final pelanggan = snapshot.data!;
        log(
          '[FutureBuilder Pelanggan] ✅ Data pelanggan berhasil dimuat untuk: ${pelanggan.nama}.',
          name: 'profil_page.dart',
        );

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
                            log(
                              '[Aksi Salin] ✅ Menyalin nomor HP ke clipboard.',
                              name: 'profil_page.dart',
                            );
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
                            log(
                              '[Aksi UI] ✅ Mengubah visibilitas password.',
                              name: 'profil_page.dart',
                            );
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
                    FutureBuilder<List<PaketAktif>>(
                      future: _riwayatLanggananFuture,
                      builder: (context, snapshotRiwayat) {
                        log(
                          '[FutureBuilder Paket] ✅ Status koneksi riwayat: ${snapshotRiwayat.connectionState}.',
                          name: 'profil_page.dart',
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
                          log(
                            '[FutureBuilder Paket] ❌ Gagal memuat riwayat langganan.',
                            name: 'profil_page.dart',
                            error: snapshotRiwayat.error,
                            stackTrace: snapshotRiwayat.stackTrace,
                          );
                          return _bangunInfoItem(
                            Icons.error_outline,
                            'Error',
                            'Gagal memuat riwayat langganan.',
                          );
                        }

                        if (!snapshotRiwayat.hasData ||
                            snapshotRiwayat.data!.isEmpty) {
                          log(
                            '[FutureBuilder Paket] ✅ Tidak ada data riwayat langganan ditemukan.',
                            name: 'profil_page.dart',
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
                                  langganan.tanggalBerakhir.isAfter(now),
                            )
                            .toList();

                        final PaketAktif? langgananTerakhir;
                        if (langgananAktif.isNotEmpty) {
                          langgananTerakhir = langgananAktif.reduce(
                            (a, b) =>
                                a.tanggalBerakhir.isAfter(b.tanggalBerakhir)
                                ? a
                                : b,
                          );
                          log(
                            '[Proses Data] ✅ Langganan aktif terakhir ditemukan, berakhir pada: ${langgananTerakhir.tanggalBerakhir}.',
                            name: 'profil_page.dart',
                          );
                        } else {
                          langgananTerakhir = null;
                          log(
                            '[Proses Data] ✅ Tidak ada langganan aktif yang ditemukan.',
                            name: 'profil_page.dart',
                          );
                        }

                        if (langgananTerakhir == null) {
                          return _bangunInfoItem(
                            Icons.wifi_off,
                            'Paket Aktif',
                            'Tidak ada paket aktif.',
                          );
                        }

                        final statusMasaAktif = hitungStatusMasaAktif(
                          langgananTerakhir.tanggalBerakhir,
                        );

                        final Color statusPembayaranColor =
                            langgananTerakhir.status == StatusPembayaran.lunas
                            ? Colors.green
                            : Colors.red;

                        if (_cacheIdPaket != langgananTerakhir.idPaket) {
                          log(
                            '[Cache] ✅ Paket baru terdeteksi. Mengambil nama paket untuk ID: ${langgananTerakhir.idPaket}.',
                            name: 'profil_page.dart',
                          );
                          _futureNamaPaket = _firestoreService.ambilNamaPaket(
                            langgananTerakhir.idPaket,
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
                                  log(
                                    '[FutureBuilder NamaPaket] ❌ Gagal mengambil nama paket: ${snapshotPaket.error}',
                                    name: 'profil_page.dart',
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
                            _bangunInfoItem(
                              Icons.date_range_outlined,
                              'Aktif Sejak',
                              formatDateTimeWithMonthName(
                                langgananTerakhir.tanggalMulai,
                              ),
                            ),
                            _bangunInfoItem(
                              Icons.date_range_outlined,
                              'Berakhir Pada',
                              formatDateTimeWithMonthName(
                                langgananTerakhir.tanggalBerakhir,
                              ),
                            ),
                            _bangunInfoItem(
                              Icons.hourglass_bottom,
                              'Masa Aktif',
                              statusMasaAktif['teks'] as String,
                              valueColor: statusMasaAktif['warna'] as Color,
                            ),
                            _bangunInfoItem(
                              Icons.check_circle_outline,
                              'Status Pembayaran',
                              langgananTerakhir.status.name
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
