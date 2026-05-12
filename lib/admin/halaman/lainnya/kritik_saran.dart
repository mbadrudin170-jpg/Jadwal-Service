// path: lib/admin/halaman/lainnya/kritik_saran.dart
import 'package:wifi/admin/halaman/detail/detail_kritik_saran.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/operasi/kritik_saran_operasi.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/shared/widget/nama_dari_id.dart';

class KritikSaranPage extends StatefulWidget {
  const KritikSaranPage({super.key});

  @override
  State<KritikSaranPage> createState() => _KritikSaranPageState();
}

class _KritikSaranPageState extends State<KritikSaranPage> {
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  late Future<List<KritikSaranModel>> _kritikSaranFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Kritik & Saran');
    _loadKritikSaran();
  }

  void _loadKritikSaran() {
    Log.info('Memuat data kritik dan saran dari database');
    setState(() {
      _kritikSaranFuture = _kritikSaranOperasi
          .getKritikSaran()
          .then((data) {
            Log.info('Berhasil memuat ${data.length} data kritik dan saran');
            for (var item in data) {
              Log.info('Data kritik/saran - ID: ${item.id}, User ID: ${item.userId}, Tanggal: ${item.tanggal}, Isi: ${item.isi.length > 50 ? '${item.isi.substring(0, 50)}...' : item.isi}');
            }
            return data;
          })
          .catchError((error, stackTrace) {
            Log.error(
              'Gagal memuat data kritik dan saran dari database',
              error: error,
              stackTrace: stackTrace,
            );
            throw error;
          });
    });
  }

  Future<void> _hapusKritikSaran(KritikSaranModel item) async {
    Log.info('Menampilkan konfirmasi hapus untuk kritik/saran ID: ${item.id}, User ID: ${item.userId}');

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Log.info('Dialog hapus kritik/saran ID: ${item.id} - User memilih Batal');
              Navigator.of(context).pop(false);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Log.info('Dialog hapus kritik/saran ID: ${item.id} - User memilih Hapus');
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      try {
        Log.info('Menjalankan operasi hapus kritik/saran ID: ${item.id} dari database');
        await _kritikSaranOperasi.hapusKritikSaran(item.id);

        Log.info('Kritik/saran ID: ${item.id} berhasil dihapus dari database');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kritik dan saran berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadKritikSaran();
      } catch (e, stackTrace) {
        Log.error(
          'Gagal menghapus kritik/saran ID: ${item.id} dari database',
          error: e,
          stackTrace: stackTrace,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman Kritik & Saran');
    return Scaffold(
      appBar: AppBar(title: const Text('Kritik & Saran')),
      body: FutureBuilder<List<KritikSaranModel>>(
        future: _kritikSaranFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'Terjadi error saat memuat data kritik dan saran di FutureBuilder',
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info('Data kritik dan saran kosong, belum ada kritik dan saran');
            return const Center(child: Text('Belum ada kritik dan saran.'));
          } else {
            final listKritikSaran = snapshot.data!;
            Log.info('Menampilkan ${listKritikSaran.length} item kritik dan saran dalam daftar');
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: listKritikSaran.length,
              itemBuilder: (context, index) {
                final item = listKritikSaran[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      Log.info('Navigasi ke halaman Detail Kritik/Saran ID: ${item.id}');
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailKritikSaranPage(id: item.id),
                        ),
                      );

                      if (result == true) {
                        Log.info('Kembali dari halaman Detail Kritik/Saran dengan perubahan data, menyegarkan daftar');
                        _loadKritikSaran();
                      } else {
                        Log.info('Kembali dari halaman Detail Kritik/Saran tanpa perubahan data');
                      }
                    },
                    onLongPress: () {
                      Log.info('Long press pada kritik/saran ID: ${item.id}, menampilkan menu hapus');
                      _hapusKritikSaran(item);
                    },
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
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              NamaDariIdWidget(
                                userId: item.userId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.isi,
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                          const Divider(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              FormatTanggal.formatTanggalDanJam(item.tanggal),
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
          }
        },
      ),
    );
  }
}
