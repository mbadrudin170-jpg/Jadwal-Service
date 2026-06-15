// path: lib/fitur/pelanggan/ui/admin/pelanggan.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Enum untuk menentukan opsi pengurutan daftar customer.
enum UrutanPelanggan {
  namaAZ,
  namaZa,
  terakhirOnline,
  terbaruOnline,
  poinTerbanyak,
  pointerkecil,
}

// --- Combined & Filtered Data Provider ---

/// Provider lokal untuk memfilter dan mengurutkan pelanggan secara reaktif berdasarkan state modern.
final filteredCustomersProvider =
    Provider.autoDispose<AsyncValue<List<(PelangganModel, int)>>>((ref) {
  final daftarPelanggan = ref.watch(daftarPelangganProvider);
  final searchQuery = ref.watch(searchQueryPelangganProvider).toLowerCase();
  final sortOption = ref.watch(urutanPelangganStateProvider);

  return daftarPelanggan.when(
    data: (customersWithPoints) {
      final filtered = customersWithPoints
          .where((tuple) => tuple.$1.name.toLowerCase().contains(searchQuery))
          .toList();

      switch (sortOption) {
        case UrutanPelanggan.namaAZ:
          filtered.sort((a, b) =>
              a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase()));
          break;
        case UrutanPelanggan.namaZa:
          filtered.sort((a, b) =>
              b.$1.name.toLowerCase().compareTo(a.$1.name.toLowerCase()));
          break;
        case UrutanPelanggan.terakhirOnline:
          filtered.sort((a, b) {
            if (a.$1.lastActiveAt == null) return 1;
            if (b.$1.lastActiveAt == null) return -1;
            return b.$1.lastActiveAt!.compareTo(a.$1.lastActiveAt!);
          });
          break;
        case UrutanPelanggan.terbaruOnline:
          filtered.sort((a, b) {
            if (a.$1.lastActiveAt == null) return -1;
            if (b.$1.lastActiveAt == null) return 1;
            return a.$1.lastActiveAt!.compareTo(b.$1.lastActiveAt!);
          });
          break;
        case UrutanPelanggan.poinTerbanyak:
          filtered.sort((a, b) => b.$2.compareTo(a.$2));
          break;
        case UrutanPelanggan.pointerkecil:
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
class Pelanggan extends ConsumerWidget {
  const Pelanggan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSearchQuery = ref.watch(searchQueryPelangganProvider);
    final searchController = TextEditingController(text: currentSearchQuery);

    searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: searchController.text.length));

    return Scaffold(
      appBar: _buildAppBar(context, ref, searchController),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(daftarPelangganProvider.future),
        child: _buildContent(context, ref),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _naviagsiKeForm(context, ref),
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
          onPressed: () => _dialogSort(context, ref),
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
        Log.error('Gagal memuat daftar customer', e: e, s: s);
        return Center(
          child: Text('Gagal memuat data: $e'),
        );
      },
      data: (listPelanggan) {
        if (listPelanggan.isEmpty) {
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
          itemCount: listPelanggan.length,
          itemBuilder: (context, index) {
            final (pelanggan, poin) = listPelanggan[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(pelanggan.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  pelanggan.lastActiveAt == null
                      ? '-'
                      : FormatWaktuLengkap.formatSingkat(
                          pelanggan.lastActiveAt!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(TIcons.star, color: Colors.amber),
                    gapH4,
                    Text(
                      poin.toString(),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () => _navigasiKeDetail(context, ref, pelanggan.id),
                onLongPress: () => _dialogOpsi(context, ref, pelanggan),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _dialogSort(BuildContext context, WidgetRef ref) async {
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

    final hasil = await showDialog<UrutanPelanggan>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: <Widget>[
          buildOption('Nama (A-Z)', UrutanPelanggan.namaAZ),
          buildOption('Nama (Z-A)', UrutanPelanggan.namaZa),
          buildOption(
              'Aktivitas Terakhir (Terbaru)', UrutanPelanggan.terakhirOnline),
          buildOption(
              'Aktivitas Terakhir (Terlama)', UrutanPelanggan.terbaruOnline),
          buildOption('Poin (Tertinggi)', UrutanPelanggan.poinTerbanyak),
          buildOption('Poin (Terendah)', UrutanPelanggan.pointerkecil),
        ],
      ),
    );

    if (hasil != null) {
      ref.read(urutanPelangganStateProvider.notifier).ubahUrutan(hasil);
    }
  }

  Future<void> _naviagsiKeForm(BuildContext context, WidgetRef ref) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const FormPelanggan()),
    );
  }

  Future<void> _navigasiKeDetail(
      BuildContext context, WidgetRef ref, String idPelanggan) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPelanggan(idPelanggan: idPelanggan),
      ),
    );
    ref.invalidate(daftarPelangganProvider);
  }

  Future<void> _dialogOpsi(
      BuildContext context, WidgetRef ref, PelangganModel pelanggan) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(pelanggan.name),
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
                    builder: (context) => FormPelanggan(pelanggan: pelanggan),
                  ),
                );
                if (result ?? false) {
                  ref.invalidate(daftarPelangganProvider);
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
                unawaited(_dialogKonfirmasiSoftDelete(context, ref, pelanggan));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dialogKonfirmasiSoftDelete(
      BuildContext context, WidgetRef ref, PelangganModel customer) async {
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
      await ref.read(pelangganOpSqliteProvider).hapusSementara(id);
      ref.invalidate(daftarPelangganProvider);
      if (context.mounted) {
        ToastUtil.success(context, 'Pelanggan berhasil diarsipkan.');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal mengarsipkan pelanggan', e: e, s: s);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal mengarsipkan customer.');
      }
    }
  }
}
