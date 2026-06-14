// path: lib/fitur/feedback/page/feedback_page_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/page/feedback_detail_page_a.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart'; // Import provider baru Anda
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  List<FeedbackModel> _hasilFilter = [];
  Map<String, String> _mapNamaUser = {};
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Kritik & Saran');
    _searchController.addListener(_syncFilterOnly);
    unawaited(_loadPelangganMapping());
  }

  @override
  void dispose() {
    Log.info('Menutup halaman Kritik & Saran');
    _searchController.removeListener(_syncFilterOnly);
    _searchController.dispose();
    super.dispose();
  }

  /// Memuat data pelanggan sekali saja untuk mapping ID -> Nama
  Future<void> _loadPelangganMapping() async {
    try {
      final pelangganList =
          await ref.read(pelangganOpSqliteProvider).ambilSemua();
      if (mounted) {
        setState(() {
          _mapNamaUser = {for (var p in pelangganList) p.id: p.name};
        });
      }
    } catch (e) {
      Log.error('Gagal memuat mapping pelanggan', e: e);
    }
  }

  /// Fungsi pembantu untuk memfilter data lokal berdasarkan query pencarian
  void _applyFilter(List<FeedbackModel> allFeedback) {
    final query = _searchController.text.toLowerCase();
    _hasilFilter = allFeedback.where((item) {
      final isi = item.content.toLowerCase();
      final namaPengirim = _mapNamaUser[item.userId]?.toLowerCase() ?? '';
      return isi.contains(query) || namaPengirim.contains(query);
    }).toList();
  }

  /// Listener sederhana saat mengetik di search bar agar UI lokal ter-update
  void _syncFilterOnly() {
    setState(() {});
  }

  Future<void> _deleteFeedback(final FeedbackModel item) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus kritik dan saran ini?'),
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
      Log.info('Memproses penghapusan kritik/saran ID: ${item.id}');
      try {
        await ref.read(feedbackOperationProvider).softDelete(item.id);
        final _ = ref.refresh(activeFeedbackListProvider);
        if (mounted) {
          ToastUtil.success(context, 'Kritik dan saran berhasil dihapus');
        }
      } on Exception catch (e, st) {
        Log.error('Gagal menghapus kritik/saran ID: ${item.id}', e: e, s: st);
        if (mounted) {
          ToastUtil.error(context, 'Gagal menghapus: $e');
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    // 3. Ambil dan pantau (watch) state dari provider baru Anda di sini
    final feedbackAsync = ref.watch(activeFeedbackListProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(activeFeedbackListProvider.future),
        child: feedbackAsync.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) {
            Log.error('Gagal memuat data kritik dan saran', e: e, s: st);
            return Center(child: Text('Gagal memuat data: $e'));
          },
          data: (allFeedback) {
            // Jalankan filter pencarian terhadap data real-time dari Riverpod
            _applyFilter(allFeedback);

            if (_hasilFilter.isEmpty) {
              return Center(
                child: Text(
                  _searchController.text.isNotEmpty
                      ? 'Tidak ada hasil ditemukan.'
                      : 'Belum ada kritik dan saran.',
                ),
              );
            }

            return ListView.builder(
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
                              FeedbackDetailPage(id: item.id),
                        ),
                      );
                      // Jika kembali membawa nilai true, segarkan data
                      if ((result ?? false) && mounted) {
                        ref.invalidate(activeFeedbackListProvider);
                      }
                    },
                    onLongPress: () => _deleteFeedback(item),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NamaPelangganWidget(customerId: item.userId),
                          gapH12,
                          Text(
                            item.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              item.date != null
                                  ? FormatDateTime.formatDateAndTimeCompact(
                                      item.date!)
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
            );
          },
        ),
      ),
    );
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
        icon: const Icon(TIcons.close),
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
        icon: const Icon(TIcons.search),
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
}
