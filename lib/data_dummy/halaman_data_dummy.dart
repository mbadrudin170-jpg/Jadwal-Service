// path: lib/data_dummy/halaman_data_dummy.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/data_dummy/dummy_dividen.dart';
import 'package:wifi/data_dummy/dummy_dompet.dart';
import 'package:wifi/data_dummy/dummy_investasi.dart';
import 'package:wifi/data_dummy/dummy_kategori.dart';
import 'package:wifi/data_dummy/dummy_paket.dart';
import 'package:wifi/data_dummy/dummy_pelanggan.dart';
import 'package:wifi/data_dummy/dummy_sub_kategori.dart';
import 'package:wifi/data_dummy/dummy_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
// ❌ HAPUS import ini karena tidak digunakan
// import 'package:wifi/fitur/investasi/operasi/investasi_op_firebase.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_sqlite.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk menambahkan data dummy ke database lokal dan Firebase.
///
/// File ini digunakan oleh:
/// - lib/admin/halaman/tab/lainnya.dart (menu debug)
class HalamanDataDummy extends ConsumerStatefulWidget {
  const HalamanDataDummy({super.key});

  @override
  ConsumerState<HalamanDataDummy> createState() => _HalamanDataDummyState();
}

class _HalamanDataDummyState extends ConsumerState<HalamanDataDummy> {
  bool _menyimpan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Data Dummy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tombolFitur(
            context: context,
            onPressed: _menyimpan ? null : () => _tambahSemuaData(context, ref),
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
          // Tombol untuk mengunggah data ke Firebase
          _tombolFitur(
            context: context,
            onPressed: () async {
              await _unggahKeFirebase(ref);
            },
            label: '🔄 UNGGAH DATA KE FIREBASE',
            icon: TIcons.cloudUpload,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk membuat tombol fitur.
  Widget _tombolFitur({
    required BuildContext context,
    required VoidCallback? onPressed,
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
  // FUNGSI TAMBAH DATA PER TABEL
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
  // FUNGSI UNGGAH KE FIREBASE
  // ============================================================

  /// Mengunggah semua data dari SQLite ke Firebase.
  /// Fungsi ini memicu mekanisme sinkronisasi yang sudah ada.
  Future<void> _unggahKeFirebase(WidgetRef ref) async {
    if (_menyimpan) return;

    Log.info('Memulai proses unggah data dummy ke Firebase');

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Unggah'),
        content: const Text(
          'Anda yakin ingin mengunggah semua data dummy ke Firebase? '
          'Data yang sudah ada di Firebase akan ditimpa (merge).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Unggah'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) {
      Log.info('Pengguna membatalkan unggah data dummy');
      return;
    }

    setState(() {
      _menyimpan = true;
    });

    try {
      if (mounted) {
        unawaited(
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mengunggah data ke Firebase...'),
                ],
              ),
            ),
          ),
        );
      }

      // Panggil layanan sinkronisasi untuk mengunggah semua data
      await ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi();

      // Tutup loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      Log.info('Proses unggah data dummy ke Firebase selesai');

      if (mounted) {
        ToastUtil.success(
          context,
          '✅ Semua data dummy berhasil diunggah ke Firebase!',
          logData: 'Data berhasil disinkronkan ke cloud',
        );
      }
    } catch (e, s) {
      Log.error('Gagal mengunggah data dummy ke Firebase', e: e, s: s);

      // Tutup loading dialog jika masih terbuka
      if (mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }

      if (mounted) {
        ToastUtil.error(
          context,
          '❌ Gagal mengunggah data: ${e.toString()}',
          logData: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _menyimpan = false;
        });
      }
    }
  }

  // ============================================================
  // TAMBAH SEMUA DATA + UNGGAH KE FIREBASE (DENGAN FUTURE.WAIT)
  // ============================================================

  Future<void> _tambahSemuaData(BuildContext context, WidgetRef ref) async {
    if (_menyimpan) return;
    setState(() {
      _menyimpan = true;
    });

    try {
      Log.info(
        '🚀 Memulai proses penambahan SEMUA data dummy dengan Future.wait',
      );

      // Tampilkan dialog loading
      if (context.mounted) {
        unawaited(
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menambahkan semua data dummy...'),
                ],
              ),
            ),
          ),
        );
      }

      // Ambil semua provider yang dibutuhkan
      final pelangganOp = ref.read(pelangganOpGlobalProvider);
      final dompetOp = ref.read(dompetOpFirebaseProvider);
      final kategoriOp = ref.read(kategoriOpSqliteProvider);
      final subKategoriOp = ref.read(subKategoriOpSqliteProvider);
      final paketOp = ref.read(paketOpGlobalProvider);
      final transaksiOp = ref.read(transaksiOpGlobalProvider);
      final investasiOp = ref.read(investasiOpFirebaseProvider);
      final settingsOp = ref.read(settingsOpSqliteProvider);

      // ============================================================
      // 1. PROSES TAMBAH DATA MENGGUNAKAN FUTURE.WAIT
      // ============================================================

      // ✅ Perbaikan: Gunakan List<Future<void>> dengan tipe generik yang eksplisit
      final futureList = <Future<void>>[];

      // 1.1 Pelanggan
      Log.info('📦 Menyiapkan data Pelanggan: ${daftarPelanggan.length} item');
      for (final data in daftarPelanggan) {
        futureList.add(pelangganOp.tambahPelanggan(data));
      }

      // 1.2 Dompet
      Log.info(
        '📦 Menyiapkan data Dompet: ${DummyDompet.daftarDompet.length} item',
      );
      for (final data in DummyDompet.daftarDompet) {
        futureList.add(dompetOp.tambahDompet(data));
      }

      // 1.3 Kategori
      Log.info(
        '📦 Menyiapkan data Kategori: ${DummyKategori.daftarKategori.length} item',
      );
      for (final data in DummyKategori.daftarKategori) {
        futureList.add(kategoriOp.tambahKategori(data));
      }

      // 1.4 Sub Kategori
      Log.info(
        '📦 Menyiapkan data Sub Kategori: ${DummySubKategori.daftarSubKategori.length} item',
      );
      for (final data in DummySubKategori.daftarSubKategori) {
        futureList.add(subKategoriOp.createSubCategory(data));
      }

      // 1.5 Paket
      Log.info(
        '📦 Menyiapkan data Paket: ${DummyPaket.daftarPaket.length} item',
      );
      for (final data in DummyPaket.daftarPaket) {
        futureList.add(paketOp.tambahPaket(data));
      }

      // 1.6 Transaksi
      Log.info('📦 Menyiapkan data Transaksi: ${daftarTransaksi.length} item');
      for (final data in daftarTransaksi) {
        futureList.add(transaksiOp.tambahTransaksi(data));
      }

      // 1.7 Investasi
      Log.info('📦 Menyiapkan data Investasi: ${daftarInvestasi.length} item');
      for (final data in daftarInvestasi) {
        futureList.add(investasiOp.tambahInvestasi(data));
      }

      // 1.8 Dividen
      Log.info('📦 Menyiapkan data Dividen: ${daftarDividen.length} item');
      for (final data in daftarDividen) {
        futureList.add(investasiOp.tambahDividen(data));
      }

      // 1.9 Pengaturan
      Log.info('📦 Menyiapkan data Pengaturan: 1 item');
      futureList.add(
        settingsOp.simpanAtauPerbaruiSettings(const SettingsModel()),
      );

      // Eksekusi semua Future secara paralel
      Log.info('⚡ Menjalankan ${futureList.length} operasi secara paralel...');
      await Future.wait(futureList);

      Log.info('✅ Semua data dummy berhasil ditambahkan ke SQLite');

      // ============================================================
      // 2. UNGGAH SEMUA DATA KE FIREBASE
      // ============================================================

      Log.info('🚀 Memulai proses unggah data ke Firebase...');

      // Jalankan sinkronisasi
      await ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi();

      Log.info('✅ Semua data berhasil diunggah ke Firebase!');

      // Tutup loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // ============================================================
      // 3. INVALIDASI PROVIDER
      // ============================================================

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
      ref.invalidate(investasiOpFirebaseProvider);

      // ============================================================
      // 4. TAMPILKAN DIALOG SUKSES
      // ============================================================

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
                gapH16,
                const Text(
                  '✅ Data juga sudah diunggah ke Firebase!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

      // Tutup loading dialog jika masih terbuka
      if (context.mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }

      if (context.mounted) {
        ToastUtil.error(
          context,
          'Terjadi kesalahan saat menambah semua data: $e',
          logData: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _menyimpan = false;
        });
      }
    }
  }
}
