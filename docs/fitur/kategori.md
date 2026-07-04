# Dokumentasi Fitur: kategori

## Daftar file

- [lib/fitur/kategori/enum/tipe_kategori.dart](../../lib/fitur/kategori/enum/tipe_kategori.dart)
- [lib/fitur/kategori/model/kategori_model.dart](../../lib/fitur/kategori/model/kategori_model.dart)
- [lib/fitur/kategori/model/sub_kategori_model.dart](../../lib/fitur/kategori/model/sub_kategori_model.dart)
- [lib/fitur/kategori/operasi/kategori_op_sqlite.dart](../../lib/fitur/kategori/operasi/kategori_op_sqlite.dart)
- [lib/fitur/kategori/operasi/sub_kategori_op_sqlite.dart](../../lib/fitur/kategori/operasi/sub_kategori_op_sqlite.dart)
- [lib/fitur/kategori/page/form_kategori.dart](../../lib/fitur/kategori/page/form_kategori.dart)
- [lib/fitur/kategori/page/kategori.dart](../../lib/fitur/kategori/page/kategori.dart)

## Isi file

### File: `lib/fitur/kategori/enum/tipe_kategori.dart`
```dart
// path: lib/fitur/kategori/enum/tipe_kategori.dart

/// Enum untuk mendefinisikan tipe-tipe kategori transaksi.
enum TipeKategori {
  /// Mewakili transaksi yang menambah saldo (pemasukan).
  income,

  /// Mewakili transaksi yang mengurangi saldo (pengeluaran).
  expense,

  /// Mewakili transaksi transfer dana antar dompet.
  transfer,
}

extension CategoryTypeExtension on TipeKategori {
  String get displayName {
    switch (this) {
      case TipeKategori.income:
        return 'Pemasukan';
      case TipeKategori.expense:
        return 'Pengeluaran';
      case TipeKategori.transfer:
        return 'Transfer';
    }
  }
}
```

### File: `lib/fitur/kategori/model/kategori_model.dart`
```dart
// path: lib/fitur/kategori/model/kategori_model.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'kategori_model.freezed.dart';

@freezed
abstract class KategoriModel with _$KategoriModel implements HasId {
  const KategoriModel._(); // Private constructor untuk method custom

  const factory KategoriModel({
    @Default('') String id,
    required String nama,
    required TipeKategori tipe,
    @Default(<SubKategoriModel>[]) List<SubKategoriModel> idSubKategori,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _KategoriModel;

  // Factory method opsional untuk membuat instance dengan UUID otomatis
  factory KategoriModel.createNew({
    required String nama,
    required TipeKategori tipe,
    List<SubKategoriModel> idSubKategori = const [],
    DateTime? diperbaruiPada,
    bool diHapus = false,
    DateTime? diarsipkanPada,
  }) {
    final id = const Uuid().v4();
    Log.info('CategoryModel created: $id, name: $nama');
    return KategoriModel(
      id: id,
      nama: nama,
      tipe: tipe,
      idSubKategori: idSubKategori,
      diperbaruiPada: diperbaruiPada,
      diHapus: diHapus,
      diarsipkanPada: diarsipkanPada,
    );
  }

  // =========================
  // SQLITE
  // =========================

  factory KategoriModel.fromSqlite(final Map<String, dynamic> map) {
    List<SubKategoriModel> parseSubCategories(final dynamic data) {
      if (data == null) return [];
      try {
        if (data is String && data.isNotEmpty) {
          final list = jsonDecode(data) as List<dynamic>;
          return list
              .map((final item) {
                if (item is Map<String, dynamic>) {
                  return SubKategoriModel.fromSqlite(item);
                }
                return null;
              })
              .whereType<SubKategoriModel>()
              .toList();
        }
        return [];
      } on FormatException catch (e, st) {
        Log.error('Failed to parse subcategories from JSON', e: e, s: st);
        return [];
      }
    }

    return KategoriModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      nama: map[NamaKolom.nama] as String? ?? '',
      tipe:
          ParserUtil.safeParseEnum(TipeKategori.values, map[NamaKolom.tipe]) ??
          TipeKategori.expense,
      idSubKategori: parseSubCategories(map[NamaKolom.idSubKategori]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.tipe: tipe.name,
      NamaKolom.idSubKategori: jsonEncode(
        idSubKategori.map((sub) => sub.toSqlite()).toList(),
      ),
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory KategoriModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    List<SubKategoriModel> parseSubCategories(final dynamic subCategoryData) {
      if (subCategoryData is List) {
        return subCategoryData
            .map((item) {
              if (item is Map<String, dynamic>) {
                final subId =
                    item[NamaKolom.id] as String? ?? const Uuid().v4();
                return SubKategoriModel.fromFirebase(subId, item);
              }
              return null;
            })
            .whereType<SubKategoriModel>()
            .toList();
      }
      return [];
    }

    return KategoriModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      tipe:
          ParserUtil.safeParseEnum(TipeKategori.values, data[NamaKolom.tipe]) ??
          TipeKategori.expense,
      idSubKategori: parseSubCategories(data[NamaKolom.idSubKategori]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.tipe: tipe.name,
      NamaKolom.idSubKategori: idSubKategori
          .map((sub) => sub.toFirebase())
          .toList(),
      NamaKolom.dihapus: diHapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
```

### File: `lib/fitur/kategori/model/sub_kategori_model.dart`
```dart
// path: lib/fitur/kategori/model/sub_kategori_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'sub_kategori_model.freezed.dart';

@freezed
abstract class SubKategoriModel with _$SubKategoriModel implements HasId {
  const SubKategoriModel._();
  const factory SubKategoriModel({
    required String id,
    required String nama,
    required String idKategori,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _SubKategoriModel;

  factory SubKategoriModel.fromSqlite(final Map<String, dynamic> map) {
    return SubKategoriModel(
      id: map[NamaKolom.id] as String? ?? '',
      nama: map[NamaKolom.nama] as String? ?? '',
      idKategori: map[NamaKolom.idKategori] as String? ?? '',
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.idKategori: idKategori,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  factory SubKategoriModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    return SubKategoriModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      idKategori: data[NamaKolom.idKategori] as String? ?? '',
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.idKategori: idKategori,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.dihapus: diHapus,
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
```

### File: `lib/fitur/kategori/operasi/kategori_op_sqlite.dart`
```dart
// path: lib/fitur/kategori/operasi/kategori_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class KategoriOpSqlite {
  final SqliteDatabase sqlitedb;
  final BaseOpSqlite _baseOpSqlite;
  final String _namaTabel = NamaTabel.kategori;

  KategoriOpSqlite({
    required this.sqlitedb,
    required final BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite;

  Future<KategoriModel> tambahKategori(
    final KategoriModel kategori, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai createCategory untuk category: ${kategori.toSqlite()}');
    try {
      final kategoriBaru = kategori.copyWith(
        diperbaruiPada: DateTime.now().toUtc(),
      );
      final data = kategoriBaru.toSqlite();

      await _baseOpSqlite.sisipkan(_namaTabel, data, dariServer: dariServer);
      Log.info('Berhasil membuat category baru dengan ID: ${kategoriBaru.id}');
      return kategoriBaru;
    } catch (e, st) {
      Log.error('Gagal saat createCategory', e: e, s: st);
      rethrow;
    }
  }

  Future<List<KategoriModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info(
      'Memulai getCategories (mengambil semua kategori yang tidak diarsipkan).',
    );
    try {
      final db = await sqlitedb.database;
      final query = tampilkanYangDiarsip
          ? null
          : '${NamaKolom.dihapus}=0 AND ${NamaKolom.diarsipkanPada} is NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        orderBy: '${NamaKolom.diperbaruiPada} DESC',
      );
      final daftarKategori = List.generate(
        maps.length,
        (i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${daftarKategori.length} data category.');
      return daftarKategori;
    } catch (e, st) {
      Log.error('Gagal saat getCategories', e: e, s: st);
      rethrow;
    }
  }

  Future<KategoriModel> ambilKategoriBerdasarkanId(String id) async {
    Log.info('Memulai getCategoryById untuk ID: $id');
    try {
      final db = await sqlitedb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final kategori = KategoriModel.fromSqlite(maps.first);
        Log.info('Category dengan ID: $id ditemukan.');
        return kategori;
      } else {
        Log.error('Category dengan ID $id tidak ditemukan di database.');
        throw Exception('Category dengan ID $id tidak ditemukan.');
      }
    } catch (e, st) {
      Log.error('Gagal saat getCategoryById untuk ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<List<KategoriModel>> ambilKategoriBerdasarkanTipe(
    TipeKategori tipe,
  ) async {
    Log.info('Memulai getCategoriesByType untuk tipe: ${tipe.name}');
    try {
      final db = await sqlitedb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.tipe} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [tipe.name],
      );
      final daftarKategori = List.generate(
        maps.length,
        (i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${daftarKategori.length} data category untuk tipe ${tipe.name}.',
      );
      return daftarKategori;
    } catch (e, st) {
      Log.error(
        'Gagal saat getCategoriesByType untuk tipe: ${tipe.name}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> updateKategori(
    final KategoriModel kategori, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai updateCategory untuk category ID: ${kategori.id}');
    try {
      final data = kategori
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();
      await _baseOpSqlite.update(
        _namaTabel,
        data,
        kategori.id,
        dariServer: dariServer,
      );
      Log.info('Berhasil updateCategory untuk ID: ${kategori.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat updateCategory untuk ID: ${kategori.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> softDeleteKategori(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk category ID: $id');
    try {
      await _baseOpSqlite.softDelete(_namaTabel, id, dariServer: dariServer);
      Log.info('Berhasil soft delete category ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat soft delete category ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAllKategori({final bool dariServer = false}) async {
    Log.info('Memulai soft delete untuk semua kategori');
    try {
      final count = await _baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: dariServer,
      );
      Log.info('Berhasil soft delete semua kategori. Total: $count item.');
      return count;
    } catch (e, st) {
      Log.error('Gagal saat soft delete semua kategori', e: e, s: st);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<KategoriModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai insertOrUpdateBatch untuk ${items.length} item category.',
    );
    if (items.isEmpty) {
      Log.warning(
        'List item untuk batch kosong, tidak ada operasi yang dilakukan.',
      );
      return;
    }
    try {
      final data = items
          .map(
            (final item) => item
                .copyWith(diperbaruiPada: DateTime.now().toUtc())
                .toSqlite(),
          )
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan insertOrUpdateBatch untuk ${items.length} item category.',
      );
    } catch (e, st) {
      Log.error(
        'Gagal saat menjalankan insertOrUpdateBatch category',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<List<KategoriModel>> ambilKategoriBerdasarkanIds(
    final List<String> ids,
  ) async {
    Log.info('Memulai getCategoriesByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
        'List ID untuk getCategoriesByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await sqlitedb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${listCategory.length} category dari ${ids.length} ID yang diminta.',
      );
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getCategoriesByIds', e: e, s: st);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/kategori/operasi/sub_kategori_op_sqlite.dart`
```dart
// path: lib/fitur/kategori/operasi/sub_kategori_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data sub-kategori di database lokal.
class SubKategoriOpSqlite {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final SqliteDatabase sqliteDb;

  /// Instance dari [BaseOpSqlite] untuk operasi CRUD dasar.
  final BaseOpSqlite baseOpSqlite;

  final String _tableName = NamaTabel.subKategori;

  SubKategoriOpSqlite({required this.sqliteDb, required this.baseOpSqlite});

  /// Menyimpan [SubKategoriModel] baru ke dalam database.
  Future<void> createSubCategory(
    final SubKategoriModel subKategori, {
    final bool fromServer = false,
  }) async {
    Log.info('Membuat sub-kategori baru: ${subKategori.nama}');
    try {
      final data = subKategori
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();
      await baseOpSqlite.sisipkan(_tableName, data, dariServer: fromServer);
      Log.info('Berhasil membuat sub-kategori ID: ${subKategori.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal membuat sub-kategori.', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua sub-kategori yang terkait dengan [categoryId].
  Future<List<SubKategoriModel>> ambilBerdasarkanIdPelanggan(
    final String categoryId,
  ) async {
    Log.info('Mengambil sub-kategori untuk kategori ID: $categoryId');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.idKategori} = ? AND ${NamaKolom.dihapus} = ?',
        whereArgs: [categoryId, 0],
      );
      Log.info('Berhasil mengambil ${maps.length} sub-kategori aktif.');
      return List.generate(maps.length, (final i) {
        return SubKategoriModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengambil sub-kategori berdasarkan kategori ID.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil [SubKategoriModel] berdasarkan [id].
  Future<SubKategoriModel?> getSubCategoryById(final String id) async {
    Log.info('Mengambil sub-kategori dengan ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Sub-kategori dengan ID: $id ditemukan.');
        return SubKategoriModel.fromSqlite(maps.first);
      }
      Log.warning('Sub-kategori dengan ID: $id tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil sub-kategori berdasarkan ID.', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui [SubKategoriModel] yang ada di database.
  Future<void> updateSubCategory(
    final SubKategoriModel subKategori, {
    final bool fromServer = false,
  }) async {
    Log.info('Memperbarui sub-kategori: ${subKategori.nama}');
    try {
      final data = subKategori
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();
      await baseOpSqlite.update(
        _tableName,
        data,
        subKategori.id,
        dariServer: fromServer,
      );
      Log.info('Berhasil memperbarui sub-kategori ID: ${subKategori.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal memperbarui sub-kategori.', e: e, s: s);
      rethrow;
    }
  }

  /// Menghapus [SubKategoriModel] dari database secara permanen.
  Future<void> delete(final String id, {final bool fromServer = false}) async {
    Log.warning('PERINGATAN: Menghapus sub-kategori ID: $id secara permanen');
    try {
      await baseOpSqlite.delete(_tableName, id, dariServer: fromServer);
      Log.warning('Berhasil melakukan hard delete sub-kategori ID: $id');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus sub-kategori secara permanen.', e: e, s: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada sub-kategori berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk sub-kategori ID: $id');
    try {
      await baseOpSqlite.softDelete(_tableName, id, dariServer: dariServer);
      Log.info('Berhasil soft delete sub-kategori ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete sub-kategori ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua sub-kategori.
  Future<int> softDeleteAll({final bool fromServer = false}) async {
    Log.info('Memulai soft delete untuk semua sub-kategori');
    try {
      final count = await baseOpSqlite.softDeleteAll(
        _tableName,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua sub-kategori. Total: $count item.');
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete semua sub-kategori', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [SubKategoriModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<SubKategoriModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk ${items.length} sub-kategori.');
    if (items.isEmpty) {
      Log.warning('List item kosong, membatalkan proses operasi batch.');
      return;
    }
    try {
      final data = items
          .map(
            (final item) => item
                .copyWith(diperbaruiPada: DateTime.now().toUtc())
                .toSqlite(),
          )
          .toList();
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _tableName,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch sub-kategori selesai diproses.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan operasi batch sub-kategori.', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [SubKategoriModel] berdasarkan daftar [ids].
  Future<List<SubKategoriModel>> getSubCategoryByIds(
    final List<String> ids,
  ) async {
    Log.info('Mengambil sub-kategori untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning('Daftar ID kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id IN ($placeholders) AND ${NamaKolom.dihapus} = 0',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} sub-kategori dari list ID.');
      return List.generate(maps.length, (final i) {
        return SubKategoriModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengambil sub-kategori berdasarkan list ID.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}
```

### File: `lib/fitur/kategori/page/form_kategori.dart`
```dart
// path lib/fitur/kategori/page/form_kategori.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman form untuk menambah atau mengedit kategori dan sub-kategori.
class CategoryForm extends ConsumerStatefulWidget {
  /// Model kategori yang akan diedit. Jika null, maka form akan membuat kategori baru.
  final KategoriModel? kategori;

  /// Model sub-kategori yang akan diedit.
  final SubKategoriModel? subKategori;

  /// ID kategori induk untuk membuat sub-kategori baru.
  final String? idKategoriInduk;

  /// Konstruktor untuk CategoryForm.
  const CategoryForm({
    super.key,
    this.kategori,
    this.subKategori,
    this.idKategoriInduk,
  });

  @override
  ConsumerState<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TipeKategori _tipe;
  late TextEditingController _namaController;
  final _namaFocusNode = FocusNode();

  final List<TextEditingController> _subKategoriControllers = [];
  final List<SubKategoriModel?> _subKategoriModels = [];

  bool get _modeEdit => widget.kategori != null || widget.subKategori != null;
  bool get _modeSubKategori =>
      widget.subKategori != null || widget.idKategoriInduk != null;

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.kategori != null || widget.subKategori != null;
    final isSubKategoriMode =
        widget.subKategori != null || widget.idKategoriInduk != null;

    Log.info(
      '''Membuat state untuk CategoryForm. Mode: ${isEditMode ? "EDIT" : "TAMBAH BARU"}, Jenis: ${isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}, ${widget.kategori != null ? "Kategori: ${widget.kategori!.nama} (ID: ${widget.kategori!.id})" : ""}${widget.subKategori != null ? "Sub-Kategori: ${widget.subKategori!.nama} (ID: ${widget.subKategori!.id})" : ""}${widget.idKategoriInduk != null ? "ID Kategori Induk: ${widget.idKategoriInduk}" : ""}''',
    );

    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman CategoryForm');
    Log.info('========================================');

    Log.info('Membuat TextEditingController untuk input nama.');
    _namaController = TextEditingController();
    Log.info('TextEditingController berhasil dibuat.');

    Log.info('Membuat FocusNode untuk input nama.');
    Log.info('FocusNode berhasil dibuat: ${_namaFocusNode.hashCode}');

    if (widget.kategori != null) {
      Log.info('MODE EDIT KATEGORI UTAMA terdeteksi.');
      Log.info('Data kategori yang akan diedit:');
      Log.info('  - ID: ${widget.kategori!.id}');
      Log.info('  - Nama: ${widget.kategori!.nama}');
      Log.info('  - Tipe: ${widget.kategori!.tipe}');
      Log.info(
        '  - Jumlah Sub-Kategori: ${widget.kategori!.idSubKategori.length}',
      );
      Log.info('  - Diperbarui: ${widget.kategori!.diperbaruiPada}');
      Log.info('  - isDeleted: ${widget.kategori!.diHapus}');
      Log.info('  - Diarsipkan: ${widget.kategori!.diarsipkanPada ?? "NULL"}');

      Log.info(
        'Mengisi TextEditingController dengan nama kategori: "${widget.kategori!.nama}"',
      );
      _namaController.text = widget.kategori!.nama;
      _tipe = widget.kategori!.tipe;
      Log.info('Tipe kategori diatur ke: ${widget.kategori!.tipe}');

      Log.info('Memuat sub-kategori yang sudah ada untuk diedit.');
      for (final sub in widget.kategori!.idSubKategori) {
        _subKategoriControllers.add(TextEditingController(text: sub.nama));
        _subKategoriModels.add(sub);
      }
      Log.info('${_subKategoriControllers.length} sub-kategori dimuat.');
    } else if (widget.subKategori != null) {
      Log.info('MODE EDIT SUB-KATEGORI terdeteksi.');
      Log.info('Data sub-kategori yang akan diedit:');
      Log.info('  - ID: ${widget.subKategori!.id}');
      Log.info('  - Nama: ${widget.subKategori!.nama}');
      Log.info('  - ID Kategori Induk: ${widget.subKategori!.idKategori}');
      Log.info('  - Diperbarui: ${widget.subKategori!.diperbaruiPada}');

      Log.info(
        'Mengisi TextEditingController dengan nama sub-kategori: "${widget.subKategori!.nama}"',
      );
      _namaController.text = widget.subKategori!.nama;
      // FIX: Inisialisasi _tipe untuk menghindari LateInitializationError.
      // Nilai ini tidak digunakan saat menyimpan sub-kategori, jadi aman diatur ke default.
      _tipe = TipeKategori.income;
      Log.info(
        'Tipe kategori diatur ke default: $_tipe (tidak relevan untuk edit sub-kategori).',
      );
    } else {
      Log.info('MODE TAMBAH BARU terdeteksi.');
      Log.info('Form akan membuat kategori baru dengan:');
      Log.info('  - ID: Akan digenerate otomatis menggunakan UUID v4');
      Log.info('  - Tipe Default: income');
      Log.info('  - Nama: Dari input pengguna');
      Log.info('  - Sub-Kategori: Opsional, bisa ditambahkan multiple');
      Log.info('  - Diperbarui: Akan diatur oleh lapisan Operasi Data');

      Log.info('Mengatur tipe default ke income.');
      _tipe = TipeKategori.income;
      Log.info('Tipe kategori diatur ke: $_tipe');

      Log.info('Menambahkan field input sub-kategori pertama secara default.');
      _tambahInputSubKategori();
    }

    Log.info(
      'Inisialisasi CategoryForm selesai. Siap menerima input dari pengguna.',
    );
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman CategoryForm');
    Log.info('Membersihkan resource:');
    Log.info('  - Mendispose TextEditingController utama (_namaController)');
    Log.info('  - Mendispose FocusNode (_namaFocusNode)');
    Log.info(
      '  - Mendispose ${_subKategoriControllers.length} TextEditingController sub-kategori',
    );
    Log.info('========================================');

    _namaController.dispose();
    _namaFocusNode.dispose();

    for (var i = 0; i < _subKategoriControllers.length; i++) {
      Log.info('  Mendispose sub-kategori controller ke-${i + 1}');
      _subKategoriControllers[i].dispose();
    }

    Log.info('Semua resource berhasil dibersihkan.');
    super.dispose();
  }

  void _tambahInputSubKategori() {
    Log.info('========================================');
    Log.info('AKSI: Menambahkan field input sub-kategori baru');
    Log.info(
      'Jumlah field sub-kategori sebelum ditambah: ${_subKategoriControllers.length}',
    );
    Log.info('========================================');

    setState(() {
      _subKategoriControllers.add(TextEditingController());
      _subKategoriModels.add(null);
    });

    Log.info('Field sub-kategori baru berhasil ditambahkan.');
    Log.info(
      'Jumlah field sub-kategori sekarang: ${_subKategoriControllers.length}',
    );
    Log.info('Index field baru: ${_subKategoriControllers.length - 1}');
  }

  void _hapusInputSubKategori(final int index) {
    Log.info('========================================');
    Log.info('AKSI: Menghapus field input sub-kategori');
    Log.info('Index yang akan dihapus: $index');
    Log.info(
      'Jumlah field sub-kategori sebelum dihapus: ${_subKategoriControllers.length}',
    );

    if (index >= 0 && index < _subKategoriControllers.length) {
      Log.info(
        'Nilai field sebelum dihapus: "${_subKategoriControllers[index].text}"',
      );
    } else {
      Log.warning(
        'Index $index tidak valid. Jumlah field: ${_subKategoriControllers.length}',
      );
    }
    Log.info('========================================');

    setState(() {
      Log.info('Mendispose controller pada index $index.');
      _subKategoriControllers[index].dispose();
      Log.info('Menghapus controller dari list.');
      _subKategoriControllers.removeAt(index);
      _subKategoriModels.removeAt(index);
    });

    Log.info('Field sub-kategori berhasil dihapus.');
    Log.info(
      'Jumlah field sub-kategori sekarang: ${_subKategoriControllers.length}',
    );
  }

  Future<void> _saveForm() async {
    final kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    Log.info('Mode: ${_modeEdit ? "EDIT" : "TAMBAH BARU"}');
    Log.info('Jenis: ${_modeSubKategori ? "SUB-KATEGORI" : "KATEGORI UTAMA"}');
    Log.info('Nama yang akan disimpan: "${_namaController.text}"');
    if (!_modeSubKategori || !_modeEdit) {
      Log.info('Tipe kategori: $_tipe');
    }

    Log.info('Memvalidasi form...');
    if (_formKey.currentState!.validate()) {
      Log.info('Validasi form BERHASIL. Semua input valid.');

      try {
        if (_modeEdit && widget.subKategori != null) {
          final parentCategoryId = widget.subKategori!.idKategori;

          Log.info('Data sub-kategori sebelum update:');
          Log.info('  - ID: ${widget.subKategori!.id}');
          Log.info('  - Nama Lama: ${widget.subKategori!.nama}');
          Log.info('  - Nama Baru: ${_namaController.text}');
          Log.info('  - ID Kategori Induk: $parentCategoryId');

          Log.info(
            'Mengambil data kategori induk dengan ID: $parentCategoryId',
          );
          final kategoriInduk =
              await kategoriOpSqlite.ambilKategoriBerdasarkanId(
                    parentCategoryId,
                  )
                  as KategoriModel?;

          if (kategoriInduk == null) {
            throw Exception('Kategori induk tidak ditemukan.');
          }

          Log.info(
            'Kategori induk ditemukan: ${kategoriInduk.nama} (memiliki ${kategoriInduk.idSubKategori.length} sub-kategori).',
          );
          Log.info(
            'Mencari index sub-kategori dengan ID: ${widget.subKategori!.id} dalam daftar sub-kategori.',
          );

          final subKategoriIndex = kategoriInduk.idSubKategori.indexWhere(
            (final s) => s.id == widget.subKategori!.id,
          );

          if (subKategoriIndex != -1) {
            Log.info('Sub-kategori ditemukan pada index: $subKategoriIndex');
            Log.info(
              'Nama sub-kategori sebelum update: "${kategoriInduk.idSubKategori[subKategoriIndex].nama}"',
            );

            Log.info('Membuat salinan sub-kategori dengan nama baru.');
            final subKategoriDiperbarui = kategoriInduk
                .idSubKategori[subKategoriIndex]
                .copyWith(nama: _namaController.text);

            Log.info(
              'Mengganti sub-kategori pada index $subKategoriIndex dengan data baru.',
            );
            kategoriInduk.idSubKategori[subKategoriIndex] =
                subKategoriDiperbarui;

            Log.info(
              'Memanggil _kategoriOperasi.updateCategory() untuk menyimpan perubahan kategori induk.',
            );
            await kategoriOpSqlite.updateKategori(kategoriInduk);

            Log.info('Update sub-kategori BERHASIL.');
            Log.info(
              'Nama sub-kategori berubah dari "${widget.subKategori!.nama}" menjadi "${_namaController.text}"',
            );
          } else {
            Log.error(
              'Sub-kategori dengan ID ${widget.subKategori!.id} tidak ditemukan dalam daftar sub-kategori kategori induk.',
            );
            throw Exception('Sub-kategori tidak ditemukan untuk diedit.');
          }
        } else if (_modeEdit && widget.kategori != null) {
          Log.info('========================================');
          Log.info('PROSES UPDATE KATEGORI UTAMA (MODE EDIT KATEGORI)');
          Log.info('========================================');

          Log.info('Memproses daftar sub-kategori untuk update...');
          final newSubCategoryList = <SubKategoriModel>[];
          for (var i = 0; i < _subKategoriControllers.length; i++) {
            final controller = _subKategoriControllers[i];
            final originalModel = _subKategoriModels[i];

            if (controller.text.isNotEmpty) {
              if (originalModel != null) {
                // Ini adalah sub-kategori yang sudah ada yang mungkin telah diedit
                newSubCategoryList.add(
                  originalModel.copyWith(nama: controller.text),
                );
              } else {
                // Ini adalah sub-kategori baru
                newSubCategoryList.add(
                  SubKategoriModel(
                    id: const Uuid().v4(),
                    nama: controller.text,
                    idKategori: widget.kategori!.id,
                  ),
                );
              }
            }
          }

          final kategoriDiperbarui = widget.kategori!.copyWith(
            nama: _namaController.text,
            tipe: _tipe,
            idSubKategori: newSubCategoryList,
          );

          Log.info(
            'Memanggil _kategoriOperasi.updateCategory() untuk menyimpan perubahan.',
          );
          await kategoriOpSqlite.updateKategori(kategoriDiperbarui);

          Log.info('Update kategori utama BERHASIL.');
        } else {
          final kategoriId = const Uuid().v4();
          Log.info('UUID berhasil digenerate: $kategoriId');

          Log.info(
            'Memproses ${_subKategoriControllers.length} field input sub-kategori.',
          );

          var subKategoriKosong = 0;
          var subKategoriTerisi = 0;

          final subKategoriList = _subKategoriControllers
              .where((final controller) {
                final isEmpty = controller.text.isEmpty;
                if (isEmpty) {
                  subKategoriKosong++;
                  Log.info(
                    '  Sub-kategori dengan nilai "${controller.text}" akan DIABAIKAN karena kosong.',
                  );
                } else {
                  subKategoriTerisi++;
                  Log.info(
                    '  Sub-kategori dengan nilai "${controller.text}" akan DISIMPAN.',
                  );
                }
                return !isEmpty;
              })
              .map((final controller) {
                return SubKategoriModel(
                  id: const Uuid().v4(),
                  nama: controller.text,
                  idKategori: kategoriId,
                );
              })
              .toList();

          Log.info(
            'Ringkasan sub-kategori: $subKategoriTerisi akan disimpan, $subKategoriKosong diabaikan.',
          );

          Log.info('Membuat objek CategoryModel baru.');
          final kategoriBaru = KategoriModel(
            id: kategoriId,
            nama: _namaController.text,
            tipe: _tipe,
            idSubKategori: subKategoriList,
          );

          Log.info('Objek CategoryModel berhasil dibuat:');
          Log.info('  - ID: ${kategoriBaru.id}');
          Log.info('  - Nama: ${kategoriBaru.nama}');
          Log.info('  - Tipe: ${kategoriBaru.tipe}');
          Log.info(
            '  - Jumlah Sub-Kategori: ${kategoriBaru.idSubKategori.length}',
          );
          Log.info('  - Diperbarui: Akan diatur oleh lapisan Operasi Data.');

          Log.info(
            'Memanggil _kategoriOperasi.createCategory() untuk menyimpan kategori baru.',
          );
          await kategoriOpSqlite.tambahKategori(kategoriBaru);
        }

        if (!mounted) {
          Log.warning(
            'Widget sudah tidak mounted setelah penyimpanan berhasil. Tidak dapat menampilkan SnackBar atau melakukan Navigator.pop.',
          );
          return;
        }

        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (mounted) {
          ToastUtil.success(
            context,
            'Kategori berhasil disimpan dan disinkronkan.',
          );
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menyimpan ${_modeSubKategori ? 'sub-kategori' : 'kategori'}. Proses ${_modeEdit ? 'update' : 'create'} mengalami kegagalan. Kemungkinan penyebab: koneksi database gagal, constraint violation, data tidak valid, atau terjadi error saat operasi database.',
          e: e,
          s: s,
        );

        if (!mounted) {
          Log.warning(
            'Widget sudah tidak mounted setelah error. Tidak dapat menampilkan SnackBar error.',
          );
          return;
        }

        Log.info(
          'Widget masih mounted. Menampilkan SnackBar error ke pengguna.',
        );
        if (mounted) {
          ToastUtil.error(context, 'Gagal menyimpan: $e');
        }
        Log.info('SnackBar error telah ditampilkan.');
      }
    } else {
      Log.warning('Validasi form GAGAL. Terdapat input yang tidak valid.');
      Log.warning(
        'Kemungkinan penyebab: Nama kategori/sub-kategori kosong atau tidak memenuhi kriteria validasi.',
      );
      Log.info('Form tidak akan disimpan sampai semua input valid.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    var judul = 'Form Kategori';
    if (_modeEdit && widget.kategori != null) judul = 'Edit Kategori';
    if (_modeEdit && widget.subKategori != null) judul = 'Edit Sub-Kategori';
    if (!_modeEdit && widget.idKategoriInduk != null) {
      judul = 'Tambah Sub-Kategori';
    }
    if (!_modeEdit && widget.kategori == null && widget.subKategori == null) {
      judul = 'Tambah Kategori Baru';
    }

    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI CategoryForm');
    Log.info('Judul halaman: "$judul"');
    Log.info('Mode: ${_modeEdit ? "EDIT" : "TAMBAH BARU"}');
    Log.info('Jenis: ${_modeSubKategori ? "SUB-KATEGORI" : "KATEGORI UTAMA"}');
    Log.info('Nama di controller: "${_namaController.text}"');
    // Log.info('Tipe terpilih: $_tipe');
    Log.info('Jumlah field sub-kategori: ${_subKategoriControllers.length}');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(judul),
        leading: BackButton(
          onPressed: () {
            Log.info(
              'NAVIGASI: Tombol Kembali ditekan. Kembali ke halaman sebelumnya dengan result false (tidak ada perubahan).',
            );
            Navigator.pop(context, false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.p16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  decoration: InputDecoration(
                    labelText: _modeSubKategori
                        ? 'Nama Sub-Kategori'
                        : 'Nama Kategori',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    Log.info(
                      'INPUT: Field nama disubmit melalui keyboard (TextInputAction.done).',
                    );
                    Log.info('Nilai yang disubmit: "${_namaController.text}"');
                    Log.info('Menghilangkan fokus dari input.');
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: (final value) {
                    Log.info(
                      'INPUT: Nama ${_modeSubKategori ? "sub-kategori" : "kategori"} berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (final value) {
                    Log.info(
                      'VALIDASI: Memvalidasi input nama. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Nama kosong.');
                      return 'Nama tidak boleh kosong';
                    }
                    Log.info('VALIDASI BERHASIL: Nama valid.');
                    return null;
                  },
                ),
                gapH16,
                if (!_modeSubKategori) ...[
                  DropdownButtonFormField<TipeKategori>(
                    initialValue: _tipe,
                    decoration: const InputDecoration(
                      labelText: 'Tipe',
                      border: OutlineInputBorder(),
                    ),
                    items: TipeKategori.values
                        .where(
                          (final type) =>
                              type == TipeKategori.income ||
                              type == TipeKategori.expense,
                        )
                        .map((kategori) {
                          Log.info(
                            'Membuat DropdownMenuItem untuk: ${kategori.displayName}',
                          );

                          return DropdownMenuItem<TipeKategori>(
                            value: kategori,
                            child: Text(kategori.displayName),
                          );
                        })
                        .toList(),
                    onChanged: (final newValue) {
                      if (newValue != null) {
                        Log.info('DROPDOWN: Tipe kategori diubah.');
                        Log.info('  - Tipe Lama: $_tipe');
                        Log.info('  - Tipe Baru: $newValue');
                        setState(() {
                          _tipe = newValue;
                        });
                        Log.info('State _tipe berhasil diperbarui ke: $_tipe');
                      }
                    },
                  ),
                  gapH24,
                ],
                if (!_modeSubKategori) ...[
                  const Text(
                    'Sub-Kategori',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subKategoriControllers.length,
                    itemBuilder: (final context, final index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: TSizes.p8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _subKategoriControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Nama Sub-Kategori ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (final value) {
                                  Log.info(
                                    'INPUT: Sub-kategori ke-${index + 1} berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                TIcons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Log.info(
                                  'AKSI: Tombol hapus sub-kategori ke-${index + 1} ditekan.',
                                );
                                _hapusInputSubKategori(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  gapH8,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Log.info(
                          'AKSI: Tombol "Tambah Input" sub-kategori ditekan.',
                        );
                        _tambahInputSubKategori();
                      },
                      icon: const Icon(TIcons.add),
                      label: const Text('Tambah Input'),
                    ),
                  ),
                ],
                gapH20,
                ElevatedButton(
                  onPressed: () async {
                    Log.info('AKSI: Tombol Simpan ditekan oleh pengguna.');
                    await _saveForm();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Simpan'),
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

### File: `lib/fitur/kategori/page/kategori.dart`
```dart
// path: lib/fitur/kategori/page/kategori.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/kategori/operasi/sub_kategori_op_sqlite.dart';
import 'package:wifi/fitur/kategori/page/form_kategori.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class KategoriPage extends ConsumerStatefulWidget {
  const KategoriPage({super.key});

  @override
  ConsumerState<KategoriPage> createState() => _KategoriPageState();
}

/// State untuk [KategoriPage].
class _KategoriPageState extends ConsumerState<KategoriPage> {
  late final KategoriOpSqlite _kategoriOpSqlite;
  late final SubKategoriOpSqlite _subKategoriOpSqlite;
  late Future<List<KategoriModel>> _categoryListFuture;
  TipeKategori _selectedType = TipeKategori.income;
  bool _isEdit = false;
  bool _isArchiveMode = false;

  @override
  void initState() {
    super.initState();
    _kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    _subKategoriOpSqlite = ref.read(subKategoriOpSqliteProvider);
    Log.info('Menginisialisasi halaman Kategori');
    _loadData();
  }

  Future<List<KategoriModel>> _loadCategoriesAndHandleErrors() async {
    try {
      return await _kategoriOpSqlite.ambilSemua();
    } on Exception catch (e, st) {
      Log.error('Gagal memuat data kategori', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data kategori: $e');
      }
      rethrow;
    }
  }

  void _loadData() {
    Log.info('Memuat data kategori dari database');
    setState(() {
      _categoryListFuture = _loadCategoriesAndHandleErrors();
    });
  }

  Future<void> _navigasiKeForm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (final context) => const CategoryForm()),
    );
    if (result ?? false) {
      if (!mounted) return;
      Log.info('Kategori baru berhasil ditambahkan, memuat ulang daftar.');
      ToastUtil.success(context, 'Kategori berhasil ditambahkan.');
      _loadData();
    }
  }

  Future<void> _navigasiKeEditKategori(final KategoriModel category) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => CategoryForm(kategori: category),
      ),
    );
    if (result ?? false) {
      if (!mounted) return;
      _loadData();
    }
  }

  Future<void> _navigateToEditSubCategory(
    final SubKategoriModel subCategory,
    final String categoryId,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) =>
            CategoryForm(subKategori: subCategory, idKategoriInduk: categoryId),
      ),
    );
    if (result ?? false) {
      if (!mounted) return;
      _loadData();
    }
  }

  Future<bool> _showConfirmDialog(
    final String title,
    final String content,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
    return confirm ?? false;
  }

  Future<void> _softDeleteCategory(final KategoriModel category) async {
    final confirm = await _showConfirmDialog(
      'Arsipkan Kategori',
      'Anda yakin ingin mengarsipkan "${category.nama}"? Ini juga akan mengarsipkan semua sub-kategorinya.',
    );
    if (!mounted || !confirm) return;

    try {
      await _kategoriOpSqlite.softDeleteKategori(category.id);
      if (!mounted) return;
      ToastUtil.success(
        context,
        'Kategori "${category.nama}" berhasil diarsipkan.',
      );
      _loadData();
    } on Exception catch (e, st) {
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan kategori: $e');
      Log.error('Gagal soft delete kategori ID: ${category.id}', e: e, s: st);
    }
  }

  Future<void> _softDeleteSubCategory(
    final SubKategoriModel subCategory,
  ) async {
    final confirm = await _showConfirmDialog(
      'Arsipkan Sub-Kategori',
      'Anda yakin ingin mengarsipkan sub-kategori "${subCategory.nama}"?',
    );
    if (!mounted || !confirm) return;

    try {
      await _subKategoriOpSqlite.softDelete(subCategory.id);
      if (!mounted) return;
      ToastUtil.success(
        context,
        'Sub-kategori "${subCategory.nama}" berhasil diarsipkan.',
      );
      _loadData();
    } on Exception catch (e, st) {
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan sub-kategori: $e');
      Log.error(
        'Gagal soft delete sub-kategori ID: ${subCategory.id}',
        e: e,
        s: st,
      );
    }
  }

  Future<void> _softDeleteAll() async {
    final confirm = await _showConfirmDialog(
      'Arsipkan Semua Kategori',
      'Anda yakin ingin mengarsipkan SEMUA kategori? Tindakan ini akan mengarsipkan semua kategori dan sub-kategorinya.',
    );
    if (!mounted || !confirm) return;

    try {
      final total = await _kategoriOpSqlite.softDeleteAllKategori();
      if (!mounted) return;
      ToastUtil.success(context, 'Berhasil mengarsipkan $total kategori.');
      _loadData();
    } on Exception catch (e, st) {
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan semua kategori: $e');
      Log.error('Gagal melakukan soft delete semua kategori', e: e, s: st);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          if (_isArchiveMode)
            IconButton(
              tooltip: 'Arsipkan Semua',
              onPressed: _softDeleteAll,
              icon: const Icon(TIcons.packages),
            ),
          IconButton(
            tooltip: _isArchiveMode ? 'Selesai' : 'Arsipkan',
            onPressed: () => setState(() {
              _isArchiveMode = !_isArchiveMode;
              if (_isArchiveMode) _isEdit = false;
            }),
            icon: Icon(_isArchiveMode ? TIcons.check : TIcons.archive),
          ),
          IconButton(
            tooltip: _isEdit ? 'Selesai' : 'Edit',
            onPressed: () => setState(() {
              _isEdit = !_isEdit;
              if (_isEdit) _isArchiveMode = false;
            }),
            icon: Icon(_isEdit ? TIcons.check : TIcons.edit),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () =>
                    setState(() => _selectedType = TipeKategori.income),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == TipeKategori.income
                      ? Colors.green
                      : Colors.grey,
                ),
                child: const Text('Pemasukan'),
              ),
              ElevatedButton(
                onPressed: () =>
                    setState(() => _selectedType = TipeKategori.expense),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == TipeKategori.expense
                      ? context.colorScheme.error
                      : Colors.grey,
                ),
                child: const Text('Pengeluaran'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<KategoriModel>>(
              future: _categoryListFuture,
              builder: (final _, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada kategori ditemukan.'),
                  );
                }

                final filteredKategori = snapshot.data!
                    .where(
                      (final k) =>
                          k.tipe == _selectedType && k.diarsipkanPada == null,
                    )
                    .toList();

                return ListView.builder(
                  itemCount: filteredKategori.length,
                  itemBuilder: (final _, final index) {
                    final kategori = filteredKategori[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text(kategori.nama),
                        trailing: _isEdit
                            ? IconButton(
                                icon: const Icon(TIcons.edit),
                                onPressed: () =>
                                    _navigasiKeEditKategori(kategori),
                              )
                            : _isArchiveMode
                            ? IconButton(
                                icon: const Icon(TIcons.archive),
                                onPressed: () => _softDeleteCategory(kategori),
                              )
                            : null,
                        children: kategori.idSubKategori
                            .where((final sub) => sub.diarsipkanPada == null)
                            .map((final sub) {
                              return ListTile(
                                title: Text(sub.nama),
                                trailing: _isEdit
                                    ? IconButton(
                                        icon: const Icon(TIcons.edit),
                                        onPressed: () =>
                                            _navigateToEditSubCategory(
                                              sub,
                                              kategori.id,
                                            ),
                                      )
                                    : _isArchiveMode
                                    ? IconButton(
                                        icon: const Icon(TIcons.archive),
                                        onPressed: () =>
                                            _softDeleteSubCategory(sub),
                                      )
                                    : null,
                              );
                            })
                            .toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigasiKeForm,
        child: const Icon(TIcons.add),
      ),
    );
  }
}
```

