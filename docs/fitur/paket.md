# Dokumentasi Fitur: paket

## Daftar file

lib/fitur/paket/core/perhitungan_paket.dart
lib/fitur/paket/enum/tipe_durasi_paket.dart
lib/fitur/paket/model/paket_model.dart
lib/fitur/paket/operasi/paket_op_firebase.dart
lib/fitur/paket/operasi/paket_op_global.dart
lib/fitur/paket/operasi/paket_op_sqlite.dart
lib/fitur/paket/page/detail_paket.dart
lib/fitur/paket/page/form_paket.dart
lib/fitur/paket/page/paket.dart
lib/fitur/paket/provider/paket_provider.dart

## Isi file

### File: `lib/fitur/paket/core/perhitungan_paket.dart`
```dart
// path: lib/fitur/paket/core/perhitungan_paket.dart

import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';

/// Kelas utilitas untuk melakukan perhitungan terkait paket.
class PerhitunganPaket {
  /// Menghitung durasi paket dalam satuan menit.
  int hitungDurasiPaket(PaketModel paket) {
    switch (paket.tipe) {
      case TipeDurasiPaket.minutes:
        return paket.durasi;
      case TipeDurasiPaket.hours:
        return paket.durasi * 60;
      case TipeDurasiPaket.days:
        return paket.durasi * 24 * 60;
      case TipeDurasiPaket.months:
        return paket.durasi * 30 * 24 * 60; // Asumsi 1 bulan = 30 hari
    }
  }
}
```

### File: `lib/fitur/paket/enum/tipe_durasi_paket.dart`
```dart
// path: lib/fitur/paket/enum/tipe_durasi_paket.dart

enum TipeDurasiPaket {
  minutes,

  hours,

  days,

  months;

  String get displayName {
    switch (this) {
      case TipeDurasiPaket.minutes:
        return 'Menit';
      case TipeDurasiPaket.hours:
        return 'Jam';
      case TipeDurasiPaket.days:
        return 'Hari';
      case TipeDurasiPaket.months:
        return 'Bulan';
    }
  }
}
```

### File: `lib/fitur/paket/model/paket_model.dart`
```dart
// path: lib/fitur/paket/model/paket_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'paket_model.freezed.dart';

@freezed
abstract class PaketModel with _$PaketModel implements HasId {
  const PaketModel._();
  const factory PaketModel({
    required String id,
    required String nama,
    required int harga,
    required int durasi,
    required TipeDurasiPaket tipe,
    @Default(0) int poinHadiah,
    @Default(0) int poinPenukaran,
    @Default(false) bool statusPublik,
    DateTime? diperbaruiPada,
    @Default(false) bool statusHapus,
    DateTime? diarsipkanPada,
  }) = _PaketModel;

  static TipeDurasiPaket _parseType(dynamic value) {
    return TipeDurasiPaket.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TipeDurasiPaket.days,
    );
  }

  factory PaketModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating PackageModel from SQLite: ${map[NamaKolom.id]}');
    return PaketModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      nama: map[NamaKolom.nama] as String? ?? '',
      harga: map[NamaKolom.harga] as int? ?? 0,
      durasi: map[NamaKolom.durasi] as int? ?? 0,
      tipe: _parseType(map[NamaKolom.tipe]),
      poinHadiah: map[NamaKolom.poinHadiah] as int? ?? 0,
      poinPenukaran: map[NamaKolom.poinPenukaran] as int? ?? 0,
      statusPublik: ParserUtil.parseBool(map[NamaKolom.statusPublik]),
      statusHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.harga: harga,
      NamaKolom.durasi: durasi,
      NamaKolom.tipe: tipe.name,
      NamaKolom.poinHadiah: poinHadiah,
      NamaKolom.poinPenukaran: poinPenukaran,
      NamaKolom.statusPublik: statusPublik ? 1 : 0,
      NamaKolom.dihapus: statusHapus ? 1 : 0,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  factory PaketModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating PackageModel from Firebase: $id');
    return PaketModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      harga: data[NamaKolom.harga] as int? ?? 0,
      durasi: data[NamaKolom.durasi] as int? ?? 0,
      tipe: _parseType(data[NamaKolom.tipe]),
      poinHadiah: data[NamaKolom.poinHadiah] as int? ?? 0,
      poinPenukaran: data[NamaKolom.poinPenukaran] as int? ?? 0,
      statusPublik: ParserUtil.parseBool(data[NamaKolom.statusPublik]),
      statusHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.harga: harga,
      NamaKolom.durasi: durasi,
      NamaKolom.tipe: tipe.name,
      NamaKolom.poinHadiah: poinHadiah,
      NamaKolom.poinPenukaran: poinPenukaran,
      NamaKolom.statusPublik: statusPublik,
      NamaKolom.dihapus: statusHapus,
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

### File: `lib/fitur/paket/operasi/paket_op_firebase.dart`
```dart
// path: lib/fitur/paket/operasi/paket_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class PaketOpFirebase {
  final FirebaseFirestore db;
  final BaseOpFirebase _baseOp;
  final String _namaKoleksi = NamaTabel.paket;

  PaketOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  }) : db = firestore,
       _baseOp = baseOp {
    Log.info('PackageOpFirebase diinisialisasi.');
  }

  CollectionReference get _collection => db.collection(_namaKoleksi);

  // ============================================================
  // ✅ OPERASI TULIS (WRITE) - Menggunakan BaseOpFirebase
  // ============================================================

  /// Menambahkan paket baru ke Firebase
  Future<void> tambahPaket(PaketModel paket) async {
    Log.info('Menambahkan paket ke Firebase: ${paket.id}');
    await _baseOp.sisipkan(_namaKoleksi, paket.id, paket.toFirebase());
  }

  /// Memperbarui paket yang sudah ada di Firebase
  Future<void> perbaruiPaket(PaketModel paket) async {
    Log.info('Memperbarui paket di Firebase: ${paket.id}');
    await _baseOp.update(_namaKoleksi, paket.id, paket.toFirebase());
  }

  /// Menghapus paket secara permanen dari Firebase
  Future<void> hapusPermanen(String id) async {
    Log.warning('Menghapus paket secara permanen: $id');
    await _baseOp.hapusPermanen(_namaKoleksi, id);
  }

  /// Soft delete paket di Firebase
  Future<void> softDelete(String id) async {
    Log.info('Memulai soft delete paket di Firestore: $id');
    await _baseOp.softDelete(_namaKoleksi, id);
  }

  /// Menyisipkan atau memperbarui banyak paket sekaligus (batch)
  Future<void> sisipkanAtauPerbaruiBatch(List<PaketModel> items) async {
    if (items.isEmpty) {
      Log.info('Batch paket: daftar kosong, operasi dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${items.length} paket di Firestore',
    );

    final dataList = items.map((item) => item.toFirebase()).toList();
    await _baseOp.insertOrUpdateBatch(_namaKoleksi, dataList, NamaKolom.id);
  }

  // ============================================================
  // ✅ OPERASI BACA (READ) - Query Langsung
  // ============================================================

  /// Mengambil semua paket publik (statusPublik = true)
  Future<List<PaketModel>> ambilPaketPublik() async {
    try {
      Log.info('Mengambil paket publik dari firebase untuk penukaran poin.');
      final querySnapshot = await _collection
          .where(NamaKolom.statusPublik, isEqualTo: true)
          .where(NamaKolom.poinPenukaran, isGreaterThan: 0)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.poinPenukaran)
          .get();

      Log.info(
        'Menemukan ${querySnapshot.docs.length} paket publik dari firebase.',
      );
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PaketModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket publik firebase: $e', e: e, s: s);
      return [];
    }
  }

  /// Mengambil paket berdasarkan ID
  Future<PaketModel?> ambilBerdasarkanId(String id) async {
    try {
      Log.info('Mengambil paket untuk ID: $id');
      final doc = await _collection.doc(id).get();

      if (doc.exists) {
        final data = doc.data()! as Map<String, dynamic>;
        final package = PaketModel.fromFirebase(doc.id, data);
        Log.info('Paket ditemukan: ${package.nama}');
        return package;
      }

      Log.warning('Paket dengan ID $id tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket: $e', e: e, s: s);
      return null;
    }
  }

  /// Mengambil semua paket (termasuk yang tidak publik)
  Future<List<PaketModel>> ambilSemua() async {
    try {
      Log.info('Mengambil semua paket dari Firebase');
      final querySnapshot = await _collection
          .where(NamaKolom.dihapus, isEqualTo: false)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} paket.');
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PaketModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil semua paket: $e', e: e, s: s);
      return [];
    }
  }

  /// Mengambil beberapa paket berdasarkan daftar ID
  Future<List<PaketModel>> ambilBerdasarkanIds(List<String> ids) async {
    if (ids.isEmpty) {
      Log.warning('Daftar ID kosong, mengembalikan list kosong');
      return [];
    }

    try {
      Log.info('Mengambil ${ids.length} paket berdasarkan ID');
      final hasil = <PaketModel>[];

      for (final id in ids) {
        final paket = await ambilBerdasarkanId(id);
        if (paket != null) {
          hasil.add(paket);
        }
      }

      Log.info('Berhasil mengambil ${hasil.length} dari ${ids.length} paket');
      return hasil;
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket berdasarkan IDs: $e', e: e, s: s);
      return [];
    }
  }

  // ============================================================
  // ✅ STREAM (REALTIME)
  // ============================================================

  /// Stream paket berdasarkan ID (real-time)
  Stream<PaketModel?> ambilStreamBerdasarkanId(String id) {
    Log.info('Memulai stream untuk paket ID: $id');
    return _collection
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()! as Map<String, dynamic>;
            Log.info('Data paket diperbarui dari stream: $id');
            return PaketModel.fromFirebase(snapshot.id, data);
          }
          Log.warning('Paket ID $id tidak ditemukan di stream.');
          return null;
        })
        .handleError((Object e, StackTrace s) {
          Log.error('Error pada stream paket ID: $id', e: e, s: s);
          return null;
        });
  }

  /// Stream semua paket publik (real-time)
  Stream<List<PaketModel>> ambilStreamPaketPublik() {
    Log.info('Memulai stream paket publik');
    return _collection
        .where(NamaKolom.statusPublik, isEqualTo: true)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .orderBy(NamaKolom.poinPenukaran)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return PaketModel.fromFirebase(doc.id, data);
          }).toList();
        })
        .handleError((Object e, StackTrace s) {
          Log.error('Error pada stream paket publik', e: e, s: s);
          return <PaketModel>[];
        });
  }
}
```

### File: `lib/fitur/paket/operasi/paket_op_global.dart`
```dart
// path: lib/fitur/paket/operasi/paket_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_firebase.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class PaketOpGlobal {
  final Ref ref;

  PaketOpGlobal({required this.ref});

  PaketOpSqlite get _paketOpSqlite => ref.read(paketOpSqliteProvider);

  PaketOpFirebase get _paketOpFirebase => ref.read(paketOpFirebaseProvider);

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

  Future<List<PaketModel>> ambilSemua() async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin mengambil paket dari SQLite');
      return await _paketOpSqlite.ambilSemua();
    } else {
      Log.info('[PaketOpGlobal] User mengambil paket dari Firebase');
      return await _paketOpFirebase.ambilSemua();
    }
  }

  Future<PaketModel?> ambilBerdasarkanId(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin mengambil paket ID: $id dari SQLite');
      return await _paketOpSqlite.ambilBerdasarkanId(id);
    } else {
      Log.info('[PaketOpGlobal] User mengambil paket ID: $id dari Firebase');
      return await _paketOpFirebase.ambilBerdasarkanId(id);
    }
  }

  Future<List<PaketModel>> ambilPaketPublik() async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin mengambil paket publik dari SQLite');
      return await _paketOpSqlite.ambilPaketPublik();
    } else {
      Log.info('[PaketOpGlobal] User mengambil paket publik dari Firebase');
      return await _paketOpFirebase.ambilPaketPublik();
    }
  }

  Future<void> perbaruiPaket(PaketModel paket) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin update paket di SQLite: ${paket.nama}');
      await _paketOpSqlite.perbaruiPaket(paket);
    } else {
      Log.info('[PaketOpGlobal] User update paket di Firebase: ${paket.nama}');
      await _paketOpFirebase.perbaruiPaket(paket);
    }
  }

  Future<void> softDelete(String id) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin hapus paket ID: $id di SQLite');
      await _paketOpSqlite.hapusSementara(id);
    } else {
      Log.info('[PaketOpGlobal] User hapus paket ID: $id di Firebase');
      await _paketOpFirebase.softDelete(id);
    }
  }

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
      final hasil = <PaketModel>[];
      for (final id in ids) {
        final paket = await _paketOpFirebase.ambilBerdasarkanId(id);
        if (paket != null) {
          hasil.add(paket);
        }
      }
      return hasil;
    }
  }

  Future<bool> cekNamaPaketSudahAda(String nama, {String? idKecuali}) async {
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[PaketOpGlobal] Admin cek nama paket di SQLite: $nama');
      final semuaPaket = await _paketOpSqlite.ambilSemua();
      return semuaPaket.any(
        (p) =>
            p.nama.toLowerCase() == nama.toLowerCase() &&
            (idKecuali == null || p.id != idKecuali),
      );
    } else {
      Log.info('[PaketOpGlobal] User cek nama paket di Firebase: $nama');
      final semuaPaket = await _paketOpFirebase.ambilSemua();
      return semuaPaket.any(
        (p) =>
            p.nama.toLowerCase() == nama.toLowerCase() &&
            (idKecuali == null || p.id != idKecuali),
      );
    }
  }
}

final paketOpGlobalProvider = Provider<PaketOpGlobal>((ref) {
  return PaketOpGlobal(ref: ref);
});
```

### File: `lib/fitur/paket/operasi/paket_op_sqlite.dart`
```dart
// path: lib/fitur/paket/operasi/paket_op_sqlite.dart

import 'package:meta/meta.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data paket di database lokal.
class PaketOpSqlite {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final SqliteDatabase sqliteDb;

  /// Instance dari [BaseOpSqlite] untuk operasi CRUD dasar.
  final BaseOpSqlite basOpSqlite;
  final String _tabel = NamaTabel.paket;
  DateTime get _nowUtc => DateTime.now().toUtc();

  PaketOpSqlite({required this.sqliteDb, required this.basOpSqlite}) {
    Log.info('PackageOperation instance dibuat.');
  }

  /// Menyimpan [PaketModel] baru ke dalam database.
  Future<void> tambahPaket(PaketModel paket, {bool dariServer = false}) async {
    Log.info('Memulai createPackage untuk id: ${paket.id}');
    try {
      final data = paket.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await basOpSqlite.sisipkan(_tabel, data, dariServer: dariServer);
      Log.info('Berhasil createPackage untuk id: ${paket.id}');
    } catch (e, s) {
      Log.error('Gagal createPackage untuk id: ${paket.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui [PaketModel] yang ada di database.
  Future<void> perbaruiPaket(
    PaketModel paket, {
    bool dariServer = false,
  }) async {
    Log.info('Memulai updatePaket untuk id: ${paket.id}');
    try {
      final data = paket.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await basOpSqlite.update(_tabel, data, paket.id, dariServer: dariServer);
      Log.info('Berhasil updatePaket untuk id: ${paket.id}');
    } catch (e, s) {
      Log.error('Gagal updatePaket untuk id: ${paket.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua paket aktif (tidak diarsipkan).
  Future<List<PaketModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Memulai proses pengambilan semua data paket aktif');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? null
          : '${NamaKolom.dihapus}=0 AND ${NamaKolom.diarsipkanPada} is NULL';
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${NamaKolom.tipe}
            WHEN 'jam' THEN ${NamaKolom.durasi}
            WHEN 'hari' THEN ${NamaKolom.durasi} * 24
            WHEN 'bulan' THEN ${NamaKolom.durasi} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $_tabel
        WHERE $query
        ORDER BY urutan ASC
      ''');
      Log.info('Berhasil mengambil ${maps.length} data paket aktif');
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket aktif', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang bersifat publik.
  Future<List<PaketModel>> ambilPaketPublik() async {
    Log.info('Memulai proses pengambilan semua data paket publik');
    try {
      final db = await sqliteDb.database;
      final maps = await db.rawQuery('''
        SELECT *,
          CASE ${NamaKolom.tipe}
            WHEN 'jam' THEN ${NamaKolom.durasi}
            WHEN 'hari' THEN ${NamaKolom.durasi} * 24
            WHEN 'bulan' THEN ${NamaKolom.durasi} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $_tabel
        WHERE ${NamaKolom.dihapus} = 0 AND ${NamaKolom.statusPublik} = 1
        ORDER BY urutan ASC
      ''');
      final daftarPaket = List.generate(
        maps.length,
        (i) => PaketModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${daftarPaket.length} data wallet.');
      return daftarPaket;
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket publik', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil [PaketModel] berdasarkan [id].
  Future<PaketModel?> ambilBerdasarkanId(String id) async {
    Log.info('Memulai pencarian paket berdasarkan ID: $id');
    try {
      final db = await sqliteDb.database;
      final maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Paket ditemukan untuk ID: $id');
        return PaketModel.fromSqlite(maps.first);
      }
      Log.warning('Paket dengan ID $id tidak ditemukan');
      return null;
    } catch (e, s) {
      Log.error('Gagal mencari paket berdasarkan ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada [PaketModel] berdasarkan [id].
  Future<void> hapusSementara(String id, {bool dariServer = false}) async {
    Log.info('Memulai soft delete untuk paket id: $id');
    try {
      await basOpSqlite.softDelete(_tabel, id, dariServer: dariServer);
      Log.info('Berhasil soft delete untuk paket id: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete untuk paket id: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menandai semua paket sebagai soft-deleted (diarsipkan).
  Future<int> hapusSementaraSemua({bool dariServer = false}) async {
    Log.info('Memulai soft-delete untuk semua paket');
    try {
      final count = await basOpSqlite.softDeleteAll(
        _tabel,
        dariServer: dariServer,
      );
      Log.info('Berhasil soft-delete semua paket. Total terupdate: $count');
      return count;
    } catch (e, s) {
      Log.error('Gagal soft-delete semua paket', e: e, s: s);
      rethrow;
    }
  }

  /// Menghapus semua paket dari database secara permanen.
  Future<void> hapusSemua({bool dariServer = false}) async {
    Log.info('Memulai proses penghapusan semua data paket');
    try {
      await basOpSqlite.operasiKompleks<void>((txn) async {
        final count = await txn.delete(_tabel);
        Log.info('Berhasil menghapus semua data paket. Total terhapus: $count');
      }, dariServer: dariServer);
    } catch (e, s) {
      Log.error('Gagal menghapus semua data paket', e: e, s: s);
      rethrow;
    }
  }

  Future<List<PaketModel>> ambilPerubahanSejak(DateTime sejak) async {
    Log.info(
      'Memulai pengambilan perubahan paket sejak ${sejak.toIso8601String()}',
    );
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.diperbaruiPada} > ?',
        whereArgs: [sejak.toUtc().millisecondsSinceEpoch],
      );
      Log.info('Ditemukan ${maps.length} perubahan paket');
      return List.generate(maps.length, (i) => PaketModel.fromSqlite(maps[i]));
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan paket', e: e, s: s);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<PaketModel> items, {
    bool dariServer = false,
  }) async {
    Log.info('Memulai insertOrUpdateBatch untuk ${items.length} item paket');
    if (items.isEmpty) {
      Log.warning('List item batch kosong, operasi dibatalkan');
      return;
    }
    try {
      final daftarPaket = items
          .map((item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite())
          .toList();
      await basOpSqlite.sisipkanAtauPerbaruiBatch(
        _tabel,
        daftarPaket,
        dariServer: dariServer,
      );
      Log.info('Berhasil insertOrUpd,ateBatch untuk ${items.length} item');
    } catch (e, s) {
      Log.error('Gagal insertOrUpdateBatch', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [PaketModel] berdasarkan daftar [ids].
  Future<List<PaketModel>> ambilBerdasarkanBeberapaId(List<String> ids) async {
    Log.info('Memulai pengambilan paket berdasarkan list ID: $ids');
    try {
      if (ids.isEmpty) {
        Log.warning('List ID kosong, mengembalikan list kosong');
        return [];
      }
      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} paket dari ${ids.length} ID');
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil paket berdasarkan list ID', e: e, s: s);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/paket/page/detail_paket.dart`
```dart
// path lib/fitur/paket/page/detail_paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/page/form_paket.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';

class DetailPaketPage extends ConsumerStatefulWidget {
  final PaketModel paket;

  const DetailPaketPage({super.key, required this.paket});

  @override
  ConsumerState<DetailPaketPage> createState() => _DetailPaketState();
}

class _DetailPaketState extends ConsumerState<DetailPaketPage> {
  @override
  void initState() {
    super.initState();
    Log.info(
      'DetailPaketPage: Membuka halaman detail paket ID: $widget.paket.id',
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailPaketAsync = ref.watch(detailPaketProvider(widget.paket.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(detailPaketAsync.value?.nama ?? ''),
        actions: [
          IconButton(
            onPressed: () async {
              unawaited(
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => FormPaket(paket: widget.paket),
                  ),
                ),
              );
            },
            icon: const Icon(TIcons.edit),
            tooltip: 'Edit Paket',
          ),
        ],
      ),
      body: detailPaketAsync.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              gapH16,
              Text(
                'Gagal memuat data paket',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              gapH8,
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              gapH16,
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(detailPaketProvider(widget.paket.id));
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (paket) => _buildContent(context, paket),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaketModel paket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.blueAccent),
                  gapH8,
                  Text(
                    'Informasi Layanan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              gapH20,
              _buildDetailRow('Nama Paket', paket.nama),
              _buildDetailRow('Harga Sewa', 'Rp ${paket.harga}'),
              _buildDetailRow(
                'Masa Aktif',
                '${paket.durasi} ${paket.tipe.displayName}',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(thickness: 1),
              ),
              Row(
                children: [
                  const Icon(TIcons.points, color: Colors.orange),
                  gapH8,
                  Text(
                    'Sistem Poin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              gapH12,
              _buildDetailRow(
                'Poin Hadiah',
                '${paket.poinHadiah} Poin',
                subTitle: 'Didapat saat beli paket',
              ),
              _buildDetailRow(
                'Poin Penukaran',
                '${paket.poinPenukaran} Poin',
                subTitle: 'Syarat tukar gratis',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(thickness: 1),
              ),
              _buildDetailRow(
                'Status Publik',
                paket.statusPublik ? 'Tersedia di Aplikasi' : 'Hanya Admin',
                customValueColor: paket.statusPublik
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    final String label,
    final String value, {
    final String? subTitle,
    final Color? customValueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                if (subTitle != null)
                  Text(
                    subTitle,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: TeksIsiSedang(value, rataTeks: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/paket/page/form_paket.dart`
```dart
// path: lib/fitur/paket/page/form_paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_angka.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';

/// Halaman form untuk menambah atau mengedit paket.
class FormPaket extends ConsumerStatefulWidget {
  /// Model paket yang akan diedit. Jika null, maka form akan membuat paket baru.
  final PaketModel? paket;

  /// Konstruktor untuk PackageForm.
  const FormPaket({super.key, this.paket});

  @override
  ConsumerState<FormPaket> createState() => _PackageFormState();
}

class _PackageFormState extends ConsumerState<FormPaket> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _durasiController = TextEditingController();
  final _poinHadiahcontroller = TextEditingController();
  final _poinPenukaranController = TextEditingController();
  final _namaFocusNode = FocusNode();
  final _hargaFocusNode = FocusNode();
  final _durasiFocusNode = FocusNode();
  final _poinHadiahFocusNode = FocusNode();
  final _poinPenukaranFocusNode = FocusNode();

  TipeDurasiPaket _selectedType = TipeDurasiPaket.days;
  bool _poin = false;
  bool get _modeEdit => widget.paket != null;
  bool _publik = false;

  @override
  void initState() {
    super.initState();
    if (_modeEdit) {
      _namaController.text = widget.paket!.nama;
      _hargaController.text = widget.paket!.harga.toString();
      _durasiController.text = widget.paket!.durasi.toString();
      _poinHadiahcontroller.text = widget.paket!.poinHadiah.toString();
      _poinPenukaranController.text = widget.paket!.poinPenukaran.toString();
      _selectedType = widget.paket!.tipe;
      _publik = widget.paket!.statusPublik;
      _poin = widget.paket!.poinHadiah > 0 || widget.paket!.poinPenukaran > 0;
    }
  }

  Future<void> _simpanForm() async {
    final paketNotifier = ref.read(paketProvider.notifier);
    if (_formKey.currentState!.validate()) {
      final paketBaru = PaketModel(
        id: _modeEdit ? widget.paket!.id : const Uuid().v4(),
        nama: _namaController.text,
        harga:
            int.tryParse(
              _hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        durasi: int.tryParse(_durasiController.text) ?? 0,
        tipe: _selectedType,
        poinHadiah: _poin ? (int.tryParse(_poinHadiahcontroller.text) ?? 0) : 0,
        poinPenukaran: _poin
            ? (int.tryParse(_poinPenukaranController.text) ?? 0)
            : 0,
        statusPublik: _publik,
        diperbaruiPada: DateTime.now(),
      );

      try {
        if (_modeEdit) {
          await paketNotifier.perbarui(paketBaru);
        } else {
          await paketNotifier.tambah(paketBaru);
        }
        ref.invalidate(paketProvider);
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (!mounted) {
          return;
        }
        ToastUtil.success(
          context,
          'Data paket berhasil ${_modeEdit ? 'diperbarui' : 'disimpan'}!',
        );
        Navigator.pop(context);
      } on DatabaseException catch (e, s) {
        var pesanError = 'Gagal menyimpan paket. Terjadi kesalahan database.';
        if (e.isUniqueConstraintError()) {
          pesanError = 'Nama paket sudah ada. Harap gunakan nama lain.';
        } else {
          Log.error(
            'DatabaseException tidak dikenal saat menyimpan paket. Kemungkinan penyebab: constraint violation lain, database corrupt, atau kesalahan struktur tabel.',
            e: e,
            s: s,
          );
        }

        if (!mounted) {
          return;
        }
        ToastUtil.error(context, pesanError);
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menyimpan paket karena error tidak dikenal (Unknown Error). Terjadi kesalahan yang tidak terduga saat operasi ${_modeEdit ? "update" : "create"} paket.',
          e: e,
          s: s,
        );

        if (!mounted) {
          return;
        }
        ToastUtil.error(context, 'Terjadi kesalahan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Paket' : 'Tambah Paket'),
        leading: IconButton(
          icon: const Icon(TIcons.back),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                InputTeks(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  nextFocusNode: _hargaFocusNode,
                  label: 'Nama Paket',
                ),

                gapH12,
                InputAngka(
                  controller: _hargaController,
                  focusNode: _hargaFocusNode,
                  label: 'Harga',
                  nextFocusNode: _durasiFocusNode,
                ),
                gapH12,
                InputAngka(
                  controller: _durasiController,
                  focusNode: _durasiFocusNode,
                  label: 'Durasi',
                  nextFocusNode: _poinHadiahFocusNode,
                ),
                gapH12,
                SwitchListTile(
                  title: const Text('Aktifkan Poin'),
                  value: _poin,
                  onChanged: (v) {
                    setState(() {
                      _poin = v;
                    });
                  },
                ),
                gapH12,
                if (_poin) ...[
                  InputAngka(
                    controller: _poinHadiahcontroller,
                    focusNode: _poinHadiahFocusNode,
                    nextFocusNode: _poinPenukaranFocusNode,
                    label: 'Poin Hadiah',
                  ),
                  gapH12,
                  InputAngka(
                    controller: _poinPenukaranController,
                    focusNode: _poinPenukaranFocusNode,
                    label: 'Poin Penukaran',
                    textInputAction: TextInputAction.done,
                  ),
                ],
                gapH16,
                DropdownButtonFormField<TipeDurasiPaket>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Tipe Durasi'),
                  items: TipeDurasiPaket.values.map((tipeDurasi) {
                    return DropdownMenuItem<TipeDurasiPaket>(
                      value: tipeDurasi,
                      child: Text(tipeDurasi.displayName),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    }
                  },
                ),
                gapH12,
                SwitchListTile(
                  title: const Text('Paket Aktif (Public)'),
                  subtitle: const Text('Jika OFF, paket tidak tampil ke user'),
                  value: _publik,
                  onChanged: (v) {
                    setState(() {
                      _publik = v;
                    });
                  },
                ),
                gapH20,
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ElevatedButton(
          onPressed: () async {
            await _simpanForm();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Simpan'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _durasiController.dispose();
    _poinHadiahcontroller.dispose();
    _poinPenukaranController.dispose();
    _namaFocusNode.dispose();
    _hargaFocusNode.dispose();
    _durasiFocusNode.dispose();
    _poinHadiahFocusNode.dispose();
    _poinPenukaranFocusNode.dispose();
    super.dispose();
  }
}
```

### File: `lib/fitur/paket/page/paket.dart`
```dart
// path lib/fitur/paket/page/paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/paket/page/form_paket.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/durasi_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

enum UrutanPaket {
  namaAZ,
  namaZA,
  hargaTertinggi,
  hargaTerendah,
  poinTertinggi,
  poinTerendah,
  durasiTerlama,
  durasiTerpendek,
}

class PackagePage extends ConsumerWidget {
  const PackagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paketAsync = ref.watch(paketProvider);
    final urutanSaatIni = ref.watch(urutanPaketStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket'),
        actions: [
          IconButton(
            onPressed: () => _tampilkanDialogUrutkan(context, ref),
            icon: const Icon(TIcons.sort),
            tooltip: 'Urutkan',
          ),
          IconButton(
            onPressed: () => _hapusSemuaPaket(context, ref),
            icon: const Icon(TIcons.delete),
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: paketAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) {
          Log.error('Terjadi error saat memuat data paket', e: e, s: s);
          return Center(child: Text('Error: $e'));
        },
        data: (paketList) {
          if (paketList.daftarPaket.isEmpty) {
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }
          final sortedList = List<PaketModel>.from(paketList.daftarPaket);
          _urutkanList(sortedList, urutanSaatIni);
          return ListView.builder(
            itemCount: sortedList.length,
            itemBuilder: (context, index) {
              final paket = sortedList[index];
              return InkWell(
                onTap: () {
                  unawaited(
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => DetailPaketPage(paket: paket),
                      ),
                    ),
                  );
                },
                onLongPress: () =>
                    _tampilkanDialogHapusEdit(context, ref, paket),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: TeksJudulSedang(
                      paket.nama,
                      tebalFont: FontWeight.bold,
                    ),
                    subtitle: TeksIsiKecil(
                      '${FormatUang.formatMataUang(paket.harga.toDouble())} / ${paket.durasi} ${paket.tipe.displayName}',
                    ),
                    trailing: TeksIsiSedang('Poin: ${paket.poinHadiah}'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          unawaited(
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (context) => const FormPaket()),
            ),
          );
        },
        tooltip: 'Tambah Paket',
        child: const Icon(TIcons.add),
      ),
    );
  }
}

void _urutkanList(List<PaketModel> daftarPaket, UrutanPaket urutan) {
  switch (urutan) {
    case UrutanPaket.namaAZ:
      daftarPaket.sort(
        (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
      );
      break;
    case UrutanPaket.namaZA:
      daftarPaket.sort(
        (a, b) => b.nama.toLowerCase().compareTo(a.nama.toLowerCase()),
      );
      break;
    case UrutanPaket.hargaTertinggi:
      daftarPaket.sort((a, b) => b.harga.compareTo(a.harga));
      break;
    case UrutanPaket.hargaTerendah:
      daftarPaket.sort((a, b) => a.harga.compareTo(b.harga));
      break;
    case UrutanPaket.poinTertinggi:
      daftarPaket.sort((a, b) => b.poinHadiah.compareTo(a.poinHadiah));
      break;
    case UrutanPaket.poinTerendah:
      daftarPaket.sort((a, b) => a.poinHadiah.compareTo(b.poinHadiah));
      break;
    case UrutanPaket.durasiTerpendek:
      daftarPaket.sort(
        (a, b) => DurasiUtil.hitungDurasiDalamMenit(
          a,
        ).compareTo(DurasiUtil.hitungDurasiDalamMenit(b)),
      );
      break;
    case UrutanPaket.durasiTerlama:
      daftarPaket.sort(
        (a, b) => DurasiUtil.hitungDurasiDalamMenit(
          b,
        ).compareTo(DurasiUtil.hitungDurasiDalamMenit(a)),
      );
      break;
  }
}

Future<void> _tampilkanDialogUrutkan(
  BuildContext context,
  WidgetRef ref,
) async {
  final urutanSaatIni = ref.read(urutanPaketStateProvider);

  final hasil = await showDialog<UrutanPaket>(
    context: context,
    builder: (context) {
      Widget buildOption(String text, UrutanPaket value) {
        final urutanTerpilih = urutanSaatIni == value;
        return SimpleDialogOption(
          onPressed: () => Navigator.pop(context, value),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: TSizes.p8,
              horizontal: TSizes.p4,
            ),
            decoration: BoxDecoration(
              color: urutanTerpilih ? TColors.pointBackground : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(text, textAlign: TextAlign.center),
          ),
        );
      }

      return SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: [
          buildOption('Durasi (Terpendek)', UrutanPaket.durasiTerpendek),
          buildOption('Durasi (Terlama)', UrutanPaket.durasiTerlama),
          buildOption('Nama (A-Z)', UrutanPaket.namaAZ),
          buildOption('Nama (Z-A)', UrutanPaket.namaZA),
          buildOption('Harga (Tertinggi)', UrutanPaket.hargaTertinggi),
          buildOption('Harga (Terendah)', UrutanPaket.hargaTerendah),
          buildOption('Poin (Tertinggi)', UrutanPaket.poinTertinggi),
          buildOption('Poin (Terendah)', UrutanPaket.poinTerendah),
        ],
      );
    },
  );

  if (hasil != null) {
    ref.read(urutanPaketStateProvider.notifier).ubahUrutan(hasil);
  }
}

Future<void> _tampilkanDialogHapusEdit(
  BuildContext context,
  WidgetRef ref,
  PaketModel paket,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(paket.nama),
        content: const Text('Pilih aksi yang ingin Anda lakukan.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (!context.mounted) return;
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => FormPaket(paket: paket),
                  ),
                ),
              );
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _tampilkanDialogKonfirmasiHapus(context, ref, paket);
            },
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );
}

Future<void> _tampilkanDialogKonfirmasiHapus(
  BuildContext context,
  WidgetRef ref,
  PaketModel paket,
) async {
  final paketOp = ref.read(paketOpGlobalProvider);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus paket ${paket.nama}?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await paketOp.softDelete(paket.id);
                ref.invalidate(paketProvider);
                unawaited(
                  ref
                      .read(layananCekSinkronisasiProvider)
                      .jalankanCekSinkronisasi(),
                );
                if (dialogContext.mounted) {
                  ToastUtil.success(context, 'Paket berhasil dihapus.');
                }
              } on Exception catch (e, s) {
                Log.error('Gagal hapus paket', e: e, s: s);
                if (dialogContext.mounted) {
                  ToastUtil.error(context, 'Gagal menghapus paket: $e');
                }
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _hapusSemuaPaket(BuildContext context, WidgetRef ref) async {
  Log.info('User menekan tombol hapus semua paket');
  final paketOpSqlite = ref.read(paketOpSqliteProvider);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus Semua'),
        content: const Text('Yakin ingin menghapus SEMUA paket?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Semua'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                Log.info('Menjalankan soft delete semua paket');
                await paketOpSqlite.hapusSementaraSemua();
                unawaited(
                  ref
                      .read(layananCekSinkronisasiProvider)
                      .jalankanCekSinkronisasi(),
                );
                ref.invalidate(paketProvider);
                if (context.mounted) {
                  ToastUtil.success(context, 'Semua paket dihapus.');
                }
              } on Exception catch (e, s) {
                Log.error('Gagal hapus semua paket', e: e, s: s);
                if (context.mounted) {
                  ToastUtil.error(context, 'Gagal menghapus semua paket: $e');
                }
              }
            },
          ),
        ],
      );
    },
  );
}
```

### File: `lib/fitur/paket/provider/paket_provider.dart`
```dart
// path: lib/fitur/paket/provider/paket_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/paket/page/paket.dart';
import 'package:wifi/shared/debug/log.dart';

part 'paket_provider.g.dart';
part 'paket_provider.freezed.dart';

@freezed
abstract class PaketState with _$PaketState {
  const factory PaketState({
    @Default([]) List<PaketModel?> daftarPaket,
    @Default([]) List<PaketModel?> daftarPaketPublik,
    @Default(0) int jumlahPaket,
  }) = _PaketState;
}

@Riverpod(keepAlive: true)
class Paket extends _$Paket {
  PaketOpGlobal get _paketOp => ref.read(paketOpGlobalProvider);

  @override
  FutureOr<PaketState> build() async {
    return _ambilData();
  }

  Future<PaketState> _ambilData() async {
    final daftarpaket = await _paketOp.ambilSemua();
    final daftarPaketPublik = await _paketOp.ambilPaketPublik();

    return PaketState(
      daftarPaket: daftarpaket,
      jumlahPaket: daftarpaket.length,
      daftarPaketPublik: daftarPaketPublik,
    );
  }

  Future<void> tambah(PaketModel paket) async {
    try {
      await _paketOp.tambahPaket(paket);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error di tambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(PaketModel paket) async {
    try {
      await _paketOp.perbaruiPaket(paket);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error diupdate: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await _paketOp.softDelete(id);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error disoftDelete: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> refresh() async {
    Log.info('PaketProvider: Menyegarkan data paket');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
    Log.info('PaketProvider: Penyegaran data paket selesai');
  }

  Future<void> invalidateProviderPaket() async {
    ref.invalidateSelf();
    ref.invalidate(detailPaketProvider);
    ref.invalidate(urutanPaketStateProvider);
  }
}

@riverpod
class UrutanPaketState extends _$UrutanPaketState {
  @override
  UrutanPaket build() {
    return UrutanPaket.durasiTerpendek;
  }

  void ubahUrutan(UrutanPaket urutanBaru) {
    state = urutanBaru;
  }
}

@riverpod
Future<PaketModel> detailPaket(Ref ref, String id) async {
  Log.info('Mendapatkan detail paket dari SQLite via paketProvider...');
  final paketOp = ref.watch(paketOpGlobalProvider);
  final paket = await paketOp.ambilBerdasarkanId(id);
  if (paket == null) {
    throw Exception('Paket dengan id $id tidak ditemukan');
  }
  return paket;
}

@riverpod
Future<String?> namaPaket(Ref ref, String idPaket) async {
  if (idPaket.isEmpty) return null;
  final paketState = await ref.watch(paketProvider.future);
  final paket = paketState.daftarPaket.firstWhere((p) => p!.id == idPaket);
  if (paket == null) return null;
  return paket.nama;
}
```

