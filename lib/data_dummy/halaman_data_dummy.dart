// path: lib/data_dummy/halaman_data_dummy.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/data_dummy/dummy_dompet.dart';
import 'package:wifi/data_dummy/dummy_investasi.dart';
import 'package:wifi/data_dummy/dummy_kategori.dart';
import 'package:wifi/data_dummy/dummy_paket.dart';
import 'package:wifi/data_dummy/dummy_pelanggan.dart';
import 'package:wifi/data_dummy/dummy_sub_kategori.dart';
import 'package:wifi/data_dummy/dummy_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_sqlite.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';
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
              await _tambahPelanggan(ref);
            },
            label: 'Tambah Pelanggan Dummy (${daftarPelanggan.length})',
            icon: TIcons.customers,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahDompet(ref);
            },
            label: 'Tambah Dompet Dummy (${DummyDompet.daftarDompet.length})',
            icon: TIcons.wallet,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahKategori(ref);
            },
            label:
                'Tambah Kategori Dummy (${DummyKategori.daftarKategori.length})',
            icon: TIcons.filter,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahSubKategori(ref);
            },
            label:
                'Tambah Sub Kategori Dummy (${DummySubKategori.daftarSubKategori.length})',
            icon: TIcons.listAlt,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahPaket(ref);
            },
            label: 'Tambah Paket Dummy (${DummyPaket.daftarPaket.length})',
            icon: TIcons.packages,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahTransaksi(ref);
            },
            label: 'Tambah Transaksi Dummy (${daftarTransaksi.length})',
            icon: TIcons.receiptLong,
          ),
          // ============================================================
          // TOMBOL INVESTASI & DIVIDEN
          // ============================================================
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahInvestasi(ref);
            },
            label: 'Tambah Investasi Dummy (${daftarInvestasi.length})',
            icon: TIcons.money,
            color: Colors.purple,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahDividen(ref);
            },
            label: 'Tambah Dividen Dummy (${daftarDividen.length})',
            icon: TIcons.points,
            color: Colors.orange,
          ),
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _tambahPengaturan(ref);
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

  // ============================================================
  // FUNGSI TAMBAH DATA PER TABEL (MENGGUNAKAN OpGlobal)
  // ============================================================

  Future<void> _tambahPelanggan(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Pelanggan dummy');
      final pelangganOp = ref.read(pelangganOpGlobalProvider);
      var successCount = 0;

      for (final data in daftarPelanggan) {
        try {
          await pelangganOp.tambahPelanggan(data);
          successCount++;
        } catch (e) {
          Log.warning('Gagal insert pelanggan ${data.nama}: $e');
        }
      }

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan $successCount dari ${daftarPelanggan.length} Pelanggan.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Pelanggan dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Pelanggan: $e');
      }
    }
  }

  Future<void> _tambahDompet(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Dompet dummy');
      final dompetOp = ref.read(dompetOpSqliteProvider);
      var successCount = 0;

      for (final data in DummyDompet.daftarDompet) {
        try {
          await dompetOp.tambahDompet(data);
          successCount++;
        } catch (e) {
          Log.warning('Gagal insert dompet ${data.nama}: $e');
        }
      }

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan $successCount dari ${DummyDompet.daftarDompet.length} Dompet.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Dompet dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Dompet: $e');
      }
    }
  }

  Future<void> _tambahKategori(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Kategori dummy');
      final kategoriOp = ref.read(kategoriOpSqliteProvider);
      var successCount = 0;

      for (final data in DummyKategori.daftarKategori) {
        try {
          await kategoriOp.tambahKategori(data);
          successCount++;
        } catch (e) {
          Log.warning('Gagal insert kategori ${data.nama}: $e');
        }
      }

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan $successCount dari ${DummyKategori.daftarKategori.length} Kategori.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Kategori dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Kategori: $e');
      }
    }
  }

  Future<void> _tambahSubKategori(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Sub Kategori dummy');
      final subKategoriOp = ref.read(subKategoriOpSqliteProvider);
      var successCount = 0;

      for (final data in DummySubKategori.daftarSubKategori) {
        try {
          await subKategoriOp.createSubCategory(data);
          successCount++;
        } catch (e) {
          Log.warning('Gagal insert sub kategori ${data.nama}: $e');
        }
      }

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan $successCount dari ${DummySubKategori.daftarSubKategori.length} Sub Kategori.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Sub Kategori dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Sub Kategori: $e');
      }
    }
  }

  Future<void> _tambahPaket(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Paket dummy');
      final paketOp = ref.read(paketOpGlobalProvider);
      var successCount = 0;

      for (final data in DummyPaket.daftarPaket) {
        try {
          await paketOp.tambahPaket(data);
          successCount++;
        } catch (e) {
          Log.warning('Gagal insert paket ${data.nama}: $e');
        }
      }

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan $successCount dari ${DummyPaket.daftarPaket.length} Paket.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Paket dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Paket: $e');
      }
    }
  }

  Future<void> _tambahTransaksi(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Transaksi dummy');
      final transaksiOp = ref.read(transaksiOpGlobalProvider);
      var successCount = 0;

      for (final data in daftarTransaksi) {
        try {
          await transaksiOp.tambahTransaksi(data);
          successCount++;
        } catch (e) {
          Log.warning('Gagal insert transaksi ${data.id}: $e');
        }
      }

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan $successCount dari ${daftarTransaksi.length} Transaksi.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Transaksi dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Transaksi: $e');
      }
    }
  }

  // ============================================================
  // FUNGSI TAMBAH INVESTASI
  // ============================================================

  Future<void> _tambahInvestasi(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Investasi dummy');
      final investasiOp = InvestasiOpSqlite(
        sqliteDb: ref.read(sqliteDatabaseProvider),
        baseOpSqlite: ref.read(baseOpSqliteProvider),
      );
      var successCount = 0;

      for (final data in daftarInvestasi) {
        try {
          await investasiOp.tambahInvestasi(data);
          successCount++;
        } catch (e) {
          Log.warning('Gagal insert investasi ${data.id}: $e');
        }
      }

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan $successCount dari ${daftarInvestasi.length} Investasi.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Investasi dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Investasi: $e');
      }
    }
  }

  // ============================================================
  // FUNGSI TAMBAH DIVIDEN
  // ============================================================

  Future<void> _tambahDividen(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Dividen dummy');
      final investasiOp = InvestasiOpSqlite(
        sqliteDb: ref.read(sqliteDatabaseProvider),
        baseOpSqlite: ref.read(baseOpSqliteProvider),
      );
      var successCount = 0;

      for (final data in daftarDividen) {
        try {
          await investasiOp.tambahDividen(data);
          successCount++;
        } catch (e) {
          Log.warning('Gagal insert dividen ${data.id}: $e');
        }
      }

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan $successCount dari ${daftarDividen.length} Dividen.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Dividen dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Dividen: $e');
      }
    }
  }

  // ============================================================
  // FUNGSI TAMBAH PENGATURAN
  // ============================================================

  Future<void> _tambahPengaturan(WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan data Pengaturan dummy');
      final settingsOp = ref.read(settingsOpSqliteProvider);
      await settingsOp.simpanAtauPerbaruiSettings(const SettingsModel());

      if (ref.context.mounted) {
        ToastUtil.success(
          ref.context,
          'Berhasil menambahkan data Pengaturan dummy.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menambahkan Pengaturan dummy', e: e, s: s);
      if (ref.context.mounted) {
        ToastUtil.error(ref.context, 'Gagal menambah Pengaturan: $e');
      }
    }
  }

  // ============================================================
  // TAMBAH SEMUA DATA
  // ============================================================

  Future<void> _tambahSemuaData(BuildContext context, WidgetRef ref) async {
    try {
      Log.info('Memulai proses penambahan SEMUA data dummy');

      // 1. Pelanggan
      final pelangganOp = ref.read(pelangganOpGlobalProvider);
      for (final data in daftarPelanggan) {
        await pelangganOp.tambahPelanggan(data);
      }
      Log.info('✅ Pelanggan: ${daftarPelanggan.length} data');

      // 2. Dompet
      final dompetOp = ref.read(dompetOpSqliteProvider);
      for (final data in DummyDompet.daftarDompet) {
        await dompetOp.tambahDompet(data);
      }
      Log.info('✅ Dompet: ${DummyDompet.daftarDompet.length} data');

      // 3. Kategori
      final kategoriOp = ref.read(kategoriOpSqliteProvider);
      for (final data in DummyKategori.daftarKategori) {
        await kategoriOp.tambahKategori(data);
      }
      Log.info('✅ Kategori: ${DummyKategori.daftarKategori.length} data');

      // 4. Sub Kategori
      final subKategoriOp = ref.read(subKategoriOpSqliteProvider);
      for (final data in DummySubKategori.daftarSubKategori) {
        await subKategoriOp.createSubCategory(data);
      }
      Log.info(
        '✅ Sub Kategori: ${DummySubKategori.daftarSubKategori.length} data',
      );

      // 5. Paket
      final paketOp = ref.read(paketOpGlobalProvider);
      for (final data in DummyPaket.daftarPaket) {
        await paketOp.tambahPaket(data);
      }
      Log.info('✅ Paket: ${DummyPaket.daftarPaket.length} data');

      // 6. Transaksi
      final transaksiOp = ref.read(transaksiOpGlobalProvider);
      for (final data in daftarTransaksi) {
        await transaksiOp.tambahTransaksi(data);
      }
      Log.info('✅ Transaksi: ${daftarTransaksi.length} data');

      // 7. Investasi
      final investasiOp = InvestasiOpSqlite(
        sqliteDb: ref.read(sqliteDatabaseProvider),
        baseOpSqlite: ref.read(baseOpSqliteProvider),
      );
      for (final data in daftarInvestasi) {
        await investasiOp.tambahInvestasi(data);
      }
      Log.info('✅ Investasi: ${daftarInvestasi.length} data');

      // 8. Dividen
      for (final data in daftarDividen) {
        await investasiOp.tambahDividen(data);
      }
      Log.info('✅ Dividen: ${daftarDividen.length} data');

      // 9. Pengaturan
      final settingsOp = ref.read(settingsOpSqliteProvider);
      await settingsOp.simpanAtauPerbaruiSettings(const SettingsModel());
      Log.info('✅ Pengaturan: 1 data');

      // Invalidate provider
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
                Text('• ${daftarInvestasi.length} Investasi'),
                Text('• ${daftarDividen.length} Dividen'),
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