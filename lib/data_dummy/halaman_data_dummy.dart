// path: lib/data_dummy/halaman_data_dummy.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/data_dummy/data_dummy.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class HalamanDataDummy extends ConsumerWidget {
  const HalamanDataDummy({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Data Dummy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tombolFitur(
              onPressed: () => _dataOrder(context, ref), label: 'Data Order'),
          _tombolFitur(onPressed: () {}, label: 'Fitur 2'),
        ],
      ),
    );
  }

  Widget _tombolFitur({
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      label: Text(label),
    );
  }

  Future<void> _dataOrder(BuildContext context, WidgetRef ref) async {
    try {
      final orderOperation = ref.read(orderOperationProvider);
      final dataOrder = DataDummy.orders;
      for (final order in dataOrder) {
        await orderOperation.saveOrder(order);
      }
      if (context.mounted) {
        ToastUtil.info(context, 'order semuanya berhasil di tambahkan');
      }
    } catch (e, st) {
      Log.error('Gagal menambahkan data pesanan dummy', e: e, st: st);
      if (context.mounted) {
        ToastUtil.error(context, 'Terjadi kesalahan: $e');
      }
    }
  }
}
