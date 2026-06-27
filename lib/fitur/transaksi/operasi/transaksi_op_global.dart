// path: lib/fitur/transaksi/operasi/transaksi_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/user/providers/user_provider.dart';

/// Kelas operasi transaksi global yang menangani logika berdasarkan role pengguna.
class TransaksiOpGlobal {
  final Ref ref;

  TransaksiOpGlobal({required this.ref});

  TransaksiOpSqlite get _transaksiOpSqlite =>
      ref.read(transaksiOpSqliteProvider);
  TransaksiOpFirebase get _transaksiOpFirebase =>
      ref.read(transaksiOpFirebaseProvider);

  // =========================
  // OPERASI TAMBAH (CREATE)
  // =========================

  /// Menambahkan transaksi baru dengan logika berdasarkan role.
  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    Log.info('Menambahkan transaksi baru: ${transaksi.id}');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.tambahTransaksi(transaksi);
    } else {
      await _transaksiOpFirebase.tambahTransaksi(transaksi);
    }
  }

  // =========================
  // OPERASI BACA (READ)
  // =========================

  /// Mengambil semua transaksi berdasarkan role.
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

  /// Mengambil transaksi berdasarkan ID.
  Future<TransaksiModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mengambil transaksi berdasarkan ID: $id');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanId(id);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanId(id);
    }
  }

  /// Mengambil transaksi berdasarkan ID pelanggan.
  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    Log.info('Mengambil transaksi berdasarkan ID pelanggan: $idPelanggan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIdPelanggan(idPelanggan);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        idPelanggan,
      );
    }
  }

  /// Mengambil transaksi berdasarkan ID dompet.
  Future<List<TransaksiModel>> ambilBerdasarkanIdDompet(String idDompet) async {
    Log.info('Mengambil transaksi berdasarkan ID dompet: $idDompet');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIdDompet(idDompet);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanIdDompet(idDompet);
    }
  }

  /// Mengambil transaksi yang merupakan aktivasi paket.
  Future<List<TransaksiModel>> ambilBerdasarkanStatusAktivasi() async {
    Log.info('Mengambil transaksi dengan status aktivasi = true');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanStatusAktivasi();
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanStatusAktivasi();
    }
  }

  /// Mengambil transaksi berdasarkan daftar ID.
  Future<List<TransaksiModel>> ambilBerdasarkanIds(List<String> ids) async {
    Log.info('Mengambil transaksi berdasarkan ${ids.length} ID');
    if (ids.isEmpty) {
      Log.warning('Daftar ID kosong, mengembalikan list kosong');
      return [];
    }
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIds(ids);
    } else {
      // Firebase tidak memiliki method ini, implementasikan manual
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

  /// Mengambil paket aktif pelanggan berdasarkan role.
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

  /// Mengambil total poin pelanggan dengan logika berdasarkan role.
  Future<int> ambilTotalPoin(String idPelanggan) async {
    Log.info('Mengambil total poin untuk pelanggan: $idPelanggan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPoin(idPelanggan);
    } else {
      return await _transaksiOpFirebase.ambilTotalPoin(idPelanggan);
    }
  }

  // =========================
  // OPERASI STATISTIK
  // =========================

  /// Menghitung total pemasukan dari semua transaksi.
  Future<double> getTotalIncome() async {
    Log.info('Menghitung total pemasukan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.getTotalIncome();
    } else {
      return 0;
    }
  }

  /// Menghitung total pengeluaran dari semua transaksi.
  Future<double> getTotalExpense() async {
    Log.info('Menghitung total pengeluaran');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.getTotalExpense();
    } else {
      return 0;
    }
  }

  /// Menghitung total bersih (pemasukan - pengeluaran).
  Future<double> getNetTotal() async {
    Log.info('Menghitung total bersih');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.getNetTotal();
    } else {
      final income = await getTotalIncome();
      final expense = await getTotalExpense();
      return income - expense;
    }
  }

  /// Mengambil total pendapatan bersih per bulan.
  Future<double> ambilTotalPendapatanPerbulan() async {
    Log.info('Mengambil total pendapatan bersih per bulan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPendapatanPerbulan();
    } else {
      return 0;
    }
  }

  /// Mengambil paket terlaris.
  Future<List<PaketTerlarisModel>> ambilPaketTerlaris({int limit = 5}) async {
    Log.info('Mengambil paket terlaris, limit: $limit');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPaketTerlaris(limit: limit);
    } else {
      return [];
    }
  }

  /// Mengambil data pendapatan harian dalam 7 hari terakhir.
  Future<List<double>> ambilPendapatanHarian() async {
    Log.info('Mengambil pendapatan harian 7 hari terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanHarian();
    } else {
      return [];
    }
  }

  /// Mengambil data pendapatan mingguan dalam 4 minggu terakhir.
  Future<List<double>> ambilPendapatanMingguan() async {
    Log.info('Mengambil pendapatan mingguan 4 minggu terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanMingguan();
    } else {
      return [];
    }
  }

  /// Mengambil data pendapatan bulanan dalam 5 bulan terakhir.
  Future<List<double>> ambilPendapatanBulanan() async {
    Log.info('Mengambil pendapatan bulanan 5 bulan terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanBulanan();
    } else {
      return [];
    }
  }

  // =========================
  // OPERASI PERBARUI (UPDATE)
  // =========================

  /// Memperbarui transaksi dengan logika berdasarkan role.
  Future<void> perbaruiTransaksi(
    String id,
    TransaksiModel transaksi, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui transaksi ID: $id');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.perbaruiTransaksi(
        id,
        transaksi,
        dariServer: dariServer,
      );
    } else {
      await _transaksiOpFirebase.softDeleteTransaksi(id);
    }
  }

  // =========================
  // OPERASI HAPUS (DELETE)
  // =========================

  /// Menghapus transaksi (soft delete) dengan logika berdasarkan role.
  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Menghapus transaksi ID: $id');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.softDelete(id, dariServer: dariServer);
    } else {
      await _transaksiOpFirebase.softDeleteTransaksi(id);
    }
  }

  /// Menghapus semua transaksi (soft delete) dengan logika berdasarkan role.
  Future<int> softDeleteAll({bool dariServer = false}) async {
    Log.info('Menghapus semua transaksi');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.softDeleteAll(dariServer: dariServer);
    } else {
      // Untuk user, hapus semua transaksi miliknya
      final userId = await ref.read(userIdProvider.future);
      if (userId == null || userId.isEmpty) {
        Log.warning('User ID tidak ditemukan, tidak ada yang dihapus');
        return 0;
      }
      final transaksi = await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        userId,
      );
      for (final t in transaksi) {
        await _transaksiOpFirebase.softDeleteTransaksi(t.id);
      }
      return transaksi.length;
    }
  }

  // =========================
  // OPERASI BATCH
  // =========================

  /// Menyisipkan atau memperbarui beberapa transaksi sekaligus (batch) berdasarkan role.
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
  }

  /// Menghitung total poin semua pelanggan dengan logika berdasarkan role.
  ///
  /// Untuk admin: menggunakan SQLite (satu query agregasi).
  /// Untuk user: menghitung total poin semua pelanggan dari Firebase (iterasi semua transaksi).
  Future<int> ambilTotalPoinSemuaPelanggan() async {
    Log.info('Menghitung total poin semua pelanggan');

    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPoinSemuaPelanggan();
    } else {
      return 0;
    }
  }
}

/// Provider untuk TransaksiOpGlobal.
final transaksiOpGlobalProvider = Provider<TransaksiOpGlobal>((ref) {
  return TransaksiOpGlobal(ref: ref);
});
