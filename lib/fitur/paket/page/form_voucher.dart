// path lib/fitur/paket/page/form_voucher.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FormVoucher extends ConsumerStatefulWidget {
  const FormVoucher({super.key});

  @override
  ConsumerState<FormVoucher> createState() => _FormVoucherState();
}

class _FormVoucherState extends ConsumerState<FormVoucher> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // panggil repository
      if (mounted) setState(() => _isLoading = false);
    } on Exception catch (e, s) {
      Log.error('Error', e: e, s: s);
      if (mounted) {
        setState(() => _isLoading = false);
        ToastUtil.error(context, 'Gagal memuat data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('FormVoucher')),
      body: Container(),
    );
  }
}
