// path: lib/fitur/transaksi/operasi/transaksi_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
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
  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.tambahTransaksi(transaksi);
    } else {
      await _transaksiOpFirebase.tambahTransaksi(transaksi);
    }
  }

  Future<List<TransaksiModel>> ambilSemua() async {
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilSemua();
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        await ref.read(userIdProvider.future) ?? '',
      );
    }
  }

  /// Mengambil transaksi berdasarkan ID.
  Future<TransaksiModel?> ambilBerdasarkanId(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanId(id);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanId(id);
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanIdDompet(String idDompet) async {
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIdDompet(idDompet);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanIdDompet(idDompet);
    }
  }

  /// Mengambil transaksi berdasarkan ID pelanggan.
  Future<List<TransaksiModel>> ambilTransaksiBerdasarkanPelanggan(
    String idPelanggan,
  ) async {
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIdPelanggan(idPelanggan);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        idPelanggan,
      );
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanStatusAktivasi() async {
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanStatusAktivasi();
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanStatusAktivasi();
    }
  }

  /// Mengupdate transaksi dengan logika berdasarkan role.
  Future<void> updateTransaksi(String id, TransaksiModel transaksi) async {
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.perbaruiTransaksi(id, transaksi);
    } else {
      await _transaksiOpFirebase.softDeleteTransaksi(id);
    }
  }

  /// Menghapus transaksi (soft delete) dengan logika berdasarkan role.
  Future<void> hapusTransaksi(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.softDelete(id);
    } else {
      await _transaksiOpFirebase.softDeleteTransaksi(id);
    }
  }

  /// Mengambil total poin pelanggan dengan logika berdasarkan role.
  Future<int> ambilTotalPoin(String idPelanggan) async {
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPoin(idPelanggan);
    } else {
      return await _transaksiOpFirebase.ambilTotalPoin(idPelanggan);
    }
  }

  /// Mengambil paket aktif pelanggan berdasarkan role.
  Future<List<TransaksiModel>> ambilPaketAktifPelanggan(
    String idPelanggan,
  ) async {
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

  /// Menyisipkan atau memperbarui beberapa transaksi sekaligus (batch) berdasarkan role pengguna.
  ///
  /// Jika user adalah admin, menggunakan SQLite. Jika user, menggunakan Firebase.
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
      await _transaksiOpSqlite.sisipkanAtauPerbaruiBatch(items);
    } else {
      await _transaksiOpFirebase.sisipkanAtauPerbaruiBatch(items);
    }
  }
}

/// Provider untuk TransaksiOpGlobal.
final transaksiOpGlobalProvider = Provider<TransaksiOpGlobal>((ref) {
  return TransaksiOpGlobal(ref: ref);
});
