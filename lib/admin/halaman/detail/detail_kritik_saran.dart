// path: lib/halaman/detail/detail_kritik_saran.dart

import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/widget/nama_dari_id.dart';
import 'package:flutter/material.dart';

class DetailKritikSaranPage extends StatefulWidget {
  final String id;

  const DetailKritikSaranPage({
    super.key,
    required this.id,
  });

  @override
  State<DetailKritikSaranPage> createState() =>
      _DetailKritikSaranPageState();
}

class _DetailKritikSaranPageState
    extends State<DetailKritikSaranPage> {
  final KritikSaranOperasi _kritikSaranOperasi =
      KritikSaranOperasi();

  late Future<KritikSaranModel> _kritikSaranFuture;

  @override
  void initState() {
    super.initState();

    Log.info(
      'Membuka halaman detail kritik dan saran dengan ID: ${widget.id}.',
    );

    _loadData();
  }

  void _loadData() {
    Log.info(
      'Memulai proses pengambilan data kritik dan saran dari database.',
    );

    _kritikSaranFuture = _kritikSaranOperasi
        .getKritikSaranById(widget.id)
        .then((value) {
      Log.info(
        'Data kritik dan saran berhasil dimuat dari database.',
      );

      return value;
    }).catchError((error, stackTrace) {
      Log.error(
        'Terjadi kesalahan saat mengambil data kritik dan saran.',
        error: error,
        stackTrace: stackTrace,
      );

      throw error;
    });
  }

  /// Fungsi untuk menghapus kritik saran
  Future<void> _hapusKritikSaran() async {
    Log.info(
      'Menampilkan dialog konfirmasi penghapusan kritik dan saran.',
    );

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        Log.info(
          'Dialog konfirmasi penghapusan berhasil ditampilkan.',
        );

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
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    Log.info(
      'Dialog konfirmasi selesai diproses dengan hasil: $konfirmasi.',
    );

    if (konfirmasi == true && mounted) {
      Log.info(
        'Memulai proses penghapusan data kritik dan saran.',
      );

      try {
        Log.info(
          'Menampilkan loading dialog selama proses penghapusan.',
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            Log.info(
              'Loading dialog berhasil ditampilkan.',
            );

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        Log.info(
          'Memanggil operasi hapus kritik dan saran ke database.',
        );

        await _kritikSaranOperasi.hapusKritikSaran(
          widget.id,
        );

        Log.info(
          'Data kritik dan saran berhasil dihapus dari database.',
        );

        if (mounted) {
          Log.info(
            'Menutup loading dialog.',
          );

          Navigator.of(context).pop();
        }

        if (mounted) {
          Log.info(
            'Menampilkan snackbar sukses penghapusan.',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Kritik dan saran berhasil dihapus',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (mounted) {
          Log.info(
            'Kembali ke halaman sebelumnya dengan status sukses.',
          );

          Navigator.of(context).pop(true);
        }
      } catch (e, stackTrace) {
        Log.error(
          'Terjadi kesalahan saat menghapus kritik dan saran.',
          error: e,
          stackTrace: stackTrace,
        );

        if (mounted) {
          Log.warning(
            'Menutup loading dialog karena terjadi error.',
          );

          Navigator.of(context).pop();
        }

        if (mounted) {
          Log.warning(
            'Menampilkan snackbar error penghapusan.',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menghapus: $e',
              ),
              backgroundColor: Colors.red,
            ),
          );
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
    Log.info(
      'Membangun UI halaman detail kritik dan saran.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Kritik & Saran',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _hapusKritikSaran,
            tooltip: 'Hapus Kritik & Saran',
          ),
        ],
      ),
      body: FutureBuilder<KritikSaranModel>(
        future: _kritikSaranFuture,
        builder: (context, snapshot) {
          Log.info(
            'FutureBuilder dijalankan dengan connection state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            Log.info(
              'Data masih dalam proses loading.',
            );

            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder menerima error saat memuat data.',
              error: snapshot.error,
            );

            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          } else if (snapshot.hasData) {
            Log.info(
              'FutureBuilder berhasil menerima data kritik dan saran.',
            );

            final kritikSaran = snapshot.data!;

            Log.info(
              'Menampilkan detail kritik dan saran dengan ID: ${kritikSaran.id}.',
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            size: 24,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: NamaDariIdWidget(
                              userId:
                                  kritikSaran.userId,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Pesan:',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        kritikSaran.isi,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const Divider(
                        height: 40,
                      ),
                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: Text(
                          FormatTanggal
                              .formatTanggalDanJam(
                            kritikSaran.tanggal,
                          ),
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
            Log.warning(
              'FutureBuilder tidak menerima data kritik dan saran.',
            );

            return const Center(
              child: Text(
                'Data tidak ditemukan',
              ),
            );
          }
        },
      ),
    );
  }
}