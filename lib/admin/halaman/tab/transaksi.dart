// path: lib/admin/halaman/tab/transaksi.dart
// revisi: Menerapkan caching state & memperbaiki peringatan linter.

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/form_transaksi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/info_ringkasan_widget.dart';
import 'package:wifi/shared/widget/transaksi_list_widgets.dart';

/// Widget untuk menampilkan ringkasan transaksi (pemasukan, pengeluaran, total).
class RingkasanTransaksi extends StatelessWidget {
  /// Jumlah total pemasukan.
  final double pemasukan;

  /// Jumlah total pengeluaran.
  final double pengeluaran;

  /// Total selisih antara pemasukan dan pengeluaran.
  final double total;

  /// Konstruktor untuk RingkasanTransaksi.
  const RingkasanTransaksi({
    super.key,
    required this.pemasukan,
    required this.pengeluaran,
    required this.total,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI RingkasanTransaksi dengan data: Pemasukan=${pemasukan.toStringAsFixed(2)}, Pengeluaran=${pengeluaran.toStringAsFixed(2)}, Total=${total.toStringAsFixed(2)}',
    );
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
              warna: total >= 0 ? Colors.blue : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

/// Halaman untuk menampilkan dan mengelola daftar transaksi.
class TransaksiPage extends StatefulWidget {
  /// Operasi transaksi untuk injeksi dependensi saat testing.
  final TransaksiOperasi? transaksiOperasi;

  /// Konstruktor untuk TransaksiPage.
  const TransaksiPage({super.key, this.transaksiOperasi});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  late TransaksiOperasi _transaksiOperasi;
  
  // Variabel state untuk caching
  Map<String, dynamic>? _cachedData;
  Object? _error;
  late Future<void> _initialLoadFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Halaman Transaksi sedang diinisialisasi (initState).');
    _transaksiOperasi = widget.transaksiOperasi ?? TransaksiOperasi();
    Log.info(
      'TransaksiOperasi telah disiapkan. Memulai pengambilan data awal.',
    );
    _initialLoadFuture = _muatData();
  }

  /// Mengambil semua data yang diperlukan dari operasi transaksi.
  Future<Map<String, dynamic>> _ambilData() async {
    Log.info(
      'Memulai proses _ambilData untuk mengambil semua data transaksi dan ringkasan.',
    );
    try {
      final results = await Future.wait([
        _transaksiOperasi.ambilSemuaTransaksi(),
        _transaksiOperasi.getTotalPemasukan(),
        _transaksiOperasi.getTotalPengeluaran(),
        _transaksiOperasi.getNetTotal(),
      ]);
      final transaksi = results[0] as List<TransaksiModel>;
      Log.info(
        'Berhasil mengambil ${transaksi.length} item transaksi dari database.',
      );
      return {
        'transaksi': transaksi,
        'pemasukan': (results[1] as num).toDouble(),
        'pengeluaran': (results[2] as num).toDouble(),
        'total': (results[3] as num).toDouble(),
      };
    } on Exception catch (e, s) {
      Log.error(
        'Gagal total saat menjalankan _ambilData. Kesalahan terjadi di level Future.wait.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  /// Memuat atau memuat ulang data dan memperbarui state.
  Future<void> _muatData({final bool muatUlang = false}) async {
    Log.info(muatUlang ? 'Memicu pemuatan ulang data...' : 'Memuat data awal...');

    if (muatUlang && mounted) {
      setState(() {
        // Hapus cache untuk menampilkan indikator loading
        _cachedData = null;
        _error = null;
      });
    }

    try {
      final data = await _ambilData();
      if (mounted) {
        setState(() {
          _cachedData = data;
        });
      }
    } on Exception catch (e, st) {
      Log.error('Gagal memuat data.', e: e, st: st);
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  /// Membuka halaman form untuk menambah transaksi baru.
  Future<void> _tambahTransaksi() async {
    Log.info('Membuka FormTransaksiPage untuk menambah entri baru.');
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
          builder: (final context) => const FormTransaksiPage()),
    );
    if (result ?? false) {
      Log.info(
        'Form ditutup dengan hasil sukses (true). Memuat ulang data transaksi.',
      );
      // Panggil metode untuk memuat ulang data dengan loading
      await _muatData(muatUlang: true);
    } else {
      Log.info(
        'Form ditutup tanpa hasil (false/null). Tidak ada data yang dimuat ulang.',
      );
    }
  }

  /// Menampilkan dialog konfirmasi dan menghapus semua transaksi jika disetujui.
  Future<void> _hapusSemuaTransaksi() async {
    try {
      final bool? konfirmasi = await showDialog<bool>(
        context: context,
        builder: (final context) {
          return AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text(
                'Apakah Anda yakin ingin menghapus semua transaksi? Tindakan ini tidak dapat diurungkan.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          );
        },
      );

      if (konfirmasi ?? false) {
        Log.warning('Pengguna mengkonfirmasi penghapusan semua transaksi.');
        await _transaksiOperasi.hapusSemuaTransaksi();
        if (!mounted) return;
        SnackBarUtil.success(context, 'Semua transaksi berhasil dihapus.');
        // Panggil metode untuk memuat ulang data dengan loading
        await _muatData(muatUlang: true);
      }
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus semua transaksi.', e: e, st: s);
      if (!mounted) return;
      SnackBarUtil.error(context, 'Gagal menghapus transaksi: $e');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI utama Halaman Transaksi (build method).');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            onPressed: _hapusSemuaTransaksi,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Hapus Semua Transaksi',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahTransaksi,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Membangun body utama berdasarkan state data (cached, error, atau loading awal).
  Widget _buildBody() {
    // Jika data ada di cache, langsung tampilkan
    if (_cachedData != null) {
      final data = _cachedData!;
      final pemasukan = (data['pemasukan'] as num?)?.toDouble() ?? 0.0;
      final pengeluaran = (data['pengeluaran'] as num?)?.toDouble() ?? 0.0;
      final total = (data['total'] as num?)?.toDouble() ?? 0.0;
      final transaksiData = data['transaksi'] as List<TransaksiModel>;
      Log.info(
        'Membangun UI dari cache. Memiliki ${transaksiData.length} transaksi.',
      );

      return Column(
        children: [
          RingkasanTransaksi(
            key: const Key(
              'ringkasan_transaksi',
            ),
            pemasukan: pemasukan,
            pengeluaran: pengeluaran,
            total: total,
          ),
          Expanded(
            child: transaksiData.isEmpty
                ? const Center(
                    child: Text('Tidak ada transaksi ditemukan.'),
                  )
                : _bangunDaftarTransaksi(transaksiData),
          ),
        ],
      );
    }

    // Jika ada error, tampilkan pesan error
    if (_error != null) {
      Log.error('Membangun UI Error: $_error');
      return Center(child: Text('Terjadi Kesalahan: $_error'));
    }

    // Jika tidak, tampilkan FutureBuilder untuk loading awal
    return FutureBuilder<void>(
      future: _initialLoadFuture,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info(
            'FutureBuilder: Menunggu hasil dari _muatData (awal). Menampilkan CircularProgressIndicator.',
          );
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          Log.error(
            'FutureBuilder: Menangkap error saat loading awal.',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return Center(child: Text('Terjadi Kesalahan: ${snapshot.error}'));
        }
        // State ini seharusnya tidak tercapai jika logika benar, tapi sebagai fallback
        Log.warning('FutureBuilder selesai tapi _cachedData masih null.');
        return const Center(child: Text('Tidak ada data ditemukan.'));
      },
    );
  }

  /// Membangun daftar transaksi yang dikelompokkan berdasarkan tanggal.
  Widget _bangunDaftarTransaksi(final List<TransaksiModel> transaksiData) {
    Log.info(
      'Membangun daftar transaksi (_bangunDaftarTransaksi) dengan ${transaksiData.length} item.',
    );
    final groupedTransaksi = groupTransaksiByDate(transaksiData);

    return ListView.builder(
      itemCount: groupedTransaksi.length,
      itemBuilder: (final context, final index) {
        final tanggal = groupedTransaksi.keys.elementAt(index);
        final transaksiPadaTanggal = groupedTransaksi[tanggal]!;
        final totalPadaTanggal = transaksiPadaTanggal.fold(
          0.0,
          (final sum, final item) =>
              sum +
              (item.tipe == TipeTransaksiEnum.pemasukan
                  ? item.jumlah
                  : -item.jumlah),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bangunHeaderSeksi(tanggal, totalPadaTanggal),
            ...transaksiPadaTanggal.map(
              (final transaksi) => bangunItemTransaksi(
                context,
                transaksi,
                () => _muatData(muatUlang: true), // Kirim fungsi untuk muat ulang
                _transaksiOperasi,
              ),
            ),
          ],
        );
      },
    );
  }
}
