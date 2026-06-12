// path: lib/admin/halaman/lainnya/package.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/form/form_paket.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/paket_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';

enum UrutanPaket {
  namaAZ,
  namaZA,
  hargaTertinggi,
  hargaTerendah,
  poinTertinggi,
  poinTerendah,
  durasiTerlama,
  durasiTerpendek,
}

class PackagePage extends ConsumerWidget {
  const PackagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPackages = ref.watch(packageListProvider);
    final urutanSaatIni = ref.watch(urutanPaketStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket'),
        actions: [
          IconButton(
            onPressed: () => _tampilkanDialogUrutkan(context, ref),
            icon: const Icon(TIcons.sort),
            tooltip: 'Urutkan',
          ),
          IconButton(
            onPressed: () => _hapusSemuaPaket(context, ref),
            icon: const Icon(TIcons.delete),
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: asyncPackages.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          Log.error('Terjadi error saat memuat data paket', e: err, s: stack);
          return Center(child: Text('Error: $err'));
        },
        data: (paketList) {
          if (paketList.isEmpty) {
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }

          // Kinerja optimal: Salin & urutkan list di sini aman karena ditangani asinkron reaktif
          final sortedList = List<PaketModel>.from(paketList);
          _urutkanList(sortedList, urutanSaatIni);

          return ListView.builder(
            itemCount: sortedList.length,
            itemBuilder: (context, index) {
              final paket = sortedList[index];
              return InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => DetailPaket(paket: paket),
                    ),
                  );
                },
                onLongPress: () => _showEditDeleteDialog(context, ref, paket),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      paket.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Rp ${paket.price} / ${paket.duration} ${paket.type.displayName}',
                    ),
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
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const FormPaket(),
            ),
          );
        },
        tooltip: 'Tambah Paket',
        child: const Icon(TIcons.add),
      ),
    );
  }
}

// --- FUNGSI UTAS / HELPER DI LUAR WIDGET CLASS ---

void _urutkanList(List<PaketModel> paketList, UrutanPaket urutan) {
  switch (urutan) {
    case UrutanPaket.namaAZ:
      paketList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case UrutanPaket.namaZA:
      paketList
          .sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      break;
    case UrutanPaket.hargaTertinggi:
      paketList.sort((a, b) => b.price.compareTo(a.price));
      break;
    case UrutanPaket.hargaTerendah:
      paketList.sort((a, b) => a.price.compareTo(b.price));
      break;
    case UrutanPaket.poinTertinggi:
      paketList.sort((a, b) => b.rewardPoints.compareTo(a.rewardPoints));
      break;
    case UrutanPaket.poinTerendah:
      paketList.sort((a, b) => a.rewardPoints.compareTo(b.rewardPoints));
      break;
    case UrutanPaket.durasiTerpendek:
      paketList.sort((a, b) =>
          _getDurationInMinutes(a).compareTo(_getDurationInMinutes(b)));
      break;
    case UrutanPaket.durasiTerlama:
      paketList.sort((a, b) =>
          _getDurationInMinutes(b).compareTo(_getDurationInMinutes(a)));
      break;
  }
}

int _getDurationInMinutes(PaketModel paket) {
  switch (paket.type) {
    case DurationType.minutes:
      return paket.duration;
    case DurationType.hours:
      return paket.duration * 60;
    case DurationType.days:
      return paket.duration * 24 * 60;
    case DurationType.months:
      return paket.duration *
          30 *
          24 *
          60; // Menggunakan perkalian 30 hari standar aplikasi
  }
}

Future<void> _tampilkanDialogUrutkan(
    BuildContext context, WidgetRef ref) async {
  final urutanSaatIni = ref.read(urutanPaketStateProvider);

  final hasil = await showDialog<UrutanPaket>(
    context: context,
    builder: (context) {
      Widget buildOption(String text, UrutanPaket value) {
        final isSelected = urutanSaatIni == value;
        return SimpleDialogOption(
          onPressed: () => Navigator.pop(context, value),
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: TSizes.p8, horizontal: TSizes.p4),
            decoration: BoxDecoration(
              color: isSelected ? TColors.pointBackground : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(text, textAlign: TextAlign.center),
          ),
        );
      }

      return SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: [
          buildOption('Durasi (Terpendek)', UrutanPaket.durasiTerpendek),
          buildOption('Durasi (Terlama)', UrutanPaket.durasiTerlama),
          buildOption('Nama (A-Z)', UrutanPaket.namaAZ),
          buildOption('Nama (Z-A)', UrutanPaket.namaZA),
          buildOption('Harga (Tertinggi)', UrutanPaket.hargaTertinggi),
          buildOption('Harga (Terendah)', UrutanPaket.hargaTerendah),
          buildOption('Poin (Tertinggi)', UrutanPaket.poinTertinggi),
          buildOption('Poin (Terendah)', UrutanPaket.poinTerendah),
        ],
      );
    },
  );

  if (hasil != null) {
    ref.read(urutanPaketStateProvider.notifier).ubahUrutan(hasil);
  }
}

Future<void> _showEditDeleteDialog(
    BuildContext context, WidgetRef ref, PaketModel paket) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(paket.name),
        content: const Text('Pilih aksi yang ingin Anda lakukan.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => FormPaket(package: paket),
                ),
              );
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              unawaited(_showDeleteConfirmationDialog(context, ref, paket));
            },
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );
}

Future<void> _showDeleteConfirmationDialog(
    BuildContext context, WidgetRef ref, PaketModel paket) async {
  final paketOperasi = ref.read(packageOperationProvider);

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus paket ${paket.name}?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () async {
              // Tutup dialog terlebih dahulu menggunakan dialogContext
              Navigator.of(dialogContext).pop();

              try {
                await paketOperasi.hapusSementara(paket.id);

                final _ = ref.refresh(packageListProvider);

                if (context.mounted) {
                  ToastUtil.success(context, 'Paket berhasil dihapus.');
                }
              } on Exception catch (e, s) {
                Log.error('Gagal hapus paket', e: e, s: s);
                if (context.mounted) {
                  ToastUtil.error(context, 'Gagal menghapus paket: $e');
                }
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _hapusSemuaPaket(BuildContext context, WidgetRef ref) async {
  Log.info('User menekan tombol hapus semua paket');
  final paketOperasi = ref.read(packageOperationProvider);

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus Semua'),
        content: const Text('Yakin ingin menghapus SEMUA paket?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Semua'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                Log.info('Menjalankan soft delete semua paket');
                await paketOperasi.hapusSementaraSemua();
                final _ = ref.refresh(packageListProvider);
                if (context.mounted) {
                  ToastUtil.success(context, 'Semua paket dihapus.');
                }
              } on Exception catch (e, s) {
                Log.error('Gagal hapus semua paket', e: e, s: s);
                if (context.mounted) {
                  ToastUtil.error(context, 'Gagal menghapus semua paket: $e');
                }
              }
            },
          ),
        ],
      );
    },
  );
}
