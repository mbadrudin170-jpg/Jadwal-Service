// path lib/fitur/pelanggan/page/admin/pelanggan_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/admin/detail_pelanggan_a.dart';
import 'package:wifi/fitur/pelanggan/page/admin/form_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Enum untuk menentukan opsi pengurutan daftar customer.
enum UrutanPelanggan {
  namaAZ,
  namaZa,
  terakhirOnline,
  terbaruOnline,
  poinTerbanyak,
  poinTerkecil,
}
// path: lib/fitur/pelanggan/page/admin/pelanggan.dart

/// Provider untuk mendapatkan daftar pelanggan dengan poin
final pelangganDenganPoinProvider =
    FutureProvider.autoDispose<List<(PelangganModel, int)>>((ref) async {
      final pelangganState = await ref.watch(pelangganProvider.future);
      final transaksiNotifier = ref.watch(
        transaksiProvider.notifier,
      ); // ✅ Gunakan notifier
      final daftarPelanggan = pelangganState.daftarPelanggan;

      // ✅ Ambil poin melalui method di transaksiProvider
      final List<int> semuaPoin = await transaksiNotifier
          .getTotalPoinBanyakPelangganParallel(
            daftarPelanggan.map((p) => p.id).toList(),
          );

      final hasil = <(PelangganModel, int)>[];
      for (int i = 0; i < daftarPelanggan.length; i++) {
        hasil.add((daftarPelanggan[i], semuaPoin[i]));
      }

      return hasil;
    });
final filteredCustomersProvider =
    Provider.autoDispose<AsyncValue<List<(PelangganModel, int)>>>((ref) {
      final pelangganWithPoints = ref.watch(pelangganDenganPoinProvider);
      final searchQuery = ref.watch(searchQueryPelangganProvider).toLowerCase();
      final sortOption = ref.watch(urutanPelangganStateProvider);

      return pelangganWithPoints.when(
        data: (customersWithPoints) {
          final filtered = customersWithPoints
              .where(
                (tuple) => tuple.$1.nama.toLowerCase().contains(searchQuery),
              )
              .toList();

          if (filtered.isNotEmpty) {
            switch (sortOption) {
              case UrutanPelanggan.namaAZ:
                filtered.sort(
                  (a, b) => a.$1.nama.toLowerCase().compareTo(
                    b.$1.nama.toLowerCase(),
                  ),
                );
                break;
              case UrutanPelanggan.namaZa:
                filtered.sort(
                  (a, b) => b.$1.nama.toLowerCase().compareTo(
                    a.$1.nama.toLowerCase(),
                  ),
                );
                break;
              case UrutanPelanggan.terakhirOnline:
                filtered.sort((a, b) {
                  if (a.$1.terkahirAktif == null) return 1;
                  if (b.$1.terkahirAktif == null) return -1;
                  return b.$1.terkahirAktif!.compareTo(a.$1.terkahirAktif!);
                });
                break;
              case UrutanPelanggan.terbaruOnline:
                filtered.sort((a, b) {
                  if (a.$1.terkahirAktif == null) return -1;
                  if (b.$1.terkahirAktif == null) return 1;
                  return a.$1.terkahirAktif!.compareTo(b.$1.terkahirAktif!);
                });
                break;
              case UrutanPelanggan.poinTerbanyak:
                filtered.sort((a, b) => b.$2.compareTo(a.$2));
                break;
              case UrutanPelanggan.poinTerkecil:
                filtered.sort((a, b) => a.$2.compareTo(b.$2));
                break;
            }
          }
          return AsyncData(filtered);
        },
        loading: () => const AsyncLoading(),
        error: AsyncError.new,
      );
    });

/// Halaman untuk menampilkan dan mengelola daftar semua customer.
class PelangganPage extends ConsumerStatefulWidget {
  const PelangganPage({super.key});

  @override
  ConsumerState<PelangganPage> createState() => _PelangganState();
}

class _PelangganState extends ConsumerState<PelangganPage> {
  late final TextEditingController _searchController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryPelangganProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(searchQueryPelangganProvider, (_, next) {
      if (_searchController.text != next) {
        _searchController.text = next;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      }
    });

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(pelangganProvider.notifier).refresh();
          ref.invalidate(pelangganDenganPoinProvider);
        },
        child: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _naviagsiKeForm,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(TIcons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    final isSearching = ref.watch(isSearchingPelangganProvider);
    return AppBar(
      title: isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari nama pelanggan...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  ref
                      .read(searchQueryPelangganProvider.notifier)
                      .updateQuery(query);
                });
              },
            )
          : const Text('Daftar Pelanggan'),
      actions: [
        IconButton(
          icon: Icon(isSearching ? TIcons.close : TIcons.search),
          onPressed: () {
            final wasSearching = ref.read(isSearchingPelangganProvider);
            ref.read(isSearchingPelangganProvider.notifier).toggle();
            if (wasSearching) {
              ref.read(searchQueryPelangganProvider.notifier).clear();
            }
          },
        ),
        IconButton(
          icon: const Icon(TIcons.sort),
          tooltip: 'Urutkan',
          onPressed: _dialogSort,
        ),
      ],
    );
  }

  Widget _buildContent() {
    final pelangganAsync = ref.watch(filteredCustomersProvider);
    final sedangMencari = ref.watch(searchQueryPelangganProvider).isNotEmpty;
    return pelangganAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        Log.error('Gagal memuat daftar customer', e: e, s: s);
        return Center(child: Text('Gagal memuat data: $e'));
      },
      data: (listPelanggan) {
        if (listPelanggan.isEmpty) {
          return Center(
            child: Text(
              sedangMencari
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
                title: Text(
                  pelanggan.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  pelanggan.terkahirAktif == null
                      ? '-'
                      : FormatWaktuLengkap.formatSingkat(
                          pelanggan.terkahirAktif!,
                        ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(TIcons.star, color: Colors.amber),
                    gapH4,
                    Text(
                      poin.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () => _navigasiKeDetail(pelanggan.id),
                onLongPress: () => _dialogOpsi(pelanggan),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _dialogSort() async {
    final urutanAktif = ref.read(urutanPelangganStateProvider);
    Widget buildOption(String text, UrutanPelanggan value) {
      final sedangDipilih = urutanAktif == value;
      return SimpleDialogOption(
        onPressed: () => Navigator.pop(context, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: sedangDipilih ? TColors.pointBackground : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: sedangDipilih ? FontWeight.bold : FontWeight.normal,
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
            'Aktivitas Terakhir (Terbaru)',
            UrutanPelanggan.terakhirOnline,
          ),
          buildOption(
            'Aktivitas Terakhir (Terlama)',
            UrutanPelanggan.terbaruOnline,
          ),
          buildOption('Poin (Tertinggi)', UrutanPelanggan.poinTerbanyak),
          buildOption('Poin (Terendah)', UrutanPelanggan.poinTerkecil),
        ],
      ),
    );
    if (hasil != null) {
      ref.read(urutanPelangganStateProvider.notifier).ubahUrutan(hasil);
    }
  }

  Future<void> _naviagsiKeForm() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const FormPelanggan()),
    );
  }

  Future<void> _navigasiKeDetail(String idPelanggan) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPelanggan(idPelanggan: idPelanggan),
      ),
    );
  }

  Future<void> _dialogOpsi(PelangganModel pelanggan) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(pelanggan.nama),
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
                  if (!mounted) return;
                  ToastUtil.success(context, 'Pelanggan berhasil diperbarui.');
                }
              },
            ),
            ListTile(
              leading: const Icon(TIcons.archive),
              title: const Text('Arsipkan Pelanggan'),
              onTap: () async {
                Navigator.of(context).pop();
                await _dialogKonfirmasiSoftDelete(pelanggan);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dialogKonfirmasiSoftDelete(PelangganModel customer) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Arsip'),
        content: Text(
          'Apakah Anda yakin ingin mengarsipkan pelanggan "${customer.nama}"?',
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
              await _softdelete(customer.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _softdelete(String id) async {
    try {
      await ref.read(pelangganProvider.notifier).softDelete(id);
      if (!mounted) return;
      ToastUtil.success(context, 'Pelanggan berhasil diarsipkan.');
    } on Exception catch (e, s) {
      Log.error('Gagal mengarsipkan pelanggan', e: e, s: s);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal mengarsipkan customer.');
      }
    }
  }
}
