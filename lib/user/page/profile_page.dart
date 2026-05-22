// path: lib/user/page/profile_page.dart
// diubah: Menggunakan getPackageModelById untuk mengambil seluruh objek paket.
// REFACTOR: Mengekstrak logika paket aktif ke method _buildActivePackageDetails.
// DITAMBAHKAN: Logging untuk memverifikasi nilai totalPoints yang diterima.
// DIPERBAIKI: Navigasi kini memeriksa hasil boolean sebelum memanggil _reloadData.
// diubah: Refaktor untuk menggunakan PointsPage generik.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/poin/firebase_points_data_source.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/page/points_page.dart';
import 'package:wifi/user/page/user_customer_detail.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/ads/ad_helper.dart';
import 'package:wifi/user/widget/ads/banner_ad_widget.dart';

/// Halaman profil pengguna yang menampilkan informasi pribadi dan paket aktif.
class ProfilePage extends StatefulWidget {
  /// ID pengguna yang sedang login.
  final String userId;

  /// Service untuk mengakses penyimpanan lokal.
  final LocalStorageService localStorageService;

  /// Membuat instance dari [ProfilePage].
  const ProfilePage({
    super.key,
    required this.userId,
    required this.localStorageService,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final CustomerOpFirebase _customerOp = CustomerOpFirebase();
  final TransactionOpFirebase _transactionOp = TransactionOpFirebase();
  final PackageOpFirebase _packageOp = PackageOpFirebase();
  Future<CustomerModel?>? _futureCustomer;
  Future<int>? _totalPointsFuture;
  Future<List<TransactionModel>>? _activePackagesFuture;

  Future<PackageModel?>? _futurePackageModel;
  String? _cachePackageId;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai inisialisasi state untuk ProfilePage, userId: ${widget.userId}',
    );
    unawaited(_initializeData());
  }

  Future<void> _initializeData() async {
    Log.info('Memulai pengambilan data awal untuk userId: ${widget.userId}.');
    if (!mounted) return;

    setState(() {
      _futureCustomer = _customerOp.getCustomerOnce(widget.userId);
    });

    try {
      final customer = await _futureCustomer;
      if (customer != null) {
        Log.info(
          'Data pelanggan berhasil diambil: ${customer.name}. Mengambil data terkait...',
        );
        if (!mounted) return;
        setState(() {
          _totalPointsFuture = _transactionOp.getTotalPoints(customer.id);
          _activePackagesFuture =
              _transactionOp.getPaketAktifCustomer(customer.id);
        });
      } else {
        Log.warning(
          'Pelanggan dengan userId: ${widget.userId} tidak ditemukan di Firestore.',
        );
      }
    } on Exception catch (e, st) {
      Log.error('Gagal memuat data awal profil.', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data profil.');
      }
    }
  }

  Future<void> _reloadData() async {
    Log.info('Memuat ulang semua data profil via onRefresh.');
    setState(() {
      _futureCustomer = _customerOp.getCustomerOnce(widget.userId);
    });
    try {
      final customer = await _futureCustomer;
      if (customer != null) {
        setState(() {
          _totalPointsFuture = _transactionOp.getTotalPoints(customer.id);
          _activePackagesFuture =
              _transactionOp.getPaketAktifCustomer(customer.id);

          _futurePackageModel = null;
          _cachePackageId = null;
        });
        await Future.wait([
          _totalPointsFuture ?? Future<int>.value(0),
          _activePackagesFuture ?? Future<List<TransactionModel>>.value([]),
        ]);
      }

      if (mounted) {
        Log.info('Data profil berhasil diperbarui.');
        ToastUtil.success(
          context,
          'Data berhasil diperbarui.',
        );
      }
    } on Exception catch (e, st) {
      Log.error('Gagal saat memuat ulang data profil.', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memperbarui data: $e');
      }
    }
  }

  Future<void> _navigateToDetail(final String userId) async {
    Log.info('Menavigasi ke UserCustomerDetailPage untuk userId: $userId');
    try {
      final hasChanged = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (final context) => UserCustomerDetailPage(userId: userId),
        ),
      );

      if (hasChanged ?? false) {
        Log.info(
          'Kembali dari halaman detail dengan perubahan, memuat ulang data.',
        );
        await _reloadData();
      } else {
        Log.info(
          'Kembali dari halaman detail tanpa perubahan.',
        );
      }
    } on Exception catch (e, st) {
      Log.error('Gagal navigasi ke detail pelanggan.', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal membuka halaman detail.');
      }
    }
  }

  Future<void> _navigateToPointsPage(final String customerId) async {
    Log.info('Menavigasi ke PointsPage untuk customerId: $customerId');
    try {
      final hasChanged = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (final context) => PointsPage(
            customerId: customerId,
            dataSource: FirebasePointsDataSource(), // Menggunakan data source Firebase
          ),
        ),
      );
      if (hasChanged ?? false) {
        Log.info('Kembali dari halaman poin dengan perubahan, memuat ulang data.');
        await _reloadData();
      } else {
        Log.info('Kembali dari halaman poin tanpa ada perubahan.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal navigasi ke halaman poin.', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal membuka halaman poin.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk ProfilePage.');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pelanggan'),
      ),
      body: _futureCustomer == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<CustomerModel?>(
              future: _futureCustomer,
              builder: (final context, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  Log.error(
                    'FutureBuilder<Customer> mendeteksi error: ${snapshot.error}.',
                    e: snapshot.error,
                    st: snapshot.stackTrace,
                  );
                  return Center(
                      child: Text('Terjadi Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  Log.warning(
                    'FutureBuilder<Customer>: Tidak ada data pelanggan ditemukan.',
                  );
                  return Center(
                    child: Text('Profil ID: ${widget.userId} tidak ditemukan.'),
                  );
                }

                final customer = snapshot.data!;
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _reloadData,
                        child: ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            _buildInfoCard(
                              context,
                              title: 'Informasi Pribadi',
                              icon: AppIcons.person,
                              children: [
                                _InfoItem(
                                  icon: AppIcons.personOutlined,
                                  label: 'Nama Lengkap',
                                  value: customer.name,
                                  trailingIcon: AppIcons.chevronRight,
                                  onTap: () =>
                                      unawaited(_navigateToDetail(customer.id)),
                                ),
                                _PointsInfoWidget(
                                  totalPointsFuture: _totalPointsFuture,
                                  onTap: () => unawaited(
                                      _navigateToPointsPage(customer.id)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              context,
                              title: 'Informasi Paket Aktif',
                              icon: AppIcons.wifi,
                              children: [
                                FutureBuilder<List<TransactionModel>>(
                                  future: _activePackagesFuture,
                                  builder: _buildActivePackageDetails,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: BannerAdWidget(
                          adUnitId: AdHelper.profileBannerAdUnitId),
                    ),
                  ],
                );
              },
            ),
    );
  }

  /// Method yang diekstrak untuk membangun detail paket aktif.
  Widget _buildActivePackageDetails(
    final BuildContext context,
    final AsyncSnapshot<List<TransactionModel>> activeSnapshot,
  ) {
    if (activeSnapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (activeSnapshot.hasError) {
      return const _InfoItem(
        icon: AppIcons.errorOutlined,
        label: 'Error',
        value: 'Gagal memuat paket aktif.',
      );
    }

    if (!activeSnapshot.hasData || activeSnapshot.data!.isEmpty) {
      return const _InfoItem(
        icon: AppIcons.noWifi,
        label: 'Paket Aktif',
        value: 'Tidak ada paket aktif.',
      );
    }

    final activeSubscriptions = activeSnapshot.data!;

    TransactionModel? lastSubscription;
    if (activeSubscriptions.isNotEmpty) {
      lastSubscription = activeSubscriptions.reduce(
        (final a, final b) => a.endDate!.isAfter(b.endDate!) ? a : b,
      );
      Log.info(
        'Langganan aktif terakhir: berakhir ${FormatDateTime.formatDateAndTimeCompact(lastSubscription.endDate!)}.',
      );
    } else {
      return const _InfoItem(
        icon: AppIcons.noWifi,
        label: 'Paket Aktif',
        value: 'Tidak ada paket aktif.',
      );
    }

    final String activePeriodText =
        CalculationUtil.getRemainingActivePeriodText(
      lastSubscription.endDate!,
    );
    final Color activePeriodColor =
        CalculationUtil.getRemainingActivePeriodColor(
      lastSubscription.endDate!,
    );
    final Color paymentStatusColor =
        lastSubscription.paymentStatus == PaymentStatus.paid
            ? Colors.green
            : Colors.red;

    if (lastSubscription.packageId != null &&
        _cachePackageId != lastSubscription.packageId) {
      Log.info(
          'ID paket berubah, ambil model baru: ${lastSubscription.packageId!}.');
      _futurePackageModel =
          _packageOp.getPackageById(lastSubscription.packageId!);
      _cachePackageId = lastSubscription.packageId;
    }

    return Column(
      children: [
        FutureBuilder<PackageModel?>(
          future: _futurePackageModel,
          builder: (final context, final packageSnapshot) {
            String packageName;
            if (packageSnapshot.connectionState == ConnectionState.waiting) {
              packageName = 'Memuat...';
            } else if (packageSnapshot.hasError) {
              packageName = 'Gagal memuat';
              Log.error(
                'Gagal ambil model paket: ${packageSnapshot.error}',
                e: packageSnapshot.error,
                st: packageSnapshot.stackTrace,
              );
            } else if (packageSnapshot.hasData) {
              final package = packageSnapshot.data!;
              packageName = package.name;
            } else {
              packageName = 'Tidak tersedia';
            }
            return _InfoItem(
              icon: AppIcons.wifi,
              label: 'Paket',
              value: packageName,
            );
          },
        ),
        if (lastSubscription.startDate != null)
          _InfoItem(
            icon: AppIcons.dateRange,
            label: 'Aktif Sejak',
            value: FormatDateTime.formatDateAndTimeCompact(
              lastSubscription.startDate!,
            ),
          ),
        _InfoItem(
          icon: AppIcons.dateRange,
          label: 'Berakhir Pada',
          value: FormatDateTime.formatDateAndTimeCompact(
            lastSubscription.endDate!,
          ),
        ),
        _InfoItem(
          icon: AppIcons.hourglass,
          label: 'Masa Aktif',
          value: activePeriodText,
          valueColor: activePeriodColor,
        ),
        _InfoItem(
          icon: AppIcons.successOutlined,
          label: 'Status Pembayaran',
          value: lastSubscription.paymentStatus.displayName
              .replaceAll('_', ' ')
              .toUpperCase(),
          valueColor: paymentStatusColor,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    final BuildContext context, {
    required final String title,
    required final IconData icon,
    required final List<Widget> children,
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
                const SizedBox(width: 8),
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

/// Widget untuk menampilkan informasi poin pengguna.
class _PointsInfoWidget extends StatelessWidget {
  final Future<int>? totalPointsFuture;
  final VoidCallback? onTap;

  const _PointsInfoWidget({
    required this.totalPointsFuture,
    this.onTap,
  });

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<int>(
      future: totalPointsFuture,
      builder: (final context, final pointsSnapshot) {
        if (pointsSnapshot.connectionState == ConnectionState.waiting) {
          return const _InfoItem(
            icon: AppIcons.points,
            label: 'Poin',
            value: 'Menghitung...',
          );
        }

        if (pointsSnapshot.hasError) {
          Log.error(
            'Gagal ambil total poin: ${pointsSnapshot.error}',
            e: pointsSnapshot.error,
            st: pointsSnapshot.stackTrace,
          );
          return const _InfoItem(
            icon: AppIcons.points,
            label: 'Poin',
            value: 'Gagal memuat',
          );
        }

        final int totalPoints = pointsSnapshot.data ?? 0;

        // Log tambahan untuk verifikasi
        Log.info(
            'FutureBuilder di _PointsInfoWidget menampilkan total poin: $totalPoints');

        return _InfoItem(
          icon: AppIcons.points,
          label: 'Poin',
          value: totalPoints.toString(),
          trailingIcon: AppIcons.chevronRight,
          onTap: onTap,
        );
      },
    );
  }
}

/// Widget item informasi generik.
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
  Widget build(final BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 2),
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
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
