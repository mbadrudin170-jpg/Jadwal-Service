# Dokumentasi Fitur: pelanggan

## Daftar file

- [lib/fitur/pelanggan/core/layanan_aktivitas_user.dart](../../lib/fitur/pelanggan/core/layanan_aktivitas_user.dart)
- [lib/fitur/pelanggan/helper/pengurut_pelanggan.dart](../../lib/fitur/pelanggan/helper/pengurut_pelanggan.dart)
- [lib/fitur/pelanggan/model/pelanggan_model.dart](../../lib/fitur/pelanggan/model/pelanggan_model.dart)
- [lib/fitur/pelanggan/operasi/pelanggan_op_firebase.dart](../../lib/fitur/pelanggan/operasi/pelanggan_op_firebase.dart)
- [lib/fitur/pelanggan/operasi/pelanggan_op_global.dart](../../lib/fitur/pelanggan/operasi/pelanggan_op_global.dart)
- [lib/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart](../../lib/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart)
- [lib/fitur/pelanggan/page/admin/detail_pelanggan_a.dart](../../lib/fitur/pelanggan/page/admin/detail_pelanggan_a.dart)
- [lib/fitur/pelanggan/page/admin/form_pelanggan.dart](../../lib/fitur/pelanggan/page/admin/form_pelanggan.dart)
- [lib/fitur/pelanggan/page/admin/pelanggan_page.dart](../../lib/fitur/pelanggan/page/admin/pelanggan_page.dart)
- [lib/fitur/pelanggan/page/user/detail_pelanggan.dart](../../lib/fitur/pelanggan/page/user/detail_pelanggan.dart)
- [lib/fitur/pelanggan/provider/pelanggan_provider.dart](../../lib/fitur/pelanggan/provider/pelanggan_provider.dart)
- [lib/fitur/pelanggan/widget/detail_pelanggan_ui.dart](../../lib/fitur/pelanggan/widget/detail_pelanggan_ui.dart)
- [lib/fitur/pelanggan/widget/nama_pelanggan_widget.dart](../../lib/fitur/pelanggan/widget/nama_pelanggan_widget.dart)

## Isi file

### File: `lib/fitur/pelanggan/core/layanan_aktivitas_user.dart`
```dart
// path: lib/shared/services/user_activity_service.dart

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';

/// Service untuk menangani pelacakan aktivitas pengguna.
class LayananAktivitasUser {
  final PelangganOpFirebase _pelangganOpFirebase;
  final SharedPreferences _prefs;
  static const String kunciPingTerakhirAktif = 'last_activity_ping_timestamp';
  static const Duration jadwalPing = Duration(minutes: 5);

  LayananAktivitasUser({
    required PelangganOpFirebase pelangganOpFirebase,
    required SharedPreferences prefs,
  }) : _pelangganOpFirebase = pelangganOpFirebase,
       _prefs = prefs;

  Future<void> pingAktivitas(String id, {bool paksa = false}) async {
    if (id.isEmpty) {
      Log.warning('pingActivity: customerId kosong, proses dibatalkan.');
      return;
    }
    try {
      final pingTerakhir = _prefs.getInt(kunciPingTerakhirAktif);
      final now = DateTime.now();
      if (pingTerakhir != null && !paksa) {
        final waktuPingTerakhir = DateTime.fromMillisecondsSinceEpoch(
          pingTerakhir,
        );
        if (now.difference(waktuPingTerakhir) < jadwalPing) {
          Log.info(
            'pingActivity: Throttled. Panggilan dibatasi karena ping terakhir < ${jadwalPing.inMinutes} menit yang lalu.',
          );
          return;
        }
      }

      Log.info(
        'pingActivity: Mengirim ping aktivitas untuk user: $id (Force: $paksa)',
      );
      unawaited(_pelangganOpFirebase.perbaruiTerakhirAktif(id));
      await _prefs.setInt(kunciPingTerakhirAktif, now.millisecondsSinceEpoch);
      Log.info(
        'pingActivity: Timestamp ping terakhir diperbarui secara lokal.',
      );
    } catch (e, st) {
      Log.error(
        'pingActivity: Terjadi error pada logika throttling atau SharedPreferences.',
        e: e,
        s: st,
      );
      // Tidak melempar ulang agar tidak mengganggu aplikasi.
    }
  }
}
```

### File: `lib/fitur/pelanggan/helper/pengurut_pelanggan.dart`
```dart
// path lib/fitur/pelanggan/helper/pengurut_pelanggan.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';

part 'pengurut_pelanggan.g.dart';

enum UrutanPelanggan {
  namaAZ('Nama A-Z'),
  namaZa('Nama Z-A'),
  terakhirOnline('Aktivitas Terakhir (Terbaru)'),
  terbaruOnline('Aktivitas Terakhir (Terlama)'),
  poinTerbanyak('Poin (Tertinggi)'),
  poinTerkecil('Poin (Terendah)');

  const UrutanPelanggan(this.teks);
  final String teks;
}

@riverpod
class UrutanPelangganState extends _$UrutanPelangganState {
  @override
  UrutanPelanggan build() => UrutanPelanggan.namaAZ;
  void ubahUrutan(UrutanPelanggan urutanBaru) => state = urutanBaru;
}

@riverpod
Future<List<(PelangganModel, int)>> pelangganDenganPoin(Ref ref) async {
  final pelangganState = await ref.watch(pelangganProvider.future);
  final transaksiState = await ref.watch(transaksiOpProvider.future);
  final daftarPelanggan = pelangganState.daftarPelanggan;

  return daftarPelanggan.map((p) {
    final poin = transaksiState.riwayatPelanggan(p.id).totalPoin;
    return (p, poin);
  }).toList();
}

@riverpod
Future<List<(PelangganModel, int)>> filteredCustomers(Ref ref) async {
  final pelangganWithPoints = await ref.watch(
    pelangganDenganPoinProvider.future,
  );
  final searchQuery = ref.watch(searchQueryPelangganProvider).toLowerCase();
  final sortOption = ref.watch(urutanPelangganStateProvider);
  final filtered = pelangganWithPoints
      .where((tuple) => tuple.$1.nama.toLowerCase().contains(searchQuery))
      .toList();
  if (filtered.isNotEmpty) {
    switch (sortOption) {
      case UrutanPelanggan.namaAZ:
        filtered.sort(
          (a, b) => a.$1.nama.toLowerCase().compareTo(b.$1.nama.toLowerCase()),
        );
        break;
      case UrutanPelanggan.namaZa:
        filtered.sort(
          (a, b) => b.$1.nama.toLowerCase().compareTo(a.$1.nama.toLowerCase()),
        );
        break;
      case UrutanPelanggan.terakhirOnline:
        filtered.sort((a, b) {
          if (a.$1.terkahirAktif == null) return 1;
          if (b.$1.terkahirAktif == null) return -1;
          return b.$1.terkahirAktif!.compareTo(a.$1.terkahirAktif!);
        });
        break;
      case UrutanPelanggan.terbaruOnline:
        filtered.sort((a, b) {
          if (a.$1.terkahirAktif == null) return -1;
          if (b.$1.terkahirAktif == null) return 1;
          return a.$1.terkahirAktif!.compareTo(b.$1.terkahirAktif!);
        });
        break;
      case UrutanPelanggan.poinTerbanyak:
        filtered.sort((a, b) => b.$2.compareTo(a.$2));
        break;
      case UrutanPelanggan.poinTerkecil:
        filtered.sort((a, b) => a.$2.compareTo(b.$2));
        break;
    }
  }
  return filtered;
}
```

### File: `lib/fitur/pelanggan/model/pelanggan_model.dart`
```dart
// path: lib/fitur/pelanggan/model/pelanggan_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'pelanggan_model.freezed.dart';

@freezed
abstract class PelangganModel with _$PelangganModel implements HasId {
  const PelangganModel._();
  const factory PelangganModel({
    required String id,
    required String nama,
    required String telepon,
    required String alamat,
    required String kataSandi,
    required String macAddress,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? terkahirAktif,
  }) = _PelangganModel;

  factory PelangganModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating CustomerModel from SQLite: ${map[NamaKolom.id]}');
    return PelangganModel(
      id: map[NamaKolom.id] as String? ?? '',
      nama: map[NamaKolom.nama] as String? ?? '',
      telepon: map[NamaKolom.telepon] as String? ?? '',
      alamat: map[NamaKolom.alamat] as String? ?? '',
      kataSandi: map[NamaKolom.kataSandi] as String? ?? '',
      macAddress: map[NamaKolom.macAddress] as String? ?? '',
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      terkahirAktif: ParserUtil.parseDateTime(map[NamaKolom.terkahirAktif]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.telepon: telepon,
      NamaKolom.alamat: alamat,
      NamaKolom.kataSandi: kataSandi,
      NamaKolom.macAddress: macAddress,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.terkahirAktif: terkahirAktif?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [PelangganModel] from a Firebase document.
  factory PelangganModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating CustomerModel from Firebase: $id');
    return PelangganModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      telepon: data[NamaKolom.telepon] as String? ?? '',
      alamat: data[NamaKolom.alamat] as String? ?? '',
      kataSandi: data[NamaKolom.kataSandi] as String? ?? '',
      macAddress: data[NamaKolom.macAddress] as String? ?? '',
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      terkahirAktif: ParserUtil.parseDateTime(data[NamaKolom.terkahirAktif]),
    );
  }

  /// Converts the [PelangganModel] to a map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.telepon: telepon,
      NamaKolom.alamat: alamat,
      NamaKolom.kataSandi: kataSandi,
      NamaKolom.macAddress: macAddress,
      NamaKolom.dihapus: diHapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
      NamaKolom.terkahirAktif: terkahirAktif != null
          ? Timestamp.fromDate(terkahirAktif!.toUtc())
          : null,
    };
  }
}
```

### File: `lib/fitur/pelanggan/operasi/pelanggan_op_firebase.dart`
```dart
// path: lib/fitur/pelanggan/operasi/pelanggan_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class PelangganOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOpFirebase;
  final String _namaKoleksi = NamaTabel.pelanggan;

  PelangganOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOpFirebase,
  }) : _firestore = firestore,
       _baseOpFirebase = baseOpFirebase {
    Log.info('CustomerOpFirebase diinisialisasi.');
  }

  CollectionReference get _koleksiPelanggan =>
      _firestore.collection(_namaKoleksi);

  Future<bool> cekDuplikasiTeleponDanPassword(
    String telepon,
    String kataSandi, {
    String? excludeId,
  }) async {
    try {
      var query = _koleksiPelanggan
          .where(NamaKolom.telepon, isEqualTo: telepon)
          .where(NamaKolom.kataSandi, isEqualTo: kataSandi)
          .where(NamaKolom.dihapus, isEqualTo: false);

      // Jika excludeId diberikan, exclude pelanggan dengan ID tersebut
      if (excludeId != null && excludeId.isNotEmpty) {
        query = query.where(NamaKolom.id, isNotEqualTo: excludeId);
      }

      final snapshot = await query.limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e, s) {
      Log.error('Gagal mengecek duplikasi pelanggan di Firebase', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    Log.info('Mendelegasikan pembuatan pelanggan: ${pelanggan.id}');
    final isDuplicate = await cekDuplikasiTeleponDanPassword(
      pelanggan.telepon,
      pelanggan.kataSandi,
    );

    if (isDuplicate) {
      throw Exception('Nomor telepon dan password sudah digunakan.');
    }
    await _baseOpFirebase.sisipkan(
      _namaKoleksi,
      pelanggan.id,
      pelanggan.toFirebase(),
    );
  }

  Future<void> perbaruiPelanggan(PelangganModel pelanggan) async {
    Log.info('Mendelegasikan pembaruan pelanggan: ${pelanggan.id}');
    final isDuplicate = await cekDuplikasiTeleponDanPassword(
      pelanggan.telepon,
      pelanggan.kataSandi,
      excludeId: pelanggan.id,
    );

    if (isDuplicate) {
      throw Exception('Nomor telepon dan password sudah digunakan.');
    }
    await _baseOpFirebase.update(
      _namaKoleksi,
      pelanggan.id,
      pelanggan.toFirebase(),
    );
  }

  Future<void> softDelete(String id) async {
    Log.info('Mendelegasikan soft delete pelanggan: $id');
    await _baseOpFirebase.softDelete(_namaKoleksi, id);
  }

  Future<void> perbaruiTerakhirAktif(String id) async {
    Log.info('Mendelegasikan update last active untuk: $id');
    await _baseOpFirebase.update(_namaKoleksi, id, {
      NamaKolom.terkahirAktif: FieldValue.serverTimestamp(),
    });
  }

  Future<void> simpanTokenFCM(String id, String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM kosong, penyimpanan dibatalkan.');
      return;
    }
    Log.info('Mendelegasikan penyimpanan token FCM untuk: $id');
    await _baseOpFirebase.update(_namaKoleksi, id, {'fcmToken': token});
  }

  Future<List<PelangganModel>> ambilSemua({
    bool tampilkanYangDiarsip = true,
  }) async {
    Log.info(
      'Mengambil semua pelanggan. Tampilkan yang diarsip: $tampilkanYangDiarsip',
    );
    try {
      Query query = _koleksiPelanggan;

      if (tampilkanYangDiarsip) {
        query = query.where(NamaKolom.dihapus, isEqualTo: false);
      } else {
        query = query.where(NamaKolom.dihapus, isEqualTo: false);
      }
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        Log.warning('Tidak ada pelanggan yang ditemukan.');
        return [];
      }
      final pelanggan = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) {
              Log.warning(
                'Data pelanggan dengan ID ${doc.id} bernilai null, dilewati.',
              );
              return null;
            }
            return PelangganModel.fromFirebase(doc.id, data);
          })
          .whereType<PelangganModel>()
          .toList();
      Log.info('Berhasil mengambil ${pelanggan.length} pelanggan.');
      return pelanggan;
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pelanggan', e: e, s: s);
      return [];
    }
  }

  Stream<PelangganModel?> ambilStreamBerdasarkanId(String id) {
    Log.info('Streaming data pelanggan untuk: $id');
    return _koleksiPelanggan
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return PelangganModel.fromFirebase(
              snapshot.id,
              snapshot.data()! as Map<String, dynamic>,
            );
          }
          return null;
        })
        .handleError((Object e, StackTrace s) {
          Log.error('Error pada stream pelanggan untuk: $id', e: e, s: s);
        });
  }

  Future<PelangganModel?> ambilBerdasarkanId(String id) async {
    try {
      final doc = await _koleksiPelanggan.doc(id).get();
      if (doc.exists) {
        return PelangganModel.fromFirebase(
          doc.id,
          doc.data()! as Map<String, dynamic>,
        );
      }
      Log.warning('Pelanggan $id tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil pelanggan: $e', e: e, s: s);
      return null;
    }
  }
}
```

### File: `lib/fitur/pelanggan/operasi/pelanggan_op_global.dart`
```dart
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
```

### File: `lib/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart`
```dart
// path: lib/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class PelangganOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final String _tabel = NamaTabel.pelanggan;

  PelangganOpSqlite({
    required this.sqliteDb,
    required BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite {
    Log.info('CustomerOperation diinisialisasi');
  }

  // path: lib/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart

  Future<bool> _ambilBerdasarkanTeleponDanKataSandi(
    String telepon,
    String kataSandi, {
    String? excludeId,
  }) async {
    try {
      final db = await sqliteDb.database;

      // Log untuk debugging
      Log.info('Mengecek kombinasi telepon dan password', {
        'telepon': telepon,
        'kataSandi': kataSandi,
        'excludeId': excludeId,
      });

      var sql =
          '''
      SELECT COUNT(*) as count
      FROM ${NamaTabel.pelanggan}
      WHERE ${NamaKolom.telepon} = ? 
        AND ${NamaKolom.kataSandi} = ? 
        AND ${NamaKolom.dihapus} = 0
    ''';
      final args = <dynamic>[telepon, kataSandi];
      if (excludeId != null && excludeId.isNotEmpty) {
        sql += ' AND ${NamaKolom.id} != ?';
        args.add(excludeId);
      }
      final result = await db.rawQuery(sql, args);
      final count = Sqflite.firstIntValue(result) ?? 0;
      Log.info('Hasil pengecekan duplikasi', {
        'count': count,
        'isDuplicate': count > 0,
      });

      return count > 0;
    } catch (e, st) {
      Log.error('Gagal mengecek duplikasi pelanggan', e: e, s: st);
      rethrow;
    }
  }

  Future<void> tambahPelanggan(
    PelangganModel pelanggan, {
    bool dariServer = false,
  }) async {
    final isDuplicate = await _ambilBerdasarkanTeleponDanKataSandi(
      pelanggan.telepon,
      pelanggan.kataSandi,
    );
    if (isDuplicate) {
      Log.warning('Data pelanggan duplikat ditemukan.', {
        'telepon': pelanggan.telepon,
        'nama': pelanggan.nama,
      });
      throw Exception(
        'Pelanggan dengan nomor telepon dan password ini sudah ada.',
      );
    }
    Log.info('Memulai pembuatan customer dengan ID: ${pelanggan.id}');
    try {
      final pelangganBaru = pelanggan.copyWith(diperbaruiPada: DateTime.now());
      final data = pelangganBaru.toSqlite();
      await _baseOpSqlite.sisipkan(_tabel, data, dariServer: dariServer);
      Log.info(
        'Customer (ID: ${pelangganBaru.id}) berhasil dibuat di database lokal.',
      );
    } on DatabaseException catch (e, s) {
      Log.error('Gagal membuat customer.', e: e, s: s);
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Nomor telepon sudah terdaftar.');
      }
      rethrow;
    }
  }

  Future<List<PelangganModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil SEMUA data customer dari database lokal.');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? null
          : '${NamaKolom.dihapus}=0 AND ${NamaKolom.diarsipkanPada} is NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: query,
        orderBy: '${NamaKolom.nama} ASC',
      );
      final daftarPelanggan = List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
      return daftarPelanggan;
    } catch (e, s) {
      Log.error('Gagal mengambil semua data customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<PelangganModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mencari customer berdasarkan ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Customer dengan ID: $id ditemukan.');
        return PelangganModel.fromSqlite(maps.first);
      }
      Log.info('Customer dengan ID: $id tidak ditemukan (hasil valid).');
      return null;
    } catch (e, s) {
      Log.error('Gagal mencari customer berdasarkan ID.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbaruiPelanggan(
    PelangganModel pelanggan, {
    bool dariServer = false,
  }) async {
    final isDuplicate = await _ambilBerdasarkanTeleponDanKataSandi(
      pelanggan.telepon,
      pelanggan.kataSandi,
      excludeId: pelanggan.id,
    );

    if (isDuplicate) {
      Log.warning('Data pelanggan duplikat ditemukan saat update.', {
        'telepon': pelanggan.telepon,
        'nama': pelanggan.nama,
        'id': pelanggan.id,
      });
      throw Exception(
        'Pelanggan dengan nomor telepon dan password ini sudah ada.',
      );
    }
    Log.info('Memulai pembaruan untuk customer ID: ${pelanggan.id}');
    try {
      final data = pelanggan
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();

      await _baseOpSqlite.update(
        _tabel,
        data,
        pelanggan.id,
        dariServer: dariServer,
      );

      Log.info('Berhasil memperbarui customer ID: ${pelanggan.id}.');
    } catch (e, s) {
      Log.error('Gagal memperbarui customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Memulai proses soft delete untuk customer ID: $id');
    try {
      await _baseOpSqlite.softDelete(_tabel, id, dariServer: dariServer);
      Log.info('Berhasil melakukan soft delete pada customer ID: $id.');
    } catch (e, s) {
      Log.error('Gagal menghapus customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<int> softDeleteSemua({bool dariServer = false}) async {
    Log.info('Memulai proses soft delete untuk semua customer.');
    try {
      final total = await _baseOpSqlite.softDeleteAll(
        _tabel,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil melakukan soft delete pada semua customer. Total: $total',
      );
      return total;
    } catch (e, s) {
      Log.error('Gagal melakukan soft delete pada semua customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> ambilPerubahanSejak(DateTime sejak) async {
    Log.info('Mengambil perubahan customer sejak: ${sejak.toIso8601String()}');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.diperbaruiPada} > ?',
        whereArgs: [sejak.toUtc().millisecondsSinceEpoch],
      );
      Log.info(
        'Ditemukan ${maps.length} perubahan customer sejak waktu yang ditentukan.',
      );
      return List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<PelangganModel> pelanggan, {
    bool dariServer = false,
  }) async {
    if (pelanggan.isEmpty) {
      Log.info('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${pelanggan.length} customer.');
    try {
      final data = pelanggan.map((item) {
        return item.copyWith(diperbaruiPada: DateTime.now().toUtc()).toSqlite();
      }).toList();

      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _tabel,
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan operasi batch untuk ${pelanggan.length} customer.',
      );
    } catch (e, s) {
      Log.error('Gagal menjalankan operasi batch.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> ambilPelangganBerdasarkanId(
    List<String> ids,
  ) async {
    if (ids.isEmpty) {
      Log.info('List ID kosong, tidak ada customer yang diambil.');
      return [];
    }
    Log.info('Mengambil data customer untuk ${ids.length} ID.');
    try {
      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil ${maps.length} customer berdasarkan list ID.',
      );
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil customer berdasarkan list ID.', e: e, s: s);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/pelanggan/page/admin/detail_pelanggan_a.dart`
```dart
// // path lib/fitur/pelanggan/page/admin/detail_pelanggan_a.dart

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
// import 'package:wifi/fitur/pelanggan/page/admin/form_pelanggan.dart';
// import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
// import 'package:wifi/fitur/pelanggan/widget/detail_pelanggan_ui.dart';
// import 'package:wifi/fitur/poin/page/halaman_poin.dart';
// import 'package:wifi/shared/debug/log.dart';
// import 'package:wifi/shared/utils/toast_util.dart';

// class DetailPelanggan extends ConsumerWidget {
//   final String idPelanggan;

//   const DetailPelanggan({super.key, required this.idPelanggan});

//   Future<void> _editPelanggan(
//     BuildContext context,
//     PelangganModel? pelanggan,
//   ) async {
//     if (pelanggan == null) return;
//     Log.info('Navigasi ke form edit pelanggan: ${pelanggan.nama}');
//     unawaited(
//       Navigator.push<bool>(
//         context,
//         MaterialPageRoute<bool>(
//           builder: (context) => FormPelanggan(pelanggan: pelanggan),
//         ),
//       ),
//     );
//   }

//   Future<void> _salinSemuaInfo(
//     BuildContext context,
//     PelangganModel customer,
//     int totalPoin,
//   ) async {
//     Log.info('Menyalin info pelanggan: ${customer.nama}');
//     final info =
//         '''
// Nama : ${customer.nama}
// No HP : ${customer.telepon}
// Alamat : ${customer.alamat}
// Password : ${customer.kataSandi}
// MAC : ${customer.macAddress}
// Poin: $totalPoin
// '''
//             .trim();

//     await Clipboard.setData(ClipboardData(text: info));
//     if (context.mounted) {
//       ToastUtil.success(context, 'Informasi pelanggan berhasil disalin.');
//     }
//   }

//   Future<void> _navigasiKePoin(
//     BuildContext context,
//     PelangganModel? pelanggan,
//   ) async {
//     if (pelanggan == null) return;
//     Log.info('Navigasi ke halaman poin pelanggan: ${pelanggan.nama}');

//     unawaited(
//       Navigator.push<void>(
//         context,
//         MaterialPageRoute<void>(
//           builder: (context) => HalamanPoin(idPelanggan: pelanggan.id),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final detailAsync = ref.watch(pelangganDetailProvider(idPelanggan));
//     return detailAsync.when(
//       skipLoadingOnReload: true,
//       loading: () => Scaffold(
//         appBar: AppBar(title: const Text('Memuat Detail...')),
//         body: const Center(child: CircularProgressIndicator()),
//       ),
//       error: (e, s) {
//         Log.error(
//           'Gagal mengambil data pelanggan ID: $idPelanggan.',
//           e: e,
//           s: s,
//         );
//         return Scaffold(
//           appBar: AppBar(title: const Text('Detail Pelanggan')),
//           body: Center(child: Text('Gagal memuat data: $e')),
//         );
//       },
//       data: (data) {
//         final (pelanggan, totalPoin) = data;
//         if (pelanggan == null) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Detail Pelanggan')),
//             body: const Center(child: Text('Pelanggan tidak ditemukan')),
//           );
//         }
//         return DetailPelangganUI(
//           pelanggan: pelanggan,
//           totalPoin: totalPoin,
//           navigasiKeEdit: () => _editPelanggan(context, pelanggan),
//           navigasiKePoin: () => _navigasiKePoin(context, pelanggan),

//           onCopyAll: () => _salinSemuaInfo(context, pelanggan, totalPoin),
//         );
//       },
//     );
//   }
// }
```

### File: `lib/fitur/pelanggan/page/admin/form_pelanggan.dart`
```dart
// path lib/fitur/pelanggan/page/admin/form_pelanggan.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_mac_address.dart';
import 'package:wifi/shared/widget/input/input_password.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';
import 'package:wifi/shared/widget/input/input_telepon.dart';

class FormPelanggan extends ConsumerStatefulWidget {
  final PelangganModel? pelanggan;

  const FormPelanggan({super.key, this.pelanggan});

  @override
  ConsumerState<FormPelanggan> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<FormPelanggan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _macAddressController = TextEditingController();

  final _namaFocusNode = FocusNode();
  final _teleponFocusNode = FocusNode();
  final _alamatFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _macAddressFocusNode = FocusNode();

  bool get _modeEdit => widget.pelanggan != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Membuka form_pelanggan dalam mode: ${_modeEdit ? "Edit" : "Tambah"}.',
    );
    if (_modeEdit) {
      Log.info(
        'Mode Edit: Mempopulasikan form dengan data pelanggan ID: ${widget.pelanggan!.id}',
      );
      _namaController.text = widget.pelanggan!.nama;
      _teleponController.text = widget.pelanggan!.telepon;
      _alamatController.text = widget.pelanggan!.alamat;
      _passwordController.text = widget.pelanggan!.kataSandi;
      _macAddressController.text = widget.pelanggan!.macAddress;
    }
  }

  @override
  void dispose() {
    Log.info(
      'Menjalankan dispose di CustomerForm. Membersihkan semua controllers dan focus nodes.',
    );
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _macAddressController.dispose();
    _namaFocusNode.dispose();
    _teleponFocusNode.dispose();
    _alamatFocusNode.dispose();
    _passwordFocusNode.dispose();
    _macAddressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _simpanPelanggan() async {
    if (_menyimpan) return;
    if (ref.isUser) {
      final isOnline = await ref
          .read(koneksiInternetServiceProvider)
          .cekInternet();
      if (!isOnline) {
        if (!mounted) return;
        ToastUtil.error(context, 'Cek koneksi internet Anda');
        return;
      }
    }
    final pelangganOp = ref.read(pelangganOpGlobalProvider);
    Log.info('Tombol "Simpan" ditekan.');
    if (!_formKey.currentState!.validate()) {
      Log.warning('Form tidak valid. Proses penyimpanan dibatalkan.');
      return;
    }
    try {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _menyimpan = true);
      final pelangganBaru = PelangganModel(
        id: _modeEdit ? widget.pelanggan!.id : const Uuid().v4(),
        nama: _namaController.text.trim(),
        telepon: _teleponController.text.trim(),
        alamat: _alamatController.text.trim(),
        kataSandi: _passwordController.text,
        macAddress: _macAddressController.text.trim().toUpperCase(),
      );
      Log.info(
        'Model Pelanggan yang akan disimpan: ${pelangganBaru.toFirebase()}',
      );

      if (_modeEdit) {
        Log.info(
          'Menjalankan operasi UPDATE untuk pelanggan ID: ${pelangganBaru.id}',
        );
        await pelangganOp.updatePelanggan(pelangganBaru);
      } else {
        Log.info(
          'Menjalankan operasi CREATE untuk pelanggan baru: ${pelangganBaru.nama}',
        );
        await pelangganOp.tambahPelanggan(pelangganBaru);
      }
      if (mounted) {
        ToastUtil.success(context, 'Data pelanggan berhasil disimpan.');
      }
      if (mounted) {
        Navigator.pop(context);
      }
      unawaited(() {
        if (ref.isAdmin) {
          Log.info('jalankan sinkroniasi');
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi();
        }
      }());
    } catch (e, s) {
      Log.error('Gagal menyimpan data pelanggan ke database.', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Nomor telepon dan password sudah digunakan.');
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
        Log.info('Proses penyimpanan selesai. isSaving diatur ke false.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI CustomerForm. isSaving: $_menyimpan');
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputTeks(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  nextFocusNode: _teleponFocusNode,
                  label: 'Nama Pelanggan',
                  prefixIcon: TIcons.personOutlined,
                ),
                gapH16,
                InputTelepon(
                  controller: _teleponController,
                  focusNode: _teleponFocusNode,
                  nextFocusNode: _alamatFocusNode,
                ),
                gapH16,
                InputTeks(
                  controller: _alamatController,
                  focusNode: _alamatFocusNode,
                  nextFocusNode: _passwordFocusNode,
                  label: 'Alamat Lengkap',
                  prefixIcon: TIcons.home,
                ),
                gapH16,
                InputPassword(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  nextFocusNode: _macAddressFocusNode,
                ),
                gapH16,
                if (ref.isAdmin)
                  InputMacAddress(
                    controller: _macAddressController,
                    focusNode: _macAddressFocusNode,
                    onSubmitted: (_) => _simpanPelanggan(),
                    textInputAction: TextInputAction.done,
                  ),
                gapH32,
                ElevatedButton(
                  onPressed: _menyimpan ? null : _simpanPelanggan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('SIMPAN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/pelanggan/page/admin/pelanggan_page.dart`
```dart
// path lib/fitur/pelanggan/page/admin/pelanggan_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/helper/pengurut_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/pelanggan/page/admin/form_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk menampilkan dan mengelola daftar semua customer.
class PelangganPage extends ConsumerStatefulWidget {
  const PelangganPage({super.key});

  @override
  ConsumerState<PelangganPage> createState() => _PelangganState();
}

class _PelangganState extends ConsumerState<PelangganPage> {
  late final TextEditingController _searchController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryPelangganProvider),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(searchQueryPelangganProvider, (_, next) {
      if (_searchController.text != next) {
        _searchController.text = next;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      }
    });

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(pelangganProvider.notifier).refresh();
          ref.invalidate(pelangganDenganPoinProvider);
        },
        child: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _naviagsiKeForm,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(TIcons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    final isSearching = ref.watch(isSearchingPelangganProvider);
    return AppBar(
      title: isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari nama pelanggan...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  ref
                      .read(searchQueryPelangganProvider.notifier)
                      .updateQuery(query);
                });
              },
            )
          : const Text('Daftar Pelanggan'),
      actions: [
        IconButton(
          icon: Icon(isSearching ? TIcons.close : TIcons.search),
          onPressed: () {
            final wasSearching = ref.read(isSearchingPelangganProvider);
            ref.read(isSearchingPelangganProvider.notifier).toggle();
            if (wasSearching) {
              ref.read(searchQueryPelangganProvider.notifier).clear();
            }
          },
        ),
        IconButton(
          icon: const Icon(TIcons.sort),
          tooltip: 'Urutkan',
          onPressed: _dialogSort,
        ),
      ],
    );
  }

  Widget _buildContent() {
    final pelangganAsync = ref.watch(filteredCustomersProvider);
    final sedangMencari = ref.watch(searchQueryPelangganProvider).isNotEmpty;
    return pelangganAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        Log.error('Gagal memuat daftar customer', e: e, s: s);
        return Center(child: Text('Gagal memuat data: $e'));
      },
      data: (listPelanggan) {
        if (listPelanggan.isEmpty) {
          return Center(
            child: Text(
              sedangMencari
                  ? 'Pelanggan tidak ditemukan.'
                  : 'Belum ada customer. Tekan tombol + untuk menambah.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          itemCount: listPelanggan.length,
          itemBuilder: (context, index) {
            final (pelanggan, poin) = listPelanggan[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(
                  pelanggan.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  pelanggan.terkahirAktif == null
                      ? '-'
                      : FormatWaktuLengkap.formatSingkat(
                          pelanggan.terkahirAktif!,
                        ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(TIcons.star, color: Colors.amber),
                    gapH4,
                    Text(
                      poin.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () => _navigasiKeDetail(pelanggan.id),
                onLongPress: () => _dialogOpsi(pelanggan),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _dialogSort() async {
    final urutanAktif = ref.read(urutanPelangganStateProvider);
    final hasil = await showDialog<UrutanPelanggan>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: UrutanPelanggan.values.map((value) {
          final sedangDipilih = urutanAktif == value;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, value),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: sedangDipilih ? TColors.pointBackground : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.teks,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: sedangDipilih
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
    if (hasil != null) {
      ref.read(urutanPelangganStateProvider.notifier).ubahUrutan(hasil);
    }
  }

  Future<void> _naviagsiKeForm() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const FormPelanggan()),
    );
  }

  Future<void> _navigasiKeDetail(String idPelanggan) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPelanggan(idPelanggan: idPelanggan),
      ),
    );
  }

  Future<void> _dialogOpsi(PelangganModel pelanggan) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(pelanggan.nama),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(TIcons.edit),
              title: const Text('Edit Pelanggan'),
              onTap: () async {
                Navigator.of(dialogContext).pop();
                unawaited(
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormPelanggan(pelanggan: pelanggan),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(TIcons.archive),
              title: const Text('Arsipkan Pelanggan'),
              onTap: () async {
                Navigator.of(context).pop();
                await _dialogKonfirmasiSoftDelete(pelanggan);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dialogKonfirmasiSoftDelete(PelangganModel customer) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Arsip'),
        content: Text(
          'Apakah Anda yakin ingin mengarsipkan pelanggan "${customer.nama}"?',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Arsipkan', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop();
              await _softdelete(customer.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _softdelete(String id) async {
    try {
      await ref.read(pelangganOpGlobalProvider).softDelete(id);
      if (!mounted) return;
      ToastUtil.success(context, 'Pelanggan berhasil diarsipkan.');
    } on Exception catch (e, s) {
      Log.error('Gagal mengarsipkan pelanggan', e: e, s: s);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal mengarsipkan customer.');
      }
    }
  }
}
```

### File: `lib/fitur/pelanggan/page/user/detail_pelanggan.dart`
```dart
// file: lib/fitur/pelanggan/page/admin/detail_pelanggan.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/admin/form_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/poin/page/halaman_poin.dart';
import 'package:wifi/fitur/poin/widget/kartu_total_poin.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class DetailPelanggan extends ConsumerStatefulWidget {
  final String idPelanggan;

  const DetailPelanggan({super.key, required this.idPelanggan});

  @override
  ConsumerState<DetailPelanggan> createState() => _DetailPelangganState();
}

class _DetailPelangganState extends ConsumerState<DetailPelanggan> {
  Future<void> _salinInformasi(String label, String data) async {
    if (!mounted) return;

    if (data.isEmpty) {
      Log.warning('Tidak ada data untuk disalin pada label: $label');
      ToastUtil.warning(context, 'Tidak ada data untuk disalin.');
      return;
    }
    Log.info('Menyalin data untuk label: $label');
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    ToastUtil.success(context, '$label berhasil disalin');
  }

  Future<void> _salinSemuaInfo(
    BuildContext context,
    PelangganModel customer,
    int totalPoin,
  ) async {
    Log.info('Menyalin info pelanggan: ${customer.nama}');
    final info =
        '''
Nama : ${customer.nama}
No HP : ${customer.telepon}
Alamat : ${customer.alamat}
Password : ${customer.kataSandi}
MAC : ${customer.macAddress}
Poin: $totalPoin
'''
            .trim();

    await Clipboard.setData(ClipboardData(text: info));
    if (context.mounted) {
      ToastUtil.success(context, 'Informasi pelanggan berhasil disalin.');
    }
  }

  void _editPelanggan(BuildContext context, PelangganModel pelanggan) {
    Log.info('Navigasi ke form edit pelanggan: ${pelanggan.nama}');
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => FormPelanggan(pelanggan: pelanggan),
        ),
      ),
    );
  }

  Future<void> _navigasiKePoin(
    BuildContext context,
    PelangganModel pelanggan,
  ) async {
    Log.info('Navigasi ke halaman poin pelanggan: ${pelanggan.nama}');
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => HalamanPoin(idPelanggan: pelanggan.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(pelangganDetailProvider(widget.idPelanggan));

    // AppBar selalu tampil, body berubah sesuai state AsyncValue
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pelanggan'),
        actions: [
          // Tombol edit tetap tampil hanya jika data tersedia nanti,
          // tapi kita bisa menampilkan tombol yang memanggil fungsi edit
          // setelah data tersedia. Untuk menghindari tombol aktif tanpa data,
          // kita cek detailAsync saat ditekan.
          IconButton(
            icon: const Icon(TIcons.edit),
            tooltip: 'Edit Profil',
            onPressed: () async {
              final data = detailAsync.asData?.value;
              if (data == null) return;
              final (pelanggan, _) = data;
              if (pelanggan == null) return;
              _editPelanggan(context, pelanggan);
            },
          ),
        ],
      ),
      body: detailAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: SizedBox.shrink()),
        error: (e, s) {
          Log.error(
            'Gagal mengambil data pelanggan ID: ${widget.idPelanggan}.',
            e: e,
            s: s,
          );
          return Center(child: Text('Gagal memuat data: $e'));
        },
        data: (data) {
          final (pelanggan, totalPoin) = data;
          if (pelanggan == null) {
            return const Center(child: Text('Pelanggan tidak ditemukan'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KartuTotalPoin(
                  poin: totalPoin,
                  onTap: () => _navigasiKePoin(context, pelanggan),
                ),
                gapH24,
                _buildBagianInformasiPelanggan(pelanggan),
                gapH24,
                if (ref.isAdmin)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _salinSemuaInfo(context, pelanggan, totalPoin),
                    icon: const Icon(Icons.copy_all),
                    label: const Text('Salin Semua Info'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBagianInformasiPelanggan(PelangganModel pelanggan) {
    return Column(
      children: [
        _buildBarisDetail(
          'Nama',
          pelanggan.nama,
          () => _salinInformasi('Nama', pelanggan.nama),
        ),
        _buildBarisDetail(
          'Telepon',
          pelanggan.telepon,
          () => _salinInformasi('No Telepon', pelanggan.telepon),
        ),
        _buildBarisDetail(
          'Alamat',
          pelanggan.alamat,
          () => _salinInformasi('Alamat', pelanggan.alamat),
        ),
        if (ref.isAdmin)
          _buildBarisDetail(
            'Password',
            pelanggan.kataSandi,
            () => _salinInformasi('Password', pelanggan.kataSandi),
          ),
        _buildBarisDetail(
          'MAC Address',
          pelanggan.macAddress,
          () => _salinInformasi('MAC Address', pelanggan.macAddress),
        ),
      ],
    );
  }

  Widget _buildBarisDetail(
    String judul,
    String isiInformasi,
    Future<void> Function() salinInformasi,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blueGrey,
            ),
          ),
          gapH4,
          Row(
            children: [
              Expanded(
                child: Text(
                  isiInformasi.isEmpty ? '-' : isiInformasi,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await salinInformasi();
                },
                icon: const Icon(Icons.content_copy, size: 20),
                color: Colors.grey,
                tooltip: 'Salin $judul',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/pelanggan/provider/pelanggan_provider.dart`
```dart
// path lib/fitur/pelanggan/provider/pelanggan_provider.dart

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';

part 'pelanggan_provider.g.dart';
part 'pelanggan_provider.freezed.dart';

@freezed
abstract class PelangganState with _$PelangganState {
  const PelangganState._();
  const factory PelangganState({
    @Default([]) List<PelangganModel> daftarPelanggan,
    @Default(0) int jumlahPelanggan,
    @Default(0) int totalPoin,
  }) = _PelangganState;
  // di dalam PelangganState (freezed)
  PelangganModel? ambilBerdasarkanId(String idPelanggan) {
    // pastikan import 'package:collection/collection.dart';
    return daftarPelanggan.firstWhereOrNull((p) => p.id == idPelanggan);
  }
}

@Riverpod(keepAlive: true)
class Pelanggan extends _$Pelanggan {
  PelangganOpGlobal get _pelangganOp => ref.read(pelangganOpGlobalProvider);
  TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);

  @override
  FutureOr<PelangganState> build() {
    return _ambilData();
  }

  Future<PelangganState> _ambilData() async {
    final hasil = await _pelangganOp.ambilSemua();
    final hitungPoinFutures = hasil.map(
      (pelanggan) => _transaksiOp.ambilTotalPoin(pelanggan.id),
    );
    final daftarPoin = await Future.wait(hitungPoinFutures);
    final totalPoinSistem = daftarPoin.fold<int>(0, (sum, poin) => sum + poin);
    return PelangganState(
      daftarPelanggan: hasil,
      jumlahPelanggan: hasil.length,
      totalPoin: totalPoinSistem,
    );
  }

  void invalidateDetailPelanggan(String? idPelanggan) {
    ref.invalidateSelf();
    if (idPelanggan != null) {
      ref.invalidate(pelangganDetailProvider(idPelanggan));
    } else {
      ref.invalidate(pelangganDetailProvider);
    }
    ref.invalidate(isSearchingPelangganProvider);
    ref.invalidate(searchQueryPelangganProvider);
    ref.invalidate(namaPelangganProvider);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
  }
}

@riverpod
class IsSearchingPelanggan extends _$IsSearchingPelanggan {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void setFalse() => state = false;
}

/// Provider generator modern untuk menyimpan text query pencarian pelanggan
@riverpod
class SearchQueryPelanggan extends _$SearchQueryPelanggan {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

@riverpod
Future<String?> namaPelanggan(Ref ref, String idPelanggan) async {
  if (idPelanggan.isEmpty) return null;
  final pelangganOp = ref.watch(pelangganOpGlobalProvider);
  final pelanggan = await pelangganOp.ambilBerdasarkanId(idPelanggan);
  return pelanggan?.nama;
}

@riverpod
Future<(PelangganModel?, int)> pelangganDetail(
  Ref ref,
  String idPelanggan,
) async {
  final pelangganOp = ref.watch(pelangganOpGlobalProvider);
  final transaksiOp = ref.watch(transaksiOpGlobalProvider);
  final pelanggan = await pelangganOp.ambilBerdasarkanId(idPelanggan);
  final poin = await transaksiOp.ambilTotalPoin(idPelanggan);
  return (pelanggan, poin);
}
```

### File: `lib/fitur/pelanggan/widget/detail_pelanggan_ui.dart`
```dart
// path: lib/fitur/pelanggan/widget/detail_pelanggan_ui.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/poin/widget/kartu_total_poin.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class DetailPelangganUI extends ConsumerStatefulWidget {
  final PelangganModel pelanggan;
  final int totalPoin;
  final VoidCallback? navigasiKeEdit;
  final VoidCallback? navigasiKePoin;
  final VoidCallback? onCopyAll;

  const DetailPelangganUI({
    super.key,
    required this.pelanggan,
    required this.totalPoin,
    this.navigasiKeEdit,
    this.navigasiKePoin,
    this.onCopyAll,
  });

  @override
  ConsumerState<DetailPelangganUI> createState() => _DetailPelangganUIState();
}

class _DetailPelangganUIState extends ConsumerState<DetailPelangganUI> {
  Future<void> _salinInformasi(String label, String data) async {
    if (!mounted) return;

    if (data.isEmpty) {
      Log.warning('Tidak ada data untuk disalin pada label: $label');
      ToastUtil.warning(context, 'Tidak ada data untuk disalin.');
      return;
    }
    Log.info('Menyalin data untuk label: $label');
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    ToastUtil.success(context, '$label berhasil disalin');
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun CustomerDetailUI untuk pelanggan: ${widget.pelanggan.nama}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pelanggan'),
        actions: [
          if (widget.navigasiKeEdit != null)
            IconButton(
              icon: const Icon(TIcons.edit),
              tooltip: 'Edit Profil',
              onPressed: () {
                Log.info('Tombol Edit ditekan.');
                widget.navigasiKeEdit!();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildKartuPoin(),
            gapH24,
            _buildBagianInformasiPelanggan(),
            gapH24,
            if (widget.onCopyAll != null && ref.isAdmin)
              _buildTombolSalinSemua(),
          ],
        ),
      ),
    );
  }

  Widget _buildKartuPoin() {
    return KartuTotalPoin(
      poin: widget.totalPoin,
      onTap: () {
        if (widget.navigasiKePoin != null) {
          Log.info('Kartu Poin ditekan, navigasi ke halaman poin.');
          widget.navigasiKePoin!();
        }
      },
    );
  }

  Widget _buildBagianInformasiPelanggan() {
    return Column(
      children: [
        _buildBarisDetail('Nama', widget.pelanggan.nama, () async {
          await _salinInformasi('Nama', widget.pelanggan.nama);
        }),
        _buildBarisDetail('Telepon', widget.pelanggan.telepon, () async {
          await _salinInformasi('No Telepon', widget.pelanggan.telepon);
        }),
        _buildBarisDetail('Alamat', widget.pelanggan.alamat, () async {
          await _salinInformasi('Alamat', widget.pelanggan.alamat);
        }),
        _buildBarisDetail('Password', widget.pelanggan.kataSandi, () async {
          await _salinInformasi('Password', widget.pelanggan.kataSandi);
        }),
        _buildBarisDetail('MAC Address', widget.pelanggan.macAddress, () async {
          await _salinInformasi('MAC Address', widget.pelanggan.macAddress);
        }),
      ],
    );
  }

  Widget _buildTombolSalinSemua() {
    return ElevatedButton.icon(
      onPressed: () {
        Log.info('Tombol Salin Semua Info ditekan.');
        widget.onCopyAll!();
      },
      icon: const Icon(Icons.copy_all),
      label: const Text('Salin Semua Info'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 45),
      ),
    );
  }

  Widget _buildBarisDetail(
    final String judul,
    final String isiInformasi,
    final VoidCallback salinInformasi,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blueGrey,
            ),
          ),
          gapH4,
          Row(
            children: [
              Expanded(
                child: Text(
                  isiInformasi.isEmpty ? '-' : isiInformasi,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: salinInformasi,
                icon: const Icon(Icons.content_copy, size: 20),
                color: Colors.grey,
                tooltip: 'Salin $judul',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/pelanggan/widget/nama_pelanggan_widget.dart`
```dart
// path: lib/fitur/pelanggan/widget/nama_pelanggan_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/debug/log.dart';

class NamaPelangganWidget extends ConsumerWidget {
  final String idPelanggan;
  final TextStyle? style;
  final bool showLoadingIndicator;
  final String loadingText;
  final String errorText;
  final String emptyText;
  final TextAlign? textAlign;

  const NamaPelangganWidget({
    super.key,
    required this.idPelanggan,
    this.style,
    this.textAlign,
    this.showLoadingIndicator = false,
    this.loadingText = '',
    this.errorText = 'Error memuat data',
    this.emptyText = 'Pelanggan tidak ditemukan',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (idPelanggan.isEmpty) {
      return Text(
        emptyText,
        style:
            style?.copyWith(color: Colors.grey, fontStyle: FontStyle.italic) ??
            const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }
    final namaAsync = ref.watch(namaPelangganProvider(idPelanggan));
    return namaAsync.when(
      skipLoadingOnReload: true,
      loading: () {
        if (showLoadingIndicator) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return Text(
          loadingText,
          style:
              style?.copyWith(color: Colors.grey.shade400) ??
              const TextStyle(color: Colors.grey),
          textAlign: textAlign,
        );
      },
      error: (error, stack) {
        Log.error(
          'Gagal memuat pelanggan ID: $idPelanggan',
          e: error,
          s: stack,
        );
        return Text(
          errorText,
          style:
              style?.copyWith(color: Colors.red, fontStyle: FontStyle.italic) ??
              const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
        );
      },
      data: (nama) {
        if (nama == null || nama.isEmpty) {
          return Text(
            emptyText,
            style:
                style?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ) ??
                const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          );
        }
        return Text(nama, style: style, overflow: TextOverflow.ellipsis);
      },
    );
  }
}
```

