// path lib/fitur/paket/page/paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/paket/page/form_paket.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/durasi_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
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
    final paketAsync = ref.watch(paketProvider);
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
      body: paketAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) {
          Log.error('Terjadi error saat memuat data paket', e: e, s: s);
          return Center(child: Text('Error: $e'));
        },
        data: (paketList) {
          if (paketList.daftarPaket.isEmpty) {
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }
          final sortedList = List<PaketModel>.from(paketList.daftarPaket);
          _urutkanList(sortedList, urutanSaatIni);
          return ListView.builder(
            itemCount: sortedList.length,
            itemBuilder: (context, index) {
              final paket = sortedList[index];
              return InkWell(
                onTap: () {
                  unawaited(
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => DetailPaketPage(paket: paket),
                      ),
                    ),
                  );
                },
                onLongPress: () =>
                    _tampilkanDialogHapusEdit(context, ref, paket),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: TeksJudulSedang(
                      paket.nama,
                      tebalFont: FontWeight.bold,
                    ),
                    subtitle: TeksIsiKecil(
                      '${FormatUang.formatMataUang(paket.harga.toDouble())} / ${paket.durasi} ${paket.tipe.displayName}',
                    ),
                    trailing: TeksIsiSedang('Poin: ${paket.poinHadiah}'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          unawaited(
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (context) => const FormPaket()),
            ),
          );
        },
        tooltip: 'Tambah Paket',
        child: const Icon(TIcons.add),
      ),
    );
  }
}

void _urutkanList(List<PaketModel> daftarPaket, UrutanPaket urutan) {
  switch (urutan) {
    case UrutanPaket.namaAZ:
      daftarPaket.sort(
        (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
      );
      break;
    case UrutanPaket.namaZA:
      daftarPaket.sort(
        (a, b) => b.nama.toLowerCase().compareTo(a.nama.toLowerCase()),
      );
      break;
    case UrutanPaket.hargaTertinggi:
      daftarPaket.sort((a, b) => b.harga.compareTo(a.harga));
      break;
    case UrutanPaket.hargaTerendah:
      daftarPaket.sort((a, b) => a.harga.compareTo(b.harga));
      break;
    case UrutanPaket.poinTertinggi:
      daftarPaket.sort((a, b) => b.poinHadiah.compareTo(a.poinHadiah));
      break;
    case UrutanPaket.poinTerendah:
      daftarPaket.sort((a, b) => a.poinHadiah.compareTo(b.poinHadiah));
      break;
    case UrutanPaket.durasiTerpendek:
      daftarPaket.sort(
        (a, b) => DurasiUtil.hitungDurasiDalamMenit(
          a,
        ).compareTo(DurasiUtil.hitungDurasiDalamMenit(b)),
      );
      break;
    case UrutanPaket.durasiTerlama:
      daftarPaket.sort(
        (a, b) => DurasiUtil.hitungDurasiDalamMenit(
          b,
        ).compareTo(DurasiUtil.hitungDurasiDalamMenit(a)),
      );
      break;
  }
}

Future<void> _tampilkanDialogUrutkan(
  BuildContext context,
  WidgetRef ref,
) async {
  final urutanSaatIni = ref.read(urutanPaketStateProvider);

  final hasil = await showDialog<UrutanPaket>(
    context: context,
    builder: (context) {
      Widget buildOption(String text, UrutanPaket value) {
        final urutanTerpilih = urutanSaatIni == value;
        return SimpleDialogOption(
          onPressed: () => Navigator.pop(context, value),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: TSizes.p8,
              horizontal: TSizes.p4,
            ),
            decoration: BoxDecoration(
              color: urutanTerpilih ? TColors.pointBackground : null,
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

Future<void> _tampilkanDialogHapusEdit(
  BuildContext context,
  WidgetRef ref,
  PaketModel paket,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(paket.nama),
        content: const Text('Pilih aksi yang ingin Anda lakukan.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (!context.mounted) return;
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => FormPaket(paket: paket),
                  ),
                ),
              );
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _tampilkanDialogKonfirmasiHapus(context, ref, paket);
            },
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );
}

Future<void> _tampilkanDialogKonfirmasiHapus(
  BuildContext context,
  WidgetRef ref,
  PaketModel paket,
) async {
  final paketOp = ref.read(paketOpGlobalProvider);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus paket ${paket.nama}?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await paketOp.softDelete(paket.id);
                ref.invalidate(paketProvider);
                unawaited(
                  ref
                      .read(layananCekSinkronisasiProvider)
                      .jalankanCekSinkronisasi(),
                );
                if (dialogContext.mounted) {
                  ToastUtil.success(context, 'Paket berhasil dihapus.');
                }
              } on Exception catch (e, s) {
                Log.error('Gagal hapus paket', e: e, s: s);
                if (dialogContext.mounted) {
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
  final paketOpSqlite = ref.read(paketOpSqliteProvider);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
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
                await paketOpSqlite.hapusSementaraSemua();
                unawaited(
                  ref
                      .read(layananCekSinkronisasiProvider)
                      .jalankanCekSinkronisasi(),
                );
                ref.invalidate(paketProvider);
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
