// path: lib/data_dummy/halaman_data_dummy.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/data_dummy/dummy_dompet.dart';
import 'package:wifi/data_dummy/dummy_kategori.dart';
import 'package:wifi/data_dummy/dummy_paket.dart';
import 'package:wifi/data_dummy/dummy_pelanggan.dart';
import 'package:wifi/data_dummy/dummy_sub_kategori.dart';
import 'package:wifi/data_dummy/dummy_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class HalamanDataDummy extends ConsumerWidget {
  const HalamanDataDummy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Data Dummy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tombolFitur(
            context: context,
            onPressed: () => _tambahSemuaData(context, ref),
            label: 'TAMBAH SEMUA DATA DUMMY',
            icon: Icons.abc_outlined,
            color: Colors.green,
          ),
          const Divider(height: 32, thickness: 2),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData<PelangganModel>(
                context,
                ref,
                'Pelanggan',
                daftarPelanggan,
                ref.read(pelangganOpSqliteProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(pelangganOpSqliteProvider);
            },
            label: 'Tambah Pelanggan Dummy (${daftarPelanggan.length})',
            icon: TIcons.customers,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData<DompetModel>(
                context,
                ref,
                'Dompet',
                DummyDompet.daftarDompet,
                ref.read(dompetOpSqliteProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(dompetOpSqliteProvider);
            },
            label: 'Tambah Dompet Dummy (${DummyDompet.daftarDompet.length})',
            icon: TIcons.wallet,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData<KategoriModel>(
                context,
                ref,
                'Kategori',
                DummyKategori.daftarKategori,
                ref.read(kategoriOpSqliteProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(kategoriOpSqliteProvider);
            },
            label:
                'Tambah Kategori Dummy (${DummyKategori.daftarKategori.length})',
            icon: TIcons.filter,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData<SubKategoriModel>(
                context,
                ref,
                'Sub Kategori',
                DummySubKategori.daftarSubKategori,
                ref.read(subKategoriOpSqliteProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(subKategoriOpSqliteProvider);
            },
            label:
                'Tambah Sub Kategori Dummy (${DummySubKategori.daftarSubKategori.length})',
            icon: TIcons.listAlt,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData<PaketModel>(
                context,
                ref,
                'Paket',
                DummyPaket.daftarPaket,
                ref.read(paketOpSqliteProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(paketOpSqliteProvider);
            },
            label: 'Tambah Paket Dummy (${DummyPaket.daftarPaket.length})',
            icon: TIcons.packages,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData<TransaksiModel>(
                context,
                ref,
                'Transaksi',
                daftarTransaksi,
                ref.read(transaksiOpGlobalProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(transaksiOpSqliteProvider);
            },
            label: 'Tambah Transaksi Dummy (${daftarTransaksi.length})',
            icon: TIcons.receiptLong,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              // Hapus atau komentari dulu karena belum ada implementasi konversi yang valid
              //   await _tambahData<dynamic>(
              //     context,
              //     ref,
              //     'Pelanggan Aktif',
              //     [], // Kosongkan dulu
              //     ref
              //         .read(pelangganAktifOpSqliteProvider)
              //         .sisipkanAtauPerbaruiBatch,
              //   );
              //   ref.invalidate(pelangganAktifProvider);
            },
            label: 'Tambah Pelanggan Aktif Dummy',
            icon: TIcons.pelangganAktif,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData<FeedbackModel>(
                context,
                ref,
                'Feedback',
                [], // Kosongkan
                ref.read(feedbackOpSqliteProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(feedbackOpSqliteProvider);
            },
            label: 'Tambah Feedback Dummy',
            icon: TIcons.feedback,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahData<VersiApkModel>(
                context,
                ref,
                'Versi APK',
                [], // Kosongkan
                ref.read(versiApkOpSqliteProvider).sisipkanAtauPerbaruiBatch,
              );
              ref.invalidate(versiApkOpSqliteProvider);
            },
            label: 'Tambah Versi APK Dummy',
            icon: TIcons.systemUpdate,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahPengaturan(context, ref);
              ref.invalidate(settingsOpSqliteProvider);
            },
            label: 'Tambah Pengaturan Dummy',
            icon: TIcons.settings,
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
    Color? color,
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
          backgroundColor: color,
          foregroundColor: color != null ? Colors.white : null,
        ),
      ),
    );
  }

  /// Menambahkan data dummy secara generik.
  Future<void> _tambahData<T>(
    BuildContext context,
    WidgetRef ref,
    String modelName,
    List<T> dataList,
    Future<void> Function(List<T> data, {bool dariServer}) batchFunction,
  ) async {
    if (dataList.isEmpty) {
      if (context.mounted) {
        ToastUtil.info(
          context,
          'Tidak ada data $modelName dummy yang tersedia.',
        );
      }
      return;
    }

    try {
      Log.info('Memulai proses penambahan data $modelName dummy');
      await batchFunction(dataList, dariServer: false);

      if (context.mounted) {
        ToastUtil.success(
          context,
          'Berhasil menambahkan ${dataList.length} data $modelName dummy.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan data $modelName dummy', e: e, s: s);
      if (context.mounted) {
        ToastUtil.error(
          context,
          'Terjadi kesalahan saat menambah $modelName: $e',
        );
      }
    }
  }

  /// Menambahkan data pengaturan dummy.
  Future<void> _tambahPengaturan(BuildContext context, WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Pengaturan dummy');
      final settingsOperation = ref.read(settingsOpSqliteProvider);
      // Settings default
      await settingsOperation.simpanAtauPerbaruiSettings(const SettingsModel());

      if (context.mounted) {
        ToastUtil.success(
          context,
          'Berhasil menambahkan data Pengaturan dummy.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan data Pengaturan dummy', e: e, s: s);
      if (context.mounted) {
        ToastUtil.error(
          context,
          'Terjadi kesalahan saat menambah Pengaturan: $e',
        );
      }
    }
  }

  /// Menambahkan semua data dummy sekaligus.
  Future<void> _tambahSemuaData(BuildContext context, WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan SEMUA data dummy');

      // 1. Tambahkan Pelanggan
      await ref
          .read(pelangganOpSqliteProvider)
          .sisipkanAtauPerbaruiBatch(daftarPelanggan);
      Log.info('✅ Pelanggan: ${daftarPelanggan.length} data');

      // 2. Tambahkan Dompet
      await ref
          .read(dompetOpSqliteProvider)
          .sisipkanAtauPerbaruiBatch(DummyDompet.daftarDompet);
      Log.info('✅ Dompet: ${DummyDompet.daftarDompet.length} data');

      // 3. Tambahkan Kategori
      await ref
          .read(kategoriOpSqliteProvider)
          .sisipkanAtauPerbaruiBatch(DummyKategori.daftarKategori);
      Log.info('✅ Kategori: ${DummyKategori.daftarKategori.length} data');

      // 4. Tambahkan Sub Kategori
      await ref
          .read(subKategoriOpSqliteProvider)
          .sisipkanAtauPerbaruiBatch(DummySubKategori.daftarSubKategori);
      Log.info(
        '✅ Sub Kategori: ${DummySubKategori.daftarSubKategori.length} data',
      );

      // 5. Tambahkan Paket
      await ref
          .read(paketOpSqliteProvider)
          .sisipkanAtauPerbaruiBatch(DummyPaket.daftarPaket);
      Log.info('✅ Paket: ${DummyPaket.daftarPaket.length} data');

      // 6. Tambahkan Transaksi
      await ref
          .read(transaksiOpGlobalProvider)
          .sisipkanAtauPerbaruiBatch(daftarTransaksi);
      Log.info('✅ Transaksi: ${daftarTransaksi.length} data');

      // 7. Tambahkan Pengaturan
      await ref
          .read(settingsOpSqliteProvider)
          .simpanAtauPerbaruiSettings(const SettingsModel());
      Log.info('✅ Pengaturan: 1 data');

      // Invalidate semua provider
      ref.invalidate(pelangganOpSqliteProvider);
      ref.invalidate(dompetOpSqliteProvider);
      ref.invalidate(kategoriOpSqliteProvider);
      ref.invalidate(subKategoriOpSqliteProvider);
      ref.invalidate(paketOpSqliteProvider);
      ref.invalidate(transaksiOpSqliteProvider);
      ref.invalidate(pelangganAktifProvider);
      ref.invalidate(orderOpSqliteProvider);
      ref.invalidate(feedbackOpSqliteProvider);
      ref.invalidate(versiApkOpSqliteProvider);
      ref.invalidate(settingsOpSqliteProvider);

      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('✅ Berhasil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Semua data dummy berhasil ditambahkan:'),
                gapH8,
                Text('• ${daftarPelanggan.length} Pelanggan'),
                Text('• ${DummyDompet.daftarDompet.length} Dompet'),
                Text('• ${DummyKategori.daftarKategori.length} Kategori'),
                Text(
                  '• ${DummySubKategori.daftarSubKategori.length} Sub Kategori',
                ),
                Text('• ${DummyPaket.daftarPaket.length} Paket'),
                Text('• ${daftarTransaksi.length} Transaksi'),
                const Text('• 1 Pengaturan'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan semua data dummy', e: e, s: s);
      if (context.mounted) {
        ToastUtil.error(
          context,
          'Terjadi kesalahan saat menambah semua data: $e',
        );
      }
    }
  }
}
