// path: lib/user/page/user_customer_detail.dart
// diubah: Memperbaiki nama kelas PoinPageUser → PointsPageUser,
//         CustomerDetailUi → CustomerDetailUI, idPelanggan → customerId.
// diubah: Menghapus import yang tidak digunakan.
// DIPERBAIKI: Menghapus pemanggilan _reloadData yang tidak perlu setelah kembali dari halaman poin.
// DIPERBAIKI: Mengganti onPopInvoked yang usang dengan onPopInvokedWithResult.
// diubah: Refaktor untuk menggunakan PointsPage generik.
// DIUBAH: Menambahkan `showAd: true` saat menavigasi ke PointsPage.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/poin/firebase_points_data_source.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';
import 'package:wifi/shared/widget/page/points_page.dart';
import 'package:wifi/user/page/edit_profile_page.dart';

/// Kelas untuk menggabungkan data yang dibutuhkan oleh UI.
class _ProfileData {
  final CustomerModel customer;
  final int totalPoints;

  _ProfileData({required this.customer, required this.totalPoints});
}

/// Halaman untuk menampilkan detail profil pengguna.
///
/// Halaman ini mengambil data pelanggan dan total poin dari Firestore,
/// lalu menampilkannya menggunakan widget [CustomerDetailUI].
class UserCustomerDetailPage extends StatefulWidget {
  /// ID unik pengguna yang detailnya akan ditampilkan.
  final String userId;

  /// Membuat instance dari [UserCustomerDetailPage].
  const UserCustomerDetailPage({super.key, required this.userId});

  @override
  State<UserCustomerDetailPage> createState() => _UserCustomerDetailPageState();
}

class _UserCustomerDetailPageState extends State<UserCustomerDetailPage> {
  final CustomerOpFirebase _customerOp = CustomerOpFirebase();
  final TransactionOpFirebase _transactionOp = TransactionOpFirebase();
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

  /// Mengambil semua data yang diperlukan dari Firestore.
  Future<_ProfileData> _loadData() async {
    try {
      Log.info('Mengambil data pelanggan dari Firestore...');
      final customer = await _customerOp.getCustomerOnce(widget.userId);
      if (customer == null) {
        throw Exception(
          'Pelanggan dengan ID ${widget.userId} tidak ditemukan.',
        );
      }
      Log.info(
        'Pelanggan ditemukan: ${customer.name}. Mengambil riwayat transaksi...',
      );

      final history =
          await _transactionOp.getTransactionsByCustomerId(customer.id);
      Log.info('Ditemukan ${history.length} transaksi. Menghitung poin...');

      final int earnedPoints = history.fold<int>(
        0,
        (final sum, final item) => sum + item.earnedPoints,
      );
      final int usedPoints = history.fold<int>(
        0,
        (final sum, final item) => sum + item.usedPoints,
      );
      final int totalPoints = earnedPoints - usedPoints;

      Log.info('Perhitungan poin selesai. Total Poin: $totalPoints');
      return _ProfileData(customer: customer, totalPoints: totalPoints);
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

  Future<void> _navigateToEdit(final CustomerModel customer) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) =>
            EditProfilePage(customer: customer, userId: widget.userId),
      ),
    );
    if (result ?? false) {
      Log.info('Kembali dari edit, memuat ulang data.');
      setState(() {
        _hasMadeChanges = true;
      });
      _reloadData();
    }
  }

  Future<void> _navigateToPoints(final String customerId) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => PointsPage(
          customerId: customerId,
          dataSource: FirebasePointsDataSource(), // Menggunakan data source Firebase
          showAd: true, // Tampilkan iklan di halaman poin untuk pengguna
        ),
      ),
    );
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
  Widget build(final BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (final bool didPop, final bool? result) {
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

          return CustomerDetailUI(
            customer: data.customer,
            totalPoints: data.totalPoints,
            onEdit: () => _navigateToEdit(data.customer),
            onNavigateToPoints: () => _navigateToPoints(data.customer.id),
          );
        },
      ),
    );
  }
}
