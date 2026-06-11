// path: lib/user/page/user_customer_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';
import 'package:wifi/fitur/poin/page/points_page.dart';
import 'package:wifi/user/page/edit_profile_page.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';

/// Kelas untuk menggabungkan data yang dibutuhkan oleh UI.
class _ProfileData {
  final CustomerModel customer;
  final int totalPoints;

  _ProfileData({required this.customer, required this.totalPoints});
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
      final customerOpFirebase = ref.read(customerOpFirebaseProvider);
      final transactionOp = ref.read(transactionOpFirebaseProvider);
      final customer =
          await customerOpFirebase.ambilBerdasarkanId(widget.userId);
      if (customer == null) {
        throw Exception(
          'Pelanggan dengan ID ${widget.userId} tidak ditemukan.',
        );
      }
      Log.info(
        'Pelanggan ditemukan: ${customer.name}. Mengambil riwayat transaksi...',
      );
      final totalPoin = await transactionOp.getTotalPoints(customer.id);
      Log.info('Perhitungan poin selesai. Total Poin: $totalPoin');
      return _ProfileData(customer: customer, totalPoints: totalPoin);
    } catch (e, s) {
      Log.error(
        'Gagal memuat data profil lengkap dari Firestore.',
        e: e,
        st: s,
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
  Future<void> _navigateToEdit(CustomerModel customer) async {
    await ref.read(interstitialAdServiceProvider).show();
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => EditProfilePage(customer: customer),
      ),
    );
    await ref.read(interstitialAdServiceProvider).show();
    // 2. Setelah kembali, periksa jika ada perubahan dan muat ulang data.
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
        builder: (final context) => PointsPage(
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
        builder: (final context, final snapshot) {
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
              customer: data.customer,
              totalPoints: data.totalPoints,
              onEdit: () => _navigateToEdit(data.customer),
              onNavigateToPoints: () => _navigateToPoints(data.customer.id),
            ),
            bottomNavigationBar: const BannerAdsWidget(),
          );
        },
      ),
    );
  }
}
