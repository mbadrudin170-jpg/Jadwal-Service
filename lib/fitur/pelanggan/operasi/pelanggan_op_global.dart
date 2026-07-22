// path: lib/fitur/pelanggan/operasi/pelanggan_op_global.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

/// Abstract class sebagai "kontrak" untuk semua operasi pelanggan.
abstract class PelangganAbstrak {
  Future<void> tambahPelanggan(PelangganModel pelanggan);
  Future<void> perbaruiPelanggan(PelangganModel pelanggan);
  Future<void> softDelete(String id);
  Future<List<PelangganModel>> ambilSemua();
  Future<PelangganModel?> ambilBerdasarkanId(String id);
}

class PelangganOpGlobal implements PelangganAbstrak {
  final Ref ref;

  PelangganOpGlobal({required this.ref});

  /// Logika baru untuk memilih datasource yang tepat.
  PelangganAbstrak get _operasi {
    if (kIsWeb) {
      // 1. Jika di web, selalu gunakan Firebase.
      return ref.read(pelangganOpFirebaseProvider);
    } else {
      // 2. Jika di mobile, gunakan role untuk memutuskan.
      if (ref.isAdmin) {
        return ref.read(pelangganOpSqliteProvider);
      } else {
        return ref.read(pelangganOpFirebaseProvider);
      }
    }
  }

  void _invalidateProviderTerkait(String? idPelanggan) {
    ref.read(pelangganProvider.notifier).invalidateDetailPelanggan(idPelanggan);
  }

  @override
  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    await _operasi.tambahPelanggan(pelanggan);
    _invalidateProviderTerkait(pelanggan.id);
  }

  @override
  Future<void> perbaruiPelanggan(PelangganModel pelanggan) async {
    await _operasi.perbaruiPelanggan(pelanggan);
    _invalidateProviderTerkait(pelanggan.id);
  }

  @override
  Future<void> softDelete(String id) async {
    await _operasi.softDelete(id);
    _invalidateProviderTerkait(id);
  }

  @override
  Future<List<PelangganModel>> ambilSemua() {
    return _operasi.ambilSemua();
  }

  @override
  Future<PelangganModel?> ambilBerdasarkanId(String id) {
    return _operasi.ambilBerdasarkanId(id);
  }
}

/// Provider untuk PelangganOpGlobal
final pelangganOpGlobalProvider = Provider<PelangganOpGlobal>((ref) {
  return PelangganOpGlobal(ref: ref);
});
