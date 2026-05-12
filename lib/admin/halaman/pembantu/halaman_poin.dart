// path: lib/halaman/pembantu/halaman_poin.dart
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';

// Enum untuk mengontrol tab yang aktif
enum MenuPoin { penukaran, riwayat }

class HalamanPoin extends StatefulWidget {
  final String idPelanggan;

  const HalamanPoin({super.key, required this.idPelanggan});

  @override
  State<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends State<HalamanPoin> {
  MenuPoin _menuPilihan = MenuPoin.penukaran;
  final PaketOperasi _paketOperasi = PaketOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();

  int _totalPoin = 0;
  List<PaketModel> _daftarHadiah = [];
  List<TransaksiModel> _riwayatTransaksi = [];
  bool _isLoading = false;
  bool _isLoadingRiwayat = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman HalamanPoin');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info('Menu default: Penukaran');
    Log.info('========================================');
    Log.info('Memanggil _loadDataPoin() untuk memuat data poin pelanggan.');
    _loadDataPoin();
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman HalamanPoin');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info('Membersihkan resource halaman poin.');
    Log.info('========================================');
    super.dispose();
  }

  Future<void> _loadDataPoin() async {
    Log.info('========================================');
    Log.info('MEMUAT DATA POIN PELANGGAN');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info('========================================');

    if (!mounted) {
      Log.warning(
        'Widget sudah tidak mounted saat _loadDataPoin() dipanggil. Membatalkan proses.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load total poin dari database
      Log.info('Menghitung total poin pelanggan dari transaksi...');
      final totalPoin = await _transaksiOperasi.getTotalPoin(
        widget.idPelanggan,
      );

      // Load daftar hadiah (paket aktif)
      Log.info('Memuat daftar hadiah (paket aktif) dari database...');
      final daftarHadiah = await _paketOperasi.getPaketByIsPublic();

      if (!mounted) return;

      setState(() {
        _totalPoin = totalPoin;
        _daftarHadiah = daftarHadiah;
        _isLoading = false;
        Log.info(
          'Berhasil memuat data. Total poin: $totalPoin, Hadiah: ${daftarHadiah.length}',
        );
      });

      // Load riwayat transaksi jika tab riwayat yang aktif
      if (_menuPilihan == MenuPoin.riwayat) {
        await _loadRiwayatTransaksi();
      }
    } catch (e, stackTrace) {
      Log.error('Gagal memuat data poin: $e', error: e, stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
        Log.warning('Gagal memuat data poin.');
      });
    }
  }

  // Method untuk memuat riwayat transaksi
  Future<void> _loadRiwayatTransaksi() async {
    Log.info('========================================');
    Log.info('MEMUAT RIWAYAT TRANSAKSI PELANGGAN');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info('========================================');

    if (!mounted) return;

    setState(() {
      _isLoadingRiwayat = true;
    });

    try {
      Log.info('Mengambil riwayat transaksi dari database...');
      final riwayatTransaksi = await _transaksiOperasi
          .ambilTransaksiByPelangganId(widget.idPelanggan);

      // Filter transaksi yang berkaitan dengan poin (ada poin yang dihasilkan/digunakan)
      final transaksiPoin = riwayatTransaksi
          .where((t) => t.poinYangDihasilkan > 0 || t.poinYangDigunakan > 0)
          .toList();

      if (!mounted) return;

      setState(() {
        _riwayatTransaksi = transaksiPoin;
        _isLoadingRiwayat = false;
        Log.info(
          'Berhasil memuat ${transaksiPoin.length} riwayat transaksi poin.',
        );
      });
    } catch (e, stackTrace) {
      Log.error(
        'Gagal memuat riwayat transaksi: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        _isLoadingRiwayat = false;
        _riwayatTransaksi = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI HalamanPoin');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info(
      'Menu aktif: ${_menuPilihan == MenuPoin.penukaran ? "Penukaran Hadiah" : "Riwayat Poin"}',
    );
    Log.info('Total poin ditampilkan: $_totalPoin');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Poin: '),
            NamaPelangganWidget(idPelanggan: widget.idPelanggan),
          ],
        ),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'NAVIGASI: Tombol Kembali ditekan. Kembali ke halaman sebelumnya.',
            );
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          _buildInfoPoinHeader(),
          _buildSegmentedControl(),
          Expanded(child: _buildContentView()),
        ],
      ),
    );
  }

  // Widget untuk menampilkan informasi total poin
  Widget _buildInfoPoinHeader() {
    Log.info('Membangun header informasi total poin. Total: $_totalPoin');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).primaryColor.withAlpha(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Total Poin Anda',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            '$_totalPoin',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol segment (Penukaran/Riwayat)
  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<MenuPoin>(
        segments: const [
          ButtonSegment<MenuPoin>(
            value: MenuPoin.penukaran,
            label: Text('Tukar Hadiah'),
            icon: Icon(Icons.card_giftcard),
          ),
          ButtonSegment<MenuPoin>(
            value: MenuPoin.riwayat,
            label: Text('Riwayat Poin'),
            icon: Icon(Icons.history),
          ),
        ],
        selected: {_menuPilihan},
        onSelectionChanged: (Set<MenuPoin> newSelection) async {
          final selection = newSelection.first;
          Log.info('SEGMENTED CONTROL: Tab dipilih berubah.');
          Log.info(
            '  - Tab sebelumnya: ${_menuPilihan == MenuPoin.penukaran ? "Penukaran Hadiah" : "Riwayat Poin"}',
          );
          Log.info(
            '  - Tab baru: ${selection == MenuPoin.penukaran ? "Penukaran Hadiah" : "Riwayat Poin"}',
          );
          setState(() {
            _menuPilihan = selection;
          });

          // Load riwayat transaksi jika pindah ke tab riwayat
          if (selection == MenuPoin.riwayat && _riwayatTransaksi.isEmpty) {
            await _loadRiwayatTransaksi();
          }

          Log.info(
            'State _menuPilihan berhasil diperbarui. UI akan menampilkan konten tab yang dipilih.',
          );
        },
      ),
    );
  }

  // Widget untuk menampilkan konten berdasarkan tab yang dipilih
  Widget _buildContentView() {
    Log.info(
      'Membangun konten untuk tab: ${_menuPilihan == MenuPoin.penukaran ? "Penukaran Hadiah" : "Riwayat Poin"}',
    );

    switch (_menuPilihan) {
      case MenuPoin.penukaran:
        return _buildDaftarHadiah();
      case MenuPoin.riwayat:
        return _buildRiwayatPoin();
    }
  }

  // Widget daftar hadiah yang terhubung dengan database
  Widget _buildDaftarHadiah() {
    Log.info('Membangun daftar hadiah yang tersedia untuk ditukar.');

    // Tampilkan loading indicator saat memuat data
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat daftar hadiah...'),
          ],
        ),
      );
    }

    // Tampilkan pesan error jika ada
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDataPoin,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Tampilkan pesan jika tidak ada hadiah
    if (_daftarHadiah.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada hadiah tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    Log.info('Jumlah hadiah tersedia: ${_daftarHadiah.length}');
    for (var hadiah in _daftarHadiah) {
      final cukupPoin = _totalPoin >= hadiah.poinPenukaran;
      Log.info(
        '  - ${hadiah.nama}: ${hadiah.poinPenukaran} poin (Status: ${cukupPoin ? "DAPAT DITUKAR" : "POIN KURANG (butuh ${hadiah.poinPenukaran - _totalPoin} poin lagi)"})',
      );
    }

    return ListView.builder(
      itemCount: _daftarHadiah.length,
      itemBuilder: (context, index) {
        final hadiah = _daftarHadiah[index];
        final cukupPoin = _totalPoin >= hadiah.poinPenukaran;
        final progresPoin = hadiah.poinPenukaran > 0
            ? (_totalPoin / hadiah.poinPenukaran).clamp(0.0, 1.0)
            : 1.0;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(hadiah.nama),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${hadiah.poinPenukaran} Poin'),
                LinearProgressIndicator(
                  value: progresPoin,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    cukupPoin ? Colors.green : Colors.orange,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Text(
                  'Poin Anda: $_totalPoin / ${hadiah.poinPenukaran}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cukupPoin ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget riwayat poin yang terhubung dengan database
  Widget _buildRiwayatPoin() {
    Log.info('Membangun daftar riwayat poin pelanggan.');

    // Tampilkan loading indicator saat memuat data
    if (_isLoadingRiwayat) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat riwayat poin...'),
          ],
        ),
      );
    }

    // Tampilkan pesan jika tidak ada riwayat
    if (_riwayatTransaksi.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat poin',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    Log.info('Jumlah riwayat transaksi poin: ${_riwayatTransaksi.length}');
    for (var transaksi in _riwayatTransaksi) {
      final isPenambahan = transaksi.poinYangDihasilkan > 0;
      final poinValue = isPenambahan
          ? transaksi.poinYangDihasilkan
          : transaksi.poinYangDigunakan;
      Log.info(
        '  - ${FormatTanggal.formatTanggalBasic(transaksi.tanggal)}: ${transaksi.keterangan} '
        '(${isPenambahan ? "PENAMBAHAN +$poinValue" : "PENGURANGAN -$poinValue"} poin)',
      );
    }

    return ListView.builder(
      itemCount: _riwayatTransaksi.length,
      itemBuilder: (context, index) {
        final transaksi = _riwayatTransaksi[index];
        final isPenambahan = transaksi.poinYangDihasilkan > 0;
        final poinValue = isPenambahan
            ? transaksi.poinYangDihasilkan
            : transaksi.poinYangDigunakan;
        final poinStr = isPenambahan ? '+$poinValue' : '-$poinValue';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: Icon(
              isPenambahan
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: isPenambahan ? Colors.green : Colors.red,
            ),
            title: Text(transaksi.keterangan),
            subtitle: Text(
              FormatTanggal.formatTanggalBasic(transaksi.tanggal),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              poinStr,
              style: TextStyle(
                color: isPenambahan ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
