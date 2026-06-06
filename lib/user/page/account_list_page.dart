// path: lib/user/page/account_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/account_list_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

class AccountListPage extends ConsumerWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);
    // Tonton juga localStorageServiceProvider untuk menangani state loading awalnya
    final storageAsync = ref.watch(localStorageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pilih Akun Tersimpan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: accountsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Gagal memuat akun: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (accountList) {
                if (accountList.isEmpty) {
                  return const Center(
                    child: Text('Belum ada riwayat login di perangkat ini.'),
                  );
                }
                return ListView.builder(
                  itemCount: accountList.length,
                  itemBuilder: (context, index) {
                    final account = accountList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                              account.name.isNotEmpty ? account.name[0] : ''),
                        ),
                        title: Text(account.name),
                        onTap: () => _selectAccount(context, ref, account),
                        onLongPress: () =>
                            _showDeleteDialog(context, ref, account),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Gunakan .when dari storage untuk mengaktifkan tombol hanya saat service siap
          storageAsync.when(
            data: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showExitDialog(context, ref),
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
                      Icon(Icons.logout, size: 20, color: Colors.white),
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
            // Saat loading atau error, tampilkan tombol yang dinonaktifkan
            loading: () => const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: SizedBox(
                  width: double.infinity,
                  child:
                      ElevatedButton(onPressed: null, child: Text('Keluar'))),
            ),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectAccount(
      BuildContext context, WidgetRef ref, CustomerModel customer) async {
    final navigator = Navigator.of(context);
    try {
      final storage = await ref.read(localStorageServiceProvider.future);
      final activityService = await ref.read(userActivityServiceProvider.future);

      Log.info('Mulai memilih akun',
          {'customer_id': customer.id, 'nama': customer.name});
      await storage.saveCurrentAccount(customer);
      await activityService.pingActivity(customer.id, force: true);

      await navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (context) => const MainPage()),
        (route) => false,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal menyimpan akun yang dipilih',
          e: e, st: st, data: {'customer_id': customer.id});
      ToastUtil.error(context, 'Gagal memilih akun', logData: e.toString());
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, CustomerModel customer) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: Text('Anda yakin ingin menghapus akun ${customer.name}?'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal')),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Tutup dialog
              try {
                final storage =
                    await ref.read(localStorageServiceProvider.future);
                final currentAccount = await storage.getUserIdLogin();

                if (currentAccount?.id == customer.id) {
                  await _handleDeleteActiveAccount(
                      context, ref, customer, storage);
                } else {
                  Log.info('Menghapus akun tersimpan',
                      {'customer_id': customer.id, 'nama': customer.name});
                  await storage.deleteAccount(customer.id);
                  ref.invalidate(accountListProvider);
                  ToastUtil.success(context, 'Akun berhasil dihapus');
                }
              } on Exception catch (e, st) {
                Log.error('Gagal menghapus akun',
                    e: e, st: st, data: {'customer_id': customer.id});
                ToastUtil.error(context, 'Gagal menghapus akun',
                    logData: e.toString());
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteActiveAccount(BuildContext context, WidgetRef ref,
      CustomerModel customer, LocalStorageService storage) async {
    final navigator = Navigator.of(context);
    Log.info('Menghapus akun aktif & keluar',
        {'customer_id': customer.id, 'nama': customer.name});
    await storage.deleteAccount(customer.id);
    await storage.deleteCurrentAccount();

    ToastUtil.success(
        navigator.context, 'Akun berhasil dihapus, silakan login ulang');

    await navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _showExitDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Pilih metode keluar:'),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              try {
                final storage =
                    await ref.read(localStorageServiceProvider.future);
                Log.info('Keluar & hapus akun yang sedang digunakan');
                final account = await storage.getUserIdLogin();
                if (account != null) {
                  await storage.deleteAccount(account.id);
                }
                await storage.deleteCurrentAccount();
                ref.invalidate(accountListProvider);

                ToastUtil.success(
                    context, 'Anda telah keluar dan akun dihapus');
                await navigator.pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                      builder: (context) => const LoginPage()),
                  (route) => false,
                );
              } on Exception catch (e, st) {
                Log.error('Gagal keluar & hapus akun', e: e, st: st);
                ToastUtil.error(context, 'Gagal keluar', logData: e.toString());
              }
            },
            style: TextButton.styleFrom(
                backgroundColor: TColors.errorColor,
                foregroundColor: TColors.textOnDark),
            child: const Text('Keluar/Hapus Akun'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: TColors.errorColor,
                foregroundColor: TColors.textOnDark),
            onPressed: () async {
              final navigator = Navigator.of(context);
              try {
                final storage =
                    await ref.read(localStorageServiceProvider.future);
                Log.info('Mulai proses logout (hapus token)');
                await storage.deleteLoginToken();

                ToastUtil.success(context, 'Token berhasil dihapus');
                await navigator.pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                      builder: (context) => const LoginPage()),
                  (route) => false,
                );
              } on Exception catch (e, st) {
                Log.error('Gagal menghapus token login', e: e, st: st);
                ToastUtil.error(context, 'Gagal keluar', logData: e.toString());
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
