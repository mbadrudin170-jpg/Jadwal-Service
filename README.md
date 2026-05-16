
# Dokumentasi Operasi



## wallet_operation.dart

```dart
// path: lib/shared/operasi/wallet_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Menambahkan konstruktor yang dapat diinjeksi untuk pengujian.
// diubah: Mengganti nama class dari DompetOperasi menjadi WalletOperation.
// diubah: Menggunakan BaseOperation (bukan OperasiDasar) dan WalletModel (bukan DompetModel).

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data dompet di database lokal.
class WalletOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  late final DatabaseHelper dbHelper;
  late final BaseOperation _baseOperation;

  /// Konstruktor dengan injeksi dependensi untuk pengujian.
  WalletOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('WalletOperation instance dibuat.');
  }

  /// Menyimpan [WalletModel] baru ke dalam database.
  ///
  /// [fromServer] menandakan apakah operasi ini berasal dari sinkronisasi server.
  Future<void> createWallet(
    final WalletModel wallet, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai createWallet untuk wallet: ${wallet.toSqlite()}');
    try {
      final data =
          wallet.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.insert('dompet', data, fromServer: fromServer);
      Log.info('Berhasil membuat wallet dengan ID: ${wallet.id}');
    } catch (e, st) {
      Log.error('Gagal saat createWallet', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua dompet dari database.
  ///
  /// Jika [showArchived] `true`, maka dompet yang telah diarsipkan juga akan diambil.
  Future<List<WalletModel>> getWallets({
    final bool showArchived = false,
  }) async {
    Log.info('Memulai getWallets (showArchived: $showArchived).');
    try {
      final db = await dbHelper.database;
      final query = showArchived
          ? '${ColumnNames.isDeleted} = 0'
          : '${ColumnNames.isDeleted} = 0 AND ${ColumnNames.archivedAt} IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: query,
      );

      final listWallet = List.generate(
        maps.length,
        (final i) => WalletModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listWallet.length} data wallet.');
      return listWallet;
    } catch (e, st) {
      Log.error('Gagal saat getWallets', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [WalletModel] berdasarkan [id].
  Future<WalletModel?> getWalletById(final String id) async {
    Log.info('Memulai getWalletById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: '${ColumnNames.id} = ? AND ${ColumnNames.isDeleted} = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final wallet = WalletModel.fromSqlite(maps.first);
        Log.info('Wallet dengan ID: $id ditemukan.');
        return wallet;
      }

      Log.warning('Wallet dengan ID: $id tidak ditemukan di database.');
      return null;
    } catch (e, st) {
      Log.error(
        'Gagal saat getWalletById untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [WalletModel] yang ada di database.
  Future<void> updateWallet(
    final WalletModel wallet, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai updateWallet untuk wallet ID: ${wallet.id}');
    try {
      final data =
          wallet.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.update(
        'dompet',
        data,
        wallet.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil updateWallet untuk ID: ${wallet.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat updateWallet untuk ID: ${wallet.id}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan semua dompet yang aktif.
  Future<void> archiveAllWallets({final bool fromServer = false}) async {
    Log.info('Memulai proses pengarsipan untuk semua wallet.');
    try {
      final activeWallets = await getWallets();
      Log.info(
          'Ditemukan ${activeWallets.length} wallet aktif untuk diarsipkan.');

      for (final wallet in activeWallets) {
        await updateWallet(
          wallet.copyWith(archivedAt: DateTime.now().toUtc()),
          fromServer: fromServer,
        );
      }

      Log.info('Proses pengarsipan semua wallet telah selesai.');
    } catch (e, st) {
      Log.error(
        'Gagal saat proses pengarsipan massal wallet.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus semua dompet dari database secara permanen.
  Future<void> deleteAllWallets({final bool fromServer = false}) async {
    Log.warning(
        'PERINGATAN: Memulai deleteAllWallets. Ini adalah operasi destruktif.');
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final count = await txn.delete('dompet');
          Log.info(
              'Berhasil deleteAllWallets. Total baris yang dihapus: $count');
        },
        fromServer: fromServer,
      );
    } catch (e, st) {
      Log.error('Gagal saat deleteAllWallets', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan satu dompet berdasarkan [id] (soft delete).
  Future<void> archiveOneWallet(final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai archiveOneWallet (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now().toUtc();
      final Map<String, dynamic> dataToUpdate = {
        ColumnNames.archivedAt: now.millisecondsSinceEpoch,
        ColumnNames.updatedAt: now.millisecondsSinceEpoch,
        ColumnNames.isDeleted: 1,
      };

      await _baseOperation.update(
        'dompet',
        dataToUpdate,
        id,
        fromServer: fromServer,
      );

      Log.info('Berhasil archiveOneWallet untuk ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat archiveOneWallet untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghitung total saldo dari semua dompet aktif.
  Future<double> getTotalBalance() async {
    Log.info(
        'Memulai getTotalBalance (menghitung total saldo dari semua wallet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(${ColumnNames.balance}) as total FROM dompet WHERE ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getTotalBalance', e: e, st: st);
      rethrow;
    }
  }

  /// Menghitung total saldo positif dari semua dompet aktif.
  Future<double> getPositiveBalance() async {
    Log.info(
        'Memulai getPositiveBalance (menghitung total saldo > 0 dari wallet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(${ColumnNames.balance}) as total FROM dompet WHERE ${ColumnNames.balance} > 0 AND ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo positif: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getPositiveBalance', e: e, st: st);
      rethrow;
    }
  }

  /// Menghitung total saldo negatif dari semua dompet aktif.
  Future<double> getNegativeBalance() async {
    Log.info(
        'Memulai getNegativeBalance (menghitung total saldo < 0 dari wallet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(${ColumnNames.balance}) as total FROM dompet WHERE ${ColumnNames.balance} < 0 AND ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo negatif: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getNegativeBalance', e: e, st: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan dompet dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<WalletModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai insertOrUpdateBatch untuk ${items.length} item wallet.');
    if (items.isEmpty) {
      Log.warning(
          'List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final data = items.map((final item) => item.toSqlite()).toList();
      await _baseOperation.insertOrUpdateBatch(
        'dompet',
        data,
        fromServer: fromServer,
      );
      Log.info(
          'Berhasil menyelesaikan insertOrUpdateBatch untuk ${items.length} item.');
    } catch (e, st) {
      Log.error('Gagal saat menjalankan insertOrUpdateBatch', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [WalletModel] berdasarkan daftar [ids].
  Future<List<WalletModel>> getWalletsByIds(final List<String> ids) async {
    Log.info('Memulai getWalletsByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
          'List ID untuk getWalletsByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );

      final listWallet = List.generate(
        maps.length,
        (final i) => WalletModel.fromSqlite(maps[i]),
      );
      Log.info(
          'Berhasil mengambil ${listWallet.length} wallet dari ${ids.length} ID yang diminta.');
      return listWallet;
    } catch (e, st) {
      Log.error('Gagal saat getWalletsByIds', e: e, st: st);
      rethrow;
    }
  }
}
```

## category_operation.dart

```dart
// path: lib/shared/operasi/category_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari KategoriOperasi menjadi CategoryOperation.
// diubah: Menggunakan BaseOperation dan CategoryModel.

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data kategori di database lokal.
class CategoryOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final DatabaseHelper dbHelper;

  /// Instance dari BaseOperation untuk operasi database umum.
  final BaseOperation _baseOperation;

  /// Konstruktor untuk CategoryOperation.
  CategoryOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('CategoryOperation instance dibuat.');
  }

  /// Membuat [CategoryModel] baru di database.
  Future<CategoryModel> createCategory(
    final CategoryModel category, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai createCategory untuk category: ${category.toSqlite()}');
    try {
      final newCategory = category.copyWith(updatedAt: DateTime.now().toUtc());
      final data = newCategory.toSqlite();

      await _baseOperation.insert('kategori', data, fromServer: fromServer);
      Log.info('Berhasil membuat category baru dengan ID: ${newCategory.id}');
      return newCategory;
    } catch (e, st) {
      Log.error('Gagal saat createCategory', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua kategori yang tidak diarsipkan.
  Future<List<CategoryModel>> getCategories() async {
    Log.info(
        'Memulai getCategories (mengambil semua kategori yang tidak diarsipkan).');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.archivedAt} IS NULL',
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => CategoryModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listCategory.length} data category.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getCategories', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [CategoryModel] berdasarkan [id].
  Future<CategoryModel> getCategoryById(final String id) async {
    Log.info('Memulai getCategoryById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final category = CategoryModel.fromSqlite(maps.first);
        Log.info('Category dengan ID: $id ditemukan.');
        return category;
      } else {
        Log.error('Category dengan ID $id tidak ditemukan di database.');
        throw Exception('Category dengan ID $id tidak ditemukan.');
      }
    } catch (e, st) {
      Log.error(
        'Gagal saat getCategoryById untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil semua kategori berdasarkan [CategoryType].
  Future<List<CategoryModel>> getCategoriesByType(
      final CategoryType type) async {
    Log.info('Memulai getCategoriesByType untuk tipe: ${type.name}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.type} = ? AND ${ColumnNames.archivedAt} IS NULL',
        whereArgs: [type.name],
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => CategoryModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${listCategory.length} data category untuk tipe ${type.name}.',
      );
      return listCategory;
    } catch (e, st) {
      Log.error(
        'Gagal saat getCategoriesByType untuk tipe: ${type.name}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [CategoryModel] yang ada di database.
  Future<void> updateCategory(
    final CategoryModel category, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai updateCategory untuk category ID: ${category.id}');
    try {
      final data =
          category.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.update(
        'kategori',
        data,
        category.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil updateCategory untuk ID: ${category.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat updateCategory untuk ID: ${category.id}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus [CategoryModel] dari database secara permanen.
  Future<void> deleteCategory(final String id,
      {final bool fromServer = false}) async {
    Log.warning(
        'PERINGATAN: Memulai deleteCategory (hard delete) untuk category ID: $id');
    try {
      await _baseOperation.delete('kategori', id, fromServer: fromServer);
      Log.info('Berhasil deleteCategory untuk ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat deleteCategory untuk ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan satu kategori berdasarkan [id] (soft delete).
  Future<void> archiveOneCategory(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai archiveOneCategory (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now().toUtc();
      final Map<String, dynamic> dataToUpdate = {
        ColumnNames.archivedAt: now.millisecondsSinceEpoch,
        ColumnNames.updatedAt: now.millisecondsSinceEpoch,
        ColumnNames.isDeleted: 1,
      };

      await _baseOperation.update(
        'kategori',
        dataToUpdate,
        id,
        fromServer: fromServer,
      );

      Log.info('Berhasil archiveOneCategory untuk ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat archiveOneCategory untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus semua kategori yang ada dan menyisipkan yang baru.
  Future<void> clearAndInsertAll(
    final List<CategoryModel> items, {
    final bool fromServer = false,
  }) async {
    Log.warning(
      'PERINGATAN: Memulai clearAndInsertAll. Ini akan menghapus semua category dan menggantinya dengan ${items.length} item baru.',
    );
    if (items.isEmpty) {
      Log.warning(
          'List item untuk clearAndInsertAll kosong, hanya operasi pembersihan yang akan dilakukan.');
    }
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          await txn.delete('kategori');
          Log.info('Tabel kategori berhasil dibersihkan.');
          for (final item in items) {
            await txn.insert(
              'kategori',
              item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
            );
          }
          Log.info(
              'Berhasil menyisipkan ${items.length} item baru ke tabel kategori.');
        },
        fromServer: fromServer,
      );
    } catch (e, st) {
      Log.error('Gagal saat menjalankan clearAndInsertAll', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua kategori yang telah diubah sejak [since].
  Future<List<CategoryModel>> getChangesSince(final DateTime since) async {
    Log.info(
        'Memulai getChangesSince untuk category sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => CategoryModel.fromSqlite(maps[i]),
      );
      Log.info(
          'Berhasil menemukan ${listCategory.length} perubahan category sejak ${since.toIso8601String()}.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getChangesSince category', e: e, st: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [CategoryModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<CategoryModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info(
        'Memulai insertOrUpdateBatch untuk ${items.length} item category.');
    if (items.isEmpty) {
      Log.warning(
          'List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final data = items
          .map(
            (final item) =>
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await _baseOperation.insertOrUpdateBatch(
        'kategori',
        data,
        fromServer: fromServer,
      );
      Log.info(
          'Berhasil menyelesaikan insertOrUpdateBatch untuk ${items.length} item category.');
    } catch (e, st) {
      Log.error('Gagal saat menjalankan insertOrUpdateBatch category',
          e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [CategoryModel] berdasarkan daftar [ids].
  Future<List<CategoryModel>> getCategoriesByIds(final List<String> ids) async {
    Log.info('Memulai getCategoriesByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
          'List ID untuk getCategoriesByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => CategoryModel.fromSqlite(maps[i]),
      );
      Log.info(
          'Berhasil mengambil ${listCategory.length} category dari ${ids.length} ID yang diminta.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getCategoriesByIds', e: e, st: st);
      rethrow;
    }
  }
}
```

## package_operation.dart

```dart
// path: lib/shared/operasi/package_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari PaketOperasi menjadi PackageOperation.
// diubah: Menggunakan BaseOperation dan PackageModel.

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data paket di database lokal.
class PackageOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  // (private field, tidak perlu @visibleForTesting)
  final BaseOperation _baseOperation;

  /// Konstruktor untuk [PackageOperation].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [baseOperation]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  PackageOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('PackageOperation instance dibuat.');
  }

  /// Menyimpan [PackageModel] baru ke dalam database.
  Future<void> createPackage(final PackageModel package,
      {final bool fromServer = false}) async {
    Log.info('Memulai createPackage untuk id: ${package.id}');
    try {
      final data =
          package.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.insert('paket', data, fromServer: fromServer);
      Log.info('Berhasil createPackage untuk id: ${package.id}');
    } catch (e, s) {
      Log.error('Gagal createPackage untuk id: ${package.id}', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket, termasuk yang diarsipkan.
  Future<List<PackageModel>> getAllPackages() async {
    Log.info('Memulai proses pengambilan semua data paket');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket aktif (tidak diarsipkan).
  Future<List<PackageModel>> getPackages() async {
    Log.info('Memulai proses pengambilan semua data paket aktif');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        WHERE ${ColumnNames.isDeleted} = 0
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket aktif');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket aktif', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang bersifat publik.
  Future<List<PackageModel>> getPublicPackages() async {
    Log.info('Memulai proses pengambilan semua data paket publik');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        WHERE ${ColumnNames.isDeleted} = 0 AND ${ColumnNames.isPublic} = 1
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket publik');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket publik', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil [PackageModel] berdasarkan [id].
  Future<PackageModel?> getPackageById(final String id) async {
    Log.info('Memulai pencarian paket berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Paket ditemukan untuk ID: $id');
        return PackageModel.fromSqlite(maps.first);
      } else {
        Log.warning('Paket dengan ID $id tidak ditemukan');
        return null;
      }
    } catch (e, s) {
      Log.error('Gagal mencari paket berdasarkan ID: $id', e: e, st: s);
      rethrow;
    }
  }

  /// Memperbarui [PackageModel] yang ada di database.
  Future<void> updatePackage(final PackageModel package,
      {final bool fromServer = false}) async {
    Log.info('Memulai updatePackage untuk id: ${package.id}');
    try {
      final data =
          package.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.update(
        'paket',
        data,
        package.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil updatePackage untuk id: ${package.id}');
    } catch (e, s) {
      Log.error('Gagal updatePackage untuk id: ${package.id}', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus [PackageModel] dari database secara permanen.
  Future<void> deletePackage(final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai deletePackage untuk id: $id');
    try {
      await _baseOperation.delete('paket', id, fromServer: fromServer);
      Log.info('Berhasil deletePackage untuk id: $id');
    } catch (e, s) {
      Log.error('Gagal deletePackage untuk id: $id', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus semua paket dari database secara permanen.
  Future<void> deleteAllPackages({final bool fromServer = false}) async {
    Log.info('Memulai proses penghapusan semua data paket');
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final int count = await txn.delete('paket');
          Log.info(
              'Berhasil menghapus semua data paket. Total terhapus: $count');
        },
        fromServer: fromServer,
      );
    } catch (e, s) {
      Log.error('Gagal menghapus semua data paket', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang telah diubah sejak [since].
  Future<List<PackageModel>> getChangesSince(final DateTime since) async {
    Log.info(
        'Memulai pengambilan perubahan paket sejak ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: '${ColumnNames.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      Log.info('Ditemukan ${maps.length} perubahan paket');
      return List.generate(
          maps.length, (final i) => PackageModel.fromSqlite(maps[i]));
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan paket', e: e, st: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [PackageModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<PackageModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai insertOrUpdateBatch untuk ${items.length} item paket');
    if (items.isEmpty) {
      Log.warning('List item batch kosong, operasi dibatalkan');
      return;
    }
    try {
      final dataList = items
          .map(
            (final item) =>
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await _baseOperation.insertOrUpdateBatch(
        'paket',
        dataList,
        fromServer: fromServer,
      );
      Log.info('Berhasil insertOrUpdateBatch untuk ${items.length} item');
    } catch (e, s) {
      Log.error('Gagal insertOrUpdateBatch', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [PackageModel] berdasarkan daftar [ids].
  Future<List<PackageModel>> getPackagesByIds(final List<String> ids) async {
    Log.info('Memulai pengambilan paket berdasarkan list ID: $ids');
    try {
      if (ids.isEmpty) {
        Log.warning('List ID kosong, mengembalikan list kosong');
        return [];
      }
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} paket dari ${ids.length} ID');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil paket berdasarkan list ID', e: e, st: s);
      rethrow;
    }
  }
}
```

## active_customer_operation.dart

```dart
// path: lib/shared/operasi/active_customer_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari PelangganAktifOperasi menjadi ActiveCustomerOperation.
// diubah: Menggunakan BaseOperation dan ActiveCustomerModel.

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Konstanta untuk generate UUID.
const uuid = Uuid();

/// Kelas untuk operasi terkait data pelanggan aktif di database lokal.
class ActiveCustomerOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final BaseOperation _baseOperation = BaseOperation();

  /// Instance dari NotifikasiServis untuk menjadwalkan notifikasi.
  late final NotifikasiServis notifikasiServis;
  final CustomerOperation _customerOperation = CustomerOperation();

  /// Konstruktor untuk `ActiveCustomerOperation`.
  ActiveCustomerOperation({final NotifikasiServis? notifikasiServis}) {
    this.notifikasiServis = notifikasiServis ?? NotifikasiServis();
    Log.info('ActiveCustomerOperation diinisialisasi');
  }

  /// Membuat [ActiveCustomerModel] baru di database.
  Future<ActiveCustomerModel> createActiveCustomer(
    final ActiveCustomerModel activeCustomer, {
    final bool fromServer = false,
  }) async {
    try {
      final newId = activeCustomer.id.isEmpty ? uuid.v4() : activeCustomer.id;
      final customerToSave = activeCustomer.copyWith(
        id: newId,
        updatedAt: DateTime.now().toUtc(),
      );

      Log.info('Membuat active customer baru - ID: $newId');

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final data = customerToSave.toSqlite();
          await txn.insert(
            'pelanggan_aktif',
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        },
        fromServer: fromServer,
      );

      await _scheduleNotification(customerToSave);
      Log.info('Active customer ID: $newId berhasil dibuat');
      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal membuat active customer', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan aktif (tidak diarsipkan).
  Future<List<ActiveCustomerModel>> getAllActiveCustomers() async {
    try {
      final db = await dbHelper.database;
      Log.info('Mengambil semua active customer dari database lokal');

      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: '${ColumnNames.isDeleted} = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} active customer');
      return List.generate(
        maps.length,
        (final i) => ActiveCustomerModel.fromSqlite(maps[i]),
      );
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil semua active customer', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [ActiveCustomerModel] berdasarkan [id].
  Future<ActiveCustomerModel?> getActiveCustomerById(final String id) async {
    try {
      final db = await dbHelper.database;
      Log.info('Mencari active customer dengan ID: $id');

      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final activeCustomer = ActiveCustomerModel.fromSqlite(maps.first);
        Log.info('Active customer ID: $id ditemukan');
        return activeCustomer;
      }

      Log.info('Active customer ID: $id tidak ditemukan');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil active customer ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Memperbarui [ActiveCustomerModel] yang ada di database.
  Future<ActiveCustomerModel> updateActiveCustomer(
    final ActiveCustomerModel activeCustomer, {
    final bool fromServer = false,
  }) async {
    try {
      final customerToSave = activeCustomer.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );

      Log.info('Memperbarui active customer ID: ${customerToSave.id}');

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final data = customerToSave.toSqlite();
          await txn.update(
            'pelanggan_aktif',
            data,
            where: '${ColumnNames.id} = ?',
            whereArgs: [customerToSave.id],
          );
        },
        fromServer: fromServer,
      );

      await _scheduleNotification(customerToSave);
      Log.info('Active customer ID: ${customerToSave.id} berhasil diperbarui');
      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal memperbarui active customer ID: ${activeCustomer.id}',
          e: e, st: st);
      rethrow;
    }
  }

  /// Menjadwalkan notifikasi untuk [ActiveCustomerModel].
  Future<void> _scheduleNotification(
      final ActiveCustomerModel activeCustomer) async {
    try {
      Log.info(
          'Menjadwalkan notifikasi untuk active customer ID: ${activeCustomer.id}');

      final customer =
          await _customerOperation.getCustomerById(activeCustomer.customerId);
      final customerName = customer?.name ?? 'Tanpa Nama';

      // Batalkan notifikasi lama
      await notifikasiServis.batalNotifikasi(activeCustomer.id.hashCode);
      await notifikasiServis.batalNotifikasi((activeCustomer.id.hashCode + 1));
      await notifikasiServis.batalNotifikasi((activeCustomer.id.hashCode + 2));

      // 1. NOTIFIKASI TEPAT SAAT BERAKHIR
      final exactTime = activeCustomer.endDate;
      if (exactTime.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id: (activeCustomer.id.hashCode + 2),
          title: 'Masa Aktif Habis!',
          body: 'Paket WiFi untuk $customerName telah berakhir sekarang.',
          jadwal: exactTime,
        );
      }

      // 2. NOTIFIKASI H-1
      final h1Schedule =
          activeCustomer.endDate.subtract(const Duration(days: 1));
      if (h1Schedule.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id: activeCustomer.id.hashCode,
          title: 'Paket Akan Segera Berakhir',
          body: 'Paket untuk pelanggan $customerName akan berakhir besok.',
          jadwal: h1Schedule,
        );
      }

      // 3. NOTIFIKASI H-3
      final h3Schedule =
          activeCustomer.endDate.subtract(const Duration(days: 3));
      if (h3Schedule.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id: (activeCustomer.id.hashCode + 1),
          title: 'Pengingat Paket',
          body:
              'Paket untuk pelanggan $customerName akan berakhir dalam 3 hari.',
          jadwal: h3Schedule,
        );
      }

      Log.info('Penjadwalan notifikasi selesai');
    } on Exception catch (e, st) {
      Log.error('Gagal menjadwalkan notifikasi', e: e, st: st);
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [ActiveCustomerModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<ActiveCustomerModel> items, {
    final bool fromServer = false,
  }) async {
    try {
      Log.info('Memproses batch ${items.length} active customer');

      final data = items
          .map(
            (final item) =>
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();

      await _baseOperation.insertOrUpdateBatch(
        'pelanggan_aktif',
        data,
        fromServer: fromServer,
      );

      Log.info('Batch ${items.length} active customer berhasil diproses');
    } on Exception catch (e, st) {
      Log.error('Gagal memproses batch ${items.length} active customer',
          e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan [ActiveCustomerModel] berdasarkan [id].
  Future<void> archiveActiveCustomer(
    final String id, {
    final bool fromServer = false,
  }) async {
    try {
      Log.info('Mengarsipkan active customer ID: $id');

      final activeCustomer = await getActiveCustomerById(id);
      if (activeCustomer == null) {
        Log.info('Active customer ID: $id tidak ditemukan');
        return;
      }

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final archivedCustomer = activeCustomer.copyWith(
            isDeleted: true,
            archivedAt: DateTime.now().toUtc(),
          );

          await txn.update(
            'pelanggan_aktif',
            archivedCustomer.toSqlite(),
            where: '${ColumnNames.id} = ?',
            whereArgs: [id],
          );

          await notifikasiServis.batalNotifikasi(id.hashCode);
          await notifikasiServis.batalNotifikasi((id.hashCode + 1));
          await notifikasiServis.batalNotifikasi((id.hashCode + 2));
        },
        fromServer: fromServer,
      );

      Log.info('Active customer ID: $id berhasil diarsipkan');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan active customer ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Menghapus permanen pelanggan yang sudah diarsipkan lebih dari 30 hari.
  Future<void> permanentlyDeleteArchivedCustomers({
    final bool fromServer = false,
  }) async {
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final deadline =
              DateTime.now().toUtc().subtract(const Duration(days: 30));

          final List<Map<String, dynamic>> expiredCustomers = await txn.query(
            'pelanggan_aktif',
            where:
                '${ColumnNames.archivedAt} IS NOT NULL AND ${ColumnNames.archivedAt} < ?',
            whereArgs: [deadline.millisecondsSinceEpoch],
          );

          if (expiredCustomers.isEmpty) {
            Log.info('Tidak ada active customer diarsipkan lebih dari 30 hari');
            return;
          }

          final idsToDelete = expiredCustomers
              .map((final map) => map[ColumnNames.id] as String)
              .toList();

          final count = await txn.delete(
            'pelanggan_aktif',
            where:
                '${ColumnNames.id} IN (${List.filled(idsToDelete.length, '?').join(',')})',
            whereArgs: idsToDelete,
          );

          Log.info('$count active customer telah dihapus permanen');
        },
        fromServer: fromServer,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal menghapus permanen active customer diarsipkan',
          e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan pelanggan yang sudah kadaluarsa.
  Future<int> archiveExpiredCustomers({final bool fromServer = false}) async {
    try {
      Log.info('Memeriksa active customer kadaluarsa');
      final db = await dbHelper.database;
      final now = DateTime.now().toUtc();

      final List<Map<String, dynamic>> expiredCustomers = await db.query(
        'pelanggan_aktif',
        where: '${ColumnNames.endDate} < ? AND ${ColumnNames.isDeleted} = 0',
        whereArgs: [now.millisecondsSinceEpoch],
      );

      if (expiredCustomers.isEmpty) {
        Log.info('Tidak ada active customer kadaluarsa');
        return 0;
      }

      final idsToArchive = expiredCustomers
          .map((final p) => p[ColumnNames.id] as String)
          .toList();

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

          await txn.update(
            'pelanggan_aktif',
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.archivedAt: nowMs,
              ColumnNames.updatedAt: nowMs,
            },
            where:
                '${ColumnNames.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
            whereArgs: idsToArchive,
          );

          for (final id in idsToArchive) {
            await notifikasiServis.batalNotifikasi(id.hashCode);
            await notifikasiServis.batalNotifikasi((id.hashCode + 1));
            await notifikasiServis.batalNotifikasi((id.hashCode + 2));
          }
        },
        fromServer: fromServer,
      );

      Log.info(
          '${idsToArchive.length} active customer kadaluarsa telah diarsipkan');
      return idsToArchive.length;
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan active customer kadaluarsa', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan semua pelanggan aktif.
  Future<int> archiveAllActiveCustomers({final bool fromServer = false}) async {
    try {
      Log.info('Mengarsipkan SEMUA active customer');
      final allCustomers = await getAllActiveCustomers();

      if (allCustomers.isEmpty) {
        Log.info('Tidak ada active customer untuk diarsipkan');
        return 0;
      }

      final idsToArchive = allCustomers.map((final p) => p.id).toList();

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

          await txn.update(
            'pelanggan_aktif',
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.archivedAt: nowMs,
              ColumnNames.updatedAt: nowMs,
            },
            where:
                '${ColumnNames.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
            whereArgs: idsToArchive,
          );

          for (final id in idsToArchive) {
            await notifikasiServis.batalNotifikasi(id.hashCode);
            await notifikasiServis.batalNotifikasi((id.hashCode + 1));
            await notifikasiServis.batalNotifikasi((id.hashCode + 2));
          }
        },
        fromServer: fromServer,
      );

      Log.info('${idsToArchive.length} active customer telah diarsipkan');
      return idsToArchive.length;
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan semua active customer', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [ActiveCustomerModel] berdasarkan daftar [ids].
  Future<List<ActiveCustomerModel>> getActiveCustomersByIds(
    final List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        Log.info('getActiveCustomersByIds dipanggil dengan list ID kosong');
        return [];
      }

      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );

      Log.info('Ditemukan ${maps.length} dari ${ids.length} active customer');
      return List.generate(maps.length, (final i) {
        return ActiveCustomerModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil active customer berdasarkan IDs',
          e: e, st: st);
      rethrow;
    }
  }
}
```
