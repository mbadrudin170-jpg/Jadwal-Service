// path lib/user/page/profile_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/page/points_page.dart';
import 'package:wifi/user/page/user_customer_detail.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

// PENJELASAN: Kelas ini dibuat untuk menampung semua data yang dibutuhkan oleh halaman profil.
// Tujuannya adalah memuat semua data ini dalam satu operasi asynchronous,
// lalu membangun UI sekali jalan untuk menghindari render berulang.
class _ProfileData {
  final CustomerModel customer;
  final int totalPoints;
  final TransactionModel? lastActiveSubscription;
  final PackageModel? packageModel;

  _ProfileData({
    required this.customer,
    required this.totalPoints,
    this.lastActiveSubscription,
    this.packageModel,
  });
}

/// Halaman profil pengguna yang menampilkan informasi pribadi dan paket aktif.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final CustomerOpFirebase _customerOp;
  late final TransactionOpFirebase _transactionOp;
  late final PackageOpFirebase _packageOp;

  // DIUBAH: Hanya satu Future yang mengelola semua data untuk halaman ini.
  Future<_ProfileData>? _futureProfileData;

  @override
  void initState() {
    super.initState();
    ref.read(interstitialAdServiceProvider).preloadAd();
    _customerOp = ref.read(customerOpFirebaseProvider);
    _transactionOp = ref.read(transactionOpFirebaseProvider);
    _packageOp = ref.read(packageOpFirebaseProvider);
    _futureProfileData = _loadProfileData();
  }

  // PENJELASAN: Ini adalah inti dari perbaikan. Method ini bertanggung jawab untuk
  // mengambil semua data yang diperlukan secara efisien.
  Future<_ProfileData> _loadProfileData() async {
    final userId = await ref.read(userIdProvider.future);
    if (userId == null) {
      throw Exception('ID Pengguna tidak ditemukan, mohon login kembali.');
    }
    Log.info('Memulai pengambilan data profil lengkap untuk userId: $userId.');
    try {
      final customer = await _customerOp.getCustomerOnce(userId);
      if (customer == null) {
        throw Exception('Pelanggan dengan ID  tidak ditemukan.');
      }
      Log.info('Data pelanggan berhasil diambil: ${customer.name}.');

      // 2. Ambil total poin dan paket aktif secara bersamaan (paralel)
      // Ini lebih efisien karena tidak perlu menunggu satu sama lain.
      final results = await Future.wait([
        _transactionOp.getTotalPoints(customer.id),
        _transactionOp.getPaketAktifCustomer(customer.id),
      ]);

      final totalPoints = results[0] as int;
      final activeSubscriptions = results[1] as List<TransactionModel>;
      Log.info(
          'Total poin diambil: $totalPoints. Langganan aktif ditemukan: ${activeSubscriptions.length}.');

      TransactionModel? lastSubscription;
      PackageModel? packageModel;

      if (activeSubscriptions.isNotEmpty) {
        // 3. Cari langganan yang paling baru berakhir
        lastSubscription = activeSubscriptions.reduce(
          (a, b) => a.endDate!.isAfter(b.endDate!) ? a : b,
        );
        Log.info(
            'Langganan terakhir berakhir pada: ${lastSubscription.endDate}.');

        // 4. Jika ada langganan aktif, ambil detail paketnya
        if (lastSubscription.packageId != null) {
          packageModel =
              await _packageOp.getPackageById(lastSubscription.packageId!);
          Log.info('Detail paket "${packageModel?.name}" berhasil diambil.');
        }
      }

      // 5. Kembalikan semua data dalam satu objek.
      return _ProfileData(
        customer: customer,
        totalPoints: totalPoints,
        lastActiveSubscription: lastSubscription,
        packageModel: packageModel,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal total memuat data profil.', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data profil.');
      }
      // Lemparkan kembali error agar FutureBuilder bisa menanganinya di UI.
      rethrow;
    }
  }

  // Method _reloadData diubah untuk memanggil _initializeData lagi.
  Future<void> _reloadData() async {
    setState(() {
      _futureProfileData = _loadProfileData();
    });
    await _futureProfileData;
    if (mounted) {
      ToastUtil.success(context, 'Data berhasil diperbarui.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk ProfilePage.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pelanggan'),
      ),
      // DIUBAH: Hanya ada satu FutureBuilder utama yang mengelola state loading/error/data.
      body: FutureBuilder<_ProfileData>(
        future: _futureProfileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            Log.error('FutureBuilder<_ProfileData> error: ${snapshot.error}.',
                e: snapshot.error, st: snapshot.stackTrace);
            return Center(
              child: Text('Terjadi Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            final userId = ref.watch(userIdProvider);
            return Center(
              child: Text('Profil ID: $userId tidak ditemukan.'),
            );
          }

          final profileData = snapshot.data!;
          final customer = profileData.customer;

          return RefreshIndicator(
            onRefresh: _reloadData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildInfoCard(
                  context,
                  title: 'Informasi Pribadi',
                  icon: TIcons.person,
                  children: [
                    _InfoItem(
                      icon: TIcons.personOutlined,
                      label: 'Nama Lengkap',
                      value: customer.name,
                      trailingIcon: TIcons.chevronRight,
                      onTap: () => _navigateToDetail(customer.id),
                    ),
                    _InfoItem(
                      icon: TIcons.points,
                      label: 'Poin',
                      value: profileData.totalPoints.toString(),
                      trailingIcon: TIcons.chevronRight,
                      onTap: () => _navigateToPointsPage(customer.id),
                    ),
                  ],
                ),
                gapH16,
                _buildInfoCard(
                  context,
                  title: 'Informasi Paket Aktif',
                  icon: TIcons.wifi,
                  children: [
                    _buildActivePackageDetails(
                      context,
                      profileData.lastActiveSubscription,
                      profileData.packageModel,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // DIUBAH: Method ini sekarang menjadi sinkron dan hanya bertanggung jawab membangun UI
  // dari data yang sudah siap, bukan lagi melakukan fetching.
  Widget _buildActivePackageDetails(
    BuildContext context,
    TransactionModel? lastSubscription,
    PackageModel? packageModel,
  ) {
    if (lastSubscription == null) {
      return const _InfoItem(
        icon: TIcons.noWifi,
        label: 'Paket Aktif',
        value: 'Tidak ada paket aktif.',
      );
    }

    final String activePeriodText =
        CalculationUtil.getRemainingActivePeriodText(lastSubscription.endDate!);
    final Color activePeriodColor =
        CalculationUtil.getRemainingActivePeriodColor(
            lastSubscription.endDate!);
    final Color paymentStatusColor =
        lastSubscription.paymentStatus == PaymentStatus.paid
            ? Colors.green
            : Colors.red;

    return Column(
      children: [
        _InfoItem(
          icon: TIcons.wifi,
          label: 'Paket',
          value: packageModel?.name ?? 'Tidak tersedia',
        ),
        if (lastSubscription.startDate != null)
          _InfoItem(
            icon: TIcons.dateRange,
            label: 'Aktif Sejak',
            value: FormatDateTime.formatDateAndTimeCompact(
                lastSubscription.startDate!),
          ),
        _InfoItem(
          icon: TIcons.dateRange,
          label: 'Berakhir Pada',
          value: FormatDateTime.formatDateAndTimeCompact(
              lastSubscription.endDate!),
        ),
        _InfoItem(
          icon: TIcons.hourglass,
          label: 'Masa Aktif',
          value: activePeriodText,
          valueColor: activePeriodColor,
        ),
        _InfoItem(
          icon: TIcons.successOutlined,
          label: 'Status Pembayaran',
          value: lastSubscription.paymentStatus.displayName
              .replaceAll('_', ' ')
              .toUpperCase(),
          valueColor: paymentStatusColor,
        ),
        if (lastSubscription.durasiBonus! > 0 &&
            lastSubscription.durasiBonusType != null)
          _InfoItem(
            icon: Icon(TIcons.reward),
            label: 'Bonus',
            value:
                '${lastSubscription.durasiBonus} ${lastSubscription.durasiBonusType!.displayName}',
          )
      ],
    );
  }

  Future<void> _navigateToDetail(String userId) async {
    await ref.read(interstitialAdServiceProvider).show();
    try {
      final hasChanged = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (context) => UserCustomerDetailPage(userId: userId),
        ),
      );
      await ref.read(interstitialAdServiceProvider).show();
      if (hasChanged ?? false) {
        _reloadData();
      }
    } on Exception catch (e, st) {
      Log.error('Gagal navigasi ke detail pelanggan.', e: e, st: st);
      if (mounted) ToastUtil.error(context, 'Gagal membuka halaman detail.');
    }
  }

  Future<void> _navigateToPointsPage(String customerId) async {
    await ref.read(interstitialAdServiceProvider).show();
    try {
      final hasChanged = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (context) => PointsPage(
            customerId: customerId,
            showAd: true,
          ),
        ),
      );
      await ref.read(interstitialAdServiceProvider).show();
      if (hasChanged ?? false) {
        _reloadData();
      }
    } on Exception catch (e, st) {
      Log.error('Gagal navigasi ke halaman poin.', e: e, st: st);
      if (mounted) ToastUtil.error(context, 'Gagal membuka halaman poin.');
    }
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                gapW8,
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                gapH4,
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: Colors.grey.shade600, size: 20),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }
    return content;
  }
}
