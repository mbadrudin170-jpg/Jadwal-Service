// path: lib/fitur/transaksi/operasi/transaksi_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/user/providers/user_provider.dart';

class TransaksiOpGlobal {
  final Ref ref;
  TransaksiOpGlobal({required this.ref});

  TransaksiOpSqlite get _transaksiOpSqlite =>
      ref.read(transaksiOpSqliteProvider);
  TransaksiOpFirebase get _transaksiOpFirebase =>
      ref.read(transaksiOpFirebaseProvider);

  void _invalidate(String? idDompet) {
    ref.read(transaksiProvider.notifier).invalidateProviderTransaksi();
    ref.read(dompetProvider.notifier).invalidateDompetProvider(idDompet);
  }

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    Log.info('Menambahkan transaksi baru: ${transaksi.id}');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.tambahTransaksi(transaksi);
    } else {
      await _transaksiOpFirebase.tambahTransaksi(transaksi);
    }
    _invalidate(null);
  }

  Future<void> perbaruiTransaksi(
    TransaksiModel transaksi, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.perbaruiTransaksi(
        transaksi,
        dariServer: dariServer,
      );
    } else {
      await _transaksiOpFirebase.perbaruiTransaksi(transaksi);
    }
    _invalidate(null);
  }

  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Menghapus transaksi ID: $id');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.softDelete(id, dariServer: dariServer);
    } else {
      await _transaksiOpFirebase.softDeleteTransaksi(id);
    }
    _invalidate(null);
  }

  Future<void> softDeleteAll({bool dariServer = false}) async {
    Log.info('Menghapus semua transaksi');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.softDeleteAll(dariServer: dariServer);
    } else {
      final userId = await ref.read(userIdProvider.future);
      if (userId == null || userId.isEmpty) {
        Log.warning('User ID tidak ditemukan, tidak ada yang dihapus');
        return;
      }
      final transaksi = await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        userId,
      );
      for (final t in transaksi) {
        await _transaksiOpFirebase.softDeleteTransaksi(t.id);
      }
    }
    _invalidate(null);
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<TransaksiModel> items, {
    bool dariServer = false,
  }) async {
    if (items.isEmpty) {
      Log.info('Batch transaksi: daftar kosong, operasi dibatalkan.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${items.length} transaksi');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.sisipkanAtauPerbaruiBatch(
        items,
        dariServer: dariServer,
      );
    } else {
      await _transaksiOpFirebase.sisipkanAtauPerbaruiBatch(items);
    }
    _invalidate(null);
  }

  Future<List<TransaksiModel>> ambilSemua() async {
    Log.info('Mengambil semua transaksi berdasarkan role');
    if (RoleUtil.isAdmin(ref)) {
      Log.info('Mode Admin: Mengambil transaksi dari SQLite');
      return await _transaksiOpSqlite.ambilSemua();
    } else {
      Log.info('Mode User: Mengambil transaksi dari Firebase');
      final userId = await ref.read(userIdProvider.future);
      if (userId == null || userId.isEmpty) {
        Log.warning('User ID tidak ditemukan, mengembalikan list kosong');
        return [];
      }
      return await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(userId);
    }
  }

  Future<TransaksiModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mengambil transaksi berdasarkan ID: $id');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanId(id);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanId(id);
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    Log.info('[TransaksiOpGlobal] ambilBerdasarkanIdPelanggan: $idPelanggan');
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[TransaksiOpGlobal] Admin → SQLite');
      return await _transaksiOpSqlite.ambilBerdasarkanIdPelanggan(idPelanggan);
    } else {
      Log.info('[TransaksiOpGlobal] User → Firebase');
      return await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        idPelanggan,
      );
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanIdDompet(String idDompet) async {
    Log.info('Mengambil transaksi berdasarkan ID dompet: $idDompet');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIdDompet(idDompet);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanIdDompet(idDompet);
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanStatusAktivasi() async {
    Log.info('Mengambil transaksi dengan status aktivasi = true');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanStatusAktivasi();
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanStatusAktivasi();
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanIds(List<String> ids) async {
    Log.info('Mengambil transaksi berdasarkan ${ids.length} ID');
    if (ids.isEmpty) {
      Log.warning('Daftar ID kosong, mengembalikan list kosong');
      return [];
    }
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIds(ids);
    } else {
      final List<TransaksiModel> hasil = [];
      for (final id in ids) {
        final transaksi = await _transaksiOpFirebase.ambilBerdasarkanId(id);
        if (transaksi != null) {
          hasil.add(transaksi);
        }
      }
      return hasil;
    }
  }

  Future<List<TransaksiModel>> ambilPaketAktifPelanggan(
    String idPelanggan,
  ) async {
    Log.info('Mengambil paket aktif untuk pelanggan: $idPelanggan');
    if (RoleUtil.isAdmin(ref)) {
      final semuaTransaksi = await _transaksiOpSqlite
          .ambilBerdasarkanIdPelanggan(idPelanggan);
      final sekarang = DateTime.now();
      return semuaTransaksi
          .where(
            (t) =>
                t.tanggalBerakhir != null &&
                t.tanggalBerakhir!.isAfter(sekarang) &&
                t.statusPembayaran.name == 'paid',
          )
          .toList();
    } else {
      return await _transaksiOpFirebase.ambilPaketAktifPelanggan(idPelanggan);
    }
  }

  Future<int> ambilTotalPoin(String idPelanggan) async {
    Log.info('Mengambil total poin untuk pelanggan: $idPelanggan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPoin(idPelanggan);
    } else {
      return await _transaksiOpFirebase.ambilTotalPoin(idPelanggan);
    }
  }

  Future<double> ambilTotalPemasukan() async {
    Log.info('Menghitung total pemasukan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPemasukan();
    } else {
      return 0;
    }
  }

  Future<double> ambilTotalPengeluaran() async {
    Log.info('Menghitung total pengeluaran');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPengeluaran();
    } else {
      return 0;
    }
  }

  Future<double> getNetTotal() async {
    Log.info('Menghitung total bersih');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.getNetTotal();
    } else {
      final income = await ambilTotalPemasukan();
      final expense = await ambilTotalPengeluaran();
      return income - expense;
    }
  }

  Future<double> ambilTotalPendapatanPerbulan() async {
    Log.info('Mengambil total pendapatan bersih per bulan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPendapatanPerbulan();
    } else {
      return 0;
    }
  }

  Future<List<PaketTerlarisModel>> ambilPaketTerlaris({int limit = 5}) async {
    Log.info('Mengambil paket terlaris, limit: $limit');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPaketTerlaris(limit: limit);
    } else {
      return [];
    }
  }

  Future<List<double>> ambilPendapatanHarian() async {
    Log.info('Mengambil pendapatan harian 7 hari terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanHarian();
    } else {
      return [];
    }
  }

  Future<List<double>> ambilPendapatanMingguan() async {
    Log.info('Mengambil pendapatan mingguan 4 minggu terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanMingguan();
    } else {
      return [];
    }
  }

  Future<List<double>> ambilPendapatanBulanan() async {
    Log.info('Mengambil pendapatan bulanan 5 bulan terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanBulanan();
    } else {
      return [];
    }
  }

  Future<int> ambilTotalPoinSemuaPelanggan() async {
    Log.info('Menghitung total poin semua pelanggan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPoinSemuaPelanggan();
    } else {
      return 0;
    }
  }
}

final transaksiOpGlobalProvider = Provider<TransaksiOpGlobal>((ref) {
  return TransaksiOpGlobal(ref: ref);
});
