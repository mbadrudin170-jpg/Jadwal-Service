// path: lib/admin/halaman/detail/detail_kritik_saran.dart
// Fitur: Detail Kritik dan Saran
// Tujuan: Menampilkan detail dari satu item kritik dan saran, dan menyediakan opsi untuk menghapusnya.
//
// Daftar Fungsi:
// - _loadData(): Memuat data kritik dan saran berdasarkan ID dari operasi.
// - _hapusKritikSaran(): Menangani logika untuk menghapus item kritik dan saran dengan konfirmasi.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/shared/operasi/kritik_saran_operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/nama_dari_id.dart';

/// Halaman untuk menampilkan detail dari sebuah kritik atau saran.
///
/// Pengguna dapat melihat isi pesan, pengirim, dan tanggal.
/// Terdapat juga opsi untuk menghapus item ini dari database.
class DetailKritikSaranPage extends StatefulWidget {
  /// ID unik dari dokumen kritik dan saran di Firestore.
  final String id;

  /// Konstruktor untuk membuat instance [DetailKritikSaranPage].
  const DetailKritikSaranPage({
    super.key,
    required this.id,
  });

  @override
  State<DetailKritikSaranPage> createState() => _DetailKritikSaranPageState();
}

/// State untuk [DetailKritikSaranPage].
class _DetailKritikSaranPageState extends State<DetailKritikSaranPage> {
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();

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

    _kritikSaranFuture =
        _kritikSaranOperasi.getKritikSaranById(widget.id).then((final value) {
      Log.info(
        'Data kritik dan saran berhasil dimuat dari database.',
      );

      return value;
      // diubah: Menambahkan tipe eksplisit Object dan StackTrace pada error handling.
      // Alasan: Untuk memenuhi aturan analisis statis yang ketat dan menghindari error 'inference_failure' dan 'argument_type_not_assignable'.
    }).catchError((final Object e, final StackTrace st) {
      Log.error(
        'Terjadi kesalahan saat mengambil data kritik dan saran.',
        e: e,
        st: st,
      );
      // diubah: Melempar error dengan tipe yang benar.
      // Alasan: Mengikuti praktik terbaik penanganan error setelah tipenya dipastikan.
      // diubah: Membungkus error dalam sebuah Exception untuk mematuhi aturan lint.
      throw Exception(e);
    });
  }

  Future<void> _hapusKritikSaran() async {
    Log.info(
      'Menampilkan dialog konfirmasi penghapusan kritik dan saran.',
    );

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final context) {
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

    if ((konfirmasi ?? false) && mounted) {
      Log.info(
        'Memulai proses penghapusan data kritik dan saran.',
      );

      try {
        Log.info(
          'Menampilkan loading dialog selama proses penghapusan.',
        );
        // diubah: Menambahkan await untuk memenuhi aturan unawaited_futures.
        // Alasan: Meskipun tidak menunggu hasilnya, ini adalah praktik yang baik untuk kejelasan kode dan menghilangkan peringatan linter.
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (final context) {
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
      } on Exception catch (e, st) {
        Log.error(
          'Terjadi kesalahan saat menghapus kritik dan saran.',
          e: e,
          st: st,
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
  Widget build(final BuildContext context) {
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
        builder: (final context, final snapshot) {
          Log.info(
            'FutureBuilder dijalankan dengan connection state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Data masih dalam proses loading.',
            );

            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder menerima error saat memuat data.',
              e: snapshot.error,
              st: snapshot.stackTrace,
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
                            size: 24,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: NamaDariIdWidget(
                              userId: kritikSaran.userId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        kritikSaran.isi,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const Divider(
                        height: 40,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          kritikSaran.tanggal != null
                              ? FormatTanggal.formatTanggalDanJam(
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
