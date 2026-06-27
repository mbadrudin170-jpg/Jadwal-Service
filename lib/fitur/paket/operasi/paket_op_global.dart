// path: lib/fitur/paket/operasi/paket_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_firebase.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

/// Kelas untuk mengelola operasi paket secara global
/// dengan logika berdasarkan role (admin/user).
class PaketOpGlobal {
  final Ref ref;

  PaketOpGlobal({required this.ref});

  // ✅ Accessor untuk SQLite (digunakan oleh admin)
  PaketOpSqlite get _paketOpSqlite => ref.read(paketOpSqliteProvider);

  // ✅ Accessor untuk Firebase (digunakan oleh user)
  PaketOpFirebase get _paketOpFirebase => ref.read(paketOpFirebaseProvider);

  /// Menambahkan paket baru dengan logika berdasarkan role
  ///
  /// - Admin: Simpan ke SQLite (akan disinkronisasi ke Firebase)
  /// - User: Simpan langsung ke Firebase
  Future<void> tambahPaket(PaketModel paket) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin menambah paket ke SQLite: ${paket.nama}');
      await _paketOpSqlite.tambahPaket(paket);
    } else {
      Log.info(
        '[PaketOpGlobal] User menambah paket ke Firebase: ${paket.nama}',
      );
      await _paketOpFirebase.tambahPaket(paket);
    }
  }

  /// Mengambil semua paket berdasarkan role
  ///
  /// - Admin: Ambil dari SQLite
  /// - User: Ambil dari Firebase
  Future<List<PaketModel>> ambilPaketPublik() async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin mengambil paket dari SQLite');
      return await _paketOpSqlite.ambilPaketPublik();
    } else {
      Log.info('[PaketOpGlobal] User mengambil paket dari Firebase');
      return await _paketOpFirebase.ambilPaketPublik();
    }
  }

  /// Mengambil paket berdasarkan ID
  ///
  /// - Admin: Ambil dari SQLite
  /// - User: Ambil dari Firebase
  Future<PaketModel?> ambilPaketBerdasarkanId(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin mengambil paket ID: $id dari SQLite');
      return await _paketOpSqlite.ambilBerdasarkanId(id);
    } else {
      Log.info('[PaketOpGlobal] User mengambil paket ID: $id dari Firebase');
      return await _paketOpFirebase.ambilBerdasarkanId(id);
    }
  }

  /// Mengambil paket publik (hanya yang statusPublik = true)
  ///
  /// - Admin: Ambil dari SQLite
  /// - User: Ambil dari Firebase
  Future<List<PaketModel>> ambilPaketPublik() async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin mengambil paket publik dari SQLite');
      return await _paketOpSqlite.ambilPaketPublik();
    } else {
      Log.info('[PaketOpGlobal] User mengambil paket publik dari Firebase');
      return await _paketOpFirebase.ambilPaketPublik();
    }
  }

  /// Memperbarui paket yang ada
  ///
  /// - Admin: Update di SQLite (akan disinkronisasi ke Firebase)
  /// - User: Update langsung di Firebase
  Future<void> updatePaket(PaketModel paket) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin update paket di SQLite: ${paket.nama}');
      await _paketOpSqlite.perbaruiPaket(paket);
    } else {
      Log.info('[PaketOpGlobal] User update paket di Firebase: ${paket.nama}');
      await _paketOpFirebase.tambahPaket(
        paket,
      ); // Firebase menggunakan tambahPaket untuk upsert
    }
  }

  /// Menghapus paket (soft delete)
  ///
  /// - Admin: Soft delete di SQLite (akan disinkronisasi ke Firebase)
  /// - User: Soft delete langsung di Firebase
  Future<void> hapusPaket(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin hapus paket ID: $id di SQLite');
      await _paketOpSqlite.hapusSementara(id);
    } else {
      Log.info('[PaketOpGlobal] User hapus paket ID: $id di Firebase');
      await _paketOpFirebase.softDelete(id);
    }
  }

  /// Mengambil beberapa paket berdasarkan daftar ID
  ///
  /// - Admin: Ambil dari SQLite
  /// - User: Ambil dari Firebase (satu per satu)
  Future<List<PaketModel>> ambilPaketBerdasarkanIds(List<String> ids) async {
    if (ids.isEmpty) {
      Log.warning(
        '[PaketOpGlobal] Daftar ID kosong, mengembalikan list kosong',
      );
      return [];
    }

    if (RoleUtil.isAdmin(ref)) {
      Log.info(
        '[PaketOpGlobal] Admin mengambil ${ids.length} paket dari SQLite',
      );
      return await _paketOpSqlite.ambilBerdasarkanBeberapaId(ids);
    } else {
      Log.info(
        '[PaketOpGlobal] User mengambil ${ids.length} paket dari Firebase',
      );
      final List<PaketModel> hasil = [];
      for (final id in ids) {
        final paket = await _paketOpFirebase.ambilBerdasarkanId(id);
        if (paket != null) {
          hasil.add(paket);
        }
      }
      return hasil;
    }
  }

  /// Mengecek apakah ada paket dengan nama yang sama (untuk validasi)
  ///
  /// - Admin: Cek di SQLite
  /// - User: Cek di Firebase
  Future<bool> cekNamaPaketSudahAda(String nama, {String? excludeId}) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin cek nama paket di SQLite: $nama');
      final semuaPaket = await _paketOpSqlite.ambilSemua();
      return semuaPaket.any(
        (p) =>
            p.nama.toLowerCase() == nama.toLowerCase() &&
            (excludeId == null || p.id != excludeId),
      );
    } else {
      Log.info('[PaketOpGlobal] User cek nama paket di Firebase: $nama');
      final semuaPaket = await _paketOpFirebase.ambilPaketPublik();
      return semuaPaket.any(
        (p) =>
            p.nama.toLowerCase() == nama.toLowerCase() &&
            (excludeId == null || p.id != excludeId),
      );
    }
  }
}

/// Provider untuk PaketOpGlobal
final paketOpGlobalProvider = Provider<PaketOpGlobal>((ref) {
  return PaketOpGlobal(ref: ref);
});
