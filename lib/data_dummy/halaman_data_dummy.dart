// path: lib/data_dummy/halaman_data_dummy.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/data_dummy/data_dummy.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
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
                  ref.read(orderOpSqliteProvider).sisipkanAtauPerbaruiBatch);
              ref.invalidate(orderOpSqliteProvider);
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
                      .read(pelangganOpSqliteProvider)
                      .sisipkanAtauPerbaruiBatch);
              ref.invalidate(pelangganOpSqliteProvider);
            },
            label: 'Tambah Pelanggan Dummy',
            icon: Icons.person_add,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Paket', DataDummy.packages,
                  ref.read(paketOpSqliteProvider).sisipkanAtauPerbaruiBatch);
              ref.invalidate(paketOpSqliteProvider);
            },
            label: 'Tambah Paket Dummy',
            icon: Icons.inventory_2,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Kategori', DataDummy.categories,
                  ref.read(kategoriOpSqliteProvider).sisipkanAtauPerbaruiBatch);
              ref.invalidate(kategoriOpSqliteProvider);
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
                  ref
                      .read(subKategoriOpSqliteProvider)
                      .sisipkanAtauPerbaruiBatch);
              ref.invalidate(subKategoriOpSqliteProvider);
            },
            label: 'Tambah Sub Kategori Dummy',
            icon: Icons.list_alt,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Dompet', DataDummy.wallets,
                  ref.read(dompetOpSqliteProvider).sisipkanAtauPerbaruiBatch);
              ref.invalidate(dompetOpSqliteProvider);
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
                ref.read(transaksiOpSqliteProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(transaksiOpSqliteProvider);
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
                (data, {dariServer = false}) => ref
                    .read(pelangganAktifOpSqliteProvider)
                    .sisipkanAtauPerbaruiBatch(data, fromServer: dariServer),
              );
              ref.invalidate(pelangganAktifProvider);
            },
            label: 'Tambah Pelanggan Aktif Dummy',
            icon: Icons.wifi,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData(context, ref, 'Feedback', DataDummy.feedbacks,
                  ref.read(feedbackOpSqliteProvider).sisipkanAtauPerbaruiBatch);
              ref.invalidate(feedbackOpSqliteProvider);
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
                  ref.read(versiApkOpSqliteProvider).sisipkanAtauPerbaruiBatch);
              ref.invalidate(versiApkOpSqliteProvider);
            },
            label: 'Tambah Versi APK Dummy',
            icon: Icons.system_update,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahPengaturan(context, ref);
              ref.invalidate(settingsOpSqliteProvider);
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
    Future<void> Function(List<T> data, {bool dariServer}) batchFunction,
  ) async {
    try {
      Log.info('Memulai proses penambahan data $modelName dummy');
      await batchFunction(dataList, dariServer: false);

      if (context.mounted) {
        ToastUtil.success(
          context,
          'Berhasil menambahkan/memperbarui ${dataList.length} data $modelName dummy.',
        );
      }
    } catch (e, s) {
      Log.error(
        'Gagal menambahkan data $modelName dummy',
        e: e,
        s: s,
      );
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
      final settingsOperation = ref.read(settingsOpSqliteProvider);
      await settingsOperation.saveOrUpdateSettings(DataDummy.settings);

      if (context.mounted) {
        ToastUtil.success(
            context, 'Berhasil menambahkan/memperbarui data Pengaturan dummy.');
      }
    } catch (e, s) {
      Log.error(
        'Gagal menambahkan data Pengaturan dummy',
        e: e,
        s: s,
      );
      if (context.mounted) {
        ToastUtil.error(
            context, 'Terjadi kesalahan saat menambah Pengaturan: $e');
      }
    }
  }
}
