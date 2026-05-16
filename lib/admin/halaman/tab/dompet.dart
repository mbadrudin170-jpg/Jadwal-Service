// path: lib/admin/halaman/tab/dompet.dart
// diubah: Memperbaiki LateInitializationError dengan menginisialisasi _dompetOperasi di initState.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/detail/detail_dompet.dart';
import 'package:wifi/admin/halaman/form/form_dompet.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/info_ringkasan_widget.dart';

/// Halaman untuk menampilkan dan mengelola dompet.
///
/// Menampilkan ringkasan keuangan (pemasukan, pengeluaran, total) dan daftar dompet.
class DompetPage extends StatefulWidget {
  /// Operasi dompet yang akan digunakan oleh halaman.
  final DompetOperasi? dompetOperasi;

  /// Operasi transaksi yang akan digunakan oleh halaman, terutama untuk diteruskan ke halaman detail.
  final TransaksiOperasi? transaksiOperasi;

  /// Membuat instance dari [DompetPage].
  const DompetPage({
    super.key,
    this.dompetOperasi,
    this.transaksiOperasi,
  });

  @override
  State<DompetPage> createState() => _DompetPageState();
}

class _DompetPageState extends State<DompetPage> {
  late final DompetOperasi _dompetOperasi;
  late Future<List<DompetModel>> _listaDompetFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Halaman Dompet sedang diinisialisasi.');
    _dompetOperasi = widget.dompetOperasi ?? DompetOperasi();
    _loadDompet();
  }

  void _loadDompet() {
    Log.info('Memulai pemuatan data dompet dan ringkasan keuangan.');
    setState(() {
      _listaDompetFuture = _dompetOperasi.getDompet();
    });

    Log.info('Pemuatan data dompet dan ringkasan keuangan telah dijadwalkan.');
  }

  Future<void> _tambahDompet() async {
    Log.info('Navigasi ke halaman tambah dompet.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (final context) => const FormDompet()),
    );
    if (!mounted) return;
    if (result ?? false) {
      Log.info('Berhasil menambahkan dompet baru, memuat ulang data.');
      _loadDompet();
    }
  }

  Future<void> _tampilkanDialogHapusSemua() async {
    Log.info('Menampilkan dialog konfirmasi hapus semua dompet.');
    final dompetList = await _dompetOperasi.getDompet();
    if (!mounted) return;

    if (dompetList.isEmpty) {
      Log.warning('Tidak ada dompet untuk dihapus. Dialog tidak ditampilkan.');
      SnackBarUtil.info(
        context,
        'Tidak ada dompet untuk dihapus.',
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua dompet? Tindakan ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Pengguna membatalkan penghapusan semua dompet.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Log.warning(
                  'Pengguna mengkonfirmasi penghapusan semua dompet melalui dialog. Memanggil _hapusSemuaDompet.',
                );
                Navigator.of(context).pop();
                unawaited(
                  _hapusSemuaDompet(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDialogHapusSatu(final DompetModel dompet) async {
    Log.info(
      'Memicu fungsi _showDialogHapusSatu untuk dompet ID: ${dompet.id}, Nama: "${dompet.namaDompet}". Menampilkan dialog konfirmasi.',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan dompet "${dompet.namaDompet}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info(
                  'Pengguna membatalkan pengarsipan dompet ID: ${dompet.id}, Nama: "${dompet.namaDompet}". Dialog ditutup, tidak ada aksi.',
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                Log.warning(
                  'Pengguna mengkonfirmasi pengarsipan dompet ID: ${dompet.id}, Nama: "${dompet.namaDompet}". Memanggil _hapusSatuDompet.',
                );
                Navigator.of(context).pop();
                unawaited(_hapusSatuDompet(dompet));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _hapusSatuDompet(final DompetModel dompet) async {
    Log.info('Memulai pengarsipan dompet: "${dompet.namaDompet}".');
    try {
      await _dompetOperasi.arsipkanSatuDompet(dompet.id);
      _loadDompet();
      if (!mounted) return;
      Log.info('Dompet "${dompet.namaDompet}" berhasil diarsipkan.');
      SnackBarUtil.success(
        context,
        'Dompet berhasil diarsipkan.',
      );
    } on Exception catch (e, s) {
      if (!mounted) return;
      Log.error(
        'Gagal mengarsipkan dompet: "${dompet.namaDompet}".',
        e: e,
        st: s,
      );
      SnackBarUtil.error(
        context,
        'Gagal mengarsipkan dompet: $e',
      );
    }
  }

  Future<void> _hapusSemuaDompet() async {
    Log.info('Memulai penghapusan semua dompet.');
    try {
      await _dompetOperasi.hapusSemuaDompet();
      _loadDompet();
      if (!mounted) return;
      Log.info('Semua dompet berhasil dihapus.');
      SnackBarUtil.success(
        context,
        'Semua dompet berhasil dihapus.',
      );
    } on Exception catch (e, s) {
      if (!mounted) return;
      Log.error('Gagal menghapus semua dompet.', e: e, st: s);
      SnackBarUtil.error(
        context,
        'Gagal menghapus dompet: $e',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk Halaman Dompet.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _tampilkanDialogHapusSemua,
            tooltip: 'Hapus Semua Dompet',
          ),
        ],
      ),
      body: Column(
        children: [
          RingkasanKeuangan(
            dompetOperasi: _dompetOperasi,
          ),
          Expanded(
            child: FutureBuilder<List<DompetModel>>(
              future: _listaDompetFuture,
              builder: (final context, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  Log.info('Menunggu data dompet...');
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  Log.error(
                    'Error saat memuat data dompet.',
                    e: snapshot.error,
                    st: snapshot.stackTrace,
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  Log.info('Tidak ada data dompet ditemukan.');
                  return const Center(
                    child: Text('Tidak ada dompet ditemukan.'),
                  );
                } else {
                  Log.info(
                    'Berhasil memuat ${snapshot.data!.length} dompet, membangun daftar.',
                  );
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (final context, final index) {
                      final dompet = snapshot.data![index];
                      return DompetCard(
                        dompet: dompet,
                        onTap: () async {
                          Log.info(
                            'Navigasi ke detail dompet: "${dompet.namaDompet}".',
                          );
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (final context) => DetailDompet(
                                dompet: dompet,
                                dompetOperasi: _dompetOperasi,
                                transaksiOperasi: widget.transaksiOperasi,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          _loadDompet();
                        },
                        onLongPress: () => _showDialogHapusSatu(dompet),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahDompet,
        tooltip: 'Tambah Dompet',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget untuk menampilkan ringkasan keuangan.
///
/// Menampilkan pemasukan, pengeluaran, dan total saldo.
class RingkasanKeuangan extends StatefulWidget {
  /// Operasi dompet yang akan digunakan untuk mengambil data ringkasan.
  final DompetOperasi dompetOperasi;

  /// Membuat instance dari [RingkasanKeuangan].
  const RingkasanKeuangan({super.key, required this.dompetOperasi});

  @override
  State<RingkasanKeuangan> createState() => _RingkasanKeuanganState();
}

class _RingkasanKeuanganState extends State<RingkasanKeuangan> {
  late Future<List<double>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi widget Ringkasan Keuangan.');
    _loadSummary();
  }

  void _loadSummary() {
    Log.info('Memuat data ringkasan keuangan.');
    _summaryFuture = Future.wait([
      widget.dompetOperasi.getTotalSaldoPositif(),
      widget.dompetOperasi.getTotalSaldoNegatif(),
      widget.dompetOperasi.getTotalSaldo(),
    ]);
  }

  // Metode ini bisa dipanggil dari parent untuk refresh
  void refresh() {
    Log.info('Memuat ulang data ringkasan keuangan atas permintaan parent.');
    setState(_loadSummary);
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk widget Ringkasan Keuangan.');
    return FutureBuilder<List<double>>(
      future: _summaryFuture,
      builder: (final context, final snapshot) {
        double pemasukan = 0.0;
        double pengeluaran = 0.0;
        double total = 0.0;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final result = snapshot.data!;
          pemasukan = result[0];
          pengeluaran = result[1].abs(); // Tampilkan sebagai angka positif
          total = result[2];
          Log.info(
            'Ringkasan keuangan berhasil dihitung: Pemasukan=$pemasukan, Pengeluaran=$pengeluaran, Total=$total',
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Menunggu data ringkasan keuangan...');
        } else if (snapshot.hasError) {
          Log.error(
            'Gagal memuat ringkasan keuangan',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
        }

        return Card(
          margin: const EdgeInsets.all(12.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      bangunInfoRingkasan(
                        context: context,
                        label: 'Pemasukan',
                        jumlah: pemasukan,
                        warna: Colors.green,
                      ),
                      bangunInfoRingkasan(
                        context: context,
                        label: 'Pengeluaran',
                        jumlah: pengeluaran,
                        warna: Colors.red,
                      ),
                      bangunInfoRingkasan(
                        context: context,
                        label: 'Total',
                        jumlah: total,
                        warna: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Widget kartu untuk menampilkan informasi dompet.
///
/// Menampilkan nama dompet dan saldo dalam bentuk kartu.
class DompetCard extends StatelessWidget {
  /// Model dompet yang akan ditampilkan.
  final DompetModel dompet;

  /// Callback saat kartu di-tap.
  final VoidCallback onTap;

  /// Callback saat kartu di-long press.
  final VoidCallback onLongPress;

  /// Membuat instance dari [DompetCard].
  const DompetCard({
    super.key,
    required this.dompet,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(final BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(
          Icons.account_balance_wallet,
          size: 40,
          color: Colors.blueAccent,
        ),
        title: Text(
          dompet.namaDompet,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(dompet.saldo)}',
          style: TextStyle(
            fontSize: 16,
            color: dompet.saldo < 0 ? Colors.red : Colors.black54,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
