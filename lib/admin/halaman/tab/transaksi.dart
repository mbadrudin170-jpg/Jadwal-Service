// path: lib/halaman/tab/transaksi.dart
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/form/form_transaksi.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/widget/transaksi_list_widgets.dart';

// diubah: RingkasanTransaksi sekarang menjadi StatelessWidget yang hanya menerima data.
class RingkasanTransaksi extends StatelessWidget {
  final double pemasukan;
  final double pengeluaran;
  final double total;

  const RingkasanTransaksi({
    super.key,
    required this.pemasukan,
    required this.pengeluaran,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI RingkasanTransaksi dengan data: Pemasukan=${pemasukan.toStringAsFixed(2)}, Pengeluaran=${pengeluaran.toStringAsFixed(2)}, Total=${total.toStringAsFixed(2)}');
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // diubah: Menggunakan named arguments sesuai definisi fungsi yang baru.
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

class TransaksiPage extends StatefulWidget {
  // ditambahkan: Parameter opsional untuk injeksi dependensi saat testing.
  final TransaksiOperasi? transaksiOperasi;

  const TransaksiPage({super.key, this.transaksiOperasi});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  // diubah: Dibuat non-final dan diinisialisasi di initState.
  late TransaksiOperasi _transaksiOperasi;
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Halaman Transaksi sedang diinisialisasi (initState).');
    // diubah: Menggunakan dependensi yang diinjeksikan (jika ada) atau membuat instance baru.
    _transaksiOperasi = widget.transaksiOperasi ?? TransaksiOperasi();
    Log.info('TransaksiOperasi telah disiapkan. Memulai pengambilan data awal.');
    _dataFuture = _getData();
  }

  // diubah: Menggabungkan semua pengambilan data ke dalam satu fungsi.
  Future<Map<String, dynamic>> _getData() async {
    Log.info('Memulai proses _getData untuk mengambil semua data transaksi dan ringkasan.');
    try {
      final results = await Future.wait([
        _transaksiOperasi.ambilSemuaTransaksi(),
        _transaksiOperasi.getTotalPemasukan(),
        _transaksiOperasi.getTotalPengeluaran(),
        _transaksiOperasi.getNetTotal(),
      ]);
      final transaksi = results[0] as List<TransaksiModel>;
      Log.info('Berhasil mengambil ${transaksi.length} item transaksi dari database.');
      return {
        'transaksi': transaksi,
        'pemasukan': results[1] as double,
        'pengeluaran': results[2] as double,
        'total': results[3] as double,
      };
    } catch (e, s) {
      Log.error('Gagal total saat menjalankan _getData. Kesalahan terjadi di level Future.wait.', error: e, stackTrace: s);
      // Re-throw the error to be caught by the FutureBuilder
      rethrow;
    }
  }

  // untuk memuat atau memuat ulang semua data dengan setState untuk memicu rebuild.
  void _loadData() {
    Log.info('Memicu pemuatan ulang data transaksi secara manual melalui _loadData.');
    setState(() {
      _dataFuture = _getData();
    });
  }

  // untuk menavigasi ke halaman tambah transaksi dan memuat ulang data jika berhasil.
  void _tambahTransaksi() async {
    Log.info('Membuka FormTransaksiPage untuk menambah entri baru.');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormTransaksiPage()),
    );
    if (result == true) {
      Log.info('Form ditutup dengan hasil sukses (true). Memuat ulang data transaksi.');
      _loadData();
    } else {
      Log.info('Form ditutup tanpa hasil (false/null). Tidak ada data yang dimuat ulang.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI utama Halaman Transaksi (build method).');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
              onPressed: () {
                Log.warning(
                    'Tombol hapus semua transaksi ditekan, tetapi fungsi belum diimplementasikan.');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fitur hapus semua belum tersedia.')),
                );
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info('FutureBuilder: Menunggu hasil dari _getData. Menampilkan CircularProgressIndicator.');
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            Log.error('FutureBuilder: Menangkap error saat membangun UI.', error: snapshot.error, stackTrace: snapshot.stackTrace);
            return Center(child: Text('Terjadi Kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            Log.warning('FutureBuilder: Tidak menerima data (null). Menampilkan pesan "Tidak ada data ditemukan."');
            return const Center(child: Text('Tidak ada data ditemukan.'));
          }

          final data = snapshot.data!;
          final pemasukan = data['pemasukan'] ?? 0.0;
          final pengeluaran = data['pengeluaran'] ?? 0.0;
          final total = data['total'] ?? 0.0;
          final transaksiData = data['transaksi'] as List<TransaksiModel>;
          Log.info(
              'FutureBuilder: Data berhasil diterima. Membangun UI dengan ${transaksiData.length} transaksi.');

          return Column(
            children: [
              RingkasanTransaksi(
                key: const Key(
                  'ringkasan_transaksi',
                ), // ditambahkan: Key untuk ringkasan
                pemasukan: pemasukan,
                pengeluaran: pengeluaran,
                total: total,
              ),
              Expanded(
                child: transaksiData.isEmpty
                    ? const Center(
                        child: Text('Tidak ada transaksi ditemukan.'),
                      )
                    : _buildTransaksiList(transaksiData),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahTransaksi,
        child: const Icon(Icons.add),
      ),
    );
  }

  // diubah: Menggunakan fungsi dari widget/transaksi_list_widgets.dart
  Widget _buildTransaksiList(List<TransaksiModel> transaksiData) {
    Log.info('Membangun daftar transaksi (_buildTransaksiList) dengan ${transaksiData.length} item.');
    // diubah: Menggunakan fungsi publik dari file widget.
    final groupedTransaksi = groupTransaksiByDate(transaksiData);

    return ListView.builder(
      itemCount: groupedTransaksi.length,
      itemBuilder: (context, index) {
        final tanggal = groupedTransaksi.keys.elementAt(index);
        final transaksiPadaTanggal = groupedTransaksi[tanggal]!;
        final totalPadaTanggal = transaksiPadaTanggal.fold(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.pemasukan
                  ? item.jumlah
                  : -item.jumlah),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // diubah: Menggunakan widget publik dari file widget.
            bangunHeaderSeksi(tanggal, totalPadaTanggal),
            ...transaksiPadaTanggal.map(
              // diubah: Menggunakan widget publik dari file widget dan memberikan callback _loadData.
              (transaksi) => bangunItemTransaksi(
                context,
                transaksi,
                _loadData,
                _transaksiOperasi,
              ),
            ),
          ],
        );
      },
    );
  }
}
