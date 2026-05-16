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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/theme/app_colors.dart';
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
  /// Service untuk mengakses penyimpanan lokal.
  final LocalStorageService? localStorageService;

  /// Builder untuk membuat halaman utama setelah login berhasil.
  final MainPageBuilder? mainPageBuilder;

  /// Membuat instance dari [AccountListPage].
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
      setState(() {
        _accountListFuture = _localStorageService.getAccountList();
      });
    }
  }

  Future<void> _selectAccount(final CustomerModel customer) async {
    if (!_isLocalStorageInitialized) return;
    final navigator = Navigator.of(context);
    await _localStorageService.saveAccount(customer);

    if (!mounted) return;
    final page = widget.mainPageBuilder != null
        ? widget.mainPageBuilder!(customer.id, _localStorageService)
        : MainPage(
            userId: customer.id,
            localStorageService: _localStorageService,
          );

    await navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (final context) => page),
    );
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
                final pageContext = context;

                if (!_isLocalStorageInitialized) return;
                final currentAccount =
                    await _localStorageService.getCurrentAccount();

                if (!dialogContext.mounted) return;
                if (currentAccount?.id == customer.id) {
                  dialogNavigator.pop();

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
                              final navigator = Navigator.of(context);

                              await _localStorageService
                                  .deleteAccount(customer.id);
                              await _localStorageService.deleteCurrentAccount();

                              if (!context.mounted) return;

                              await navigator.pushNamedAndRemoveUntil(
                                '/login',
                                (final route) => false,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  await _localStorageService.deleteAccount(customer.id);
                  dialogNavigator.pop();
                  _loadAccountList();
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
              final account = await _localStorageService.getCurrentAccount();
              if (account != null) {
                await _localStorageService.deleteAccount(account.id);
              }
              await _localStorageService.deleteCurrentAccount();
              await navigator.pushNamedAndRemoveUntil(
                '/login',
                (final route) => false,
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.errorColor.withAlpha(25),
              foregroundColor: AppColors.textOnDark,
            ),
            child: const Text('Keluar/Hapus Akun'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.errorColor.withAlpha(25),
              foregroundColor: AppColors.textOnDark,
            ),
            onPressed: () async {
              final pageNavigator = Navigator.of(context);
              Navigator.of(dialogContext).pop();

              if (!_isLocalStorageInitialized) return;

              await _localStorageService.deleteLoginToken();
              Log.info('Token login berhasil dihapus');

              if (!context.mounted) return;

              await pageNavigator.pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (final context) => const LoginPage(),
                ),
                (final route) => false,
              );
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
                  return Center(child: Text('Error: ${snapshot.error}'));
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
