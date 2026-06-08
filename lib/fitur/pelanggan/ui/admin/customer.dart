// path: lib/fitur/pelanggan/ui/admin/customer.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/customer_detail.dart';
import 'package:wifi/admin/halaman/form/customer_form.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Enum untuk menentukan opsi pengurutan daftar customer.
enum UrutanPelanggan {
  nameAZ,
  nameZA,
  lastActiveNewest,
  lastActiveOldest,
  pointsHighest,
  pointsLowest,
}

// --- Combined & Filtered Data Provider ---

/// Provider lokal untuk memfilter dan mengurutkan pelanggan secara reaktif berdasarkan state modern.
final filteredCustomersProvider =
    Provider.autoDispose<AsyncValue<List<(CustomerModel, int)>>>((ref) {
  final customerListAsync = ref.watch(customerListProvider);
  final searchQuery = ref.watch(searchQueryPelangganProvider).toLowerCase();
  final sortOption = ref.watch(urutanPelangganStateProvider);

  return customerListAsync.when(
    data: (customersWithPoints) {
      // 1. Jalankan Fitur Filter Pencarian
      final filtered = customersWithPoints
          .where((tuple) => tuple.$1.name.toLowerCase().contains(searchQuery))
          .toList();

      // 2. Jalankan Fitur Pengurutan (Sorting)
      switch (sortOption) {
        case UrutanPelanggan.nameAZ:
          filtered.sort((a, b) =>
              a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase()));
          break;
        case UrutanPelanggan.nameZA:
          filtered.sort((a, b) =>
              b.$1.name.toLowerCase().compareTo(a.$1.name.toLowerCase()));
          break;
        case UrutanPelanggan.lastActiveNewest:
          filtered.sort((a, b) {
            if (a.$1.lastActiveAt == null) return 1;
            if (b.$1.lastActiveAt == null) return -1;
            return b.$1.lastActiveAt!.compareTo(a.$1.lastActiveAt!);
          });
          break;
        case UrutanPelanggan.lastActiveOldest:
          filtered.sort((a, b) {
            if (a.$1.lastActiveAt == null) return -1;
            if (b.$1.lastActiveAt == null) return 1;
            return a.$1.lastActiveAt!.compareTo(b.$1.lastActiveAt!);
          });
          break;
        case UrutanPelanggan.pointsHighest:
          filtered.sort((a, b) => b.$2.compareTo(a.$2));
          break;
        case UrutanPelanggan.pointsLowest:
          filtered.sort((a, b) => a.$2.compareTo(b.$2));
          break;
      }
      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
  );
});

/// Halaman untuk menampilkan dan mengelola daftar semua customer.
class CustomerPage extends ConsumerWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSearchQuery = ref.watch(searchQueryPelangganProvider);
    final searchController = TextEditingController(text: currentSearchQuery);

    searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: searchController.text.length));

    return Scaffold(
      appBar: _buildAppBar(context, ref, searchController),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(customerListProvider.future),
        child: _buildContent(context, ref),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCustomer(context, ref),
        tooltip: 'Tambah Pelanggan',
        child: const Icon(TIcons.add),
      ),
    );
  }

  AppBar _buildAppBar(
      BuildContext context, WidgetRef ref, TextEditingController controller) {
    final isSearching = ref.watch(isSearchingPelangganProvider);

    return AppBar(
      title: isSearching
          ? TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari nama customer...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) => ref
                  .read(searchQueryPelangganProvider.notifier)
                  .updateQuery(query),
            )
          : const Text('Daftar Pelanggan'),
      actions: [
        IconButton(
          icon: const Icon(TIcons.sort),
          tooltip: 'Urutkan',
          onPressed: () => _showSortDialog(context, ref),
        ),
        IconButton(
          icon: Icon(isSearching ? TIcons.close : TIcons.search),
          onPressed: () {
            ref.read(isSearchingPelangganProvider.notifier).toggle();
            if (!ref.read(isSearchingPelangganProvider)) {
              ref.read(searchQueryPelangganProvider.notifier).clear();
            }
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(filteredCustomersProvider);
    final isSearching = ref.watch(isSearchingPelangganProvider);

    return customersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        Log.error('Gagal memuat daftar customer', e: e, st: s);
        return Center(
          child: Text('Gagal memuat data: $e'),
        );
      },
      data: (customers) {
        if (customers.isEmpty) {
          return Center(
            child: Text(
              isSearching
                  ? 'Pelanggan tidak ditemukan.'
                  : 'Belum ada customer. Tekan tombol + untuk menambah.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final (customer, points) = customers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  customer.lastActiveAt == null
                      ? '-'
                      : FormatDateTime.formatDateAndTimeCompact(
                          customer.lastActiveAt!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(TIcons.star, color: Colors.amber),
                    gapH4,
                    Text(
                      points.toString(),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () => _viewCustomerDetail(context, ref, customer.id),
                onLongPress: () => _showOptionsDialog(context, ref, customer),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSortDialog(BuildContext context, WidgetRef ref) async {
    final activeSort = ref.read(urutanPelangganStateProvider);

    Widget buildOption(String text, UrutanPelanggan value) {
      final isSelected = activeSort == value;
      return SimpleDialogOption(
        onPressed: () => Navigator.pop(context, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? TColors.pointBackground : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    final result = await showDialog<UrutanPelanggan>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: <Widget>[
          buildOption('Nama (A-Z)', UrutanPelanggan.nameAZ),
          buildOption('Nama (Z-A)', UrutanPelanggan.nameZA),
          buildOption(
              'Aktivitas Terakhir (Terbaru)', UrutanPelanggan.lastActiveNewest),
          buildOption(
              'Aktivitas Terakhir (Terlama)', UrutanPelanggan.lastActiveOldest),
          buildOption('Poin (Tertinggi)', UrutanPelanggan.pointsHighest),
          buildOption('Poin (Terendah)', UrutanPelanggan.pointsLowest),
        ],
      ),
    );

    if (result != null) {
      ref.read(urutanPelangganStateProvider.notifier).ubahUrutan(result);
    }
  }

  Future<void> _addCustomer(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CustomerForm()),
    );
    if (result ?? false) {
      ref.invalidate(customerListProvider);
      if (context.mounted) {
        ToastUtil.success(context, 'Pelanggan berhasil ditambahkan.');
      }
    }
  }

  Future<void> _viewCustomerDetail(
      BuildContext context, WidgetRef ref, String customerId) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customerId: customerId),
      ),
    );
    ref.invalidate(customerListProvider);
  }

  Future<void> _showOptionsDialog(
      BuildContext context, WidgetRef ref, CustomerModel customer) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(customer.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(TIcons.edit),
              title: const Text('Edit Pelanggan'),
              onTap: () async {
                Navigator.of(dialogContext).pop();
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerForm(customer: customer),
                  ),
                );
                if (result ?? false) {
                  ref.invalidate(customerListProvider);
                  if (context.mounted) {
                    ToastUtil.success(
                        context, 'Pelanggan berhasil diperbarui.');
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(TIcons.archive),
              title: const Text('Arsipkan Pelanggan'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showSoftDeleteConfirmation(context, ref, customer);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSoftDeleteConfirmation(
      BuildContext context, WidgetRef ref, CustomerModel customer) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Arsip'),
        content: Text(
          'Apakah Anda yakin ingin mengarsipkan pelanggan "${customer.name}"?',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Arsipkan', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop();
              await _softDeleteCustomer(context, ref, customer.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _softDeleteCustomer(
      BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(customerOperationProvider).softDelete(id);
      ref.invalidate(customerListProvider);
      if (context.mounted) {
        ToastUtil.success(context, 'Pelanggan berhasil diarsipkan.');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal mengarsipkan pelanggan', e: e, st: s);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal mengarsipkan customer.');
      }
    }
  }
}
