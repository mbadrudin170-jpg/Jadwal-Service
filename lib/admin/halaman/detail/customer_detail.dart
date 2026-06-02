// path: lib/admin/halaman/detail/customer_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/customer_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/user_role_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/poin/sqlite_points_data_source.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';
import 'package:wifi/shared/widget/page/points_page.dart';

class CustomerDetailPage extends ConsumerWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  Future<void> _editCustomer(
      BuildContext context, WidgetRef ref, CustomerModel? customer) async {
    if (customer == null) return;
    Log.info('Navigasi ke form edit pelanggan: ${customer.name}');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => CustomerForm(customer: customer),
      ),
    );
    if (result ?? false) {
      Log.info('Kembali dari edit pelanggan, memuat ulang data.');
      ref.invalidate(customerDetailProvider(customerId));
      ref.invalidate(
          customerListProvider); // Biar halaman daftar pelanggan ikut terbarui
    }
  }

  Future<void> _copyAllInfo(
      BuildContext context, CustomerModel customer) async {
    Log.info('Menyalin info pelanggan: ${customer.name}');
    final info = '''
Nama : ${customer.name}
No HP : ${customer.phone}
Alamat : ${customer.address}
Password : ${customer.password}
MAC : ${customer.macAddress}
'''
        .trim();

    await Clipboard.setData(ClipboardData(text: info));
    if (context.mounted) {
      ToastUtil.success(context, 'Informasi pelanggan berhasil disalin.');
    }
  }

  Future<void> _navigateToPoints(
      BuildContext context, WidgetRef ref, CustomerModel? customer) async {
    if (customer == null) return;
    final sqLitePointsDataSource = ref.read(sqlitePointsDataSourceProvider);
    Log.info('Navigasi ke halaman poin pelanggan: ${customer.name}');

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (final context) => PointsPage(
          customerId: customer.id,
          dataSource: sqLitePointsDataSource,
          role: UserRole.admin,
        ),
      ),
    );

    Log.info('Kembali dari halaman poin, memuat ulang data detail poin.');
    ref.invalidate(customerDetailProvider(customerId));
    ref.invalidate(
        customerListProvider); // Biar poin di halaman daftar ikut terbarui
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Di sini penggunaan ref.watch sangat tepat karena diletakkan di dalam metode build
    final detailAsync = ref.watch(customerDetailProvider(customerId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Memuat Detail...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) {
        Log.error('Gagal mengambil data pelanggan ID: $customerId.',
            e: e, st: s);
        return Scaffold(
          appBar: AppBar(title: const Text('Detail Pelanggan')),
          body: Center(child: Text('Gagal memuat data: $e')),
        );
      },
      data: (data) {
        final (customer, totalPoints) = data;

        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Pelanggan')),
            body: const Center(child: Text('Pelanggan tidak ditemukan')),
          );
        }

        return CustomerDetailUI(
          customer: customer,
          totalPoints: totalPoints,
          onEdit: () => _editCustomer(context, ref, customer),
          onNavigateToPoints: () => _navigateToPoints(context, ref, customer),
          onCopyAll: () => _copyAllInfo(context, customer),
        );
      },
    );
  }
}
