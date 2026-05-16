// path: lib/admin/halaman/pembantu/halaman_poin_admin.dart
// diubah: Direfaktor untuk menggunakan PoinPageUi dan menambahkan dokumentasi.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan.dart';
import 'package:wifi/shared/widget/poin_page_ui.dart';

/// Halaman untuk menampilkan dan mengelola poin pelanggan dari sisi admin.
///
/// Halaman ini memungkinkan admin untuk melihat total poin, daftar hadiah
/// yang dapat ditukar, dan riwayat perolehan/penggunaan poin pelanggan.
class PoinPageAdmin extends StatefulWidget {
  /// ID unik dari pelanggan yang poinnya ingin ditampilkan.
  final String idPelanggan;

  /// Membuat instance dari [PoinPageAdmin].
  ///
  /// Membutuhkan [idPelanggan] untuk mengidentifikasi pelanggan.
  const PoinPageAdmin({super.key, required this.idPelanggan});

  @override
  State<PoinPageAdmin> createState() => _PoinPageAdminState();
}

class _PoinPageAdminState extends State<PoinPageAdmin> {
  MenuPoin _menuPilihan = MenuPoin.penukaran;
  final PaketOperasi _paketOperasi = PaketOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();

  int _totalPoin = 0;
  List<PaketModel> _daftarHadiah = [];
  List<TransactionModel> _riwayatTransaksi = [];
  bool _isLoading = false;
  bool _isLoadingRiwayat = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDataPoin());
  }

  Future<void> _loadDataPoin() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final totalPoin = await _transaksiOperasi.getTotalPoin(
        widget.idPelanggan,
      );
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
    } on Exception catch (e, st) {
      Log.error('Gagal memuat data poin: $e', e: e, st: st);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  Future<void> _loadRiwayatTransaksi() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRiwayat = true;
    });

    try {
      final riwayatTransaksi = await _transaksiOperasi
          .ambilTransaksiByPelangganId(widget.idPelanggan);
      final transaksiPoin = riwayatTransaksi
          .where(
              (final t) => t.poinYangDihasilkan > 0 || t.poinYangDigunakan > 0)
          .toList();

      if (!mounted) return;

      setState(() {
        _riwayatTransaksi = transaksiPoin;
        _isLoadingRiwayat = false;
      });
    } on Exception catch (e, st) {
      Log.error('Gagal memuat riwayat transaksi: $e', e: e, st: st);
      if (!mounted) return;
      setState(() {
        _isLoadingRiwayat = false;
        _riwayatTransaksi = [];
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return PoinPageUi(
      appBarTitle: Row(
        children: [
          const Text('Poin: '),
          NamaPelangganWidget(idPelanggan: widget.idPelanggan),
        ],
      ),
      totalPoin: _totalPoin,
      menuPilihan: _menuPilihan,
      onSelectionChanged: (final Set<MenuPoin> newSelection) async {
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
      itemBuilder: (final context, final index) {
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

  Widget _buildRiwayatPoin() {
    if (_isLoadingRiwayat) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_riwayatTransaksi.isEmpty) {
      return const Center(child: Text('Belum ada riwayat poin'));
    }

    return ListView.builder(
      itemCount: _riwayatTransaksi.length,
      itemBuilder: (final context, final index) {
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
