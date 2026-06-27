// path: lib/fitur/pelanggan/operasi/pelanggan_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class PelangganOpGlobal {
  final Ref ref;

  PelangganOpGlobal({required this.ref});

  // ✅ Cara benar mengakses provider
  PelangganOpSqlite get _pelangganOpSqlite =>
      ref.read(pelangganOpSqliteProvider);
  PelangganOpFirebase get _pelangganOpFirebase =>
      ref.read(pelangganOpFirebaseProvider);

  /// Menambahkan pelanggan dengan logika berdasarkan role
  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    if (RoleUtil.isAdmin(ref)) {
      await _pelangganOpSqlite.tambahPelanggan(pelanggan);
    } else {
      await _pelangganOpFirebase.tambahPelanggan(pelanggan);
    }
  }

  /// Mengambil daftar pelanggan berdasarkan role
  Future<List<PelangganModel>> ambilSemuaPelanggan() async {
    if (RoleUtil.isAdmin(ref)) {
      return await _pelangganOpSqlite.ambilSemua();
    } else {
      return await _pelangganOpFirebase.ambilSemuaPelanggan();
    }
  }

  /// Mengambil pelanggan berdasarkan ID
  Future<PelangganModel?> ambilPelanggan(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      return await _pelangganOpSqlite.ambilBerdasarkanId(id);
    } else {
      return await _pelangganOpFirebase.ambilBerdasarkanId(id);
    }
  }

  /// Mengupdate pelanggan
  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    if (RoleUtil.isAdmin(ref)) {
      await _pelangganOpSqlite.perbaruiPelanggan(pelanggan);
    } else {
      await _pelangganOpFirebase.perbaruiPelanggan(pelanggan);
    }
  }

  /// Menghapus pelanggan (soft delete)
  Future<void> hapusPelanggan(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      await _pelangganOpSqlite.softDelete(id);
    } else {
      await _pelangganOpFirebase.softDelete(id);
    }
  }
}

/// Provider untuk PelangganOpGlobal
final pelangganOpGlobalProvider = Provider<PelangganOpGlobal>((ref) {
  return PelangganOpGlobal(ref: ref);
});
