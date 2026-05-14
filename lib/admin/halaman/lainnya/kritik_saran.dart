// path: lib/admin/halaman/lainnya/kritik_saran.dart
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/detail_kritik_saran.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/shared/operasi/kritik_saran_operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';
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
      _kritikSaranFuture = _kritikSaranOperasi.getKritikSaran().then((final data) {
        Log.info('Berhasil memuat ${data.length} data kritik dan saran');
        return data;
      }).catchError((final Object e, final StackTrace st) {
        Log.error(
          'Gagal memuat data kritik dan saran dari database',
          e: e,
          st: st,
        );
        // diubah: Membungkus error dalam sebuah Exception untuk mematuhi aturan lint.
        throw Exception(e);
      });
    });
  }

  Future<void> _hapusKritikSaran(final KritikSaranModel item) async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kritik dan saran berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadKritikSaran();
      } on Exception catch (e, st) {
        Log.error(
          'Gagal menghapus kritik/saran ID: ${item.id}',
          e: e,
          st: st,
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
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kritik & Saran')),
      body: FutureBuilder<List<KritikSaranModel>>(
        future: _kritikSaranFuture,
        builder: (final context, final snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada kritik dan saran.'));
          } else {
            final listKritikSaran = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: listKritikSaran.length,
              itemBuilder: (final context, final index) {
                final item = listKritikSaran[index];
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
                      if (result ?? false) {
                        _loadKritikSaran();
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
                          Text(item.isi),
                          const Divider(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            // diubah: Menambahkan null check untuk properti tanggal
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
            );
          }
        },
      ),
    );
  }
}
