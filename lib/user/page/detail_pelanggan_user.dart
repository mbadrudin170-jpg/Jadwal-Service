// path: lib/user/page/detail_pelanggan_user.dart
// diubah: Mengirim idPelanggan saat navigasi ke PoinPageUser.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/user/page/edit_profil_page.dart';
import 'package:wifi/user/page/poin_page_user.dart';
import 'package:wifi/user/services/firestore_service.dart';
import 'package:wifi/shared/widget/detail_pelanggan_ui.dart';

// Kelas untuk menggabungkan data yang dibutuhkan oleh UI
class _ProfilData {
  final PelangganModel pelanggan;
  final int totalPoin;

  _ProfilData({required this.pelanggan, required this.totalPoin});
}

class DetailPelangganUserPage extends StatefulWidget {
  final String userId;

  const DetailPelangganUserPage({super.key, required this.userId});

  @override
  State<DetailPelangganUserPage> createState() =>
      _DetailPelangganUserPageState();
}

class _DetailPelangganUserPageState extends State<DetailPelangganUserPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Future<_ProfilData>? _dataFuture;

  @override
  void initState() {
    super.initState();
    Log.info(
        'Memulai initState pada DetailPelangganUserPage untuk userId: ${widget.userId}');
    _dataFuture = _loadData();
  }

  // Fungsi terpusat untuk mengambil semua data yang diperlukan dari Firestore
  Future<_ProfilData> _loadData() async {
    try {
      Log.info('Mengambil data pelanggan dari Firestore...');
      final pelanggan =
          await _firestoreService.ambilPelangganSekali(widget.userId);
      if (pelanggan == null) {
        throw Exception(
            'Pelanggan dengan ID ${widget.userId} tidak ditemukan.');
      }
      Log.info(
          'Pelanggan ditemukan: ${pelanggan.nama}. Mengambil riwayat transaksi...');

      final riwayat =
          await _firestoreService.ambilRiwayatLangganan(pelanggan.id);
      Log.info('Ditemukan ${riwayat.length} transaksi. Menghitung poin...');

      int poinDihasilkan =
          riwayat.fold(0, (sum, item) => sum + item.poinYangDihasilkan);
      int poinDigunakan =
          riwayat.fold(0, (sum, item) => sum + item.poinYangDigunakan);
      final int totalPoin = poinDihasilkan - poinDigunakan;

      Log.info('Perhitungan poin selesai. Total Poin: $totalPoin');
      return _ProfilData(pelanggan: pelanggan, totalPoin: totalPoin);
    } catch (e, s) {
      Log.error('Gagal memuat data profil lengkap dari Firestore.',
          e: e, st: s);
      rethrow; // Lempar ulang error untuk ditangani oleh FutureBuilder
    }
  }

  void _muatUlangData() {
    Log.info('Memuat ulang data dari Firestore...');
    setState(() {
      _dataFuture = _loadData();
    });
  }

  void _navigasiKeEdit(PelangganModel pelanggan) async {
    final bool? hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfilPage(pelanggan: pelanggan, userId: widget.userId),
      ),
    );
    if (hasil == true) {
      Log.info('Kembali dari edit, memuat ulang data.');
      _muatUlangData();
    }
  }

  // diubah: Menambahkan parameter idPelanggan.
  void _navigateToPoin(String idPelanggan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // diubah: Mengirim idPelanggan ke PoinPageUser.
        builder: (context) => PoinPageUser(idPelanggan: idPelanggan),
      ),
    ).then((_) => _muatUlangData());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfilData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Memuat Profil...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat data: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return DetailPelangganUI(
          pelanggan: data.pelanggan,
          totalPoin: data.totalPoin,
          onEdit: () => _navigasiKeEdit(data.pelanggan),
          // diubah: Memanggil _navigateToPoin dengan id pelanggan.
          onNavigateToPoin: () => _navigateToPoin(data.pelanggan.id),
          // onCopyAll sengaja dibuat null karena user tidak memiliki fungsi ini
        );
      },
    );
  }
}
