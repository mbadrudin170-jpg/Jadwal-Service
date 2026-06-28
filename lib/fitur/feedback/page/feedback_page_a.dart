// path: lib/fitur/feedback/page/feedback_page_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_global.dart';
import 'package:wifi/fitur/feedback/page/feedback_detail_a.dart';
import 'package:wifi/fitur/feedback/page/form_feedback_u.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart'; // Import provider baru Anda
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';

class FeedbackPageA extends ConsumerStatefulWidget {
  const FeedbackPageA({super.key});

  @override
  ConsumerState<FeedbackPageA> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPageA> {
  List<FeedbackModel> _hasilFilter = [];
  Map<String, String> _mapNamaUser = {};
  bool _mencari = false;
  final TextEditingController _mencariController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Kritik & Saran');
    _mencariController.addListener(_syncFilterOnly);
    unawaited(_loadPelangganMapping());
  }

  @override
  void dispose() {
    Log.info('Menutup halaman Kritik & Saran');
    _mencariController.removeListener(_syncFilterOnly);
    _mencariController.dispose();
    super.dispose();
  }

  /// Memuat data pelanggan sekali saja untuk mapping ID -> Nama
  Future<void> _loadPelangganMapping() async {
    try {
      final pelangganList = await ref
          .read(pelangganOpSqliteProvider)
          .ambilSemua();
      if (mounted) {
        setState(() {
          _mapNamaUser = {for (var p in pelangganList) p.id: p.nama};
        });
      }
    } catch (e) {
      Log.error('Gagal memuat mapping pelanggan', e: e);
    }
  }

  /// Fungsi pembantu untuk memfilter data lokal berdasarkan query pencarian
  void _applyFilter(List<FeedbackModel> allFeedback) {
    final query = _mencariController.text.toLowerCase();
    _hasilFilter = allFeedback.where((item) {
      final isi = item.pesan.toLowerCase();
      final namaPengirim = _mapNamaUser[item.userId]?.toLowerCase() ?? '';
      return isi.contains(query) || namaPengirim.contains(query);
    }).toList();
  }

  void _syncFilterOnly() {
    setState(() {});
  }

  Future<void> _hapusFeedback(FeedbackModel feedback) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      Log.info('Memproses penghapusan kritik/saran ID: ${feedback.id}');
      try {
        await ref.read(feedbackOpGlobalProvider).softDelete(feedback.id);
        if (mounted) {
          ToastUtil.success(context, 'Kritik dan saran berhasil dihapus');
        }
      } catch (e, st) {
        Log.error(
          'Gagal menghapus kritik/saran ID: ${feedback.id}',
          e: e,
          s: st,
        );
        if (mounted) {
          ToastUtil.error(context, 'Gagal menghapus: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackAsync = ref.watch(daftarFeedbackAktifProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(daftarFeedbackAktifProvider.future),
        child: feedbackAsync.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) {
            Log.error('Gagal memuat data kritik dan saran', e: e, s: st);
            return Center(child: Text('Gagal memuat data: $e'));
          },
          data: (semuaFeedback) {
            _applyFilter(semuaFeedback);
            if (_hasilFilter.isEmpty) {
              return Center(
                child: Text(
                  _mencariController.text.isNotEmpty
                      ? 'Tidak ada hasil ditemukan.'
                      : 'Belum ada kritik dan saran.',
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _hasilFilter.length,
              itemBuilder: (context, index) {
                final item = _hasilFilter[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () async {
                      unawaited(
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => FeedbackDetailA(id: item.id),
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _hapusFeedback(item),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NamaPelangganWidget(idPelanggan: item.userId),
                          gapH12,
                          Text(
                            item.pesan,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              item.tanggal != null
                                  ? FormatWaktuLengkap.formatSingkat(
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => const FormFeedBackU()),
        ),
        label: const Text('Beri Masukan'),
        icon: const Icon(TIcons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _mencari ? _buildSearchField() : const Text('Kritik & Saran'),
      actions: _mencari ? _buildSearchActions() : _buildDefaultActions(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _mencariController,
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
              _mencari = false;
            });
          }
          _mencariController.clear();
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
              _mencari = true;
            });
          }
        },
        tooltip: 'Cari',
      ),
    ];
  }
}
