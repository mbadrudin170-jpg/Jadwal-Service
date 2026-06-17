// path: lib/fitur/pelanggan/page/user/detail_pelanggan_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/poin/page/halaman_poin.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/fitur/pelanggan/widget/detail_pelanggan_ui.dart';
import 'package:wifi/fitur/pelanggan/page/user/edit_profile_page.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';

/// Kelas untuk menggabungkan data yang dibutuhkan oleh UI.
class _DataDetailPelanggan {
  final PelangganModel pelanggan;
  final int totalPoin;

  _DataDetailPelanggan({required this.pelanggan, required this.totalPoin});
}

/// Halaman untuk menampilkan detail profil pengguna.
class DetailPelangganU extends ConsumerStatefulWidget {
  final String userId;
  const DetailPelangganU({super.key, required this.userId});

  @override
  ConsumerState<DetailPelangganU> createState() => _DetailPelangganUState();
}

class _DetailPelangganUState extends ConsumerState<DetailPelangganU> {
  Future<_DataDetailPelanggan>? _dataFuture;
  bool _hasMadeChanges = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai initState pada UserCustomerDetailPage untuk userId: ${widget.userId}',
    );
    _dataFuture = _loadData();
  }

  Future<_DataDetailPelanggan> _loadData() async {
    try {
      Log.info('Mengambil data pelanggan dari Firestore...');
      final pelangganOpFirebase = ref.read(pelangganOpFirebaseProvider);
      final transaksiOpFirebase = ref.read(transaksiOpFirebaseProvider);
      final pelanggan = await pelangganOpFirebase.ambilBerdasarkanId(
        widget.userId,
      );
      if (pelanggan == null) {
        throw Exception(
          'Pelanggan dengan ID ${widget.userId} tidak ditemukan.',
        );
      }
      Log.info(
        'Pelanggan ditemukan: ${pelanggan.nama}. Mengambil riwayat transaksi...',
      );
      final totalPoin = await transaksiOpFirebase.ambilTotalPoin(pelanggan.id);
      Log.info('Perhitungan poin selesai. Total Poin: $totalPoin');
      return _DataDetailPelanggan(pelanggan: pelanggan, totalPoin: totalPoin);
    } catch (e, s) {
      Log.error('Gagal memuat data profil lengkap dari Firestore.', e: e, s: s);
      rethrow;
    }
  }

  void _reloadData() {
    Log.info('Memuat ulang data dari Firestore...');
    setState(() {
      _dataFuture = _loadData();
    });
  }

  /// Navigasi ke halaman edit profil, lalu menampilkan iklan saat kembali.
  Future<void> _navigasiKeEdit(PelangganModel pelanggan) async {
    await ref.read(interstitialAdServiceProvider).show();
    final bool? hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => EditProfilePage(pelanggan: pelanggan),
      ),
    );
    await ref.read(interstitialAdServiceProvider).show();
    if (hasil ?? false) {
      Log.info('Kembali dari edit, memuat ulang data.');
      setState(() {
        _hasMadeChanges = true;
      });
      _reloadData();
    }
  }

  Future<void> _navigasiKePoin(String idPelanggan) async {
    await ref.read(interstitialAdServiceProvider).show();
    final bool? hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => HalamanPoin(
          idPelanggan: idPelanggan,
          tampilkanIklan:
              true, // Tampilkan iklan di halaman poin untuk pengguna
        ),
      ),
    );
    await ref.read(interstitialAdServiceProvider).show();
    if (hasil ?? false) {
      Log.info(
        'Kembali dari halaman poin dengan perubahan, memuat ulang data.',
      );
      setState(() {
        _hasMadeChanges = true;
      });
      _reloadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, bool? hasil) {
        if (didPop) {
          return;
        }
        Navigator.pop(context, _hasMadeChanges);
      },
      child: FutureBuilder<_DataDetailPelanggan>(
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

          return Scaffold(
            body: DetailPelangganUI(
              pelanggan: data.pelanggan,
              totalPoin: data.totalPoin,
              navigasiKeEdit: () => _navigasiKeEdit(data.pelanggan),
              navigasiKePoin: () => _navigasiKePoin(data.pelanggan.id),
            ),
            bottomNavigationBar: const BannerAdsWidget(),
          );
        },
      ),
    );
  }
}
