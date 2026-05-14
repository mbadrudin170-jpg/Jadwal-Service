// path: lib/admin/halaman/tab/pelanggan_aktif.dart
// diubah: Menambahkan trailing comma untuk memperbaiki warning dari analyzer.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/shared/data/sync/unggah_data.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_aktif_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/pelanggan_aktif_sorter.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
import 'package:wifi/shared/widget/nama_paket.dart';
import 'package:wifi/shared/widget/nama_pelanggan.dart';

/// Enum untuk opsi lanjutan pada halaman pelanggan aktif.
enum OpsiHapusPilihan {
  /// Opsi untuk menghapus semua pelanggan aktif.
  hapusSemua,

  /// Opsi untuk mengarsipkan pelanggan yang sudah kadaluarsa.
  arsipkanKadaluarsa,

  /// Opsi untuk membatalkan aksi.
  batal
}

/// Halaman untuk menampilkan daftar pelanggan yang sedang aktif berlangganan.
class PelangganAktifPage extends StatefulWidget {
  /// Konstruktor untuk PelangganAktifPage.
  const PelangganAktifPage({super.key});

  @override
  State<PelangganAktifPage> createState() => _PelangganAktifPageState();
}

class _PelangganAktifPageState extends State<PelangganAktifPage>
    with AutomaticKeepAliveClientMixin<PelangganAktifPage> {
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final now = DateTime.now();
  List<PelangganAktifModel> _semuaPelanggan = [];
  List<PelangganAktifModel> _hasilFilter = [];
  Map<String, String> _mapNamaPelanggan = {};
  bool _isLoading = true;
  OpsiUrutkan _urutanAktif = OpsiUrutkan.tanggalBerakhir;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final KoneksiInternetService _koneksiService = KoneksiInternetService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Log.info('Halaman Pelanggan Aktif sedang diinisialisasi.');
    unawaited(_loadData());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    Log.info('Halaman Pelanggan Aktif sedang dibersihkan.');
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilterAndSort();
  }

  Future<void> _refreshData() async {
    Log.info('Memuat ulang data Pelanggan Aktif karena permintaan pengguna.');
    await _loadData(forceRefresh: true);
  }

  Future<void> _loadData({final bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final syncManager = Provider.of<SyncManager>(context, listen: false);

    try {
      final koneksiTersedia = await _koneksiService.cekKoneksi();
      Log.info(
        'Status koneksi internet saat ini: ${koneksiTersedia ? "Online" : "Offline"}.',
      );

      if (koneksiTersedia && forceRefresh) {
        Log.info('Memulai pengunggahan data pelanggan aktif ke server.');
        await LayananUnggahData().unggahDataPelangganAktif().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            Log.warning('Waktu unggah data habis.');
            throw TimeoutException(
              'Waktu sinkronisasi habis, periksa kembali koneksi internet Anda.',
            );
          },
        );

        await syncManager.setTerakhirUnggah(now);
        Log.info('Pengunggahan data pelanggan aktif berhasil.');
      } else if (!koneksiTersedia && forceRefresh) {
        Log.warning(
          'Gagal memuat ulang data karena tidak ada koneksi internet.',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jaringan tidak tersedia. Menampilkan data lokal.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      final pelangganList = await _pelangganOperasi.getPelanggan();
      _mapNamaPelanggan = {for (var p in pelangganList) p.id: p.nama};

      final pelangganAktifList =
          await _pelangganAktifOperasi.ambilSemuaPelangganAktif();
      _semuaPelanggan = pelangganAktifList;

      Log.info(
        'Berhasil memuat ${_semuaPelanggan.length} data pelanggan aktif dari database lokal.',
      );
      _applyFilterAndSort();
    } on Exception catch (e, s) {
      Log.error(
        'Terjadi kesalahan saat memuat data pelanggan aktif.',
        e: e,
        st: s,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilterAndSort() {
    List<PelangganAktifModel> tempResult;
    final query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      tempResult = _semuaPelanggan.where((final pelanggan) {
        final nama =
            _mapNamaPelanggan[pelanggan.idPelanggan]?.toLowerCase() ?? '';
        return nama.contains(query);
      }).toList();
      Log.info(
        'Pencarian untuk "$query" menghasilkan ${tempResult.length} hasil.',
      );
    } else {
      tempResult = List.of(_semuaPelanggan);
    }

    final sortedResult =
        PelangganAktifSorter.sort(tempResult, _urutanAktif, _mapNamaPelanggan);
    Log.info('Data diurutkan berdasarkan: ${_urutanAktif.name}.');

    if (mounted) {
      setState(() {
        _hasilFilter = sortedResult;
      });
    }
  }

  Future<void> _arsipkanPelanggan(final PelangganAktifModel pelangganAktif) async {
    Log.info(
      'Meminta konfirmasi untuk mengarsipkan pelanggan aktif dengan ID: ${pelangganAktif.id}.',
    );
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsipkan'),
          content: Wrap(
            children: [
              const Text('Yakin ingin mengarsipkan '),
              NamaPelangganWidget(
                idPelanggan: pelangganAktif.idPelanggan,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Arsipkan',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (konfirmasi ?? false) {
      try {
        await _pelangganAktifOperasi.arsipkanPelangganAktif(pelangganAktif.id);
        Log.info(
          'Pelanggan aktif dengan ID: ${pelangganAktif.id} berhasil diarsipkan.',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pelanggan berhasil diarsipkan.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _semuaPelanggan.removeWhere((final p) => p.id == pelangganAktif.id);
          _hasilFilter.removeWhere((final p) => p.id == pelangganAktif.id);
        });
      } on Exception catch (e, s) {
        Log.error(
          'Gagal mengarsipkan pelanggan aktif dengan ID: ${pelangganAktif.id}.',
          e: e,
          st: s,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengarsipkan pelanggan: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showUrutkanDialog() async {
    Log.info('Membuka dialog untuk memilih opsi pengurutan.');
    final OpsiUrutkan? pilihan = await showDialog<OpsiUrutkan>(
      context: context,
      builder: (final BuildContext context) {
        Widget buildOption(final String text, final OpsiUrutkan value) {
          final bool isSelected = _urutanAktif == value;
          return Container(
            color: isSelected ? Theme.of(context).highlightColor : null,
            child: SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Tanggal Berakhir', OpsiUrutkan.tanggalBerakhir),
            buildOption('Tanggal Mulai', OpsiUrutkan.tanggalMulai),
            buildOption('Terakhir Diperbarui', OpsiUrutkan.diPerbarui),
            buildOption('Nama (A-Z)', OpsiUrutkan.namaAZ),
            buildOption('Nama (Z-A)', OpsiUrutkan.namaZA),
            buildOption('Status Pembayaran (Lunas)', OpsiUrutkan.lunas),
            buildOption(
              'Status Pembayaran (Belum Lunas)',
              OpsiUrutkan.belumLunas,
            ),
            buildOption('Status Paket (Aktif)', OpsiUrutkan.paketAktif),
            buildOption(
              'Status Paket (Tidak Aktif)',
              OpsiUrutkan.paketTidakAktif,
            ),
            SimpleDialogOption(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );

    if (pilihan != null && pilihan != _urutanAktif) {
      if (mounted) {
        setState(() {
          _urutanAktif = pilihan;
        });
      }
      _applyFilterAndSort();
    }
  }

  Future<void> _tambahPelangganAktif() async {
    Log.info('Navigasi ke halaman tambah pelanggan aktif.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (final context) => FormPelangganAktif()),
    );
    if (!mounted) return;
    if (result ?? false) {
      Log.info('Berhasil menambahkan pelanggan aktif baru.');
      await _loadData(forceRefresh: true);
    }
  }

  Future<void> _opsiLanjutan() async {
    Log.info('Membuka dialog opsi lanjutan.');
    final OpsiHapusPilihan? pilihan = await showDialog<OpsiHapusPilihan>(
      context: context,
      builder: (final BuildContext context) {
        return SimpleDialog(
          title: const Text('Opsi Lanjutan'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(context, OpsiHapusPilihan.arsipkanKadaluarsa),
              child: const Text('Arsipkan pelanggan kadaluarsa'),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(context, OpsiHapusPilihan.hapusSemua),
              child: Text(
                'Hapus Semua Pelanggan Aktif',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, OpsiHapusPilihan.batal),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    switch (pilihan) {
      case OpsiHapusPilihan.hapusSemua:
        Log.warning(
          'Meminta konfirmasi untuk menghapus semua pelanggan aktif.',
        );
        final bool? konfirmasi = await showDialog(
          context: context,
          builder: (final BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Hapus Semua'),
              content: const Text(
                'Yakin ingin menghapus SEMUA pelanggan aktif? Tindakan ini tidak dapat dibatalkan.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Hapus Semua'),
                ),
              ],
            );
          },
        );

        if (konfirmasi ?? false) {
          await _pelangganAktifOperasi.arsipkanSemuaPelangganAktif();
          Log.info('Semua pelanggan aktif berhasil diarsipkan.');
          await _loadData(forceRefresh: true);
        }
        break;
      case OpsiHapusPilihan.arsipkanKadaluarsa:
        Log.info(
          'Memulai proses pengarsipan pelanggan aktif yang sudah kadaluarsa.',
        );
        final int jumlahDiarsipkan =
            await _pelangganAktifOperasi.arsipkanPelangganKadaluarsa();
        Log.info(
          'Berhasil mengarsipkan $jumlahDiarsipkan pelanggan aktif yang sudah kadaluarsa.',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$jumlahDiarsipkan pelanggan kadaluarsa berhasil diarsipkan.',
            ),
          ),
        );
        await _loadData(forceRefresh: true);
        break;
      default:
        break;
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching ? _buildSearchField() : const Text('Pelanggan Aktif'),
      actions: _isSearching ? _buildSearchActions() : _buildDefaultActions(),
    );
  }

  Widget _buildSearchField() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Cari nama pelanggan...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _searchController.clear,
                )
              : null,
        ),
      ),
    );
  }

  List<Widget> _buildSearchActions() {
    return [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          Log.info('Menutup mode pencarian.');
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
          _searchController.clear();
        },
        tooltip: 'Tutup Pencarian',
      ),
    ];
  }

  List<Widget> _buildDefaultActions() {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          Log.info('Membuka mode pencarian.');
          if (mounted) {
            setState(() {
              _isSearching = true;
            });
          }
        },
        tooltip: 'Cari',
      ),
      IconButton(
        icon: const Icon(Icons.sort),
        onPressed: _showUrutkanDialog,
        tooltip: 'Urutkan',
      ),
      IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: _opsiLanjutan,
        tooltip: 'Lainnya',
      ),
    ];
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _semuaPelanggan.isEmpty
                  ? const Center(
                      child: Text('Tidak ada pelanggan aktif ditemukan.'),
                    )
                  : _hasilFilter.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(child: Text('Pelanggan tidak ditemukan.'))
                      : ListView.builder(
                          itemCount: _hasilFilter.length,
                          itemBuilder: (final context, final index) {
                            final pelanggan = _hasilFilter[index];
                            final statusPembayaran = pelanggan.status;
                            final paketFuture =
                                _paketOperasi.getPaketById(pelanggan.idPaket);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onLongPress: () =>
                                    _arsipkanPelanggan(pelanggan),
                                onTap: () async {
                                  Log.info(
                                    'Navigasi ke halaman detail pelanggan aktif dengan ID: ${pelanggan.id}.',
                                  );
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (final context) =>
                                          DetailPelangganAktif(
                                        pelanggan: pelanggan,
                                      ),
                                    ),
                                  );
                                  await _loadData(forceRefresh: true);
                                },
                                child: ListTile(
                                  title: NamaPelangganWidget(
                                    idPelanggan: pelanggan.idPelanggan,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      NamaPaketWidget(paketFuture: paketFuture),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pembayaran: ${statusPembayaran.displayName}',
                                        style: TextStyle(
                                          color: statusPembayaran ==
                                                  StatusPembayaranEnum.lunas
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Status: ${PerhitunganUtil.getTeksSisaMasaAktif(pelanggan.tanggalBerakhir)}',
                                        style: TextStyle(
                                          color: PerhitunganUtil
                                              .getWarnaSisaMasaAktif(
                                            pelanggan.tanggalBerakhir,
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Berakhir: ${FormatTanggal.formatTanggalBasic(pelanggan.tanggalBerakhir)} ${FormatJam.formatJamMenit(pelanggan.tanggalBerakhir)}',
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              ),
                            );
                          },
                        ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPelangganAktif,
        child: const Icon(Icons.add),
      ),
    );
  }
}
