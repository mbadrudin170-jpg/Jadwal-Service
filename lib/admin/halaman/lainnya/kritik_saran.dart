// path: lib/admin/halaman/lainnya/kritik_saran.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/detail_kritik_saran.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/kritik_saran_operasi.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/nama_dari_id.dart';

/// Halaman untuk menampilkan daftar kritik dan saran dari pengguna.
///
/// Admin dapat melihat, membuka detail, dan menghapus kritik dan saran
/// yang masuk melalui halaman ini.
class KritikSaranPage extends StatefulWidget {
  /// Membuat instance dari [KritikSaranPage].
  const KritikSaranPage({super.key});

  @override
  State<KritikSaranPage> createState() => _KritikSaranPageState();
}

class _KritikSaranPageState extends State<KritikSaranPage> {
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  List<FeedbackModel> _semuaKritikSaran = [];
  List<FeedbackModel> _hasilFilter = [];
  Map<String, String> _mapNamaUser = {};
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Kritik & Saran');
    unawaited(_loadKritikSaran());
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    Log.info('Menutup halaman Kritik & Saran');
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    Log.info('Menerapkan filter dengan query: "$query"');
    setState(() {
      _hasilFilter = _semuaKritikSaran.where((final item) {
        final isi = item.isi.toLowerCase();
        final namaPengirim = _mapNamaUser[item.userId]?.toLowerCase() ?? '';
        return isi.contains(query) || namaPengirim.contains(query);
      }).toList();
    });
  }

  Future<void> _loadKritikSaran() async {
    Log.info('Memuat data kritik dan saran dari database');
    if (!_isLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final List<dynamic> results = await Future.wait([
        _kritikSaranOperasi.getKritikSaran(),
        _pelangganOperasi.getPelanggan(),
      ]);

      final List<FeedbackModel> kritikSaranList =
          results[0] as List<FeedbackModel>;
      final List<PelangganModel> pelangganList =
          results[1] as List<PelangganModel>;

      if (mounted) {
        setState(() {
          _semuaKritikSaran = kritikSaranList;
          _mapNamaUser = {for (var p in pelangganList) p.id: p.nama};
          _applyFilter();
          _isLoading = false;
        });
        Log.info(
            'Berhasil memuat ${_semuaKritikSaran.length} data kritik dan saran');
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memuat data kritik dan saran dari database',
        e: e,
        st: st,
      );
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal memuat data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _hapusKritikSaran(final FeedbackModel item) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if ((konfirmasi ?? false) && mounted) {
      try {
        await _kritikSaranOperasi.hapusKritikSaran(item.id);

        if (mounted) {
          SnackBarUtil.success(context, 'Kritik dan saran berhasil dihapus');
        }
        await _loadKritikSaran();
      } on Exception catch (e, st) {
        Log.error(
          'Gagal menghapus kritik/saran ID: ${item.id}',
          e: e,
          st: st,
        );
        if (mounted) {
          SnackBarUtil.error(context, 'Gagal menghapus: $e');
        }
      }
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching ? _buildSearchField() : const Text('Kritik & Saran'),
      actions: _isSearching ? _buildSearchActions() : _buildDefaultActions(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Cari...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
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
    ];
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadKritikSaran,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_hasilFilter.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? 'Tidak ada hasil ditemukan.'
                          : 'Belum ada kritik dan saran.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _hasilFilter.length,
                    itemBuilder: (final context, final index) {
                      final item = _hasilFilter[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute<bool>(
                                builder: (final context) =>
                                    DetailKritikSaranPage(id: item.id),
                              ),
                            );
                            if ((result ?? false) && mounted) {
                              await _loadKritikSaran();
                            }
                          },
                          onLongPress: () => _hapusKritikSaran(item),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NamaDariIdWidget(userId: item.userId),
                                const SizedBox(height: 12),
                                Text(
                                  item.isi,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(height: 24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    item.tanggal != null
                                        ? FormatTanggal.formatTanggalDanJam(
                                            item.tanggal!,
                                          )
                                        : 'Tanggal tidak tersedia',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
      ),
    );
  }
}
