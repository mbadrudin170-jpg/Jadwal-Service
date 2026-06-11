// path: lib/admin/halaman/detail/customer_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wifi/admin/halaman/form/customer_form.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/poin/page/points_page.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';

class CustomerDetailPage extends ConsumerWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  Future<void> _editCustomer(
      BuildContext context, CustomerModel? customer) async {
    if (customer == null) return;
    Log.info('Navigasi ke form edit pelanggan: ${customer.name}');
    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => CustomerForm(customer: customer),
      ),
    );
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
      BuildContext context, CustomerModel? customer) async {
    if (customer == null) return;
    Log.info('Navigasi ke halaman poin pelanggan: ${customer.name}');

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PoinPage(
          customerId: customer.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onEdit: () => _editCustomer(context, customer),
          onNavigateToPoints: () => _navigateToPoints(context, customer),
          onCopyAll: () => _copyAllInfo(context, customer),
        );
      },
    );
  }
}
