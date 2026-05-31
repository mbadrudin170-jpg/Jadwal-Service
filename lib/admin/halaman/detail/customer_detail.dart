// path: lib/admin/halaman/detail/customer_detail.dart
// diubah: Menggunakan ToastUtil, menghapus SnackBarUtil.
// diubah: Refaktor untuk menggunakan PointsPage generik.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/customer_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/user_role_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/poin/sqlite_points_data_source.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';
import 'package:wifi/shared/widget/page/points_page.dart';

class CustomerDetailPage extends ConsumerStatefulWidget {
  /// ID pelanggan yang akan ditampilkan.
  final String customerId;

  /// Konstruktor untuk CustomerDetailPage.
  const CustomerDetailPage({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage> {
  late final CustomerOperation _customerOperation;
  late final TransactionOperation _transactionOperation;

  CustomerModel? _customer;
  int _totalPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai initState pada CustomerDetailPage untuk ID: ${widget.customerId}.',
    );
    _customerOperation = ref.read(customerOperationProvider);
    _transactionOperation = ref.read(transactionOperationProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    Log.info('Memulai pengambilan data pelanggan ID: ${widget.customerId}.');
    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      final customerResult = await _customerOperation.getById(
        widget.customerId,
      );
      final pointsResult =
          await _transactionOperation.getTotalPoints(widget.customerId);

      if (!mounted) return;

      setState(() {
        _customer = customerResult;
        _totalPoints = pointsResult;
        _isLoading = false;
      });

      Log.info(
        'Data pelanggan dimuat. Nama: ${_customer?.name}, Poin: $_totalPoints',
      );
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil data pelanggan ID: ${widget.customerId}.',
          e: e, st: s);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editCustomer() async {
    if (_customer == null) return;
    Log.info('Navigasi ke form edit pelanggan: ${_customer!.name}');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => CustomerForm(customer: _customer),
      ),
    );
    if ((result ?? false) && mounted) {
      Log.info('Kembali dari edit pelanggan, memuat ulang data.');
      await _loadData();
    }
  }

  Future<void> _copyAllInfo(final CustomerModel customer) async {
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
    if (!mounted) return;
    ToastUtil.success(context, 'Informasi pelanggan berhasil disalin.');
  }

  Future<void> _navigateToPoints() async {
    if (_customer == null) return;
    Log.info('Navigasi ke halaman poin pelanggan: ${_customer!.name}');
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (final context) => PointsPage(
          customerId: _customer!.id,
          dataSource: SQLitePointsDataSource(),
          role: UserRole.admin,
        ),
      ),
    );
    if (!mounted) return;
    Log.info('Kembali dari halaman poin, memuat ulang data.');
    await _loadData();
  }

  @override
  Widget build(final BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat Detail...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final customer = _customer;
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const Center(child: Text('Pelanggan tidak ditemukan')),
      );
    }

    return CustomerDetailUI(
      customer: customer,
      totalPoints: _totalPoints,
      onEdit: _editCustomer,
      onNavigateToPoints: _navigateToPoints,
      onCopyAll: () => _copyAllInfo(customer),
    );
  }
}
