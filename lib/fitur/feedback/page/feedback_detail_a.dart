// path: lib/fitur/feedback/page/feedback_detail_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_global.dart';
import 'package:wifi/fitur/feedback/page/form_feedback_u.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';

class FeedbackDetailA extends ConsumerStatefulWidget {
  final String id;

  const FeedbackDetailA({super.key, required this.id});

  @override
  ConsumerState<FeedbackDetailA> createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends ConsumerState<FeedbackDetailA> {
  FeedbackOpGlobal get _feedbackOpGlobal => ref.read(feedbackOpGlobalProvider);
  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman detail feedback dengan ID: ${widget.id}');
    // ✅ Hapus _loadData() karena tidak berguna
  }

  Future<void> _softDeletedFeedback() async {
    Log.info('Menampilkan dialog konfirmasi penghapusan feedback.');

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Log.warning('Pengguna membatalkan penghapusan.');
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Log.info('Pengguna mengonfirmasi penghapusan.');
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if ((konfirmasi ?? false) && mounted) {
      try {
        unawaited(
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Menghapus feedback...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await _feedbackOpGlobal.softDelete(widget.id);
        if (mounted) {
          Navigator.pop(context); // Tutup loading dialog
          ToastUtil.success(context, 'Feedback berhasil dihapus');
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        }
      } catch (e, st) {
        Log.error('Gagal menghapus feedback', e: e, s: st);
        if (mounted) {
          Navigator.pop(context); // Tutup loading dialog
          ToastUtil.error(context, 'Gagal menghapus: $e');
        }
      }
    }
  }

  void _navigasiKeDetail(FeedbackModel feedback) {
    try {
      unawaited(
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => FormFeedBackU(feedback: feedback),
          ),
        ),
      );
    } on Exception catch (e, s) {
      Log.error('Error di navigasiKeDetail: $e', e: e, s: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman detail feedback.');

    final detailFeedbackAsync = ref.watch(detailFeedbackProvider(widget.id));
    return detailFeedbackAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        Log.error('Gagal memuat detail feedback', e: e, s: s);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Gagal memuat data: $e', textAlign: TextAlign.center),
          ),
        );
      },
      data: (feedback) {
        if (feedback == null) {
          return const Center(child: Text('Tidak ada feedback ditemukan'));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Feedback'),
            actions: [
              IconButton(
                onPressed: () => _navigasiKeDetail(feedback),
                icon: const Icon(TIcons.edit),
                tooltip: 'Edit',
              ),
              // ✅ Perbaiki akses isAdmin
              IconButton(
                icon: const Icon(TIcons.delete),
                onPressed: _softDeletedFeedback,
                tooltip: 'Hapus Feedback',
              ),
            ],
          ),
          body: _buildContent(context, feedback),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FeedbackModel feedback) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_pin,
                    color: Theme.of(context).colorScheme.primary,
                    size: TSizes.p12,
                  ),
                  gapH12,
                  Expanded(
                    child: NamaPelangganWidget(
                      idPelanggan: feedback.userId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              gapH12,
              const Text(
                'Pesan:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              gapH8,
              Text(
                feedback.pesan,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const Divider(height: 40),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  feedback.tanggal != null
                      ? FormatWaktuLengkap.formatSingkat(feedback.tanggal!)
                      : 'Tanggal tidak tersedia',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
