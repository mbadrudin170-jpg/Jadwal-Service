# 16 Mei 2026, 22:21

# customer
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
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
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
                      DetailPelangganPage(idPelanggan: customer.id),
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
# model
// path: lib/shared/export/model.dart
// Fitur: [Model Export]
// Tujuan: Mengekspor semua model dari satu file untuk impor yang lebih bersih.

export '../model/active_customer_model.dart';
export '../model/apk_version_model.dart';
export '../model/category_model.dart';
export '../model/customer_model.dart';
export '../model/feedback_model.dart';
export '../model/has_id.dart';
export '../model/order_model.dart';
export '../model/package_model.dart';
export '../model/save_result_model.dart';
export '../model/settings_model.dart';
export '../model/sub_category_model.dart';
export '../model/transaction_model.dart';
export '../model/upload_status_model.dart';
export '../model/wallet_model.dart';

# operasi
// path: lib/shared/export/operasi.dart

export 'package:wifi/shared/operasi/active_customer_operation.dart';
export 'package:wifi/shared/operasi/base_operation.dart';
export 'package:wifi/shared/operasi/category_operation.dart';
export 'package:wifi/shared/operasi/customer_operation.dart';
export 'package:wifi/shared/operasi/feedback_operation.dart';
export 'package:wifi/shared/operasi/package_operation.dart';
export 'package:wifi/shared/operasi/pembersihan_data_operasi.dart';
export 'package:wifi/shared/operasi/settings_operation.dart';
export 'package:wifi/shared/operasi/order_operation.dart';
export 'package:wifi/shared/operasi/riwayat_langganan_operasi.dart';
export 'package:wifi/shared/operasi/sub_category_operation.dart';
export 'package:wifi/shared/operasi/transaction_operation.dart';
export 'package:wifi/shared/operasi/upload_status_operasi.dart';
export 'package:wifi/shared/operasi/apk_version_operation.dart';
export 'package:wifi/shared/operasi/wallet_operation.dart';

# package
// path: lib/admin/halaman/lainnya/package.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/package_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';

/// Enum untuk menentukan kriteria pengurutan daftar paket.
enum UrutanPaket {
  /// Urutkan berdasarkan nama paket dari A hingga Z.
  namaAZ,

  /// Urutkan berdasarkan nama paket dari Z hingga A.
  namaZA,

  /// Urutkan berdasarkan harga paket dari yang tertinggi ke terendah.
  hargaTertinggi,

  /// Urutkan berdasarkan harga paket dari yang terendah ke tertinggi.
  hargaTerendah,

  /// Urutkan berdasarkan perolehan poin dari yang tertinggi ke terendah.
  poinTertinggi,

  /// Urutkan berdasarkan perolehan poin dari yang terendah ke tertinggi.
  poinTerendah,
}

/// Halaman untuk mengelola daftar paket internet.
///
/// Dari halaman ini, admin dapat melihat, menambah, mengubah,
/// menghapus, dan mengurutkan daftar paket yang ditawarkan.
class PackagePage extends StatefulWidget {
  /// Membuat instance dari [PackagePage].
  const PackagePage({super.key});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  final PackageOperation _paketOperasi = PackageOperation();
  late Future<List<PackageModel>> _paketFuture;
  // ditambah: Variabel untuk menyimpan status pengurutan saat ini, defaultnya A-Z.
  UrutanPaket _urutanSaatIni = UrutanPaket.namaAZ;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Paket');
    _refreshPaketList();
  }

  void _refreshPaketList() {
    Log.info('Memperbarui daftar paket dari database');
    setState(() {
      _paketFuture = _paketOperasi.getPackages();
    });
  }

  // ditambah: Fungsi untuk menampilkan dialog pilihan pengurutan.
  Future<void> _tampilkanDialogUrutkan() async {
    Log.info('Menampilkan dialog urutkan');
    final UrutanPaket? hasil = await showDialog<UrutanPaket>(
      context: context,
      builder: (final context) {
        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.namaAZ);
                Log.info('Mengurutkan berdasarkan: Nama (A-Z)');
              },
              child: const Text('Nama (A-Z)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.namaZA);
                Log.info('Mengurutkan berdasarkan: Nama (Z-A)');
              },
              child: const Text('Nama (Z-A)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.hargaTertinggi);
                Log.info('Mengurutkan berdasarkan: Harga (Tertinggi)');
              },
              child: const Text('Harga (Tertinggi)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.hargaTerendah);
                Log.info('Mengurutkan berdasarkan: Harga (Terendah)');
              },
              child: const Text('Harga (Terendah)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.poinTertinggi);
                Log.info('Mengurutkan berdasarkan: Poin (Tertinggi)');
              },
              child: const Text('Poin (Tertinggi)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, UrutanPaket.poinTerendah);
                Log.info('Mengurutkan berdasarkan: Poin (Terendah)');
              },
              child: const Text('Poin (Terendah)'),
            ),
          ],
        );
      },
    );

    if (hasil != null) {
      setState(() => _urutanSaatIni = hasil);
    }
  }

  Future<void> _showEditDeleteDialog(final PackageModel paket) async {
    Log.info('Menampilkan dialog opsi untuk paket: ${paket.name}');
    await showDialog<void>(
      context: context,
      builder: (final context) {
        return AlertDialog(
          title: Text(paket.name),
          content: const Text('Pilih aksi yang ingin Anda lakukan.'),
          actions: [
            TextButton(
              onPressed: () async {
                Log.info(
                  'Memilih navigasi ke Form Edit untuk paket: ${paket.name}',
                );
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (final context) => PackageForm(package: paket),
                  ),
                );
                Log.info('Kembali dari Form Edit, menyegarkan daftar paket');
                _refreshPaketList();
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Log.info('Memilih opsi Hapus untuk paket: ${paket.name}');
                Navigator.pop(context);
                unawaited(_showDeleteConfirmationDialog(paket));
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(final PackageModel paket) async {
    Log.info(
      'Menampilkan konfirmasi hapus untuk paket ID: ${paket.id}, nama: ${paket.name}',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus paket ${paket.name}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info(
                  'Penghapusan paket ${paket.name} dibatalkan oleh user',
                );
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();

                try {
                  Log.info(
                    'Menjalankan operasi hapus paket ID: ${paket.id}, nama: ${paket.name}',
                  );
                  await _paketOperasi.deletePackage(paket.id);
                  Log.info(
                    'Paket ID: ${paket.id} berhasil dihapus dari database',
                  );
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } on Exception catch (e, s) {
                  Log.error(
                    'Gagal menghapus paket ID: ${paket.id}, nama: ${paket.name}',
                    e: e,
                    st: s,
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus paket: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _hapusSemuaPaket() async {
    Log.info('User menekan tombol hapus semua paket');
    await showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Semua'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus SEMUA paket? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Penghapusan massal semua paket dibatalkan oleh user');
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus Semua'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();

                try {
                  Log.info(
                    'Menjalankan operasi hapus semua paket dari database',
                  );
                  await _paketOperasi.deleteAllPackages();
                  Log.info('Semua paket berhasil dihapus dari database');
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Semua paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } on Exception catch (e, s) {
                  Log.error(
                    'Gagal menghapus semua paket dari database',
                    e: e,
                    st: s,
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus semua paket: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman Daftar Paket');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket'),
        actions: [
          // diubah: IconButton untuk menampilkan dialog pengurutan.
          IconButton(
            onPressed: _tampilkanDialogUrutkan,
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
          ),
          IconButton(
            onPressed: _hapusSemuaPaket,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: FutureBuilder<List<PackageModel>>(
        future: _paketFuture,
        builder: (final context, final snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            Log.error(
              'Terjadi error saat memuat data paket',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info('Data paket kosong, tidak ada paket yang tersedia');
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }

          final paketList = List<PackageModel>.from(snapshot.data!);

          // ditambah: Logika untuk mengurutkan daftar paket berdasarkan _urutanSaatIni
          switch (_urutanSaatIni) {
            case UrutanPaket.namaAZ:
              paketList.sort(
                (final a, final b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
              break;
            case UrutanPaket.namaZA:
              paketList.sort(
                (final a, final b) =>
                    b.name.toLowerCase().compareTo(a.name.toLowerCase()),
              );
              break;
            case UrutanPaket.hargaTertinggi:
              paketList.sort((final a, final b) => b.price.compareTo(a.price));
              break;
            case UrutanPaket.hargaTerendah:
              paketList.sort((final a, final b) => a.price.compareTo(b.price));
              break;
            // diubah: Menggunakan rewardPoints untuk pengurutan
            case UrutanPaket.poinTertinggi:
              paketList.sort(
                  (final a, final b) => b.rewardPoints.compareTo(a.rewardPoints));
              break;
            case UrutanPaket.poinTerendah:
              paketList.sort(
                  (final a, final b) => a.rewardPoints.compareTo(b.rewardPoints));
              break;
          }

          Log.info(
            'Menampilkan ${paketList.length} paket dalam daftar, diurutkan berdasarkan $_urutanSaatIni',
          );

          return ListView.builder(
            itemCount: paketList.length,
            itemBuilder: (final context, final index) {
              final paket = paketList[index];
              return InkWell(
                onTap: () async {
                  Log.info(
                    'Navigasi ke halaman Detail Paket: ${paket.name} (ID: ${paket.id})',
                  );
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (final context) => PackageDetailPage(package: paket),
                    ),
                  );
                  Log.info(
                    'Kembali dari halaman Detail Paket, menyegarkan daftar',
                  );
                  _refreshPaketList();
                },
                onLongPress: () async {
                  Log.info(
                    'Long press pada paket: ${paket.name} (ID: ${paket.id}), menampilkan menu edit/hapus',
                  );
                  await _showEditDeleteDialog(paket);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      paket.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Rp ${paket.price} / ${paket.duration} ${paket.type.name}',
                    ),
                    // diubah: Menampilkan rewardPoints di trailing
                    trailing: Text('Poin: ${paket.rewardPoints}'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Log.info('Navigasi ke Form Tambah Paket');
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (final context) => const PackageForm()),
          );
          Log.info('Kembali dari Form Tambah Paket, menyegarkan daftar');
          _refreshPaketList();
        },
        tooltip: 'Tambah Paket',
        child: const Icon(Icons.add),
      ),
    );
  }
}

# package_activation_history
// path: lib/admin/halaman/lainnya/package_activation_history.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman dalam navigasi admin (tab Lainnya).
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/subscription_history_detail.dart (DetailLanggananTransaksiPage)
//   - lib/shared/widget/customer_name.dart (CustomerNameWidget)
//   - lib/shared/widget/package_name.dart (PackageNameWidget)
//   - lib/shared/enum/payment_status_enum.dart (PaymentStatus)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation) — untuk PackageNameWidget
//   - lib/shared/utils/format_util.dart (FormatUtil)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/subscription_history_detail.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/customer_name.dart';
import 'package:wifi/shared/widget/package_name.dart';

/// Enum untuk opsi pengurutan riwayat aktivasi paket.
enum SortOption {
  /// Urutkan berdasarkan paket yang akan berakhir hari ini.
  endingToday,

  /// Urutkan berdasarkan transaksi terbaru.
  newest,

  /// Urutkan berdasarkan transaksi terlama.
  oldest,

  /// Tampilkan transaksi lunas di bagian atas.
  paid,

  /// Tampilkan transaksi yang belum lunas di bagian atas.
  unpaid,
}

/// Halaman untuk menampilkan riwayat aktivasi paket langganan.
///
/// Admin dapat melihat, mengurutkan, dan membuka detail setiap transaksi
/// aktivasi paket yang pernah dilakukan.
class PackageActivationHistoryPage extends StatefulWidget {
  /// Membuat instance dari [PackageActivationHistoryPage].
  const PackageActivationHistoryPage({super.key});

  @override
  State<PackageActivationHistoryPage> createState() =>
      _PackageActivationHistoryPageState();
}

class _PackageActivationHistoryPageState
    extends State<PackageActivationHistoryPage> {
  final TransactionOperation _transactionOperation = TransactionOperation();
  final PackageOperation _packageOperation = PackageOperation();
  late Future<List<TransactionModel>> _transactionListFuture;
  SortOption _activeSort = SortOption.newest;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Riwayat Aktivasi Paket');
    unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    Log.info('Memuat data transaksi aktivasi paket dari database');
    setState(() {
      _transactionListFuture = _transactionOperation
          .getTransactionsByPackageActivation()
          .then((final list) {
        Log.info(
          'Berhasil memuat ${list.length} data transaksi aktivasi paket',
        );

        // Log ringkasan setiap transaksi
        int paidCount = 0;
        int unpaidCount = 0;
        int endingTodayCount = 0;
        final now = DateTime.now();

        for (var transaction in list) {
          if (transaction.paymentStatus == PaymentStatus.paid) {
            paidCount++;
          } else {
            unpaidCount++;
          }

          if (transaction.endDate != null &&
              transaction.endDate!.year == now.year &&
              transaction.endDate!.month == now.month &&
              transaction.endDate!.day == now.day) {
            endingTodayCount++;
          }

          Log.info(
            'Transaksi ID: ${transaction.id} - Pelanggan ID: ${transaction.customerId ?? "N/A"}, Paket ID: ${transaction.packageId ?? "N/A"}, Status: ${transaction.paymentStatus.name}, Mulai: ${transaction.startDate != null ? FormatUtil.formatDateBasic(transaction.startDate!) : "N/A"}, Berakhir: ${transaction.endDate != null ? FormatUtil.formatDateBasic(transaction.endDate!) : "N/A"}',
          );
        }

        Log.info(
          'Ringkasan transaksi - Total: ${list.length}, Lunas: $paidCount, Belum Lunas: $unpaidCount, Berakhir Hari Ini: $endingTodayCount',
        );

        _sortList(list, _activeSort);
        return list;
      }).catchError((final Object error, final StackTrace st) {
        Log.error(
          'Gagal memuat data transaksi aktivasi paket dari database',
          e: error,
          st: st,
        );
        throw Exception('Gagal memuat data transaksi: $error');
      });
    });
  }

  void _sortList(final List<TransactionModel> list, final SortOption option) {
    Log.info(
      'Mengurutkan ${list.length} data transaksi berdasarkan: ${option.name}',
    );
    int Function(TransactionModel, TransactionModel) comparator;

    switch (option) {
      case SortOption.newest:
        comparator = (final a, final b) =>
            (b.updatedAt ?? b.date).compareTo(a.updatedAt ?? a.date);
        Log.info('Pengurutan: Terbaru (berdasarkan waktu update/tanggal)');
        break;
      case SortOption.oldest:
        comparator = (final a, final b) =>
            (a.updatedAt ?? a.date).compareTo(b.updatedAt ?? b.date);
        Log.info('Pengurutan: Terlama (berdasarkan waktu update/tanggal)');
        break;
      case SortOption.paid:
        comparator = (final a, final b) {
          final isPaidA = a.paymentStatus == PaymentStatus.paid;
          final isPaidB = b.paymentStatus == PaymentStatus.paid;
          if (isPaidA == isPaidB) {
            Log.info(
              'Status sama (${isPaidA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isPaidA ? -1 : 1;
          Log.info(
            'Memindahkan transaksi ${isPaidA ? "lunas" : "belum lunas"} ke ${isPaidA ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info('Pengurutan: Lunas di atas, Belum Lunas di bawah');
        break;
      case SortOption.unpaid:
        comparator = (final a, final b) {
          final isPaidA = a.paymentStatus == PaymentStatus.paid;
          final isPaidB = b.paymentStatus == PaymentStatus.paid;
          if (isPaidA == isPaidB) {
            Log.info(
              'Status sama (${isPaidA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isPaidA ? 1 : -1;
          Log.info(
            'Memindahkan transaksi ${isPaidA ? "lunas" : "belum lunas"} ke ${isPaidA ? "bawah" : "atas"}',
          );
          return result;
        };
        Log.info('Pengurutan: Belum Lunas di atas, Lunas di bawah');
        break;
      case SortOption.endingToday:
        comparator = (final a, final b) {
          final now = DateTime.now();
          final todayStr = FormatUtil.formatDateBasic(now);

          bool isToday(final DateTime? date) {
            if (date == null) return false;
            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          }

          final aIsToday = isToday(a.endDate);
          final bIsToday = isToday(b.endDate);

          if (aIsToday == bIsToday) {
            Log.info(
              'Status berakhir hari ini sama ($aIsToday), posisi tidak berubah',
            );
            return 0;
          }

          final result = aIsToday ? -1 : 1;
          Log.info(
            'Transaksi ${aIsToday ? "berakhir $todayStr" : "tidak berakhir hari ini"} dipindahkan ke ${aIsToday ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info(
          'Pengurutan: Berakhir Hari Ini (${FormatUtil.formatDateBasic(DateTime.now())}) di atas',
        );
        break;
    }

    list.sort(comparator);

    // Log 5 data teratas setelah pengurutan
    Log.info('5 data teratas setelah pengurutan ${option.name}:');
    for (int i = 0; i < (list.length < 5 ? list.length : 5); i++) {
      final t = list[i];
      Log.info(
        '  ${i + 1}. ID: ${t.id} - Status: ${t.paymentStatus.name} - Berakhir: ${t.endDate != null ? FormatUtil.formatDateBasic(t.endDate!) : "N/A"}',
      );
    }

    Log.info('Proses pengurutan selesai, ${list.length} data telah diurutkan');
  }

  Future<void> _showSortDialog() async {
    Log.info(
      'Menampilkan dialog opsi pengurutan, urutan saat ini: ${_activeSort.name}',
    );
    final SortOption? selected = await showDialog<SortOption>(
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
            buildOption('Berakhir Hari Ini', SortOption.endingToday),
            buildOption('Terbaru', SortOption.newest),
            buildOption('Terlama', SortOption.oldest),
            buildOption('Status (Lunas di Atas)', SortOption.paid),
            buildOption('Status (Belum Lunas di Atas)', SortOption.unpaid),
          ],
        );
      },
    );

    if (selected != null && selected != _activeSort) {
      Log.info(
        'Menerapkan perubahan urutan dari ${_activeSort.name} ke ${selected.name}',
      );
      final list = await _transactionListFuture;
      setState(() {
        _activeSort = selected;
        _sortList(list, selected);
        _transactionListFuture = Future.value(list);
      });
      Log.info('Urutan berhasil diubah ke ${selected.name}');
    } else if (selected == _activeSort) {
      Log.info(
        'User memilih urutan yang sama (${_activeSort.name}), tidak ada perubahan',
      );
    } else {
      Log.info('Dialog urutkan ditutup tanpa memilih opsi');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman Riwayat Aktivasi Paket, urutan aktif: ${_activeSort.name}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'Kembali ke halaman sebelumnya dari Riwayat Aktivasi Paket',
            );
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionListFuture,
        builder: (final context, final snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data transaksi masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat menampilkan data transaksi',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info(
              'Data riwayat aktivasi kosong, menampilkan pesan tidak ada data',
            );
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          } else {
            final dataLength = snapshot.data!.length;
            Log.info('Menampilkan $dataLength data transaksi dalam ListView');

            return ListView.builder(
              itemCount: dataLength,
              itemBuilder: (final context, final index) {
                final transaction = snapshot.data![index];
                final paymentStatusColor =
                    transaction.paymentStatus == PaymentStatus.paid
                        ? Colors.green
                        : Colors.red;

                Log.info(
                  'Membangun item ke-${index + 1} dari $dataLength - ID: ${transaction.id}, Pelanggan: ${transaction.customerId ?? "N/A"}, Status: ${transaction.paymentStatus.name}',
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: ListTile(
                    onTap: () async {
                      Log.info(
                        'Navigasi ke halaman Detail Transaksi ID: ${transaction.id}, Pelanggan ID: ${transaction.customerId ?? "N/A"}',
                      );
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (final context) =>
                              DetailLanggananTransaksiPage(
                            idTransaksi: transaction.id,
                          ),
                        ),
                      );
                      if (result ?? false) {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaction.id} dengan perubahan data, menyegarkan daftar',
                        );
                        await _loadHistory();
                      } else {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaction.id} tanpa perubahan data',
                        );
                      }
                    },
                    title: CustomerNameWidget(
                      customerId: transaction.customerId ?? ' ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PackageNameWidget(
                          packageFuture: _packageOperation
                              .getPackageById(transaction.packageId ?? ''),
                          style: TextStyle(color: paymentStatusColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${transaction.paymentStatus.name}',
                          style: TextStyle(
                            color: paymentStatusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (transaction.startDate != null &&
                            transaction.endDate != null)
                          Text(
                            'Aktif: ${FormatUtil.formatDateBasic(transaction.startDate!)} - ${FormatUtil.formatDateBasic(transaction.endDate!)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

# wallet_model

// path: lib/shared/model/wallet_model.dart
// new file: Refactored from dompet_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Data model for a wallet entity in the application.
class WalletModel implements HasId {
  /// A unique ID for each wallet, generated automatically if not provided.
  @override
  final String id;

  /// The user-defined name for this wallet. This is required.
  final String name;

  /// The current balance of the wallet.
  final double balance;

  /// Timestamp of when this data was last updated on the server or locally.
  final DateTime? updatedAt;

  /// Soft delete status. If `true`, the wallet is considered deleted.
  final bool isDeleted;

  /// Timestamp of when this wallet was archived. `null` if not archived.
  final DateTime? archivedAt;

  /// Creates an instance of [WalletModel].
  WalletModel({
    final String? id,
    required this.name,
    required this.balance,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4();

  /// Creates a copy of [WalletModel] with updated fields.
  WalletModel copyWith({
    final String? id,
    final String? name,
    final double? balance,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Internal helper to parse a date value from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Creates a [WalletModel] instance from a SQLite map.
  factory WalletModel.fromSqlite(final Map<String, dynamic> map) {
    return WalletModel(
      id: map[ColumnNames.id] as String?,
      name: (map[ColumnNames.name] as String?) ?? '',
      balance: (map[ColumnNames.balance] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: map[ColumnNames.isDeleted] == 1,
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts this [WalletModel] instance into a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.balance: balance,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [WalletModel] instance from a Firestore document.
  factory WalletModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return WalletModel(
      id: id,
      name: (data[ColumnNames.name] as String?) ?? '',
      balance: (data[ColumnNames.balance] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: (data[ColumnNames.isDeleted] as bool?) ?? false,
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts this [WalletModel] instance into a map for Firestore storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.balance: balance,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}

# upload_status_model
// path: lib/shared/model/upload_status_model.dart

import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';

/// Model ini merepresentasikan satu baris tunggal dalam tabel `upload_status`.
/// Tujuannya adalah untuk bertindak sebagai "bendera" global yang menandakan
/// apakah ada perubahan lokal yang perlu diunggah ke server.
class UploadStatusModel {
  /// Nama tabel di database SQLite.
  static const String tableName = 'upload_status';

  /// Kunci unik untuk baris status `need_upload`.
  static const String idNeedUpload = 'need_upload';

  /// ID unik untuk baris ini, yang juga merupakan kuncinya (misalnya, 'need_upload').
  final String id;

  /// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
  /// `false` jika tidak.
  final bool needUpload;

  /// Waktu terakhir kali status `needUpload` diubah, disimpan sebagai milidetik sejak epoch.
  final DateTime? updatedAt;

  /// Konstruktor untuk `UploadStatusModel`.
  const UploadStatusModel({
    required this.id,
    required this.needUpload,
    this.updatedAt,
  });

  /// Membuat instance UploadStatusModel dengan logging.
  factory UploadStatusModel.create({
    required final String id,
    required final bool needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel dibuat: id=$id, needUpload=$needUpload');
    return UploadStatusModel(
      id: id,
      needUpload: needUpload,
      updatedAt: updatedAt,
    );
  }

  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory UploadStatusModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Memulai konversi dari SQLite Map ke UploadStatusModel');

    final updatedAtEpoch = map[ColumnNames.updatedAt] as int?;

    final model = UploadStatusModel(
      // Menggunakan ColumnNames.id untuk konsistensi
      id: map[ColumnNames.id] as String,
      // Database SQLite tidak punya tipe boolean, jadi kita simpan sebagai string ('0' atau '1') di kolom 'value'.
      needUpload: map[ColumnNames.value] == '1',
      // Konversi dari milidetik epoch kembali ke DateTime.
      updatedAt: updatedAtEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtEpoch)
          : null,
    );

    Log.info(
        'Konversi ke UploadStatusModel berhasil: id=${model.id}, needUpload=${model.needUpload}');
    return model;
  }

  /// Konversi dari model ke Map untuk disimpan ke database SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Memulai konversi UploadStatusModel ke SQLite Map: id=$id');

    final map = <String, dynamic>{
      ColumnNames.id: id,
      // Simpan sebagai string '0' atau '1' di kolom 'value'
      ColumnNames.value: needUpload ? '1' : '0',
      // Konversi DateTime ke milidetik sejak epoch agar bisa disimpan di SQLite sebagai INTEGER.
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };

    Log.info('Konversi ke SQLite Map berhasil: $map');
    return map;
  }

  /// Membuat salinan dari model ini dengan nilai yang diperbarui.
  UploadStatusModel copyWith({
    final String? id,
    final bool? needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel.copyWith: id=$id, needUpload=$needUpload');

    return UploadStatusModel(
      id: id ?? this.id,
      needUpload: needUpload ?? this.needUpload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UploadStatusModel(id: $id, needUpload: $needUpload, updatedAt: $updatedAt)';
  }
}
# package_activation_history

// path: lib/admin/halaman/lainnya/package_activation_history.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman dalam navigasi admin (tab Lainnya).
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/subscription_history_detail.dart (DetailLanggananTransaksiPage)
//   - lib/shared/widget/customer_name.dart (CustomerNameWidget)
//   - lib/shared/widget/package_name.dart (PackageNameWidget)
//   - lib/shared/enum/payment_status_enum.dart (PaymentStatus)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation) — untuk PackageNameWidget
//   - lib/shared/utils/format_util.dart (FormatUtil)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/subscription_history_detail.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/customer_name.dart';
import 'package:wifi/shared/widget/package_name.dart';

/// Enum untuk opsi pengurutan riwayat aktivasi paket.
enum SortOption {
  /// Urutkan berdasarkan paket yang akan berakhir hari ini.
  endingToday,

  /// Urutkan berdasarkan transaksi terbaru.
  newest,

  /// Urutkan berdasarkan transaksi terlama.
  oldest,

  /// Tampilkan transaksi lunas di bagian atas.
  paid,

  /// Tampilkan transaksi yang belum lunas di bagian atas.
  unpaid,
}

/// Halaman untuk menampilkan riwayat aktivasi paket langganan.
///
/// Admin dapat melihat, mengurutkan, dan membuka detail setiap transaksi
/// aktivasi paket yang pernah dilakukan.
class PackageActivationHistoryPage extends StatefulWidget {
  /// Membuat instance dari [PackageActivationHistoryPage].
  const PackageActivationHistoryPage({super.key});

  @override
  State<PackageActivationHistoryPage> createState() =>
      _PackageActivationHistoryPageState();
}

class _PackageActivationHistoryPageState
    extends State<PackageActivationHistoryPage> {
  final TransactionOperation _transactionOperation = TransactionOperation();
  final PackageOperation _packageOperation = PackageOperation();
  late Future<List<TransactionModel>> _transactionListFuture;
  SortOption _activeSort = SortOption.newest;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Riwayat Aktivasi Paket');
    unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    Log.info('Memuat data transaksi aktivasi paket dari database');
    setState(() {
      _transactionListFuture = _transactionOperation
          .getTransactionsByPackageActivation()
          .then((final list) {
        Log.info(
          'Berhasil memuat ${list.length} data transaksi aktivasi paket',
        );

        // Log ringkasan setiap transaksi
        int paidCount = 0;
        int unpaidCount = 0;
        int endingTodayCount = 0;
        final now = DateTime.now();

        for (var transaction in list) {
          if (transaction.paymentStatus == PaymentStatus.paid) {
            paidCount++;
          } else {
            unpaidCount++;
          }

          if (transaction.endDate != null &&
              transaction.endDate!.year == now.year &&
              transaction.endDate!.month == now.month &&
              transaction.endDate!.day == now.day) {
            endingTodayCount++;
          }

          Log.info(
            'Transaksi ID: ${transaction.id} - Pelanggan ID: ${transaction.customerId ?? "N/A"}, Paket ID: ${transaction.packageId ?? "N/A"}, Status: ${transaction.paymentStatus.name}, Mulai: ${transaction.startDate != null ? FormatUtil.formatDateBasic(transaction.startDate!) : "N/A"}, Berakhir: ${transaction.endDate != null ? FormatUtil.formatDateBasic(transaction.endDate!) : "N/A"}',
          );
        }

        Log.info(
          'Ringkasan transaksi - Total: ${list.length}, Lunas: $paidCount, Belum Lunas: $unpaidCount, Berakhir Hari Ini: $endingTodayCount',
        );

        _sortList(list, _activeSort);
        return list;
      }).catchError((final Object error, final StackTrace st) {
        Log.error(
          'Gagal memuat data transaksi aktivasi paket dari database',
          e: error,
          st: st,
        );
        throw Exception('Gagal memuat data transaksi: $error');
      });
    });
  }

  void _sortList(final List<TransactionModel> list, final SortOption option) {
    Log.info(
      'Mengurutkan ${list.length} data transaksi berdasarkan: ${option.name}',
    );
    int Function(TransactionModel, TransactionModel) comparator;

    switch (option) {
      case SortOption.newest:
        comparator = (final a, final b) =>
            (b.updatedAt ?? b.date).compareTo(a.updatedAt ?? a.date);
        Log.info('Pengurutan: Terbaru (berdasarkan waktu update/tanggal)');
        break;
      case SortOption.oldest:
        comparator = (final a, final b) =>
            (a.updatedAt ?? a.date).compareTo(b.updatedAt ?? b.date);
        Log.info('Pengurutan: Terlama (berdasarkan waktu update/tanggal)');
        break;
      case SortOption.paid:
        comparator = (final a, final b) {
          final isPaidA = a.paymentStatus == PaymentStatus.paid;
          final isPaidB = b.paymentStatus == PaymentStatus.paid;
          if (isPaidA == isPaidB) {
            Log.info(
              'Status sama (${isPaidA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isPaidA ? -1 : 1;
          Log.info(
            'Memindahkan transaksi ${isPaidA ? "lunas" : "belum lunas"} ke ${isPaidA ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info('Pengurutan: Lunas di atas, Belum Lunas di bawah');
        break;
      case SortOption.unpaid:
        comparator = (final a, final b) {
          final isPaidA = a.paymentStatus == PaymentStatus.paid;
          final isPaidB = b.paymentStatus == PaymentStatus.paid;
          if (isPaidA == isPaidB) {
            Log.info(
              'Status sama (${isPaidA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isPaidA ? 1 : -1;
          Log.info(
            'Memindahkan transaksi ${isPaidA ? "lunas" : "belum lunas"} ke ${isPaidA ? "bawah" : "atas"}',
          );
          return result;
        };
        Log.info('Pengurutan: Belum Lunas di atas, Lunas di bawah');
        break;
      case SortOption.endingToday:
        comparator = (final a, final b) {
          final now = DateTime.now();
          final todayStr = FormatUtil.formatDateBasic(now);

          bool isToday(final DateTime? date) {
            if (date == null) return false;
            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          }

          final aIsToday = isToday(a.endDate);
          final bIsToday = isToday(b.endDate);

          if (aIsToday == bIsToday) {
            Log.info(
              'Status berakhir hari ini sama ($aIsToday), posisi tidak berubah',
            );
            return 0;
          }

          final result = aIsToday ? -1 : 1;
          Log.info(
            'Transaksi ${aIsToday ? "berakhir $todayStr" : "tidak berakhir hari ini"} dipindahkan ke ${aIsToday ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info(
          'Pengurutan: Berakhir Hari Ini (${FormatUtil.formatDateBasic(DateTime.now())}) di atas',
        );
        break;
    }

    list.sort(comparator);

    // Log 5 data teratas setelah pengurutan
    Log.info('5 data teratas setelah pengurutan ${option.name}:');
    for (int i = 0; i < (list.length < 5 ? list.length : 5); i++) {
      final t = list[i];
      Log.info(
        '  ${i + 1}. ID: ${t.id} - Status: ${t.paymentStatus.name} - Berakhir: ${t.endDate != null ? FormatUtil.formatDateBasic(t.endDate!) : "N/A"}',
      );
    }

    Log.info('Proses pengurutan selesai, ${list.length} data telah diurutkan');
  }

  Future<void> _showSortDialog() async {
    Log.info(
      'Menampilkan dialog opsi pengurutan, urutan saat ini: ${_activeSort.name}',
    );
    final SortOption? selected = await showDialog<SortOption>(
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
            buildOption('Berakhir Hari Ini', SortOption.endingToday),
            buildOption('Terbaru', SortOption.newest),
            buildOption('Terlama', SortOption.oldest),
            buildOption('Status (Lunas di Atas)', SortOption.paid),
            buildOption('Status (Belum Lunas di Atas)', SortOption.unpaid),
          ],
        );
      },
    );

    if (selected != null && selected != _activeSort) {
      Log.info(
        'Menerapkan perubahan urutan dari ${_activeSort.name} ke ${selected.name}',
      );
      final list = await _transactionListFuture;
      setState(() {
        _activeSort = selected;
        _sortList(list, selected);
        _transactionListFuture = Future.value(list);
      });
      Log.info('Urutan berhasil diubah ke ${selected.name}');
    } else if (selected == _activeSort) {
      Log.info(
        'User memilih urutan yang sama (${_activeSort.name}), tidak ada perubahan',
      );
    } else {
      Log.info('Dialog urutkan ditutup tanpa memilih opsi');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman Riwayat Aktivasi Paket, urutan aktif: ${_activeSort.name}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'Kembali ke halaman sebelumnya dari Riwayat Aktivasi Paket',
            );
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionListFuture,
        builder: (final context, final snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data transaksi masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat menampilkan data transaksi',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info(
              'Data riwayat aktivasi kosong, menampilkan pesan tidak ada data',
            );
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          } else {
            final dataLength = snapshot.data!.length;
            Log.info('Menampilkan $dataLength data transaksi dalam ListView');

            return ListView.builder(
              itemCount: dataLength,
              itemBuilder: (final context, final index) {
                final transaction = snapshot.data![index];
                final paymentStatusColor =
                    transaction.paymentStatus == PaymentStatus.paid
                        ? Colors.green
                        : Colors.red;

                Log.info(
                  'Membangun item ke-${index + 1} dari $dataLength - ID: ${transaction.id}, Pelanggan: ${transaction.customerId ?? "N/A"}, Status: ${transaction.paymentStatus.name}',
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: ListTile(
                    onTap: () async {
                      Log.info(
                        'Navigasi ke halaman Detail Transaksi ID: ${transaction.id}, Pelanggan ID: ${transaction.customerId ?? "N/A"}',
                      );
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (final context) =>
                              DetailLanggananTransaksiPage(
                            idTransaksi: transaction.id,
                          ),
                        ),
                      );
                      if (result ?? false) {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaction.id} dengan perubahan data, menyegarkan daftar',
                        );
                        await _loadHistory();
                      } else {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaction.id} tanpa perubahan data',
                        );
                      }
                    },
                    title: CustomerNameWidget(
                      customerId: transaction.customerId ?? ' ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PackageNameWidget(
                          packageFuture: _packageOperation
                              .getPackageById(transaction.packageId ?? ''),
                          style: TextStyle(color: paymentStatusColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${transaction.paymentStatus.name}',
                          style: TextStyle(
                            color: paymentStatusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (transaction.startDate != null &&
                            transaction.endDate != null)
                          Text(
                            'Aktif: ${FormatUtil.formatDateBasic(transaction.startDate!)} - ${FormatUtil.formatDateBasic(transaction.endDate!)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

# active_customer_model
// path: lib/shared/model/active_customer_model.dart
// new file: Refactored from pelanggan_aktif_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for active customer data.
class ActiveCustomerModel implements HasId {
  @override
  final String id;

  /// The ID of the customer associated with this entry.
  final String customerId;

  /// The ID of the package purchased by the customer.
  final String packageId;

  /// The ID of the transaction associated with the package purchase.
  final String? transactionId;

  /// The start date of the package activation.
  final DateTime startDate;

  /// The end date of the package.
  final DateTime endDate;

  /// The payment status of the package.
  final PaymentStatus status;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this entry has been deleted (soft delete).
  final bool isDeleted;

  /// The time this entry was archived.
  final DateTime? archivedAt;

  /// Constructor for `ActiveCustomerModel`.
  ActiveCustomerModel({
    final String? id,
    required this.customerId,
    required this.packageId,
    this.transactionId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('ActiveCustomerModel created: $id for customer $customerId');
  }

  /// Creates a copy of this `ActiveCustomerModel` with some modified values.
  ActiveCustomerModel copyWith({
    final String? id,
    final String? customerId,
    final String? packageId,
    final String? transactionId,
    final DateTime? startDate,
    final DateTime? endDate,
    final PaymentStatus? status,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return ActiveCustomerModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      transactionId: transactionId ?? this.transactionId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    Log.warning('Unrecognized DateTime format: $value');
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    Log.warning('Unrecognized Boolean format, defaulting to false: $value');
    return false;
  }

  /// Creates an `ActiveCustomerModel` instance from SQLite map data.
  factory ActiveCustomerModel.fromSqlite(final Map<String, dynamic> map) {
    try {
      final startDate = _parseDateTime(map[ColumnNames.startDate]);
      final endDate = _parseDateTime(map[ColumnNames.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from SQLite');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from SQLite');
      }

      final model = ActiveCustomerModel(
        id: map[ColumnNames.id] as String,
        customerId: map[ColumnNames.customerId] as String? ?? '',
        packageId: map[ColumnNames.packageId] as String? ?? '',
        transactionId: map[ColumnNames.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (final e) => e.name == map[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
        isDeleted: _parseBool(map[ColumnNames.isDeleted]),
        archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      );
      Log.info('ActiveCustomerModel loaded from SQLite: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from SQLite: $map', e: e, st: stack);
      rethrow;
    }
  }

  /// Converts `ActiveCustomerModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: startDate.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate.millisecondsSinceEpoch,
      ColumnNames.status: status.name,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `ActiveCustomerModel` instance from Firebase map data.
  factory ActiveCustomerModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    try {
      final startDate = _parseDateTime(data[ColumnNames.startDate]);
      final endDate = _parseDateTime(data[ColumnNames.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from Firebase');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from Firebase');
      }

      final model = ActiveCustomerModel(
        id: id,
        customerId: data[ColumnNames.customerId] as String? ?? '',
        packageId: data[ColumnNames.packageId] as String? ?? '',
        transactionId: data[ColumnNames.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (final e) => e.name == data[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
        isDeleted: _parseBool(data[ColumnNames.isDeleted]),
        archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
      );
      Log.info('ActiveCustomerModel loaded from Firebase: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from Firebase: $data', e: e, st: stack);
      rethrow;
    }
  }

  /// Converts `ActiveCustomerModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    Log.info('Preparing toFirebase for ActiveCustomerModel $id');
    return {
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: Timestamp.fromDate(startDate.toUtc()),
      ColumnNames.endDate: Timestamp.fromDate(endDate.toUtc()),
      ColumnNames.status: status.name,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}

# sub_category_model

// path: lib/shared/model/sub_category_model.dart
// diperbarui: Mengganti impor dan menambahkan logging.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/category_model.dart' show CategoryModel;
import 'package:wifi/shared/model/has_id.dart';

/// Model yang merepresentasikan sebuah sub-kategori.
///
/// Setiap sub-kategori selalu berada di bawah sebuah [CategoryModel] induk.
class SubCategoryModel implements HasId {
  /// ID unik dari sub-kategori, biasanya dibuat menggunakan UUID.
  @override
  final String id;

  /// Nama dari sub-kategori.
  final String name;

  /// ID dari [CategoryModel] induk.
  final String categoryId;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? updatedAt;

  /// Penanda untuk soft-delete (penghapusan sementara).
  final bool isDeleted;

  /// Waktu saat data ini diarsipkan.
  final DateTime? archivedAt;

  /// Konstruktor utama untuk membuat instance [SubCategoryModel].
  SubCategoryModel({
    final String? id,
    required this.name,
    required this.categoryId,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('SubCategoryModel dibuat: $name ($id)');
  }

  /// Membuat salinan dari instance [SubCategoryModel] ini dengan beberapa nilai yang diubah.
  SubCategoryModel copyWith({
    final String? id,
    final String? name,
    final String? categoryId,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return SubCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Fungsi bantuan untuk mem-parsing nilai dinamis menjadi DateTime.
  static DateTime? parseDateTime(final dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return null;
  }

  /// Fungsi bantuan untuk mem-parsing nilai dinamis menjadi boolean secara aman.
  static bool parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [SubCategoryModel] dari data SQLite.
  factory SubCategoryModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Membuat SubCategoryModel dari SQLite: ${map[ColumnNames.id]}');
    return SubCategoryModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      categoryId: map[ColumnNames.categoryId] as String? ?? '',
      updatedAt: parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: parseBool(map[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi instance [SubCategoryModel] ini menjadi Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Mengonversi SubCategoryModel ke format SQLite: $id');
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.categoryId: categoryId,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor untuk membuat [SubCategoryModel] dari data Firebase.
  factory SubCategoryModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    Log.info('Membuat SubCategoryModel dari Firebase: $id');
    return SubCategoryModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      categoryId: data[ColumnNames.categoryId] as String? ?? '',
      updatedAt: parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: parseBool(data[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi instance [SubCategoryModel] ini menjadi Map untuk disimpan di Firebase.
  /// ID disertakan karena sub-kategori disimpan sebagai daftar di dalam dokumen kategori.
  Map<String, dynamic> toFirebase() {
    Log.info('Mengonversi SubCategoryModel ke format Firebase: $id');
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.categoryId: categoryId,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
# customer_model
// path: lib/shared/model/customer_model.dart
// new file: Refactored from pelanggan_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model representing a customer's data.
class CustomerModel implements HasId {
  @override
  final String id;

  /// The name of the customer.
  final String name;

  /// The phone number of the customer.
  final String phone;

  /// The address of the customer.
  final String address;

  /// The password for the customer's account.
  final String password;

  /// The MAC address of the customer's device.
  final String macAddress;

  /// A flag indicating if the customer has been soft-deleted.
  final bool isDeleted;

  /// The timestamp of the last update.
  final DateTime? updatedAt;

  /// The timestamp of when the customer was archived.
  final DateTime? archivedAt;

  /// Creates a new instance of the [CustomerModel].
  CustomerModel({
    final String? id,
    required this.name,
    required this.phone,
    required this.address,
    required this.password,
    this.macAddress = '',
    this.isDeleted = false,
    this.updatedAt,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CustomerModel created: $id, name: $name');
  }

  /// Creates a copy of the [CustomerModel] with updated fields.
  CustomerModel copyWith({
    final String? id,
    final String? name,
    final String? phone,
    final String? address,
    final String? password,
    final String? macAddress,
    final bool? isDeleted,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      macAddress: macAddress ?? this.macAddress,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Parses a dynamic value into a [DateTime] object.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    Log.warning('Unrecognized DateTime format: $value');
    return null;
  }

  /// Parses a dynamic value into a boolean.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    Log.warning('Unrecognized Boolean format, defaulting to false: $value');
    return false;
  }

  /// Creates a [CustomerModel] from a SQLite map.
  factory CustomerModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating CustomerModel from SQLite: ${map[ColumnNames.id]}');
    return CustomerModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      phone: map[ColumnNames.phone] as String? ?? '',
      address: map[ColumnNames.address] as String? ?? '',
      password: map[ColumnNames.password] as String? ?? '',
      macAddress: map[ColumnNames.macAddress] as String? ?? '',
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts the [CustomerModel] to a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.phone: phone,
      ColumnNames.address: address,
      ColumnNames.password: password,
      ColumnNames.macAddress: macAddress,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [CustomerModel] from a Firebase document.
  factory CustomerModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    Log.info('Creating CustomerModel from Firebase: $id');
    return CustomerModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      phone: data[ColumnNames.phone] as String? ?? '',
      address: data[ColumnNames.address] as String? ?? '',
      password: data[ColumnNames.password] as String? ?? '',
      macAddress: data[ColumnNames.macAddress] as String? ?? '',
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts the [CustomerModel] to a map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.name: name,
      ColumnNames.phone: phone,
      ColumnNames.address: address,
      ColumnNames.password: password,
      ColumnNames.macAddress: macAddress,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
# customer_operation
// path: lib/shared/operasi/customer_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari PelangganOperasi menjadi CustomerOperation.
// diubah: Menggunakan BaseOperation dan CustomerModel.

import 'package:meta/meta.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pelanggan di database lokal.
class CustomerOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  final BaseOperation _baseOperation;

  /// Konstruktor untuk [CustomerOperation].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [baseOperation]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  CustomerOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('CustomerOperation diinisialisasi');
  }

  /// Menyimpan [CustomerModel] baru ke dalam database.
  Future<void> createCustomer(
    final CustomerModel customer, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai pembuatan customer dengan ID: ${customer.id}');
    try {
      final customerToSave = customer.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      final data = customerToSave.toSqlite();

      await _baseOperation.insert('pelanggan', data, fromServer: fromServer);

      Log.info(
          'Customer (ID: ${customerToSave.id}) berhasil dibuat di database lokal.');
    } catch (e, s) {
      Log.error('Gagal membuat customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).
  Future<List<CustomerModel>> getCustomers() async {
    Log.info(
        'Mengambil semua customer yang aktif (tidak diarsipkan dan tidak dihapus).');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where:
            '${ColumnNames.archivedAt} IS NULL AND ${ColumnNames.isDeleted} = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} customer aktif.');
      return List.generate(maps.length, (final i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil customer aktif.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan, termasuk yang diarsipkan dan dihapus.
  Future<List<CustomerModel>> getAllCustomers() async {
    Log.info('Mengambil SEMUA data customer dari database lokal.');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('pelanggan');

      Log.info('Berhasil mengambil total ${maps.length} customer.');
      return List.generate(maps.length, (final i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil [CustomerModel] berdasarkan [id].
  Future<CustomerModel?> getCustomerById(final String id) async {
    Log.info('Mencari customer berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Customer dengan ID: $id ditemukan.');
        return CustomerModel.fromSqlite(maps.first);
      }
      Log.warning('Customer dengan ID: $id tidak ditemukan.');
      return null;
    } catch (e, s) {
      Log.error('Gagal mencari customer berdasarkan ID.', e: e, st: s);
      rethrow;
    }
  }

  /// Memperbarui [CustomerModel] yang ada di database.
  Future<void> updateCustomer(
    final CustomerModel customer, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai pembaruan untuk customer ID: ${customer.id}');
    try {
      final data =
          customer.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();

      await _baseOperation.update(
        'pelanggan',
        data,
        customer.id,
        fromServer: fromServer,
      );

      Log.info('Berhasil memperbarui customer ID: ${customer.id}.');
    } catch (e, s) {
      Log.error('Gagal memperbarui customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus [CustomerModel] dari database.
  ///
  /// Jika [softDelete] bernilai `true`, maka hanya akan menandai `isDeleted` menjadi `1`.
  /// Jika `false`, maka akan menghapus data secara permanen.
  Future<void> deleteCustomer(
    final String id, {
    final bool softDelete = true,
    final bool fromServer = false,
  }) async {
    Log.info(
        'Memulai proses penghapusan untuk customer ID: $id (softDelete: $softDelete)');
    try {
      if (softDelete) {
        await _baseOperation.update(
          'pelanggan',
          {
            ColumnNames.isDeleted: 1,
            ColumnNames.updatedAt:
                DateTime.now().toUtc().millisecondsSinceEpoch,
          },
          id,
          fromServer: fromServer,
        );
        Log.info('Berhasil melakukan soft delete pada customer ID: $id.');
      } else {
        await _baseOperation.delete('pelanggan', id, fromServer: fromServer);
        Log.warning('Berhasil melakukan hard delete pada customer ID: $id.');
      }
    } catch (e, s) {
      Log.error('Gagal menghapus customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan yang telah diubah sejak [since].
  Future<List<CustomerModel>> getChangesSince(final DateTime since) async {
    Log.info('Mengambil perubahan customer sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: '${ColumnNames.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      Log.info(
          'Ditemukan ${maps.length} perubahan customer sejak waktu yang ditentukan.');
      return List.generate(
        maps.length,
        (final i) => CustomerModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengarsipkan [CustomerModel] berdasarkan [id].
  Future<void> archiveCustomer(final String id,
      {final bool fromServer = false}) async {
    Log.info('Mengarsipkan customer ID: $id');
    try {
      final now = DateTime.now().toUtc();
      await _baseOperation.update(
        'pelanggan',
        {
          ColumnNames.isDeleted: 1,
          ColumnNames.archivedAt: now.millisecondsSinceEpoch,
          ColumnNames.updatedAt: now.millisecondsSinceEpoch,
        },
        id,
        fromServer: fromServer,
      );
      Log.info('Berhasil mengarsipkan customer ID: $id.');
    } catch (e, s) {
      Log.error('Gagal mengarsipkan customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [CustomerModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<CustomerModel> items, {
    final bool fromServer = false,
  }) async {
    if (items.isEmpty) {
      Log.info('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${items.length} customer.');
    try {
      final data = items.map((final item) {
        return item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      }).toList();

      await _baseOperation.insertOrUpdateBatch(
        'pelanggan',
        data,
        fromServer: fromServer,
      );
      Log.info(
          'Berhasil menyelesaikan operasi batch untuk ${items.length} customer.');
    } catch (e, s) {
      Log.error('Gagal menjalankan operasi batch.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [CustomerModel] berdasarkan daftar [ids].
  Future<List<CustomerModel>> getCustomersByIds(final List<String> ids) async {
    if (ids.isEmpty) {
      Log.info('List ID kosong, tidak ada customer yang diambil.');
      return [];
    }
    Log.info('Mengambil data customer untuk ${ids.length} ID.');
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
          'Berhasil mengambil ${maps.length} customer berdasarkan list ID.');
      return List.generate(maps.length, (final i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil customer berdasarkan list ID.', e: e, st: s);
      rethrow;
    }
  }
}

# feedback_detail

// path: lib/admin/halaman/detail/feedback_detail.dart
// Fitur: Detail Kritik dan Saran
// Tujuan: Menampilkan detail dari satu item kritik dan saran, dan menyediakan opsi untuk menghapusnya.
//
// Daftar Fungsi:
// - _loadData(): Memuat data kritik dan saran berdasarkan ID dari operasi.
// - _deleteFeedback(): Menangani logika untuk menghapus item kritik dan saran dengan konfirmasi.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/operasi/feedback_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/name_from_id.dart';

/// Halaman untuk menampilkan detail dari sebuah kritik atau saran.
///
/// Pengguna dapat melihat isi pesan, pengirim, dan tanggal.
/// Terdapat juga opsi untuk menghapus item ini dari database.
class FeedbackDetailPage extends StatefulWidget {
  /// ID unik dari dokumen kritik dan saran di Firestore.
  final String id;

  /// Konstruktor untuk membuat instance [FeedbackDetailPage].
  const FeedbackDetailPage({
    super.key,
    required this.id,
  });

  @override
  State<FeedbackDetailPage> createState() => _FeedbackDetailPageState();
}

/// State untuk [FeedbackDetailPage].
class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  final FeedbackOperation _feedbackOperation = FeedbackOperation();

  late Future<FeedbackModel> _feedbackFuture;

  @override
  void initState() {
    super.initState();

    Log.info(
      'Membuka halaman detail kritik dan saran dengan ID: ${widget.id}.',
    );

    _loadData();
  }

  void _loadData() {
    Log.info(
      'Memulai proses pengambilan data kritik dan saran dari database.',
    );

    _feedbackFuture =
        _feedbackOperation.getFeedbackById(widget.id).then((final value) {
      Log.info(
        'Data kritik dan saran berhasil dimuat dari database.',
      );

      return value;
      // diubah: Menambahkan tipe eksplisit Object dan StackTrace pada error handling.
      // Alasan: Untuk memenuhi aturan analisis statis yang ketat dan menghindari error 'inference_failure' dan 'argument_type_not_assignable'.
    }).catchError((final Object e, final StackTrace st) {
      Log.error(
        'Terjadi kesalahan saat mengambil data kritik dan saran.',
        e: e,
        st: st,
      );
      // diubah: Melempar error dengan tipe yang benar.
      // Alasan: Mengikuti praktik terbaik penanganan error setelah tipenya dipastikan.
      // diubah: Membungkus error dalam sebuah Exception untuk mematuhi aturan lint.
      throw Exception(e);
    });
  }

  Future<void> _deleteFeedback() async {
    Log.info(
      'Menampilkan dialog konfirmasi penghapusan kritik dan saran.',
    );

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final context) {
        Log.info(
          'Dialog konfirmasi penghapusan berhasil ditampilkan.',
        );

        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Log.warning(
                  'Pengguna membatalkan proses penghapusan kritik dan saran.',
                );

                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Log.info(
                  'Pengguna mengonfirmasi penghapusan kritik dan saran.',
                );

                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    Log.info(
      'Dialog konfirmasi selesai diproses dengan hasil: $konfirmasi.',
    );

    if ((konfirmasi ?? false) && mounted) {
      Log.info(
        'Memulai proses penghapusan data kritik dan saran.',
      );

      try {
        Log.info(
          'Menampilkan loading dialog selama proses penghapusan.',
        );

        unawaited(showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (final context) {
            Log.info(
              'Loading dialog berhasil ditampilkan.',
            );

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));

        Log.info(
          'Memanggil operasi hapus kritik dan saran ke database.',
        );

        await _feedbackOperation.deleteFeedback(
          widget.id,
        );

        Log.info(
          'Data kritik dan saran berhasil dihapus dari database.',
        );

        if (mounted) {
          Log.info(
            'Menutup loading dialog.',
          );

          Navigator.of(context).pop();
        }

        if (mounted) {
          SnackBarUtil.success(
            context,
            'Kritik dan saran berhasil dihapus',
          );
        }

        if (mounted) {
          Log.info(
            'Kembali ke halaman sebelumnya dengan status sukses.',
          );

          Navigator.of(context).pop(true);
        }
      } on Exception catch (e, st) {
        Log.error(
          'Terjadi kesalahan saat menghapus kritik dan saran.',
          e: e,
          st: st,
        );

        if (mounted) {
          Log.warning(
            'Menutup loading dialog karena terjadi error.',
          );

          Navigator.of(context).pop();
        }

        if (mounted) {
          SnackBarUtil.error(
            context,
            'Gagal menghapus: $e',
          );
        }
      }
    } else {
      Log.warning(
        'Proses penghapusan dibatalkan atau widget sudah tidak mounted.',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman detail kritik dan saran.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Kritik & Saran',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteFeedback,
            tooltip: 'Hapus Kritik & Saran',
          ),
        ],
      ),
      body: FutureBuilder<FeedbackModel>(
        future: _feedbackFuture,
        builder: (final context, final snapshot) {
          Log.info(
            'FutureBuilder dijalankan dengan connection state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Data masih dalam proses loading.',
            );

            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder menerima error saat memuat data.',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );

            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          } else if (snapshot.hasData) {
            Log.info(
              'FutureBuilder berhasil menerima data kritik dan saran.',
            );

            final kritikSaran = snapshot.data!;

            Log.info(
              'Menampilkan detail kritik dan saran dengan ID: ${kritikSaran.id}.',
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: NameFromIdWidget(
                              userId: kritikSaran.userId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Pesan:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        kritikSaran.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const Divider(
                        height: 40,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          kritikSaran.date != null
                              ? FormatUtil.formatDateAndTime(
                                  kritikSaran.date!,
                                )
                              : 'Tanggal tidak tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            Log.warning(
              'FutureBuilder tidak menerima data kritik dan saran.',
            );

            return const Center(
              child: Text(
                'Data tidak ditemukan',
              ),
            );
          }
        },
      ),
    );
  }
}


# snackbar_util
// path: lib/shared/utils/snackbar_util.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Tipe SnackBar yang tersedia.
enum SnackBarType {
  /// SnackBar sukses dengan latar hijau.
  success,

  /// SnackBar error dengan latar merah.
  error,

  /// SnackBar peringatan dengan latar oranye.
  warning,

  /// SnackBar informasi dengan latar biru.
  info,
}

/// Kelas utilitas untuk menampilkan SnackBar dengan gaya yang konsisten dan logging otomatis.
class SnackBarUtil {
  /// Fungsi internal untuk menampilkan SnackBar dan mencatat log.
  static void _show(
    final BuildContext context,
    final String message, {
    final SnackBarType type = SnackBarType.info,
  }) {
    // Mencatat pesan ke log berdasarkan tipenya
    final logMessage = '[SNACKBAR] Tipe: ${type.name}, Pesan: $message';
    switch (type) {
      case SnackBarType.success:
        Log.info(logMessage);
        break;
      case SnackBarType.error:
        Log.error(logMessage);
        break;
      case SnackBarType.warning:
        Log.warning(logMessage);
        break;
      case SnackBarType.info:
        Log.info(logMessage);
        break;
    }

    // Jangan tampilkan snackbar jika context sudah tidak valid setelah logging
    if (!context.mounted) return;

    // Tentukan warna berdasarkan tipe snackbar
    Color backgroundColor;
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue;
        break;
    }

    // Buat dan tampilkan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  /// Menampilkan SnackBar dengan tipe success.
  static void success(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.success);
  }

  /// Menampilkan SnackBar dengan tipe error.
  static void error(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.error);
  }

  /// Menampilkan SnackBar dengan tipe warning.
  static void warning(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.warning);
  }

  /// Menampilkan SnackBar dengan tipe info.
  static void info(final BuildContext context, final String message) {
    _show(context, message);
  }
}


# subscription_history_detail
// path: lib/admin/halaman/detail/subscription_history_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Halaman untuk menampilkan detail transaksi langganan.
class DetailLanggananTransaksiPage extends StatefulWidget {
  /// ID transaksi yang akan ditampilkan.
  final String idTransaksi;

  /// Konstruktor untuk DetailLanggananTransaksiPage.
  const DetailLanggananTransaksiPage({super.key, required this.idTransaksi});

  @override
  State<DetailLanggananTransaksiPage> createState() =>
      _DetailLanggananTransaksiPageState();
}

class _DetailLanggananTransaksiPageState
    extends State<DetailLanggananTransaksiPage> {
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  late Future<TransactionModel?> _transaksiFuture;

  @override
  void initState() {
    super.initState();

    Log.info(
      'Memulai inisialisasi halaman detail langganan untuk ID transaksi: ${widget.idTransaksi}.',
    );

    _transaksiFuture = _transaksiOperasi.getTransaksiById(widget.idTransaksi);

    Log.info(
      'Future transaksi berhasil dibuat untuk proses pengambilan data transaksi.',
    );
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman detail langganan transaksi.');

    return Scaffold(
      appBar: AppBar(
          title: const Text(
              'Detail Langganan')), // TODO: rencana selanjutnya adalah menambahkan tombol edit
      body: FutureBuilder<TransactionModel?>(
        future: _transaksiFuture,
        builder: (final context, final snapshot) {
          Log.info(
            'FutureBuilder transaksi dijalankan dengan state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info('Data transaksi masih dalam proses loading.');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            Log.error(
              'Terjadi kesalahan saat mengambil data transaksi.',
              e: snapshot.error,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transaksi = snapshot.data;

          if (transaksi == null) {
            Log.warning('Data transaksi tidak ditemukan di database.');
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }

          Log.info(
            'Berhasil memuat data transaksi dengan ID: ${transaksi.id}.',
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                if (transaksi.idPelanggan != null)
                  _buildFutureInfoCard<PelangganModel>(
                    'Informasi Pelanggan',
                    _pelangganOperasi.getPelangganById(transaksi.idPelanggan!),
                    'Pelanggan',
                    (final pelanggan) => [
                      _buildDetailRow(
                        'Nama Pelanggan',
                        pelanggan?.nama ?? 'Tidak Diketahui',
                      ),
                    ],
                    onTap: (final pelanggan) {
                      if (pelanggan != null) {
                        unawaited(Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (final context) => DetailPelangganPage(
                              idPelanggan: pelanggan.id,
                            ),
                          ),
                        ));
                      }
                    },
                  ),
                const SizedBox(height: 16),
                if (transaksi.idPaket != null)
                  _buildFutureInfoCard<PaketModel>(
                    'Informasi Paket',
                    _paketOperasi.getPaketById(transaksi.idPaket!),
                    'Paket',
                    (final paket) => [
                      _buildDetailRow(
                        'Nama Paket',
                        paket?.nama ?? 'Tidak Diketahui',
                      ), // Info nama paket
                      _buildDetailRow(
                        'Harga',
                        FormatUang.formatMataUang(paket?.harga.toDouble() ?? 0),
                      ), // info harga paket
                      _buildDetailRow(
                        'Durasi',
                        '${paket?.durasi ?? 0} ${paket?.tipe.name ?? ""}',
                      ),
                    ], // info durasi paket
                    onTap: (final paket) {
                      if (paket != null) {
                        unawaited(Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (final context) => DetailPaketPage(
                              paket: paket,
                            ),
                          ),
                        ));
                      }
                    },
                  ),
                const SizedBox(height: 16),
                _buildInfoPoin(transaksi),
                const SizedBox(height: 16),
                if (transaksi.tanggalMulai != null &&
                    transaksi.tanggalBerakhir != null)
                  _buildInfoCard('Waktu Langganan', [
                    _buildDetailRow(
                      'Tanggal Mulai',
                      FormatTanggal.formatTanggalDanJam(
                        transaksi.tanggalMulai!,
                      ),
                    ),
                    _buildDetailRow(
                      'Tanggal Berakhir',
                      FormatTanggal.formatTanggalDanJam(
                        transaksi.tanggalBerakhir!,
                      ),
                    ),
                  ]),
                const SizedBox(height: 16),
                _buildInfoCard('Status', [
                  _buildDetailRow(
                    'Status Pembayaran',
                    transaksi.statusPembayaran.name.toUpperCase(),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoPoin(final TransactionModel transaksi) {
    Log.info('Membangun widget informasi poin transaksi.');

    if (transaksi.poinYangDihasilkan == 0 && transaksi.poinYangDigunakan == 0) {
      Log.info('Tidak ada perubahan poin pada transaksi ini.');
      return const SizedBox.shrink();
    }

    final isPenambahan =
        transaksi.poinYangDihasilkan > transaksi.poinYangDigunakan;
    final selisihPoin =
        transaksi.poinYangDihasilkan - transaksi.poinYangDigunakan;

    Log.info(
      'Poin dihasilkan: ${transaksi.poinYangDihasilkan}, '
      'Poin digunakan: ${transaksi.poinYangDigunakan}, '
      'Selisih: $selisihPoin poin (${isPenambahan ? "PENAMBAHAN" : "PENGURANGAN"}).',
    );

    return _buildInfoCard('Informasi Poin', [
      _buildDetailRowWithColor(
        'Poin Dihasilkan',
        '+${transaksi.poinYangDihasilkan} Poin',
        transaksi.poinYangDihasilkan > 0 ? Colors.green : null,
        transaksi.poinYangDihasilkan > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      _buildDetailRowWithColor(
        'Poin Digunakan',
        '-${transaksi.poinYangDigunakan} Poin',
        transaksi.poinYangDigunakan > 0 ? Colors.red : null,
        transaksi.poinYangDigunakan > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      const Divider(height: 16),
      _buildDetailRowWithColor(
        isPenambahan ? 'Total Poin Bertambah' : 'Total Poin Berkurang',
        '${selisihPoin >= 0 ? "+" : ""}$selisihPoin Poin',
        isPenambahan ? Colors.green : Colors.red,
        FontWeight.bold,
        fontSize: 16,
      ),
    ]);
  }

  Widget _buildInfoCard(final String title, final List<Widget> children,
      {final VoidCallback? onTap}) {
    Log.info('Membangun info card dengan judul: $title.');

    final cardContent = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }

  Widget _buildFutureInfoCard<T>(
    final String title,
    final Future<T?> future,
    final String tag,
    final List<Widget> Function(T? data) builder, {
    final void Function(T? data)? onTap,
  }) {
    Log.info('Membangun Future info card untuk data $tag.');

    return FutureBuilder<T?>(
      future: future,
      builder: (final context, final snapshot) {
        Log.info(
          'FutureBuilder $tag dijalankan dengan state: ${snapshot.connectionState}.',
        );

        VoidCallback? resolvedOnTap;
        if (onTap != null &&
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            snapshot.hasData) {
          resolvedOnTap = () => onTap(snapshot.data);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Data $tag masih dalam proses loading.');
          return _buildInfoCard(title, [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ]);
        }

        if (snapshot.hasError) {
          Log.error('Gagal memuat data $tag.', e: snapshot.error);
          return _buildInfoCard(title, [const Text('Gagal memuat data')]);
        }

        if (snapshot.hasData) {
          Log.info('Data $tag berhasil dimuat secara asynchronous.');
        } else {
          Log.warning('Data $tag tidak ditemukan.');
        }

        return _buildInfoCard(title, builder(snapshot.data),
            onTap: resolvedOnTap);
      },
    );
  }

  Widget _buildDetailRow(final String label, final String value) {
    Log.info('Membangun detail row dengan label: $label dan value: $value.');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithColor(
    final String label,
    final String value,
    final Color? valueColor,
    final FontWeight fontWeight, {
    final double fontSize = 14,
  }) {
    Log.info(
      'Membangun detail row berwarna dengan label: $label dan value: $value.',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: fontWeight,
                color: valueColor,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

# package_name
// path: lib/shared/widget/package_name.dart
// digunakan oleh: lib/user/page/riwayat_langganan_user.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Widget yang menampilkan nama paket berdasarkan Future yang diberikan.
///
/// Widget ini didekopling dari sumber data. Ia hanya menerima [packageFuture]
/// dan menampilkan hasilnya. Menampilkan indikator loading saat menunggu,
/// atau 'Paket tidak tersedia' jika data null atau error.
class PackageNameWidget extends StatelessWidget {
  /// Future yang mengembalikan [PackageModel] untuk ditampilkan namanya.
  final Future<PackageModel?> packageFuture;

  /// Gaya teks opsional untuk nama paket.
  final TextStyle? style;

  /// Membuat widget [PackageNameWidget].
  const PackageNameWidget({super.key, required this.packageFuture, this.style});

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<PackageModel?>(
      future: packageFuture,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return Text(
            'Paket tidak tersedia',
            style: style?.copyWith(color: Colors.red),
          );
        } else {
          return Text(snapshot.data!.name, style: style);
        }
      },
    );
  }
}

# customer_name

// path: lib/shared/widget/customer_name.dart
// digunakan oleh: lib/admin/halaman/widget/nama_pelanggan.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';

/// Widget yang menampilkan nama pelanggan berdasarkan ID.
///
/// Mengambil data pelanggan secara async menggunakan [CustomerOperation].
/// Menampilkan '...' saat loading, 'Error' jika gagal, atau
/// 'Pelanggan tidak ditemukan' jika data null.
class CustomerNameWidget extends StatelessWidget {
  /// ID pelanggan yang akan dicari namanya.
  final String customerId;

  /// Gaya teks opsional untuk nama yang ditampilkan.
  final TextStyle? style;

  /// Membuat widget [CustomerNameWidget].
  const CustomerNameWidget({super.key, required this.customerId, this.style});

  @override
  Widget build(final BuildContext context) {
    final CustomerOperation customerOperation = CustomerOperation();

    return FutureBuilder<CustomerModel?>(
      future: customerOperation.getCustomerById(customerId),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '...',
            style: style ?? const TextStyle(color: Colors.grey),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Error',
            style: style ??
                const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!.name,
            style: style ?? const TextStyle(fontWeight: FontWeight.bold),
          );
        }
        return Text(
          'Pelanggan tidak ditemukan',
          style: style ??
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      },
    );
  }
}

# package_name

// path: lib/shared/widget/package_name.dart
// digunakan oleh: lib/user/page/riwayat_langganan_user.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Widget yang menampilkan nama paket berdasarkan Future yang diberikan.
///
/// Widget ini didekopling dari sumber data. Ia hanya menerima [packageFuture]
/// dan menampilkan hasilnya. Menampilkan indikator loading saat menunggu,
/// atau 'Paket tidak tersedia' jika data null atau error.
class PackageNameWidget extends StatelessWidget {
  /// Future yang mengembalikan [PackageModel] untuk ditampilkan namanya.
  final Future<PackageModel?> packageFuture;

  /// Gaya teks opsional untuk nama paket.
  final TextStyle? style;

  /// Membuat widget [PackageNameWidget].
  const PackageNameWidget({super.key, required this.packageFuture, this.style});

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<PackageModel?>(
      future: packageFuture,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return Text(
            'Paket tidak tersedia',
            style: style?.copyWith(color: Colors.red),
          );
        } else {
          return Text(snapshot.data!.name, style: style);
        }
      },
    );
  }
}



# format_util

// path: lib/shared/utils/format_util.dart

// File ini berisi kumpulan kelas utilitas untuk pemformatan data.
// Setiap kelas bertanggung jawab atas satu jenis format (Tanggal, Jam, Uang)
// untuk memastikan kode yang terorganisir dan mudah dikelola.

import 'package:intl/intl.dart';

/// Kelas utilitas untuk semua pemformatan yang terkait dengan tanggal.
class FormatUtil {
  // Konstruktor privat untuk mencegah instansiasi.
  FormatUtil._();

  /// Mengubah [DateTime] menjadi format tanggal "d MMM yyyy" (contoh: "17 Agu 2024").
  static String formatDateBasic(final DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  /// Mengubah [DateTime] menjadi format tanggal dan jam "d MMM yyyy, HH:mm".
  static String formatDateAndTime(final DateTime date) {
    final format = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    return format.format(date);
  }

  /// Mengubah [DateTime] menjadi format tanggal ringkas "E, d MMM yy" (contoh: "Sel, 17 Agu 26").
  static String formatDateCompact(final DateTime date) {
    return DateFormat('E, d MMM yy', 'id_ID').format(date);
  }
}

/// Kelas utilitas untuk semua pemformatan yang terkait dengan waktu/jam.
class TimeFormat {
  // Konstruktor privat untuk mencegah instansiasi.
  TimeFormat._();

  /// Mengubah [DateTime] menjadi format jam dan menit "HH:mm".
  static String formatHourMinute(final DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Mengubah [DateTime] menjadi format jam, menit, dan detik "HH:mm:ss".
  static String formatFullTime(final DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  /// Mengonversi string waktu (ISO 8601) menjadi format "HH:mm".
  static String formatTextToHour(final String timeText) {
    try {
      final dateTime = DateTime.parse(timeText);
      return DateFormat('HH:mm').format(dateTime);
    } on Exception {
      return '--:--'; // Fallback jika format teks tidak valid.
    }
  }
}

/// Kelas utilitas untuk pemformatan mata uang.
class CurrencyFormat {
  // Konstruktor privat untuk mencegah instansiasi.
  CurrencyFormat._();

  /// Memformat angka [double] menjadi format mata uang Rupiah ("Rp 50.000").
  static String formatCurrency(final double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0, // Rupiah tidak menggunakan desimal.
    );
    return formatter.format(amount);
  }
}


# payment_status_enum

// path: lib/shared/enum/payment_status_enum.dart

/// Enum untuk status pembayaran transaksi atau tagihan.
enum PaymentStatus {
  /// Status lunas, pembayaran telah diselesaikan.
  paid,

  /// Status belum lunas, pembayaran masih tertunda.
  unpaid,

  /// Status jatuh tempo, pembayaran sudah melewati batas waktu.
  overdue,
}


# log

// path: lib/shared/debug/log.dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Kelas utilitas untuk logging yang terstruktur dan berwarna.
class Log {
  static const String _green = '\x1B[38;5;76m';
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';

  static final Random _random = Random();

  static String _buatKodeUnik() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (final _) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  static String _formatData(final Object? data) {
    if (data == null) return '';

    Object? customEncoder(final Object? object) {
      if (object is DateTime) {
        return object.toIso8601String();
      }
      if (object is Timestamp) {
        return object.toDate().toIso8601String();
      }
      try {
        return (object as dynamic).toJson();
      } on Exception {
        return object.toString();
      }
    }

    try {
      if (data is Map || data is List) {
        final encoder = JsonEncoder.withIndent('  ', customEncoder);
        return '\nData: ${encoder.convert(data)}';
      }
      return '\nData: $data';
    } on Exception {
      return '\nData: $data';
    }
  }

  /// Mencatat pesan informasi.
  static void info(final String message, [final Object? data]) {
    _logCustom(
      message: '$message${_formatData(data)}',
      name: '✅',
      color: _green,
      level: 800,
    );
  }

  /// Mencatat pesan peringatan.
  static void warning(final String message, [final Object? data]) {
    _logCustom(
      message: '$message${_formatData(data)}',
      name: '⚠️',
      color: _yellow,
      level: 900,
    );
  }

  /// Mencatat pesan error.
  static void error(
    final String message, {
    final Object? e,
    final StackTrace? st,
    final Object? data,
  }) {
    _logCustom(
      message: '$message${_formatData(data)}',
      name: '❌',
      color: _red,
      level: 1000,
      e: e,
      st: st,
    );
  }

  /// Mencatat panggilan API.
  static void api(
    final String path,
    final Map<String, dynamic> data, {
    required final String method,
  }) {
    final String id = _buatKodeUnik();
    _logCustom(
      message: '[$method][$id] $path${_formatData(data)}',
      name: '🌐',
      color: _cyan,
      level: 500,
    );
  }

  static void _logCustom({
    required final String message,
    required final String name,
    required final String color,
    required final int level,
    final Object? e,
    final StackTrace? st,
  }) {
    if (!kDebugMode) return;

    final trace = StackTrace.current.toString().split('\n');
    final String callerRow = trace.length > 2 ? trace[2] : 'Unknown';
    final match = RegExp(r'#2\s+(.+)\s+\((.+)\)').firstMatch(callerRow);

    String location = '';
    if (match != null) {
      final methodCaller = match.group(1);
      final fileInfo = match.group(2);
      location = '[ $methodCaller ] - $fileInfo';
    }

    dev.log(
      '$color$message - $location$_reset',
      name: name,
      level: level,
      time: DateTime.now(),
      error: e,
      stackTrace: st,
    );
  }
}


# admin_settings

// path: lib/admin/halaman/lainnya/admin_settings.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman dalam navigasi admin (Settings).
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/form/settings_form.dart (SettingsForm)
//   - lib/shared/model/settings_model.dart (SettingsModel)
//   - lib/shared/operasi/settings_operation.dart (SettingsOperation)
//   - lib/shared/utils/sync_manager.dart (SyncManager)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/settings_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

/// Halaman untuk menampilkan dan mengelola konfigurasi pengaturan aplikasi.
///
/// Dari halaman ini, admin dapat melihat pengaturan saat ini, mengeditnya,
/// dan melakukan aksi terkait seperti mereset waktu sinkronisasi.
class SettingsAdminPage extends StatefulWidget {
  /// Membuat instance dari [SettingsAdminPage].
  const SettingsAdminPage({super.key});

  @override
  State<SettingsAdminPage> createState() => _SettingsAdminPageState();
}

class _SettingsAdminPageState extends State<SettingsAdminPage> {
  final SettingsOperation _settingsOperation = SettingsOperation();
  late Future<SettingsModel> _futureSettings;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Pengaturan Aplikasi');
    _loadSettings();
  }

  // Fungsi untuk memuat data pengaturan dari database.
  void _loadSettings() {
    Log.info('Memuat data pengaturan dari database lokal');
    setState(() {
      _futureSettings = _settingsOperation.getSettings().then((final data) {
        Log.info('Data pengaturan berhasil dimuat dari database');
        Log.info(
          'Detail pengaturan - Interval sinkronisasi: ${data.autoSyncInterval} jam, Hapus arsip: ${data.autoDeleteArchiveDays} hari, Mode pemeliharaan: ${data.maintenanceMode ? "Aktif" : "Nonaktif"}, Info pemeliharaan: ${data.maintenanceInfo.isNotEmpty ? data.maintenanceInfo : "(kosong)"}',
        );
        return data;
      }).catchError((final Object e, final StackTrace st) {
        Log.error(
          'Gagal memuat data pengaturan dari database lokal',
          e: e,
          st: st,
        );
        throw Exception('Gagal memuat data pengaturan: $e');
      });
    });
  }

  // Fungsi untuk menavigasi ke halaman form edit dan memuat ulang data jika ada perubahan.
  Future<void> _editSettings(final SettingsModel pengaturan) async {
    Log.info('Navigasi ke halaman Form Edit Pengaturan');
    Log.info(
      'Data pengaturan sebelum edit - Interval: ${pengaturan.autoSyncInterval} jam, Hapus arsip: ${pengaturan.autoDeleteArchiveDays} hari, Mode pemeliharaan: ${pengaturan.maintenanceMode}, Info: ${pengaturan.maintenanceInfo.isNotEmpty ? pengaturan.maintenanceInfo : "(kosong)"}',
    );

    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => SettingsForm(settings: pengaturan),
      ),
    );

    if ((hasil ?? false) && mounted) {
      Log.info(
        'Data pengaturan berhasil diperbarui dari Form Edit, menyegarkan tampilan',
      );
      _loadSettings();
    } else if (hasil == false) {
      Log.info('Kembali dari Form Edit Pengaturan tanpa melakukan perubahan');
    } else {
      Log.info('Kembali dari Form Edit Pengaturan (hasil: $hasil)');
    }
  }

  // Fungsi untuk mereset waktu sinkronisasi
  Future<void> _resetSyncTime() async {
    Log.info('Tombol Reset Waktu Sinkronisasi ditekan.');
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Konfirmasi Reset'),
        content: const Text(
          'Anda yakin ingin mereset waktu sinkronisasi? Tindakan ini akan memaksa aplikasi untuk mengunggah semua data yang dimodifikasi dan mengunduh semua data dari server pada siklus sinkronisasi berikutnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (konfirmasi ?? false) {
      Log.info(
        'Pengguna mengonfirmasi reset. Memanggil SyncManager().resetSyncTime().',
      );
      try {
        await SyncManager().resetSyncTime();
        Log.info('Reset waktu sinkronisasi berhasil.');
        if (mounted) {
          SnackBarUtil.success(
            context,
            'Waktu sinkronisasi berhasil di-reset.',
          );
        }
      } on Exception catch (e, st) {
        Log.error('Gagal mereset waktu sinkronisasi', e: e, st: st);
        if (mounted) {
          SnackBarUtil.error(
            context,
            'Gagal mereset waktu sinkronisasi: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman Pengaturan Aplikasi');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info('Kembali ke halaman sebelumnya dari Pengaturan');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<SettingsModel>(
        future: _futureSettings,
        builder: (final context, final snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data pengaturan masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat memuat data pengaturan',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pengaturan = snapshot.data;
            Log.info('Data pengaturan tersedia, menampilkan detail pengaturan');
            Log.info(
              'Mode pemeliharaan: ${pengaturan!.maintenanceMode ? "Aktif" : "Nonaktif"}, Info: ${pengaturan.maintenanceInfo.isNotEmpty ? pengaturan.maintenanceInfo : "(kosong)"}',
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildInfoCard(
                          judul: 'Sinkronisasi Otomatis',
                          nilai: '${pengaturan.autoSyncInterval} Jam',
                          ikon: Icons.sync,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          judul: 'Hapus Arsip Otomatis',
                          nilai: '${pengaturan.autoDeleteArchiveDays} Hari',
                          ikon: Icons.auto_delete_outlined,
                        ),
                        const Divider(height: 24, thickness: 1),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'Mode Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  pengaturan.maintenanceMode
                                      ? 'Aplikasi dalam mode pemeliharaan'
                                      : 'Aplikasi berjalan normal',
                                ),
                                value: pengaturan.maintenanceMode,
                                onChanged: null, // Read-only di halaman ini
                                secondary: Icon(
                                  pengaturan.maintenanceMode
                                      ? Icons.construction
                                      : Icons.check_circle_outline,
                                  color: pengaturan.maintenanceMode
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                              if (pengaturan.maintenanceMode)
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text(
                                    'Info Pemeliharaan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    pengaturan.maintenanceInfo.isNotEmpty
                                        ? pengaturan.maintenanceInfo
                                        : '(Tidak ada pesan diatur)',
                                  ),
                                  isThreeLine: true,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tombol Reset Waktu Sinkronisasi
                        ElevatedButton.icon(
                          icon: const Icon(Icons.sync_problem),
                          label: const Text('Reset Waktu Sinkronisasi'),
                          onPressed: _resetSyncTime,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Pengaturan'),
                    onPressed: () async {
                      Log.info('Tombol Edit Pengaturan ditekan');
                      await _editSettings(pengaturan);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          } else {
            Log.warning(
              'Data pengaturan tidak tersedia (null), menampilkan pesan kosong',
            );
            return const Center(child: Text('Pengaturan tidak ditemukan.'));
          }
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required final String judul,
    required final String nilai,
    required final IconData ikon,
  }) {
    Log.info('Membangun kartu info: $judul dengan nilai: $nilai');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        leading: Icon(ikon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          nilai,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}