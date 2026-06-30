// path: lib/fitur/pelanggan/operasi/pelanggan_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class PelangganOpGlobal {
  final Ref ref;

  PelangganOpGlobal({required this.ref});

  // ✅ Cara benar mengakses provider
  PelangganOpSqlite get _pelangganOpSqlite =>
      ref.read(pelangganOpSqliteProvider);
  PelangganOpFirebase get _pelangganOpFirebase =>
      ref.read(pelangganOpFirebaseProvider);

  void _invalidateProviderTerkait(String? idPelanggan) {
    ref.read(pelangganProvider.notifier).invalidateDetailPelanggan(idPelanggan);
  }

  /// Menambahkan pelanggan dengan logika berdasarkan role
  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    if (RoleUtil.isAdmin(ref)) {
      await _pelangganOpSqlite.tambahPelanggan(pelanggan);
    } else {
      await _pelangganOpFirebase.tambahPelanggan(pelanggan);
    }
    _invalidateProviderTerkait(pelanggan.id);
  }

  /// Mengupdate pelanggan
  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    if (RoleUtil.isAdmin(ref)) {
      await _pelangganOpSqlite.perbaruiPelanggan(pelanggan);
    } else {
      await _pelangganOpFirebase.perbaruiPelanggan(pelanggan);
    }
    _invalidateProviderTerkait(pelanggan.id);
  }

  /// Menghapus pelanggan (soft delete)
  Future<void> softDelete(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      await _pelangganOpSqlite.softDelete(id);
    } else {
      await _pelangganOpFirebase.softDelete(id);
    }
    _invalidateProviderTerkait(id);
  }

  /// Mengambil daftar pelanggan berdasarkan role
  Future<List<PelangganModel>> ambilSemua() async {
    if (RoleUtil.isAdmin(ref)) {
      return await _pelangganOpSqlite.ambilSemua();
    } else {
      return await _pelangganOpFirebase.ambilSemua();
    }
  }

  /// Mengambil pelanggan berdasarkan ID
  Future<PelangganModel?> ambilBerdasarkanId(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      return await _pelangganOpSqlite.ambilBerdasarkanId(id);
    } else {
      return await _pelangganOpFirebase.ambilBerdasarkanId(id);
    }
  }
}

/// Provider untuk PelangganOpGlobal
final pelangganOpGlobalProvider = Provider<PelangganOpGlobal>((ref) {
  return PelangganOpGlobal(ref: ref);
});
