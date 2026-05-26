// path: lib/user/page/account_list_page.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman daftar akun untuk user.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/theme/app_colors.dart (AppColors)
//   - lib/user/page/login_page.dart (LoginPage)
//   - lib/user/page/main_page.dart (MainPage)
//   - lib/user/services/storage/local_storage_service.dart (LocalStorageService)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/toast_util.dart (ToastUtil)
//   - lib/shared/services/user_activity_service.dart (UserActivityService) // DITAMBAHKAN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/services/user_activity_service.dart'; // DITAMBAHKAN
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Typedef untuk membangun halaman utama.
typedef MainPageBuilder = Widget Function(
  String userId,
  LocalStorageService localStorageService,
);

/// Halaman untuk menampilkan daftar akun yang pernah login di perangkat.
class AccountListPage extends StatefulWidget {
  /// Layanan opsional untuk mengakses penyimpanan lokal.
  /// Digunakan untuk injeksi dependensi, terutama saat testing.
  final LocalStorageService? localStorageService;

  /// Builder opsional untuk membuat halaman utama setelah login berhasil.
  /// Digunakan untuk injeksi dependensi dan kustomisasi navigasi.
  final MainPageBuilder? mainPageBuilder;

  /// {@template account_list_page}
  /// Membuat instance [AccountListPage].
  /// {@endtemplate}
  const AccountListPage({
    super.key,
    this.localStorageService,
    this.mainPageBuilder,
  });

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  late Future<List<CustomerModel>> _accountListFuture;
  late LocalStorageService _localStorageService;
  bool _isLocalStorageInitialized = false;
  final UserActivityService _activityService =
      UserActivityService(); // DITAMBAHKAN

  @override
  void initState() {
    super.initState();
    unawaited(_initializeLocalStorage());
  }

  Future<void> _initializeLocalStorage() async {
    if (widget.localStorageService != null) {
      _localStorageService = widget.localStorageService!;
      if (mounted) {
        setState(() => _isLocalStorageInitialized = true);
      }
      _loadAccountList();
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _localStorageService = LocalStorageService(prefs: prefs);
          _isLocalStorageInitialized = true;
        });
        _loadAccountList();
      }
    }
  }

  void _loadAccountList() {
    if (_isLocalStorageInitialized && mounted) {
      Log.info('Memulai pengambilan daftar akun');
      setState(() {
        _accountListFuture = _fetchAccountList();
      });
    }
  }

  Future<List<CustomerModel>> _fetchAccountList() async {
    try {
      final list = await _localStorageService.getAccountList();
      Log.info('Daftar akun berhasil dimuat', {'jumlah_akun': list.length});
      return list;
    } on Exception catch (e, st) {
      Log.error('Gagal memuat daftar akun', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat daftar akun',
            logData: e.toString());
      }
      rethrow;
    }
  }

  Future<void> _selectAccount(final CustomerModel customer) async {
    if (!_isLocalStorageInitialized) return;

    Log.info('Mulai memilih akun', {
      'customer_id': customer.id,
      'nama': customer.name,
    });

    final navigator = Navigator.of(context);
    try {
      await _localStorageService.saveCurrentAccount(customer);
      unawaited(
        _activityService.pingActivity(customer.id, force: true),
      );
      Log.info(
          'set waktu terakhir user aktif ', {'customer.id, customer.name'});
      if (!mounted) return;
      final page = widget.mainPageBuilder != null
          ? widget.mainPageBuilder!(customer.id, _localStorageService)
          : MainPage(
              userId: customer.id,
              localStorageService: _localStorageService,
            );

      // PERBAIKAN: Menggunakan pushAndRemoveUntil untuk memastikan tumpukan navigasi bersih.
      // Ini akan menghapus semua halaman sebelumnya dan menjadikan MainPage sebagai root baru,
      // sehingga mencegah state ganda dan memastikan banner iklan dimuat ulang dengan benar.
      await navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (final context) => page),
        (final route) => false,
      );

      // Toast tidak dapat ditampilkan setelah navigasi pushAndRemoveUntil karena context lama tidak valid.
      // Notifikasi keberhasilan login seharusnya ditangani di halaman tujuan jika diperlukan.
    } on Exception catch (e, st) {
      Log.error('Gagal menyimpan akun yang dipilih',
          e: e, st: st, data: {'customer_id': customer.id});
      if (mounted) {
        ToastUtil.error(context, 'Gagal memilih akun, silakan coba lagi',
            logData: e.toString());
      }
    }
  }

  Future<void> _showDeleteDialog(
    final BuildContext context,
    final CustomerModel customer,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Akun'),
          content: Text('Anda yakin ingin menghapus akun ${customer.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () async {
                final dialogNavigator = Navigator.of(dialogContext);
                final pageContext = context; // simpan referensi halaman utama

                if (!_isLocalStorageInitialized) return;

                try {
                  final currentAccount =
                      await _localStorageService.getCurrentAccount();

                  if (!dialogContext.mounted) return;

                  if (currentAccount?.id == customer.id) {
                    // Tutup dialog hapus dulu
                    dialogNavigator.pop();

                    // Konfirmasi kedua
                    await showDialog<void>(
                      context: pageContext,
                      builder: (final BuildContext confirmDialogContext) {
                        return AlertDialog(
                          title: const Text('Konfirmasi Hapus'),
                          content: const Text(
                            'Ini adalah akun yang sedang Anda gunakan. Anda akan keluar dan perlu login kembali. Lanjutkan?',
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Batal'),
                              onPressed: () =>
                                  Navigator.of(confirmDialogContext).pop(),
                            ),
                            TextButton(
                              child: const Text(
                                'Hapus & Keluar',
                                style: TextStyle(color: AppColors.errorColor),
                              ),
                              onPressed: () async {
                                final navigator =
                                    Navigator.of(pageContext); // bukan context

                                try {
                                  Log.info('Menghapus akun aktif & keluar', {
                                    'customer_id': customer.id,
                                    'nama': customer.name,
                                  });

                                  await _localStorageService
                                      .deleteAccount(customer.id);
                                  await _localStorageService
                                      .deleteCurrentAccount();

                                  if (!pageContext.mounted) return;

                                  ToastUtil.success(pageContext,
                                      'Akun berhasil dihapus, silakan login ulang');

                                  await navigator.pushAndRemoveUntil(
                                    MaterialPageRoute<void>(
                                      builder: (final context) =>
                                          const LoginPage(),
                                    ),
                                    (final route) => false,
                                  );
                                } on Exception catch (e, st) {
                                  Log.error('Gagal menghapus akun aktif',
                                      e: e,
                                      st: st,
                                      data: {'customer_id': customer.id});
                                  if (pageContext.mounted) {
                                    ToastUtil.error(
                                        pageContext, 'Gagal menghapus akun',
                                        logData: e.toString());
                                  }
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Hapus akun biasa
                    Log.info('Menghapus akun tersimpan', {
                      'customer_id': customer.id,
                      'nama': customer.name,
                    });

                    await _localStorageService.deleteAccount(customer.id);

                    dialogNavigator.pop();
                    _loadAccountList();

                    if (pageContext.mounted) {
                      ToastUtil.success(pageContext, 'Akun berhasil dihapus');
                    }
                  }
                } on Exception catch (e, st) {
                  Log.error('Gagal menghapus akun',
                      e: e, st: st, data: {'customer_id': customer.id});
                  if (dialogContext.mounted) {
                    ToastUtil.error(dialogContext, 'Gagal menghapus akun',
                        logData: e.toString());
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExitDialog(final BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (final dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Pilih metode keluar:'),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              if (!_isLocalStorageInitialized) return;

              try {
                Log.info('Keluar & hapus akun yang sedang digunakan');

                final account = await _localStorageService.getCurrentAccount();
                if (account != null) {
                  await _localStorageService.deleteAccount(account.id);
                }
                await _localStorageService.deleteCurrentAccount();

                if (!context.mounted) return;

                ToastUtil.success(
                    context, 'Anda telah keluar dan akun dihapus');
                await navigator.pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (final context) => const LoginPage()),
                  (final route) => false,
                );
              } on Exception catch (e, st) {
                Log.error('Gagal keluar & hapus akun', e: e, st: st);
                if (context.mounted) {
                  ToastUtil.error(context, 'Gagal keluar',
                      logData: e.toString());
                }
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: AppColors.textOnDark,
            ),
            child: const Text('Keluar/Hapus Akun'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: AppColors.textOnDark,
            ),
            onPressed: () async {
              final pageNavigator = Navigator.of(context);
              Navigator.of(dialogContext).pop(); // tutup dialog

              if (!_isLocalStorageInitialized) return;

              try {
                Log.info('Mulai proses logout (hapus token)');
                await _localStorageService.deleteLoginToken();

                if (!context.mounted) return;

                ToastUtil.success(context, 'Token berhasil dihapus');

                await pageNavigator.pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (final context) => const LoginPage(),
                  ),
                  (final route) => false,
                );
              } on Exception catch (e, st) {
                Log.error('Gagal menghapus token login', e: e, st: st);
                if (context.mounted) {
                  ToastUtil.error(context, 'Gagal keluar, coba lagi',
                      logData: e.toString());
                }
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    if (!_isLocalStorageInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
            child: FutureBuilder<List<CustomerModel>>(
              future: _accountListFuture,
              builder: (final context, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final accountList = snapshot.data ?? [];
                if (snapshot.hasError) {
                  // Error sudah dilog & snackbar ditampilkan di _fetchAccountList,
                  // di sini hanya tampilkan widget fallback.
                  return Center(
                    child: Text(
                      'Gagal memuat akun: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (accountList.isEmpty) {
                  return const Center(
                    child: Text('Belum ada riwayat login di perangkat ini.'),
                  );
                }
                return ListView.builder(
                  itemCount: accountList.length,
                  itemBuilder: (final context, final index) {
                    final account = accountList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                              account.name.isNotEmpty ? account.name[0] : ''),
                        ),
                        title: Text(account.name),
                        onTap: () => _selectAccount(account),
                        onLongPress: () => _showDeleteDialog(context, account),
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
                onPressed: () => _showExitDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor.withAlpha(200),
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
                    SizedBox(width: 8),
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
}
