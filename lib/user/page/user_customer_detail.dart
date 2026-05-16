// path: lib/user/page/user_customer_detail.dart
// diubah: Mengirim customerId saat navigasi ke PoinPageUser.
// diubah: Mengubah _navigateToPoin menjadi async dan menggunakan await.
// diubah: Menambahkan tipe eksplisit <bool> pada MaterialPageRoute di _navigateToEdit.
// refactor: Menghapus ketergantungan pada FirestoreService dan menggunakan CustomerOpFirebase dan TransactionOpFirebase.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/widget/customer_detail_ui.dart';
import 'package:wifi/user/page/edit_profil_page.dart';
import 'package:wifi/user/page/poin_page_user.dart';

// Kelas untuk menggabungkan data yang dibutuhkan oleh UI
class _ProfileData {
  final CustomerModel customer;
  final int totalPoints;

  _ProfileData({required this.customer, required this.totalPoints});
}

/// Halaman untuk menampilkan detail profil pengguna.
///
/// Halaman ini mengambil data pelanggan dan total poin dari Firestore,
/// lalu menampilkannya menggunakan widget [DetailPelangganUI].
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

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai initState pada UserCustomerDetailPage untuk userId: ${widget.userId}',
    );
    _dataFuture = _loadData();
  }

  // Fungsi terpusat untuk mengambil semua data yang diperlukan dari Firestore
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

      final history = await _transactionOp.getSubscriptionHistory(customer.id);
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
      rethrow; // Lempar ulang error untuk ditangani oleh FutureBuilder
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
            EditProfilPage(pelanggan: customer, userId: widget.userId),
      ),
    );
    if (result ?? false) {
      Log.info('Kembali dari edit, memuat ulang data.');
      _reloadData();
    }
  }

  Future<void> _navigateToPoints(final String customerId) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (final context) => PoinPageUser(idPelanggan: customerId),
      ),
    );
    _reloadData();
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<_ProfileData>(
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

        return DetailPelangganUI(
          pelanggan: data.customer,
          totalPoin: data.totalPoints,
          onEdit: () => _navigateToEdit(data.customer),
          onNavigateToPoin: () => _navigateToPoints(data.customer.id),
          // onCopyAll sengaja dibuat null karena user tidak memiliki fungsi ini
        );
      },
    );
  }
}
