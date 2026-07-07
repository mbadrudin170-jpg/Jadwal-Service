// path: lib/fitur/investasi/operasi/investasi_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_firebase.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

/// Kelas global untuk operasi investasi dan dividen.
/// Menentukan apakah menggunakan SQLite (admin) atau Firebase (user) berdasarkan role.
class InvestasiOpGlobal {
  final Ref ref;

  InvestasiOpGlobal({required this.ref});

  InvestasiOpSqlite get _investasiOpSqlite =>
      ref.read(investasiOpSqliteProvider);
  InvestasiOpFirebase get _investasiOpFirebase =>
      ref.read(investasiOpFirebaseProvider);

  // ============================================================
  // INVESTASI
  // ============================================================

  /// Menambahkan investasi baru.
  Future<void> tambahInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin menambah investasi ke SQLite: ${investasi.id}',
      );
      await _investasiOpSqlite.tambahInvestasi(
        investasi,
        dariServer: dariServer,
      );
    } else {
      Log.info(
        '[InvestasiOpGlobal] User menambah investasi ke Firebase: ${investasi.id}',
      );
      await _investasiOpFirebase.tambahInvestasi(investasi);
    }
  }

  /// Mengambil semua investasi.
  Future<List<InvestasiModel>> ambilSemuaInvestasi({
    bool tampilkanYangDiarsip = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[InvestasiOpGlobal] Admin mengambil investasi dari SQLite');
      return await _investasiOpSqlite.ambilSemuaInvestasi(
        tampilkanYangDiarsip: tampilkanYangDiarsip,
      );
    } else {
      Log.info('[InvestasiOpGlobal] User mengambil investasi dari Firebase');
      return await _investasiOpFirebase.ambilSemuaInvestasi(
        tampilkanYangDiarsip: tampilkanYangDiarsip,
      );
    }
  }

  /// Mengambil investasi berdasarkan ID.
  Future<InvestasiModel?> ambilInvestasiById(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil investasi ID: $id dari SQLite',
      );
      return await _investasiOpSqlite.ambilInvestasiById(id);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil investasi ID: $id dari Firebase',
      );
      return await _investasiOpFirebase.ambilInvestasiById(id);
    }
  }

  /// Mengambil investasi berdasarkan ID investor.
  Future<List<InvestasiModel>> ambilInvestasiByIdInvestor(
    String idInvestor,
  ) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil investasi untuk investor ID: $idInvestor dari SQLite',
      );
      return await _investasiOpSqlite.ambilInvestasiByIdInvestor(idInvestor);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil investasi untuk investor ID: $idInvestor dari Firebase',
      );
      return await _investasiOpFirebase.ambilInvestasiByIdInvestor(idInvestor);
    }
  }

  /// Memperbarui investasi.
  Future<void> perbaruiInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin memperbarui investasi di SQLite: ${investasi.id}',
      );
      await _investasiOpSqlite.perbaruiInvestasi(
        investasi,
        dariServer: dariServer,
      );
    } else {
      Log.info(
        '[InvestasiOpGlobal] User memperbarui investasi di Firebase: ${investasi.id}',
      );
      await _investasiOpFirebase.perbaruiInvestasi(investasi);
    }
  }

  /// Soft delete investasi.
  Future<void> softDeleteInvestasi(String id, {bool dariServer = false}) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin soft delete investasi di SQLite: $id',
      );
      await _investasiOpSqlite.softDeleteInvestasi(id, dariServer: dariServer);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User soft delete investasi di Firebase: $id',
      );
      await _investasiOpFirebase.softDeleteInvestasi(id);
    }
  }

  // ============================================================
  // DIVIDEN
  // ============================================================

  /// Menambahkan dividen baru.
  Future<void> tambahDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin menambah dividen ke SQLite: ${dividen.id}',
      );
      await _investasiOpSqlite.tambahDividen(dividen, dariServer: dariServer);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User menambah dividen ke Firebase: ${dividen.id}',
      );
      await _investasiOpFirebase.tambahDividen(dividen);
    }
  }

  /// Mengambil semua dividen.
  Future<List<DividenModel>> ambilSemuaDividen({
    bool tampilkanYangDiarsip = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[InvestasiOpGlobal] Admin mengambil dividen dari SQLite');
      return await _investasiOpSqlite.ambilSemuaDividen(
        tampilkanYangDiarsip: tampilkanYangDiarsip,
      );
    } else {
      Log.info('[InvestasiOpGlobal] User mengambil dividen dari Firebase');
      return await _investasiOpFirebase.ambilSemuaDividen(
        tampilkanYangDiarsip: tampilkanYangDiarsip,
      );
    }
  }

  /// Mengambil dividen berdasarkan ID.
  Future<DividenModel?> ambilDividenById(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil dividen ID: $id dari SQLite',
      );
      return await _investasiOpSqlite.ambilDividenById(id);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil dividen ID: $id dari Firebase',
      );
      return await _investasiOpFirebase.ambilDividenById(id);
    }
  }

  /// Mengambil dividen berdasarkan ID investor.
  Future<List<DividenModel>> ambilDividenByIdInvestor(String idInvestor) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil dividen untuk investor ID: $idInvestor dari SQLite',
      );
      return await _investasiOpSqlite.ambilDividenByIdInvestor(idInvestor);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil dividen untuk investor ID: $idInvestor dari Firebase',
      );
      return await _investasiOpFirebase.ambilDividenByIdInvestor(idInvestor);
    }
  }

  /// Mengambil dividen berdasarkan ID investasi.
  Future<List<DividenModel>> ambilDividenByIdInvestasi(
    String idInvestasi,
  ) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil dividen untuk investasi ID: $idInvestasi dari SQLite',
      );
      return await _investasiOpSqlite.ambilDividenByIdInvestasi(idInvestasi);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil dividen untuk investasi ID: $idInvestasi dari Firebase',
      );
      return await _investasiOpFirebase.ambilDividenByIdInvestasi(idInvestasi);
    }
  }

  /// Memperbarui dividen.
  Future<void> perbaruiDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin memperbarui dividen di SQLite: ${dividen.id}',
      );
      await _investasiOpSqlite.perbaruiDividen(dividen, dariServer: dariServer);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User memperbarui dividen di Firebase: ${dividen.id}',
      );
      await _investasiOpFirebase.perbaruiDividen(dividen);
    }
  }

  /// Soft delete dividen.
  Future<void> softDeleteDividen(String id, {bool dariServer = false}) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[InvestasiOpGlobal] Admin soft delete dividen di SQLite: $id');
      await _investasiOpSqlite.softDeleteDividen(id, dariServer: dariServer);
    } else {
      Log.info('[InvestasiOpGlobal] User soft delete dividen di Firebase: $id');
      await _investasiOpFirebase.softDeleteDividen(id);
    }
  }

  /// Menandai dividen sebagai sudah dibayar.
  Future<void> tandaiDividenDibayar(
    String id, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin menandai dividen dibayar di SQLite: $id',
      );
      await _investasiOpSqlite.tandaiDividenDibayar(id, dariServer: dariServer);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User menandai dividen dibayar di Firebase: $id',
      );
      await _investasiOpFirebase.tandaiDividenDibayar(id);
    }
  }

  /// Menyisipkan atau memperbarui banyak investasi sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatch(
    List<InvestasiModel> daftarInvestasi, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin batch investasi ke SQLite: ${daftarInvestasi.length} item',
      );
      await _investasiOpSqlite.sisipkanAtauPerbaruiBatch(
        daftarInvestasi,
        dariServer: dariServer,
      );
    } else {
      Log.info(
        '[InvestasiOpGlobal] User batch investasi ke Firebase: ${daftarInvestasi.length} item',
      );
      await _investasiOpFirebase.sisipkanAtauPerbaruiBatch(daftarInvestasi);
    }
  }

  /// Menyisipkan atau memperbarui banyak dividen sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatchDividen(
    List<DividenModel> daftarDividen, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[InvestasiOpGlobal] Admin batch dividen ke SQLite: ${daftarDividen.length} item',
      );
      await _investasiOpSqlite.sisipkanAtauPerbaruiBatchDividen(
        daftarDividen,
        dariServer: dariServer,
      );
    } else {
      Log.info(
        '[InvestasiOpGlobal] User batch dividen ke Firebase: ${daftarDividen.length} item',
      );
      await _investasiOpFirebase.sisipkanAtauPerbaruiBatchDividen(
        daftarDividen,
      );
    }
  }
}

/// Provider global untuk InvestasiOpGlobal.
final investasiOpGlobalProvider = Provider<InvestasiOpGlobal>((ref) {
  return InvestasiOpGlobal(ref: ref);
});
