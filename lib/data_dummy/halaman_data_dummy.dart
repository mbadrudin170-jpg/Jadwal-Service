// path: lib/data_dummy/halaman_data_dummy.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/providers/pelanggan_aktif_provider.dart';
import 'package:wifi/data_dummy/data_dummy.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';
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
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Pesanan', DataDummy.orders,
                  ref.read(orderOperationProvider).insertOrUpdateBatch);
              ref.invalidate(orderOperationProvider);
            },
            label: 'Tambah Pesanan Dummy',
            icon: Icons.add_shopping_cart,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(
                  context,
                  ref,
                  'Pelanggan',
                  DataDummy.customers,
                  ref
                      .read(customerOperationProvider)
                      .sisipkanAtauPerbaruiBatch);
              ref.invalidate(customerOperationProvider);
            },
            label: 'Tambah Pelanggan Dummy',
            icon: Icons.person_add,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Paket', DataDummy.packages,
                  ref.read(packageOperationProvider).sisipkanAtauPerbaruiBatch);
              ref.invalidate(packageOperationProvider);
            },
            label: 'Tambah Paket Dummy',
            icon: Icons.inventory_2,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Kategori', DataDummy.categories,
                  ref.read(categoryOperationProvider).insertOrUpdateBatch);
              ref.invalidate(categoryOperationProvider);
            },
            label: 'Tambah Kategori Dummy',
            icon: Icons.category,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(
                  context,
                  ref,
                  'Sub Kategori',
                  DataDummy.subCategories,
                  ref.read(subCategoryOperationProvider).insertOrUpdateBatch);
              ref.invalidate(subCategoryOperationProvider);
            },
            label: 'Tambah Sub Kategori Dummy',
            icon: Icons.list_alt,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Dompet', DataDummy.wallets,
                  ref.read(walletOperationProvider).insertOrUpdateBatch);
              ref.invalidate(walletOperationProvider);
            },
            label: 'Tambah Dompet Dummy',
            icon: Icons.account_balance_wallet,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(
                  context,
                  ref,
                  'Transaksi',
                  DataDummy.transactions,
                  ref.read(transactionOperationProvider).insertOrUpdateBatch);
              ref.invalidate(transactionOperationProvider);
            },
            label: 'Tambah Transaksi Dummy',
            icon: Icons.receipt_long,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(
                  context,
                  ref,
                  'Pelanggan Aktif',
                  DataDummy.activeCustomers,
                  ref
                      .read(activeCustomerOperationProvider)
                      .insertOrUpdateBatch);
              ref.invalidate(pelangganAktifProvider);
            },
            label: 'Tambah Pelanggan Aktif Dummy',
            icon: Icons.wifi,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Feedback', DataDummy.feedbacks,
                  ref.read(feedbackOperationProvider).insertOrUpdateBatch);
              ref.invalidate(feedbackOperationProvider);
            },
            label: 'Tambah Feedback Dummy',
            icon: Icons.feedback,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(
                  context,
                  ref,
                  'Versi APK',
                  DataDummy.apkVersions,
                  ref.read(apkVersionOperationProvider).insertOrUpdateBatch);
              ref.invalidate(apkVersionOperationProvider);
            },
            label: 'Tambah Versi APK Dummy',
            icon: Icons.system_update,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahPengaturan(context, ref);
              ref.invalidate(settingsOperationProvider);
            },
            label: 'Tambah Pengaturan Dummy',
            icon: Icons.settings,
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk membuat tombol fitur.
  Widget _tombolFitur({
    required BuildContext context,
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// 1. Menambahkan data dummy secara generik.
  Future<void> _tambahData<T>(
      BuildContext context,
      WidgetRef ref,
      String modelName,
      List<T> dataList,
      Future<void> Function(List<T>) batchFunction) async {
    try {
      Log.info('Memulai proses penambahan data $modelName dummy');
      await batchFunction(dataList);

      if (context.mounted) {
        ToastUtil.success(context,
            'Berhasil menambahkan/memperbarui ${dataList.length} data $modelName dummy.');
      }
    } catch (e, st) {
      Log.error('Gagal menambahkan data $modelName dummy', e: e, s: st);
      if (context.mounted) {
        ToastUtil.error(
            context, 'Terjadi kesalahan saat menambah $modelName: $e');
      }
    }
  }

  /// 2. Menambahkan data pengaturan dummy.
  Future<void> _tambahPengaturan(BuildContext context, WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Pengaturan dummy');
      final settingsOperation = ref.read(settingsOperationProvider);
      await settingsOperation.saveOrUpdateSettings(DataDummy.settings);

      if (context.mounted) {
        ToastUtil.success(
            context, 'Berhasil menambahkan/memperbarui data Pengaturan dummy.');
      }
    } catch (e, st) {
      Log.error('Gagal menambahkan data Pengaturan dummy', e: e, s: st);
      if (context.mounted) {
        ToastUtil.error(
            context, 'Terjadi kesalahan saat menambah Pengaturan: $e');
      }
    }
  }
}
