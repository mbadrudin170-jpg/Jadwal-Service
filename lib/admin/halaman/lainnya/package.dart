// path: lib/admin/halaman/lainnya/package.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/package_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
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
    Log.info('Membangun UI halaman Daftar Paket');

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
          Log.error('Terjadi error saat memuat data paket', e: err, st: stack);
          return Center(child: Text('Error: $err'));
        },
        data: (paketList) {
          if (paketList.isEmpty) {
            Log.info('Data paket kosong, tidak ada paket yang tersedia');
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }

          // Kinerja optimal: Salin & urutkan list di sini aman karena ditangani asinkron reaktif
          final sortedList = List<PackageModel>.from(paketList);
          _urutkanList(sortedList, urutanSaatIni);

          Log.info(
              'Menampilkan ${sortedList.length} paket, urutan: $urutanSaatIni');

          return ListView.builder(
            itemCount: sortedList.length,
            itemBuilder: (context, index) {
              final paket = sortedList[index];
              return InkWell(
                onTap: () async {
                  Log.info('Navigasi ke Detail Paket: ${paket.name}');
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => PackageDetailPage(package: paket),
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
          Log.info('Navigasi ke Form Tambah Paket');
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const PackageForm(),
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

void _urutkanList(List<PackageModel> paketList, UrutanPaket urutan) {
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

int _getDurationInMinutes(PackageModel paket) {
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
  Log.info('Menampilkan dialog urutkan');
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
    BuildContext context, WidgetRef ref, PackageModel paket) async {
  Log.info('Menampilkan dialog opsi untuk paket: ${paket.name}');
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
                  builder: (context) => PackageForm(package: paket),
                ),
              );
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showDeleteConfirmationDialog(context, ref, paket);
            },
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );
}

Future<void> _showDeleteConfirmationDialog(
    BuildContext context, WidgetRef ref, PackageModel paket) async {
  Log.info('Menampilkan konfirmasi hapus untuk: ${paket.name}');
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
                Log.info('Menjalankan soft delete untuk: ${paket.name}');
                await paketOperasi.softDelete(paket.id);

                ref.invalidate(packageListProvider);

                if (context.mounted) {
                  ToastUtil.success(context, 'Paket berhasil dihapus.');
                }
              } on Exception catch (e, s) {
                Log.error('Gagal hapus paket', e: e, st: s);
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
                await paketOperasi.softDeleteAll();

                ref.invalidate(packageListProvider);

                if (context.mounted) {
                  ToastUtil.success(context, 'Semua paket dihapus.');
                }
              } on Exception catch (e, s) {
                Log.error('Gagal hapus semua paket', e: e, st: s);
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
