// path: lib/halaman/lainnya/paket.dart

import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/debug/log.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/form/form_paket.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:flutter/material.dart';

class PaketPage extends StatefulWidget {
  const PaketPage({super.key});

  @override
  State<PaketPage> createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> {
  final PaketOperasi _paketOperasi = PaketOperasi();
  late Future<List<PaketModel>> _paketFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Paket');
    _refreshPaketList();
  }

  void _refreshPaketList() {
    Log.info('Memperbarui daftar paket dari database');
    setState(() {
      _paketFuture = _paketOperasi.getPaket();
    });
  }

  void _showEditDeleteDialog(PaketModel paket) {
    Log.info('Menampilkan dialog opsi untuk paket: ${paket.nama}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(paket.nama),
          content: const Text('Pilih aksi yang ingin Anda lakukan.'),
          actions: [
            TextButton(
              onPressed: () {
                Log.info(
                  'Memilih navigasi ke Form Edit untuk paket: ${paket.nama}',
                );
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormPaket(paket: paket),
                  ),
                ).then((_) {
                  Log.info('Kembali dari Form Edit, menyegarkan daftar paket');
                  _refreshPaketList();
                });
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Log.info('Memilih opsi Hapus untuk paket: ${paket.nama}');
                Navigator.pop(context);
                _showDeleteConfirmationDialog(paket);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(PaketModel paket) {
    Log.info(
      'Menampilkan konfirmasi hapus untuk paket ID: ${paket.id}, nama: ${paket.nama}',
    );
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus paket ${paket.nama}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info(
                  'Penghapusan paket ${paket.nama} dibatalkan oleh user',
                );
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();

                try {
                  Log.info(
                    'Menjalankan operasi hapus paket ID: ${paket.id}, nama: ${paket.nama}',
                  );
                  await _paketOperasi.hapusPaket(paket.id);
                  Log.info(
                    'Paket ID: ${paket.id} berhasil dihapus dari database',
                  );
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, s) {
                  Log.error(
                    'Gagal menghapus paket ID: ${paket.id}, nama: ${paket.nama}',
                    error: e,
                    stackTrace: s,
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus paket: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _hapusSemuaPaket() {
    Log.info('User menekan tombol hapus semua paket');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Semua'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus SEMUA paket? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Penghapusan massal semua paket dibatalkan oleh user');
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus Semua'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();

                try {
                  Log.info(
                    'Menjalankan operasi hapus semua paket dari database',
                  );
                  await _paketOperasi.hapusSemuaPaket();
                  Log.info('Semua paket berhasil dihapus dari database');
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Semua paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, s) {
                  Log.error(
                    'Gagal menghapus semua paket dari database',
                    error: e,
                    stackTrace: s,
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus semua paket: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman Daftar Paket');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket'),
        actions: [
          IconButton(
            onPressed: _hapusSemuaPaket,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: FutureBuilder<List<PaketModel>>(
        future: _paketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            Log.error(
              'Terjadi error saat memuat data paket',
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info('Data paket kosong, tidak ada paket yang tersedia');
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }
          final paketList = snapshot.data!;
          Log.info('Menampilkan ${paketList.length} paket dalam daftar');

          return ListView.builder(
            itemCount: paketList.length,
            itemBuilder: (context, index) {
              final paket = paketList[index];
              return InkWell(
                onTap: () {
                  Log.info(
                    'Navigasi ke halaman Detail Paket: ${paket.nama} (ID: ${paket.id})',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPaketPage(paket: paket),
                    ),
                  ).then((_) {
                    Log.info(
                      'Kembali dari halaman Detail Paket, menyegarkan daftar',
                    );
                    _refreshPaketList();
                  });
                },
                onLongPress: () {
                  Log.info(
                    'Long press pada paket: ${paket.nama} (ID: ${paket.id}), menampilkan menu edit/hapus',
                  );
                  _showEditDeleteDialog(paket);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      paket.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Rp ${paket.harga} / ${paket.durasi} ${paket.tipe.name}',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Log.info('Navigasi ke Form Tambah Paket');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPaket()),
          ).then((_) {
            Log.info('Kembali dari Form Tambah Paket, menyegarkan daftar');
            _refreshPaketList();
          });
        },
        tooltip: 'Tambah Paket',
        child: const Icon(Icons.add),
      ),
    );
  }
}
