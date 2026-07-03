# Dokumentasi Fitur: dompet

## Daftar file

- [lib/fitur/dompet/model/dompet_model.dart](../../lib/fitur/dompet/model/dompet_model.dart)
- [lib/fitur/dompet/operasi/dompet_op_sqlite.dart](../../lib/fitur/dompet/operasi/dompet_op_sqlite.dart)
- [lib/fitur/dompet/page/detail_dompet.dart](../../lib/fitur/dompet/page/detail_dompet.dart)
- [lib/fitur/dompet/page/dompet_page.dart](../../lib/fitur/dompet/page/dompet_page.dart)
- [lib/fitur/dompet/page/form_dompet.dart](../../lib/fitur/dompet/page/form_dompet.dart)
- [lib/fitur/dompet/provider/dompet_provider.dart](../../lib/fitur/dompet/provider/dompet_provider.dart)

## Isi file

### File: `lib/fitur/dompet/model/dompet_model.dart`
```dart
// path: lib/fitur/dompet/model/dompet_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'dompet_model.freezed.dart';

@freezed
abstract class DompetModel with _$DompetModel implements HasId {
  const DompetModel._();

  const factory DompetModel({
    required String id,
    required String nama,
    @Default(0.0) double saldo,
    DateTime? diperbaruiPada,
    @Default(false) bool dihapus,
    DateTime? diarsipkanPada,
  }) = _DompetModel;

  // Method dari SQLite
  factory DompetModel.fromSqlite(Map<String, dynamic> map) {
    final id = map[NamaKolom.id] as String?;
    return DompetModel(
      id: id ?? const Uuid().v4(),
      nama: (map[NamaKolom.nama] as String?) ?? '',
      saldo: (map[NamaKolom.saldo] as num?)?.toDouble() ?? 0.0,
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      dihapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.saldo: saldo,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: dihapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  // Method dari Firebase
  factory DompetModel.fromFirebase(String id, Map<String, dynamic> data) {
    return DompetModel(
      id: id,
      nama: (data[NamaKolom.nama] as String?) ?? '',
      saldo: (data[NamaKolom.saldo] as num?)?.toDouble() ?? 0.0,
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      dihapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.saldo: saldo,
      NamaKolom.dihapus: dihapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
    };
  }
}
```

### File: `lib/fitur/dompet/operasi/dompet_op_sqlite.dart`
```dart
// path: lib/fitur/dompet/operasi/dompet_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class DompetOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final String _tabelDompet = NamaTabel.dompet;
  final _nowUtc = DateTime.now().toUtc();

  DompetOpSqlite({
    required this.sqliteDb,
    required final BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite;

  Future<void> tambahDompet(
    final DompetModel dompet, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai tambahDompet untuk wallet: ${dompet.id}');
    try {
      final data = dompet.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOpSqlite.sisipkan(_tabelDompet, data, dariServer: dariServer);
      Log.info('Berhasil membuat wallet dengan ID: ${dompet.id}');
    } on Exception catch (e, st) {
      Log.error('Gagal saat tambahDompet', e: e, s: st);
      rethrow;
    }
  }

  Future<List<DompetModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Memulai getWallets (showArchived: $tampilkanYangDiarsip).');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? null
          : '${NamaKolom.dihapus} = 0 AND ${NamaKolom.diarsipkanPada} IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelDompet,
        where: query,
      );

      final daftarDompet = List.generate(
        maps.length,
        (i) => DompetModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${daftarDompet.length} data wallet.');
      return daftarDompet;
    } catch (e, st) {
      Log.error('Gagal saat getWallets', e: e, s: st);
      rethrow;
    }
  }

  Future<DompetModel?> ambilBerdasarkanId(String id) async {
    Log.info('Memulai getById untuk ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelDompet,
        where: '${NamaKolom.id} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final wallet = DompetModel.fromSqlite(maps.first);
        Log.info('Wallet dengan ID: $id ditemukan.');
        return wallet;
      }

      Log.warning('Wallet dengan ID: $id tidak ditemukan di database.');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getById untuk ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<void> updateDompet(DompetModel wallet) async {
    Log.info('Memulai updateDompet untuk wallet ID: ${wallet.id}');
    try {
      final data = wallet.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOpSqlite.update(_tabelDompet, data, wallet.id);
      Log.info('Berhasil updateDompet untuk ID: ${wallet.id}.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat updateDompet untuk ID: ${wallet.id}', e: e, s: st);
      rethrow;
    }
  }

  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Memulai soft delete untuk wallet ID: $id');
    try {
      await _baseOpSqlite.softDelete(_tabelDompet, id, dariServer: dariServer);
      Log.info('Berhasil soft delete wallet ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat soft delete wallet ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAll({bool dariServer = false}) async {
    Log.info('Memulai soft delete untuk semua dompet');
    try {
      final count = await _baseOpSqlite.softDeleteAll(
        _tabelDompet,
        dariServer: dariServer,
      );
      Log.info('Berhasil soft delete semua dompet. Total: $count item.');
      return count;
    } catch (e, st) {
      Log.error('Gagal saat soft delete semua dompet', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilTotalsaldo() async {
    Log.info(
      'Memulai ambilTotalsaldo (menghitung total saldo dari semua wallet aktif).',
    );
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.saldo}) as total FROM $_tabelDompet WHERE ${NamaKolom.dihapus} = 0',
      );

      var total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat ambilTotalsaldo', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilSaldoPositif() async {
    Log.info(
      'Memulai ambilSaldoPositif (menghitung total saldo > 0 dari wallet aktif).',
    );
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.saldo}) as total FROM $_tabelDompet WHERE ${NamaKolom.saldo} > 0 AND ${NamaKolom.dihapus} = 0',
      );

      var total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo positif: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat ambilSaldoPositif', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilSaldoNegatif() async {
    Log.info(
      'Memulai ambilSaldoNegatif (menghitung total saldo < 0 dari wallet aktif).',
    );
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.saldo}) as total FROM $_tabelDompet WHERE ${NamaKolom.saldo} < 0 AND ${NamaKolom.dihapus} = 0',
      );

      var total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo negatif: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat ambilSaldoNegatif', e: e, s: st);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<DompetModel> daftarDompet, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai batch insert/update untuk ${daftarDompet.length} data dompet.',
    );
    if (daftarDompet.isEmpty) {
      Log.warning('Daftar dompet kosong, membatalkan operasi batch.');
      return;
    }
    try {
      final data = daftarDompet
          .map((item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite())
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _tabelDompet,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch dompet selesai diproses.');
    } on Exception catch (e, st) {
      Log.error('Gagal menjalankan batch dompet', e: e, s: st);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/dompet/page/detail_dompet.dart`
```dart
// path: lib/fitur/dompet/page/detail_dompet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/page/form_dompet.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_a.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/widget/daftar_transaksi_widget.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/widget/ringkasan_keuangan_widget.dart';

class DetailDompet extends ConsumerWidget {
  final DompetModel dompet;
  const DetailDompet({super.key, required this.dompet});

  void _navigasiKeDetailTransaksi(
    BuildContext context,
    TransaksiModel transaksi,
  ) {
    Log.info(
      'Navigasi ke TransactionDetailPage dari WalletDetail untuk transaksi ID: ${transaksi.id}',
    );
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiA(transaksi: transaksi),
      ),
    );
  }

  void _navigasiKeFormTransaksi(
    BuildContext context, {
    TransaksiModel? transaksi,
  }) {
    Log.info(
      'Membuka FormTransaksiPage untuk mengedit transaksi ID: ${transaksi?.id} dari WalletDetail.',
    );
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => FormTransaksi(transaksi: transaksi),
      ),
    );
  }

  void _navigasiKeFormDompet(
    BuildContext context, {
    required DompetModel dompet,
  }) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => FormDompet(dompet: dompet)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailDompet = ref.watch(detailDompetProvider(dompet.id));
    return detailDompet.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Gagal memuat transaksi: $err')),
      data: (detailDompet) {
        final daftarTransaksi = detailDompet.daftarTransaksi;
        final totalPemasukan = detailDompet.totalPemasukan;
        final totalPengeluaran = detailDompet.totalPengeluaran;
        final total = detailDompet.totalSaldo;
        return Scaffold(
          appBar: AppBar(
            title: Text(detailDompet.namaDompet),
            actions: [
              IconButton(
                onPressed: () {
                  _navigasiKeFormDompet(
                    context,
                    dompet: detailDompet.dompet ?? dompet,
                  );
                },
                icon: const Icon(TIcons.edit),
              ),
            ],
          ),
          body: Column(
            children: [
              RingkasanKeuanganWidget(
                pemasukan: totalPemasukan,
                pengeluaran: totalPengeluaran,
                total: total,
              ),
              Expanded(
                child: _bangunDaftarTransaksi(context, ref, daftarTransaksi),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bangunDaftarTransaksi(
    BuildContext context,
    WidgetRef ref,
    List<TransaksiModel> daftarTransaksi,
  ) {
    final transaksiPerTanggal = kelompokkanTransaksiPerTanggal(daftarTransaksi);
    return ListView.builder(
      itemCount: transaksiPerTanggal.length,
      itemBuilder: (context, index) {
        final tanggal = transaksiPerTanggal.keys.elementAt(index);
        final transaksiPadaTanggal = transaksiPerTanggal[tanggal]!;
        final totalHarian = transaksiPadaTanggal.fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.income ? item.jumlah : -item.jumlah),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bangunHeaderBagian(tanggal, totalHarian),
            ...transaksiPadaTanggal.map(
              (transaction) => bangunItemTransaksi(
                context,
                transaction,
                onTap: () {
                  _navigasiKeDetailTransaksi(context, transaction);
                },
                onEdit: () {
                  _navigasiKeFormTransaksi(context, transaksi: transaction);
                },
                onDelete: () async {
                  Log.info('Hapus transaksi: ${transaction.id}');
                  await ref
                      .read(transaksiOpGlobalProvider)
                      .softDelete(transaction.id);
                  ref.invalidate(detailDompetProvider(dompet.id));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### File: `lib/fitur/dompet/page/dompet_page.dart`
```dart
// path: lib/fitur/dompet/page/dompet_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/page/detail_dompet.dart';
import 'package:wifi/fitur/dompet/page/form_dompet.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/ringkasan_keuangan_widget.dart';

class DompetPage extends ConsumerWidget {
  const DompetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Log.info('Membangun UI untuk Halaman Wallet (ConsumerWidget).');
    final dompetStateAsync = ref.watch(dompetProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            onPressed: () {
              ToastUtil.info(context, 'Fitur dalam pengembangan');
            },
            icon: const Icon(TIcons.sort),
          ),
          IconButton(
            icon: const Icon(TIcons.delete),
            onPressed: () => _tampilkanDialogSoftDeleteAll(context, ref),
            tooltip: 'Hapus Semua Dompet',
          ),
        ],
      ),
      body: dompetStateAsync.when(
        loading: () {
          Log.info('WalletProvider sedang loading.');
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          Log.error('Error saat memuat WalletProvider.', e: err, s: stack);
          return Center(
            child: Text(
              'Terjadi kesalahan: $err',
              style: context.textTheme.bodyMedium,
            ),
          );
        },
        data: (dompetState) {
          Log.info(
            'WalletProvider berhasil memuat ${dompetState.daftarDompet.length} dompet.',
          );
          final daftarDompet = dompetState.daftarDompet;
          if (daftarDompet.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada dompet ditemukan.',
                style: context.textTheme.bodyMedium,
              ),
            );
          }
          return Column(
            children: [
              RingkasanKeuanganWidget(
                pemasukan: dompetState.totalSaldoPositif,
                pengeluaran: dompetState.totalSaldoNegatif,
                total: dompetState.totalSaldo,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: TSizes.p8),
                  itemCount: daftarDompet.length,
                  itemBuilder: (context, index) {
                    final dompet = daftarDompet[index];
                    return WalletCard(
                      dompet: dompet,
                      onTap: () =>
                          _navigasiKeDetailDompet(context, ref, dompet),
                      onLongPress: () =>
                          _tampilkanDialogSoftDelete(context, ref, dompet),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_wallet',
        onPressed: () => _navigasiKeForm(context, ref),
        tooltip: 'Tambah Dompet',
        child: const Icon(TIcons.add),
      ),
    );
  }

  void _navigasiKeForm(BuildContext context, WidgetRef ref) {
    Log.info('Navigasi ke halaman tambah dompet.');
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const FormDompet()),
    );
  }

  void _navigasiKeDetailDompet(
    BuildContext context,
    WidgetRef ref,
    DompetModel dompet,
  ) {
    Log.info('Navigasi ke detail dompet: "${dompet.nama}".');
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => DetailDompet(dompet: dompet)),
    );
  }

  Future<void> _tampilkanDialogSoftDeleteAll(
    BuildContext context,
    WidgetRef ref,
  ) async {
    Log.info('Menampilkan dialog konfirmasi hapus semua dompet.');
    final daftarDompet = ref.read(dompetProvider).value?.daftarDompet ?? [];
    if (daftarDompet.isEmpty) {
      Log.warning('Tidak ada dompet untuk dihapus.');
      ToastUtil.info(context, 'Tidak ada dompet untuk dihapus.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua dompet? Aksi ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Hapus Semua'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await ref.read(dompetProvider.notifier).softDeleteAll();
                  if (context.mounted) {
                    ToastUtil.success(
                      context,
                      'Semua dompet berhasil dihapus.',
                    );
                  }
                  unawaited(
                    ref
                        .read(layananCekSinkronisasiProvider)
                        .jalankanCekSinkronisasi(),
                  );
                } on Exception catch (e) {
                  if (context.mounted) {
                    ToastUtil.error(context, 'Gagal menghapus dompet: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _tampilkanDialogSoftDelete(
    BuildContext context,
    WidgetRef ref,
    DompetModel dompet,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus dompet "${dompet.nama}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await ref.read(dompetProvider.notifier).softDelete(dompet.id);
                  if (context.mounted) {
                    ToastUtil.success(context, 'Dompet berhasil dihapus.');
                  }
                  unawaited(
                    ref
                        .read(layananCekSinkronisasiProvider)
                        .jalankanCekSinkronisasi(),
                  );
                } on Exception catch (e) {
                  if (context.mounted) {
                    ToastUtil.error(context, 'Gagal menghapus: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class WalletCard extends StatelessWidget {
  final DompetModel dompet;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const WalletCard({
    super.key,
    required this.dompet,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleColor = dompet.saldo < 0
        ? context.colorScheme.error
        : context.textTheme.bodySmall?.color;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: TSizes.p16,
        vertical: TSizes.p8,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(TSizes.p16),
        leading: const Icon(
          TIcons.wallet,
          size: 40,
          color: TColors.primaryColor,
        ),
        title: TeksJudulSedang(dompet.nama),
        subtitle: TeksIsiSedang(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(dompet.saldo)}',
          warna: subtitleColor,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
```

### File: `lib/fitur/dompet/page/form_dompet.dart`
```dart
// path: lib/fitur/dompet/page/form_dompet.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';

/// Halaman form untuk menambah atau mengedit dompet.
class FormDompet extends ConsumerStatefulWidget {
  /// Model dompet yang akan diedit. Jika null, maka form akan membuat dompet baru.
  final DompetModel? dompet;

  /// Konstruktor untuk WalletForm.
  const FormDompet({super.key, this.dompet});

  @override
  ConsumerState<FormDompet> createState() => _WalletFormState();
}

class _WalletFormState extends ConsumerState<FormDompet> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  late final DompetOpSqlite _dompetOpSqlite;
  late FocusNode _namaFocusNode;
  bool get _modeEdit => widget.dompet != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    _namaFocusNode = FocusNode();
    if (_modeEdit) {
      _namaController.text = widget.dompet!.nama;
    }
  }

  @override
  void dispose() {
    Log.info('Dispose WalletForm. Membersihkan resource.');
    _namaController.dispose();
    _namaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _simpanform() async {
    if (_menyimpan) return;
    try {
      _menyimpan = true;
      _namaFocusNode.unfocus();
      if (!_formKey.currentState!.validate()) {
        return;
      }
      Log.info('Validasi form berhasil. Nama: "${_namaController.text}"');

      if (_modeEdit) {
        Log.info('Proses UPDATE dompet ID: ${widget.dompet!.id}');
        Log.info(
          'Nama Lama: "${widget.dompet!.nama}", Nama Baru: "${_namaController.text}"',
        );
        Log.info('Saldo tetap: ${widget.dompet!.saldo}');
        final dataBaru = DompetModel(
          id: widget.dompet!.id,
          nama: _namaController.text,
          saldo: widget.dompet!.saldo,
        );
        await _dompetOpSqlite.updateDompet(dataBaru);
        ref.invalidate(detailDompetProvider(widget.dompet!.id));
      } else {
        final dataBaru = DompetModel(
          id: const Uuid().v4(),
          nama: _namaController.text,
        );
        await _dompetOpSqlite.tambahDompet(dataBaru);
      }
      ref.invalidate(dompetProvider);
      unawaited(
        ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
      );
      if (!mounted) return;
      ToastUtil.success(context, 'Dompet berhasil disimpan.');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e, s) {
      Log.error(
        'Gagal menyimpan dompet. Proses ${_modeEdit ? "update" : "create"} gagal.',
        e: e,
        s: s,
      );
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal menyimpan dompet: $e');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Build WalletForm. Mode: ${_modeEdit ? "EDIT" : "TAMBAH BARU"}, Nama: "${_namaController.text}"',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Nama Dompet' : 'Tambah Dompet Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputTeks(
                controller: _namaController,
                focusNode: _namaFocusNode,
                label: 'Nama Dompet',
                textInputAction: TextInputAction.done,
                prefixIcon: TIcons.wallet,
                onSubmitted: (_) async {
                  await _simpanform();
                },
              ),
              // TextFormField(
              //   controller: _namaController,
              //   focusNode: _namaFocusNode,
              //   decoration: const InputDecoration(
              //     labelText: 'Nama Dompet',
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(TIcons.wallet),
              //   ),
              //   textInputAction: TextInputAction.done,
              //   onFieldSubmitted: (_) async {
              //     Log.info('Field nama disubmit. Memanggil simpan.');
              //     await _simpanform();
              //   },
              //   onChanged: (value) {
              //     Log.info(
              //       'Nama dompet berubah: "$value" (${value.length} karakter)',
              //     );
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       Log.warning('Validasi: Nama dompet kosong.');
              //       return 'Nama dompet tidak boleh kosong';
              //     }
              //     return null;
              //   },
              // ),
              gapH24,
              ElevatedButton(
                onPressed: _menyimpan
                    ? null
                    : () async {
                        await _simpanform();
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, TSizes.p48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.p12),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/dompet/provider/dompet_provider.dart`
```dart
// path: lib/fitur/dompet/provider/dompet_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'dompet_provider.freezed.dart';
part 'dompet_provider.g.dart';

@freezed
abstract class DetailDompetState with _$DetailDompetState {
  const factory DetailDompetState({
    required List<TransaksiModel> daftarTransaksi,
    DompetModel? dompet,
    required int totalTransaksi,
    required double totalPemasukan,
    required double totalPengeluaran,
    required double totalSaldo,
    required String namaDompet,
  }) = _DetailDompetState;
}

@freezed
abstract class DompetState with _$DompetState {
  const factory DompetState({
    @Default([]) List<DompetModel> daftarDompet,
    @Default(0.0) double totalSaldoPositif,
    @Default(0.0) double totalSaldoNegatif,
    @Default(0.0) double totalSaldo,
  }) = _DompetState;
}

@riverpod
class Dompet extends _$Dompet {
  @override
  FutureOr<DompetState> build() {
    return _loadData();
  }

  Future<DompetState> _loadData() async {
    final operation = ref.read(dompetOpSqliteProvider);
    final results = await Future.wait([
      operation.ambilSemua(),
      operation.ambilSaldoPositif(),
      operation.ambilSaldoNegatif(),
      operation.ambilTotalsaldo(),
    ]);

    return DompetState(
      daftarDompet: results[0] as List<DompetModel>,
      totalSaldoPositif: results[1] as double,
      totalSaldoNegatif: (results[2] as double).abs(),
      totalSaldo: results[3] as double,
    );
  }

  /// fungsi untuk menambah data dompet baru
  Future<void> tambahDompet(DompetModel dompet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.tambahDompet(dompet);
      return _loadData();
    });
  }

  /// fungsi untuk update satu data dompet
  Future<void> updateDompet(DompetModel dompet) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.updateDompet(dompet);
      return _loadData();
    });
  }

  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.softDelete(id);
      return _loadData();
    });
  }

  Future<void> softDeleteAll() async {
    state = await AsyncValue.guard(() async {
      final operation = ref.read(dompetOpSqliteProvider);
      await operation.softDeleteAll();
      return _loadData();
    });
  }

  /// fungsi untuk menyegarkan data dompet
  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadData);
  }

  void invalidateDompetProvider(String? idDompet) {
    ref.invalidateSelf();
    if (idDompet != null) {
      ref.invalidate(detailDompetProvider(idDompet));
    } else {
      ref.invalidate(detailDompetProvider);
    }
  }
}

@riverpod
Future<DetailDompetState> detailDompet(Ref ref, String idDompet) async {
  try {
    final dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    final results = await Future.wait([
      transaksiOp.ambilBerdasarkanIdDompet(idDompet),
      dompetOpSqlite.ambilBerdasarkanId(idDompet),
    ]);
    final daftarTransaksi = results[0] as List<TransaksiModel>;
    final dompet = results[1] as DompetModel?;
    double totalPemasukan = 0;
    double totalPengeluaran = 0;
    for (final transaksi in daftarTransaksi) {
      if (transaksi.tipe == TipeTransaksi.income) {
        totalPemasukan += transaksi.jumlah;
      } else if (transaksi.tipe == TipeTransaksi.expense) {
        totalPengeluaran += transaksi.jumlah;
      }
    }
    final totalSaldo = totalPemasukan - totalPengeluaran;
    final namaDompet = dompet?.nama ?? 'Dompet Tidak Ditemukan';
    return DetailDompetState(
      daftarTransaksi: daftarTransaksi,
      dompet: dompet,
      totalTransaksi: daftarTransaksi.length,
      totalPemasukan: totalPemasukan,
      totalPengeluaran: totalPengeluaran,
      totalSaldo: totalSaldo,
      namaDompet: namaDompet,
    );
  } on Exception catch (e, s) {
    Log.error('Error diDetailDompet: $e', e: e, s: s);
    rethrow;
  }
}
```

