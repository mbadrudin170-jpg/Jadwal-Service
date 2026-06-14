// path: lib/user/page/user_customer_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/poin/page/points_page.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';
import 'package:wifi/user/page/edit_profile_page.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';

/// Kelas untuk menggabungkan data yang dibutuhkan oleh UI.
class _ProfileData {
  final PelangganModel pelanggan;
  final int totalPoin;

  _ProfileData({required this.pelanggan, required this.totalPoin});
}

/// Halaman untuk menampilkan detail profil pengguna.
class UserCustomerDetailPage extends ConsumerStatefulWidget {
  final String userId;
  const UserCustomerDetailPage({super.key, required this.userId});

  @override
  ConsumerState<UserCustomerDetailPage> createState() =>
      _UserCustomerDetailPageState();
}

class _UserCustomerDetailPageState
    extends ConsumerState<UserCustomerDetailPage> {
  Future<_ProfileData>? _dataFuture;
  bool _hasMadeChanges = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai initState pada UserCustomerDetailPage untuk userId: ${widget.userId}',
    );
    _dataFuture = _loadData();
  }

  Future<_ProfileData> _loadData() async {
    try {
      Log.info('Mengambil data pelanggan dari Firestore...');
      final pelangganOpFirebase = ref.read(customerOpFirebaseProvider);
      final transaksiOpFirebase = ref.read(transactionOpFirebaseProvider);
      final pelanggan = await pelangganOpFirebase.getById(widget.userId);
      if (pelanggan == null) {
        throw Exception(
          'Pelanggan dengan ID ${widget.userId} tidak ditemukan.',
        );
      }
      Log.info(
        'Pelanggan ditemukan: ${pelanggan.name}. Mengambil riwayat transaksi...',
      );
      final totalPoin = await transaksiOpFirebase.ambilTotalPoin(pelanggan.id);
      Log.info('Perhitungan poin selesai. Total Poin: $totalPoin');
      return _ProfileData(pelanggan: pelanggan, totalPoin: totalPoin);
    } catch (e, s) {
      Log.error(
        'Gagal memuat data profil lengkap dari Firestore.',
        e: e,
        s: s,
      );
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
  Future<void> _navigateToEdit(PelangganModel customer) async {
    await ref.read(interstitialAdServiceProvider).show();
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => EditProfilePage(customer: customer),
      ),
    );
    await ref.read(interstitialAdServiceProvider).show();
    if (result ?? false) {
      Log.info('Kembali dari edit, memuat ulang data.');
      setState(() {
        _hasMadeChanges = true;
      });
      _reloadData();
    }
  }

  Future<void> _navigateToPoints(final String customerId) async {
    await ref.read(interstitialAdServiceProvider).show();
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => PoinPage(
          customerId: customerId,
          showAd: true, // Tampilkan iklan di halaman poin untuk pengguna
        ),
      ),
    );
    await ref.read(interstitialAdServiceProvider).show();
    if (result ?? false) {
      Log.info(
          'Kembali dari halaman poin dengan perubahan, memuat ulang data.');
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
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) {
          return;
        }
        Navigator.pop(context, _hasMadeChanges);
      },
      child: FutureBuilder<_ProfileData>(
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
            body: CustomerDetailUI(
              pelanggan: data.pelanggan,
              totalPoin: data.totalPoin,
              navigasiKeEdit: () => _navigateToEdit(data.pelanggan),
              navigasiKePoin: () => _navigateToPoints(data.pelanggan.id),
            ),
            bottomNavigationBar: const BannerAdsWidget(),
          );
        },
      ),
    );
  }
}
