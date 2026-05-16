// path: lib/admin/halaman/lainnya/customer.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman dalam navigasi admin (tab Pelanggan).
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/detail_pelanggan.dart (DetailPelangganPage)
//   - lib/admin/halaman/form/customer_form.dart (CustomerForm)
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/customer_detail.dart';
import 'package:wifi/admin/halaman/form/customer_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Enum untuk menentukan opsi pengurutan daftar customer.
enum SortOption {
  /// Urutkan berdasarkan nama dari A hingga Z.
  nameAZ,

  /// Urutkan berdasarkan nama dari Z hingga A.
  nameZA,
}

/// Halaman untuk menampilkan dan mengelola daftar semua customer.
///
/// Admin dapat mencari, mengurutkan, menambah, mengedit, dan mengarsipkan customer.
class CustomerPage extends StatefulWidget {
  /// Membuat instance dari [CustomerPage].
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final CustomerOperation _customerOperation = CustomerOperation();

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = true;

  SortOption _activeSort = SortOption.nameAZ;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Menginisialisasi state untuk CustomerPage. Memanggil _refreshCustomerList untuk pertama kali.',
    );
    unawaited(_refreshCustomerList());
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    Log.info(
      'Membersihkan resource di CustomerPage. _searchController di-dispose.',
    );
    _searchController.dispose();
    super.dispose();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari nama customer...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            )
          : const Text('Daftar Pelanggan'),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: 'Urutkan',
          onPressed: _showSortDialog,
        ),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            Log.info(
              'Tombol search/close ditekan. Mengubah state _isSearching.',
            );
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                Log.info(
                  'Mode pencarian dinonaktifkan. Membersihkan search controller.',
                );
                _searchController.clear();
              } else {
                Log.info('Mode pencarian diaktifkan.');
              }
            });
          },
        ),
      ],
    );
  }

  Future<void> _showSortDialog() async {
    Log.info('Menampilkan dialog opsi pengurutan.');
    final SortOption? result = await showDialog<SortOption>(
      context: context,
      builder: (final BuildContext context) {
        Widget buildOption(final String text, final SortOption value) {
          final bool isSelected = _activeSort == value;
          return SimpleDialogOption(
            onPressed: () {
              Log.info(
                'User memilih opsi urutkan: ${value.name} (${isSelected ? "sudah aktif" : "berubah"} dari ${_activeSort.name})',
              );
              Navigator.pop(context, value);
            },
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Nama (A-Z)', SortOption.nameAZ),
            buildOption('Nama (Z-A)', SortOption.nameZA),
          ],
        );
      },
    );

    if (result != null && result != _activeSort) {
      _applySort(result);
    }
  }

  void _applySort(final SortOption option) {
    Log.info('Menerapkan pengurutan: $option');
    setState(() {
      _activeSort = option;
      switch (option) {
        case SortOption.nameAZ:
          _filteredCustomers.sort(
            (final a, final b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          break;
        case SortOption.nameZA:
          _filteredCustomers.sort(
            (final a, final b) =>
                b.name.toLowerCase().compareTo(a.name.toLowerCase()),
          );
          break;
      }
    });
  }

  Future<void> _refreshCustomerList() async {
    Log.info(
      'Memulai proses refresh daftar customer. Mengatur _isLoading ke true.',
    );
    if (mounted) setState(() => _isLoading = true);

    try {
      final list = await _customerOperation.getCustomers();
      Log.info('Berhasil mengambil ${list.length} data customer.');

      if (mounted) {
        setState(() {
          _allCustomers = list;
          _filteredCustomers = list;
          _applySort(_activeSort);
          _isLoading = false;
          Log.info(
            'State diperbarui dengan daftar pelanggan yang baru. _isLoading diatur ke false.',
          );
        });
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal total saat memuat daftar customer.',
        e: e,
        st: s,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarUtil.error(
            context, 'Gagal memuat data customer. Silakan coba lagi.');
      }
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    Log.info(
      'Listener _searchController aktif. Memfilter daftar dengan query: "$query".',
    );

    setState(() {
      _filteredCustomers = _allCustomers
          .where((final c) => c.name.toLowerCase().contains(query))
          .toList();
      _applySort(_activeSort);
      Log.info(
        'Filter selesai. Ditemukan ${_filteredCustomers.length} pelanggan yang cocok.',
      );
    });
  }

  Future<void> _addCustomer() async {
    Log.info(
      'Tombol FAB (+) ditekan. Menavigasi ke CustomerForm untuk menambah data baru.',
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (final context) => const CustomerForm()),
    );
    if (result ?? false) {
      Log.info(
        'Kembali dari CustomerForm dengan hasil sukses (true). Memanggil _refreshCustomerList untuk memuat ulang data.',
      );
      await _refreshCustomerList();
    } else {
      Log.info(
        'Kembali dari CustomerForm tanpa hasil (false atau null). Tidak ada aksi yang diambil.',
      );
    }
  }

  Future<void> _showOptionsDialog(final CustomerModel customer) async {
    Log.info(
      'Menampilkan dialog opsi (Edit/Arsipkan) untuk pelanggan: ${customer.name} (ID: ${customer.id}).',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
        return AlertDialog(
          title: Text(customer.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Pelanggan'),
                onTap: () async {
                  Log.info(
                    'Opsi "Edit Pelanggan" dipilih. Menutup dialog dan menavigasi ke CustomerForm dengan data yang ada.',
                  );
                  Navigator.of(dialogContext).pop();
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (final context) =>
                          CustomerForm(customer: customer),
                    ),
                  );
                  await _refreshCustomerList();
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Arsipkan Pelanggan'),
                onTap: () async {
                  Log.info(
                    'Opsi "Arsipkan Pelanggan" dipilih. Menutup dialog dan memanggil _showArchiveDialog.',
                  );
                  Navigator.of(dialogContext).pop();
                  await _showArchiveDialog(customer);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showArchiveDialog(final CustomerModel customer) async {
    Log.info(
      'Menampilkan dialog konfirmasi pengarsipan untuk pelanggan "${customer.name}".',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan pelanggan "${customer.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Pengguna membatalkan proses pengarsipan.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Arsipkan',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Log.info(
                  'Pengguna mengonfirmasi pengarsipan. Memanggil _archiveCustomer dengan ID: ${customer.id}.',
                );
                Navigator.of(context).pop();
                await _archiveCustomer(customer.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _archiveCustomer(final String id) async {
    Log.info('Memulai proses pengarsipan untuk ID pelanggan: $id.');
    try {
      await _customerOperation.archiveCustomer(id);
      Log.info(
        'Berhasil mengarsipkan pelanggan dengan ID: $id. Memuat ulang daftar dan menampilkan SnackBar.',
      );
      await _refreshCustomerList();
      if (mounted) {
        SnackBarUtil.success(context, 'Pelanggan berhasil diarsipkan.');
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengarsipkan pelanggan dengan ID: $id.',
        e: e,
        st: s,
      );
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal mengarsipkan customer.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI CustomerPage. Status loading: $_isLoading.');
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshCustomerList,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredCustomers.isEmpty) {
      Log.info('Membangun UI content: Daftar pelanggan kosong.');
      return Center(
        child: Text(
          _isSearching
              ? 'Pelanggan tidak ditemukan untuk pencarian ini.'
              : 'Belum ada customer. Tekan tombol + untuk menambah.',
          textAlign: TextAlign.center,
        ),
      );
    }

    Log.info(
      'Membangun UI content: Menampilkan ListView dengan ${_filteredCustomers.length} customer.',
    );
    return ListView.builder(
      itemCount: _filteredCustomers.length,
      itemBuilder: (final context, final index) {
        final customer = _filteredCustomers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              customer.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(customer.macAddress),
            onTap: () async {
              Log.info(
                'ListTile untuk pelanggan "${customer.name}" ditekan. Menavigasi ke DetailPelangganPage.',
              );
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (final context) =>
                      CustomerDetailPage(customerId: customer.id),
                ),
              );
              await _refreshCustomerList();
            },
            onLongPress: () async {
              Log.info(
                'ListTile untuk pelanggan "${customer.name}" ditekan lama (long press). Memanggil _showOptionsDialog.',
              );
              await _showOptionsDialog(customer);
            },
          ),
        );
      },
    );
  }
}
