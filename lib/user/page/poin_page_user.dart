// path: lib/user/page/poin_page_user.dart
// diubah: Mengimplementasikan logika pengambilan data dari Firestore.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/poin_page_ui.dart';

class PoinPageUser extends StatefulWidget {
  // ditambah: Menerima idPelanggan.
  final String idPelanggan;
  const PoinPageUser({super.key, required this.idPelanggan});

  @override
  State<PoinPageUser> createState() => _PoinPageUserState();
}

class _PoinPageUserState extends State<PoinPageUser> {
  MenuPoin _menuPilihan = MenuPoin.penukaran;
  // ditambah: Operasi untuk Firestore.
  final PaketOperasi _paketOperasi = PaketOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();

  // diubah: State untuk data dari Firestore.
  int _totalPoin = 0;
  List<PaketModel> _daftarHadiah = [];
  List<TransaksiModel> _riwayatTransaksi = [];
  bool _isLoading = false;
  bool _isLoadingRiwayat = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // ditambah: Memuat data dari Firestore saat inisialisasi.
    _loadDataPoin();
  }

  // ditambah: Logika untuk memuat data poin dan hadiah dari Firestore.
  Future<void> _loadDataPoin() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final totalPoin =
          await _transaksiOperasi.getTotalPoin(widget.idPelanggan);
      final daftarHadiah = await _paketOperasi.getPaketByIsPublic();

      if (!mounted) return;

      setState(() {
        _totalPoin = totalPoin;
        _daftarHadiah = daftarHadiah;
        _isLoading = false;
      });

      if (_menuPilihan == MenuPoin.riwayat) {
        await _loadRiwayatTransaksi();
      }
    } catch (e, st) {
      Log.error('Gagal memuat data poin: $e', e: e, st: st);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  // ditambah: Logika untuk memuat riwayat transaksi dari Firestore.
  Future<void> _loadRiwayatTransaksi() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRiwayat = true;
    });

    try {
      final riwayatTransaksi = await _transaksiOperasi
          .ambilTransaksiByPelangganId(widget.idPelanggan);
      final transaksiPoin = riwayatTransaksi
          .where((t) => t.poinYangDihasilkan > 0 || t.poinYangDigunakan > 0)
          .toList();

      if (!mounted) return;

      setState(() {
        _riwayatTransaksi = transaksiPoin;
        _isLoadingRiwayat = false;
      });
    } catch (e, st) {
      Log.error('Gagal memuat riwayat transaksi: $e', e: e, st: st);
      if (!mounted) return;
      setState(() {
        _isLoadingRiwayat = false;
        _riwayatTransaksi = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PoinPageUi(
      appBarTitle: const Text('Poin & Hadiah'),
      totalPoin: _totalPoin,
      menuPilihan: _menuPilihan,
      onSelectionChanged: (Set<MenuPoin> newSelection) async {
        final selection = newSelection.first;
        setState(() {
          _menuPilihan = selection;
        });

        if (selection == MenuPoin.riwayat && _riwayatTransaksi.isEmpty) {
          await _loadRiwayatTransaksi();
        }
      },
      contentView: _buildContentView(),
    );
  }

  Widget _buildContentView() {
    switch (_menuPilihan) {
      case MenuPoin.penukaran:
        return _buildDaftarHadiah();
      case MenuPoin.riwayat:
        return _buildRiwayatPoin();
    }
  }

  // diubah: Menampilkan daftar hadiah dari Firestore.
  Widget _buildDaftarHadiah() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_daftarHadiah.isEmpty) {
      return const Center(child: Text('Belum ada hadiah tersedia'));
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
            leading: const Icon(Icons.card_giftcard, size: 40),
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
            trailing: ElevatedButton(
              onPressed: cukupPoin
                  ? () {
                      // TODO: Implementasi logika penukaran poin
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Fitur penukaran untuk ${hadiah.nama} belum tersedia.')),
                      );
                    }
                  : null,
              child: const Text('Tukar'),
            ),
          ),
        );
      },
    );
  }

  // diubah: Menampilkan riwayat poin dari Firestore.
  Widget _buildRiwayatPoin() {
    if (_isLoadingRiwayat) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_riwayatTransaksi.isEmpty) {
      return const Center(child: Text('Belum ada riwayat poin'));
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
