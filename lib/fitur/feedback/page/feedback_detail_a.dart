// path: lib/fitur/feedback/page/feedback_detail_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
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
  late final FeedbackOpSqlite _feedbackOpSqlite;

  late Future<FeedbackModel> _feedbackFuture;

  @override
  void initState() {
    super.initState();
    _feedbackOpSqlite = ref.watch(feedbackOpSqliteProvider);
    Log.info(
      'Membuka halaman detail kritik dan saran dengan ID: ${widget.id}.',
    );
    _loadData();
  }

  void _loadData() {
    Log.info('Memulai proses pengambilan data kritik dan saran dari database.');

    _feedbackFuture = _feedbackOpSqlite
        .ambilBerdasarkanId(widget.id)
        .then((value) {
          Log.info('Data kritik dan saran berhasil dimuat dari database.');

          return value;
        })
        .catchError((Object e, StackTrace s) {
          Log.error(
            'Terjadi kesalahan saat mengambil data kritik dan saran.',
            e: e,
            s: s,
          );
          throw Exception(e);
        });
  }

  Future<void> _deleteFeedback() async {
    Log.info('Menampilkan dialog konfirmasi penghapusan kritik dan saran.');

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        Log.info('Dialog konfirmasi penghapusan berhasil ditampilkan.');

        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Log.warning(
                  'Pengguna membatalkan proses penghapusan kritik dan saran.',
                );
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Log.info(
                  'Pengguna mengonfirmasi penghapusan kritik dan saran.',
                );

                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    Log.info('Dialog konfirmasi selesai diproses dengan hasil: $konfirmasi.');

    if ((konfirmasi ?? false) && mounted) {
      Log.info('Memulai proses penghapusan data kritik dan saran.');

      try {
        Log.info('Menampilkan loading dialog selama proses penghapusan.');

        unawaited(
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              Log.info('Loading dialog berhasil ditampilkan.');

              return const Center(child: CircularProgressIndicator());
            },
          ),
        );

        Log.info('Memanggil operasi hapus kritik dan saran ke database.');

        await _feedbackOpSqlite.softDelete(widget.id);

        Log.info('Data kritik dan saran berhasil dihapus dari database.');

        if (mounted) {
          Log.info('Menutup loading dialog.');

          Navigator.of(context).pop();
        }

        if (mounted) {
          ToastUtil.success(context, 'Kritik dan saran berhasil dihapus');
        }

        if (mounted) {
          Log.info('Kembali ke halaman sebelumnya dengan status sukses.');

          Navigator.of(context).pop(true);
        }
      } catch (e, st) {
        Log.error(
          'Terjadi kesalahan saat menghapus kritik dan saran.',
          e: e,
          s: st,
        );

        if (mounted) {
          Log.warning('Menutup loading dialog karena terjadi error.');

          Navigator.of(context).pop();
        }

        if (mounted) {
          ToastUtil.error(context, 'Gagal menghapus: $e');
        }
      }
    } else {
      Log.warning(
        'Proses penghapusan dibatalkan atau widget sudah tidak mounted.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman detail kritik dan saran.');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kritik & Saran'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(TIcons.edit),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteFeedback,
            tooltip: 'Hapus Kritik & Saran',
          ),
        ],
      ),
      body: FutureBuilder<FeedbackModel>(
        future: _feedbackFuture,
        builder: (context, snapshot) {
          Log.info(
            'FutureBuilder dijalankan dengan connection state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info('Data masih dalam proses loading.');

            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder menerima error saat memuat data.',
              e: snapshot.error,
              s: snapshot.stackTrace,
            );

            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Log.info('FutureBuilder berhasil menerima data kritik dan saran.');

            final kritikSaran = snapshot.data!;

            Log.info(
              'Menampilkan detail kritik dan saran dengan ID: ${kritikSaran.id}.',
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                              idPelanggan: kritikSaran.userId,
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
                        kritikSaran.pesan,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const Divider(height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          kritikSaran.tanggal != null
                              ? FormatWaktuLengkap.formatSingkat(
                                  kritikSaran.tanggal!,
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
          } else {
            Log.warning('FutureBuilder tidak menerima data kritik dan saran.');

            return const Center(child: Text('Data tidak ditemukan'));
          }
        },
      ),
    );
  }
}
