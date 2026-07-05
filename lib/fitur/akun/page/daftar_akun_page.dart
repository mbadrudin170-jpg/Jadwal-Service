// path: lib/fitur/akun/page/daftar_akun_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_provider.dart';

class DaftarAkunPage extends ConsumerWidget {
  const DaftarAkunPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pengelolaAkun = ref.watch(pengelolaAkunProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Akun Tersimpan')),
      body: Column(
        children: [
          Expanded(
            child: pengelolaAkun.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Gagal memuat akun: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (data) {
                final daftarAkun = data.daftarAkunTersimpan;
                if (daftarAkun.isEmpty) {
                  return const Center(
                    child: Text('Belum ada riwayat login di perangkat ini.'),
                  );
                }
                return ListView.builder(
                  itemCount: daftarAkun.length,
                  itemBuilder: (context, index) {
                    final akun = daftarAkun[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(akun.nama.isNotEmpty ? akun.nama[0] : ''),
                        ),
                        title: Text(akun.nama),
                        onTap: () async {
                          if (!context.mounted) return;
                          await _pilihAkun(context, ref, akun);
                        },
                        onLongPress: () =>
                            _tampilkanDialogHapus(context, ref, akun),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _tampilkanDialogKeluar(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.errorColor.withAlpha(200),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(TIcons.logout, size: 20, color: Colors.white),
                    gapW8,
                    Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pilihAkun(
    BuildContext context,
    WidgetRef ref,
    PelangganModel pelanggan,
  ) async {
    final navigator = Navigator.of(context);
    try {
      await ref.read(pengelolaAkunProvider.notifier).login(pelanggan);
      final activityService = await ref.read(
        layananAktivitasUserProvider.future,
      );
      ref.invalidate(transaksiOpProvider);
      Log.info('Mulai memilih akun', {
        'customer_id': pelanggan.id,
        'nama': pelanggan.nama,
      });
      unawaited(activityService.pingAktivitas(pelanggan.id, paksa: true));
      if (!context.mounted) return;
      await navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (context) => const MainPage()),
        (route) => false,
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menyimpan akun yang dipilih',
        e: e,
        s: st,
        data: {'customer_id': pelanggan.id},
      );
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal memilih akun', logData: e.toString());
      }
    }
  }

  Future<void> _tampilkanDialogHapus(
    BuildContext context,
    WidgetRef ref,
    PelangganModel customer,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: Text('Anda yakin ingin menghapus akun ${customer.nama}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () async {
              try {
                final akunLogin = await ref.read(userIdProvider.future);
                if (!context.mounted) return;
                Navigator.of(dialogContext).pop();
                if (akunLogin == customer.id) {
                  await _tanganiHapusAkunAktif(context, ref, customer);
                } else {
                  Log.info('Menghapus akun tersimpan', {
                    'customer_id': customer.id,
                    'nama': customer.nama,
                  });
                  await ref
                      .read(pengelolaAkunProvider.notifier)
                      .hapusAkun(customer.id);
                  if (!context.mounted) return;
                  ToastUtil.success(context, 'Akun berhasil dihapus');
                }
              } catch (e, st) {
                Log.error(
                  'Gagal menghapus akun',
                  e: e,
                  s: st,
                  data: {'customer_id': customer.id},
                );
                if (context.mounted) {
                  ToastUtil.error(
                    context,
                    'Gagal menghapus akun',
                    logData: e.toString(),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _tanganiHapusAkunAktif(
    BuildContext context,
    WidgetRef ref,
    PelangganModel pelanggan,
  ) async {
    Log.info('akun yang di hapus ternyata akun yang sedang login', {
      'customer_id': pelanggan.id,
      'nama': pelanggan.nama,
    });
    await ref.read(pengelolaAkunProvider.notifier).hapusAkun(pelanggan.id);
    if (!context.mounted) return;
    ToastUtil.success(context, 'Akun berhasil dihapus, silakan login ulang');
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _tampilkanDialogKeluar(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Pilih metode keluar:'),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final dialogNavigator = Navigator.of(dialogContext);
              try {
                final penyimpananLokal = await ref.read(
                  layananPenyimpananLokalProvider.future,
                );
                Log.info('Keluar & hapus akun yang sedang digunakan');
                final akun = await penyimpananLokal.ambilAkunLogin();
                if (akun != null) {
                  await ref
                      .read(pengelolaAkunProvider.notifier)
                      .hapusAkun(akun.id);
                }
                if (dialogNavigator.context.mounted) {
                  dialogNavigator.pop();
                }
                await Future<void>.delayed(Duration.zero);
                if (!context.mounted) return;
                ToastUtil.success(
                  context,
                  'Anda telah keluar dan akun dihapus',
                );
                await navigator.pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              } on Exception catch (e, st) {
                Log.error('Gagal keluar & hapus akun', e: e, s: st);
                if (context.mounted) {
                  ToastUtil.error(
                    context,
                    'Gagal keluar',
                    logData: e.toString(),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: TColors.errorColor,
              foregroundColor: TColors.textOnDark,
            ),
            child: const Text('Keluar & Hapus Akun'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: TColors.errorColor,
              foregroundColor: TColors.textOnDark,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final dialogNavigator = Navigator.of(dialogContext);
              try {
                await ref
                    .read(pengelolaAkunProvider.notifier)
                    .hapusTokenLogin();

                if (dialogNavigator.context.mounted) {
                  dialogNavigator.pop();
                }
                await Future<void>.delayed(Duration.zero);
                if (!context.mounted) return;
                ToastUtil.success(context, 'Token berhasil dihapus');
                await navigator.pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              } catch (e, st) {
                Log.error('Gagal menghapus token login', e: e, s: st);
                if (context.mounted) {
                  ToastUtil.error(
                    context,
                    'Gagal keluar',
                    logData: e.toString(),
                  );
                }
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
