// path: lib/admin/halaman/lainnya/kritik_saran.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/feedback_detail.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/feedback_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/customer_name.dart';

/// Halaman untuk menampilkan daftar kritik dan saran dari pengguna.
///
/// Admin dapat melihat, membuka detail, dan menghapus kritik dan saran
/// yang masuk melalui halaman ini.
class FeedbackPage extends StatefulWidget {
  /// Membuat instance dari [FeedbackPage].
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FeedbackOperation _feedbackOperation = FeedbackOperation();
  final CustomerOperation _customerOperation = CustomerOperation();

  List<FeedbackModel> _allFeedback = [];
  List<FeedbackModel> _hasilFilter = [];
  Map<String, String> _mapNamaUser = {};
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Kritik & Saran');
    unawaited(_loadFeedback());
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
      _hasilFilter = _allFeedback.where((final item) {
        final isi = item.content.toLowerCase();
        final namaPengirim = _mapNamaUser[item.userId]?.toLowerCase() ?? '';
        return isi.contains(query) || namaPengirim.contains(query);
      }).toList();
    });
  }

  Future<void> _loadFeedback() async {
    Log.info('Memuat data kritik dan saran dari database');
    if (!_isLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final List<dynamic> results = await Future.wait([
        _feedbackOperation.getAllFeedback(),
        _customerOperation.getCustomers(),
      ]);

      final List<FeedbackModel> kritikSaranList =
          results[0] as List<FeedbackModel>;
      final List<CustomerModel> pelangganList =
          results[1] as List<CustomerModel>;

      if (mounted) {
        setState(() {
          _allFeedback = kritikSaranList;
          _mapNamaUser = {for (var p in pelangganList) p.id: p.name};
          _applyFilter();
          _isLoading = false;
        });
        Log.info(
            'Berhasil memuat ${_allFeedback.length} data kritik dan saran');
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

  Future<void> _deleteFeedback(final FeedbackModel item) async {
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
        await _feedbackOperation.deleteFeedback(item.id);

        if (mounted) {
          SnackBarUtil.success(context, 'Kritik dan saran berhasil dihapus');
        }
        await _loadFeedback();
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
        onRefresh: _loadFeedback,
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
                                    FeedbackDetailPage(id: item.id),
                              ),
                            );
                            if ((result ?? false) && mounted) {
                              await _loadFeedback();
                            }
                          },
                          onLongPress: () => _deleteFeedback(item),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomerNameWidget(customerId: item.userId),
                                const SizedBox(height: 12),
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
                                        ? FormatDateTime
                                            .formatDateAndTimeCompact(
                                            item.date!,
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
