// path: lib/admin/halaman/lainnya/package.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/package_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';

/// Enum untuk menentukan kriteria pengurutan daftar paket.
enum UrutanPaket {
  /// Urutkan berdasarkan nama paket dari A hingga Z.
  namaAZ,

  /// Urutkan berdasarkan nama paket dari Z hingga A.
  namaZA,

  /// Urutkan berdasarkan harga paket dari yang tertinggi ke terendah.
  hargaTertinggi,

  /// Urutkan berdasarkan harga paket dari yang terendah ke tertinggi.
  hargaTerendah,

  /// Urutkan berdasarkan perolehan poin dari yang tertinggi ke terendah.
  poinTertinggi,

  /// Urutkan berdasarkan perolehan poin dari yang terendah ke tertinggi.
  poinTerendah,
}

/// Halaman untuk mengelola daftar paket internet.
///
/// Dari halaman ini, admin dapat melihat, menambah, mengubah,
/// menghapus, dan mengurutkan daftar paket yang ditawarkan.
class PackagePage extends StatefulWidget {
  /// Membuat instance dari [PackagePage].
  const PackagePage({super.key});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  final PackageOperation _paketOperasi = PackageOperation();
  late Future<List<PackageModel>> _paketFuture;
  // ditambah: Variabel untuk menyimpan status pengurutan saat ini, defaultnya A-Z.
  UrutanPaket _urutanSaatIni = UrutanPaket.namaAZ;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Paket');
    _refreshPaketList();
  }

  void _refreshPaketList() {
    Log.info('Memperbarui daftar paket dari database');
    setState(() {
      _paketFuture = _paketOperasi.getPackages();
    });
  }

  // ditambah: Fungsi untuk menampilkan dialog pilihan pengurutan.
  Future<void> _tampilkanDialogUrutkan() async {
    Log.info('Menampilkan dialog urutkan');
    final UrutanPaket? hasil = await showDialog<UrutanPaket>(
      context: context,
      builder: (final context) {
        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.namaAZ);
                Log.info('Mengurutkan berdasarkan: Nama (A-Z)');
              },
              child: const Text('Nama (A-Z)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.namaZA);
                Log.info('Mengurutkan berdasarkan: Nama (Z-A)');
              },
              child: const Text('Nama (Z-A)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.hargaTertinggi);
                Log.info('Mengurutkan berdasarkan: Harga (Tertinggi)');
              },
              child: const Text('Harga (Tertinggi)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.hargaTerendah);
                Log.info('Mengurutkan berdasarkan: Harga (Terendah)');
              },
              child: const Text('Harga (Terendah)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.poinTertinggi);
                Log.info('Mengurutkan berdasarkan: Poin (Tertinggi)');
              },
              child: const Text('Poin (Tertinggi)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.poinTerendah);
                Log.info('Mengurutkan berdasarkan: Poin (Terendah)');
              },
              child: const Text('Poin (Terendah)'),
            ),
          ],
        );
      },
    );

    if (hasil != null) {
      setState(() => _urutanSaatIni = hasil);
    }
  }

  Future<void> _showEditDeleteDialog(final PackageModel paket) async {
    Log.info('Menampilkan dialog opsi untuk paket: ${paket.name}');
    await showDialog<void>(
      context: context,
      builder: (final context) {
        return AlertDialog(
          title: Text(paket.name),
          content: const Text('Pilih aksi yang ingin Anda lakukan.'),
          actions: [
            TextButton(
              onPressed: () async {
                Log.info(
                  'Memilih navigasi ke Form Edit untuk paket: ${paket.name}',
                );
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (final context) => PackageForm(package: paket),
                  ),
                );
                Log.info('Kembali dari Form Edit, menyegarkan daftar paket');
                _refreshPaketList();
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Log.info('Memilih opsi Hapus untuk paket: ${paket.name}');
                Navigator.pop(context);
                unawaited(_showDeleteConfirmationDialog(paket));
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(final PackageModel paket) async {
    Log.info(
      'Menampilkan konfirmasi hapus untuk paket ID: ${paket.id}, nama: ${paket.name}',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus paket ${paket.name}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info(
                  'Penghapusan paket ${paket.name} dibatalkan oleh user',
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
                    'Menjalankan operasi hapus paket ID: ${paket.id}, nama: ${paket.name}',
                  );
                  await _paketOperasi.softDelete(paket.id);
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
                } on Exception catch (e, s) {
                  Log.error(
                    'Gagal menghapus paket ID: ${paket.id}, nama: ${paket.name}',
                    e: e,
                    st: s,
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

  Future<void> _hapusSemuaPaket() async {
    Log.info('User menekan tombol hapus semua paket');
    await showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
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
                  await _paketOperasi.softDeleteAll();
                  Log.info('Semua paket berhasil dihapus dari database');
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Semua paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } on Exception catch (e, s) {
                  Log.error(
                    'Gagal menghapus semua paket dari database',
                    e: e,
                    st: s,
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
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman Daftar Paket');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket'),
        actions: [
          // diubah: IconButton untuk menampilkan dialog pengurutan.
          IconButton(
            onPressed: _tampilkanDialogUrutkan,
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
          ),
          IconButton(
            onPressed: _hapusSemuaPaket,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: FutureBuilder<List<PackageModel>>(
        future: _paketFuture,
        builder: (final context, final snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            Log.error(
              'Terjadi error saat memuat data paket',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info('Data paket kosong, tidak ada paket yang tersedia');
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }

          final paketList = List<PackageModel>.from(snapshot.data!);

          // ditambah: Logika untuk mengurutkan daftar paket berdasarkan _urutanSaatIni
          switch (_urutanSaatIni) {
            case UrutanPaket.namaAZ:
              paketList.sort(
                (final a, final b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
              break;
            case UrutanPaket.namaZA:
              paketList.sort(
                (final a, final b) =>
                    b.name.toLowerCase().compareTo(a.name.toLowerCase()),
              );
              break;
            case UrutanPaket.hargaTertinggi:
              paketList.sort((final a, final b) => b.price.compareTo(a.price));
              break;
            case UrutanPaket.hargaTerendah:
              paketList.sort((final a, final b) => a.price.compareTo(b.price));
              break;
            // diubah: Menggunakan rewardPoints untuk pengurutan
            case UrutanPaket.poinTertinggi:
              paketList.sort((final a, final b) =>
                  b.rewardPoints.compareTo(a.rewardPoints));
              break;
            case UrutanPaket.poinTerendah:
              paketList.sort((final a, final b) =>
                  a.rewardPoints.compareTo(b.rewardPoints));
              break;
          }

          Log.info(
            'Menampilkan ${paketList.length} paket dalam daftar, diurutkan berdasarkan $_urutanSaatIni',
          );

          return ListView.builder(
            itemCount: paketList.length,
            itemBuilder: (final context, final index) {
              final paket = paketList[index];
              return InkWell(
                onTap: () async {
                  Log.info(
                    'Navigasi ke halaman Detail Paket: ${paket.name} (ID: ${paket.id})',
                  );
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (final context) =>
                          PackageDetailPage(package: paket),
                    ),
                  );
                  Log.info(
                    'Kembali dari halaman Detail Paket, menyegarkan daftar',
                  );
                  _refreshPaketList();
                },
                onLongPress: () async {
                  Log.info(
                    'Long press pada paket: ${paket.name} (ID: ${paket.id}), menampilkan menu edit/hapus',
                  );
                  await _showEditDeleteDialog(paket);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      paket.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Rp ${paket.price} / ${paket.duration} ${paket.type.displayName}',
                    ),
                    // diubah: Menampilkan rewardPoints di trailing
                    trailing: Text('Poin: ${paket.rewardPoints}'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Log.info('Navigasi ke Form Tambah Paket');
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (final context) => const PackageForm()),
          );
          Log.info('Kembali dari Form Tambah Paket, menyegarkan daftar');
          _refreshPaketList();
        },
        tooltip: 'Tambah Paket',
        child: const Icon(Icons.add),
      ),
    );
  }
}
