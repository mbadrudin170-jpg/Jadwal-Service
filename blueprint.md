# bluprint.md
1. AI harus memberi tahukan saya jika ada file yang tadi kita kerjakan belum di edit atau tambahkan ke file blueprint.md ini.
2. ini isi dari sluruh projek saya, jadi pastikan semua file terkait harus di cek agar tidak ada error 

# File Penting


1. Jika AI menemukan isi file di bawah ini tidak sama dengan file aslinya harap beritahukan ke saya agar saya merubah isi file-file di bawah ini .





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


# Dokumentasi Model

Berikut adalah dokumentasi untuk setiap model data dalam aplikasi.

## active_customer_model.dart

```dart
// path: lib/shared/model/active_customer_model.dart
// new file: Refactored from pelanggan_aktif_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for active customer data.
class ActiveCustomerModel implements HasId {
  @override
  final String id;

  /// The ID of the customer associated with this entry.
  final String customerId;

  /// The ID of the package purchased by the customer.
  final String packageId;

  /// The ID of the transaction associated with the package purchase.
  final String? transactionId;

  /// The start date of the package activation.
  final DateTime startDate;

  /// The end date of the package.
  final DateTime endDate;

  /// The payment status of the package.
  final PaymentStatus status;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this entry has been deleted (soft delete).
  final bool isDeleted;

  /// The time this entry was archived.
  final DateTime? archivedAt;

  /// Constructor for `ActiveCustomerModel`.
  ActiveCustomerModel({
    final String? id,
    required this.customerId,
    required this.packageId,
    this.transactionId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('ActiveCustomerModel created: $id for customer $customerId');
  }

  /// Creates a copy of this `ActiveCustomerModel` with some modified values.
  ActiveCustomerModel copyWith({
    final String? id,
    final String? customerId,
    final String? packageId,
    final String? transactionId,
    final DateTime? startDate,
    final DateTime? endDate,
    final PaymentStatus? status,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return ActiveCustomerModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      transactionId: transactionId ?? this.transactionId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    Log.warning('Unrecognized DateTime format: $value');
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    Log.warning('Unrecognized Boolean format, defaulting to false: $value');
    return false;
  }

  /// Creates an `ActiveCustomerModel` instance from SQLite map data.
  factory ActiveCustomerModel.fromSqlite(final Map<String, dynamic> map) {
    try {
      final startDate = _parseDateTime(map[ColumnNames.startDate]);
      final endDate = _parseDateTime(map[ColumnNames.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from SQLite');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from SQLite');
      }

      final model = ActiveCustomerModel(
        id: map[ColumnNames.id] as String,
        customerId: map[ColumnNames.customerId] as String? ?? '',
        packageId: map[ColumnNames.packageId] as String? ?? '',
        transactionId: map[ColumnNames.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (final e) => e.name == map[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
        isDeleted: _parseBool(map[ColumnNames.isDeleted]),
        archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      );
      Log.info('ActiveCustomerModel loaded from SQLite: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from SQLite: $map', e: e, st: stack);
      rethrow;
    }
  }

  /// Converts `ActiveCustomerModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: startDate.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate.millisecondsSinceEpoch,
      ColumnNames.status: status.name,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `ActiveCustomerModel` instance from Firebase map data.
  factory ActiveCustomerModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    try {
      final startDate = _parseDateTime(data[ColumnNames.startDate]);
      final endDate = _parseDateTime(data[ColumnNames.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from Firebase');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from Firebase');
      }

      final model = ActiveCustomerModel(
        id: id,
        customerId: data[ColumnNames.customerId] as String? ?? '',
        packageId: data[ColumnNames.packageId] as String? ?? '',
        transactionId: data[ColumnNames.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (final e) => e.name == data[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
        isDeleted: _parseBool(data[ColumnNames.isDeleted]),
        archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
      );
      Log.info('ActiveCustomerModel loaded from Firebase: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from Firebase: $data', e: e, st: stack);
      rethrow;
    }
  }

  /// Converts `ActiveCustomerModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    Log.info('Preparing toFirebase for ActiveCustomerModel $id');
    return {
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: Timestamp.fromDate(startDate.toUtc()),
      ColumnNames.endDate: Timestamp.fromDate(endDate.toUtc()),
      ColumnNames.status: status.name,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
```

## apk_version_model.dart

```dart
// path: lib/shared/model/apk_version_model.dart
// new file: Refactored from user_apk_version_model.dart to use English naming and proper structure.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model representing application version information for the user.
class ApkVersionModel implements HasId {
  @override
  final String id;

  /// Release notes or changelog for this version.
  final String releaseNotes;

  /// A map containing the latest build number for each APK architecture.
  final Map<ApkArchitectureEnum, int> latestBuildNumber;

  /// A map containing the download link for each APK architecture.
  final Map<ApkArchitectureEnum, String> downloadLinks;

  /// The user-facing version number, e.g., "1.0.2".
  final String latestVersion;

  /// Indicates whether updating to this version is mandatory.
  final bool isUpdateRequired;

  /// Link to a relevant YouTube tutorial for this version.
  final String youtubeTutorial;

  /// Soft delete flag.
  final bool isDeleted;

  /// Timestamp when this version was archived.
  final DateTime? archivedAt;

  /// Timestamp when this version was last updated.
  final DateTime? updatedAt;

  /// Constructor for creating an instance of `ApkVersionModel`.
  ApkVersionModel({
    final String? id,
    this.releaseNotes = '',
    this.latestBuildNumber = const {},
    this.downloadLinks = const {},
    this.latestVersion = '',
    this.isUpdateRequired = false,
    this.youtubeTutorial = '',
    this.isDeleted = false,
    this.archivedAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  /// Creates a copy of this model with updated values.
  ApkVersionModel copyWith({
    final String? id,
    final String? releaseNotes,
    final Map<ApkArchitectureEnum, int>? latestBuildNumber,
    final Map<ApkArchitectureEnum, String>? downloadLinks,
    final String? latestVersion,
    final bool? isUpdateRequired,
    final String? youtubeTutorial,
    final bool? isDeleted,
    final DateTime? archivedAt,
    final DateTime? updatedAt,
  }) {
    return ApkVersionModel(
      id: id ?? this.id,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      latestBuildNumber: latestBuildNumber ?? this.latestBuildNumber,
      downloadLinks: downloadLinks ?? this.downloadLinks,
      latestVersion: latestVersion ?? this.latestVersion,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      youtubeTutorial: youtubeTutorial ?? this.youtubeTutorial,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================
  // HELPERS
  // =========================

  /// Helper to parse `DateTime` from various formats.
  static DateTime? _parseDateTime(final dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return null;
  }

  /// Helper to convert a String to an `ApkArchitectureEnum` enum.
  static ApkArchitectureEnum? _architectureFromString(final String? value) {
    if (value == null) return null;
    for (final val in ApkArchitectureEnum.values) {
      if (val.name == value) {
        return val;
      }
    }
    return null;
  }

  /// Helper to parse build number data from a Map or JSON String.
  static Map<ApkArchitectureEnum, int> _parseBuildNumber(final dynamic data) {
    final result = <ApkArchitectureEnum, int>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) mapData = decoded;
      } on FormatException catch (e, st) {
        Log.error('Failed to parse build number JSON', e: e, st: st);
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final architecture = _architectureFromString(item.key.toString());
        if (architecture != null) {
          result[architecture] =
              item.value is num ? (item.value as num).toInt() : 0;
        }
      }
    }

    return result;
  }

  /// Helper to parse download link data from a Map or JSON String.
  static Map<ApkArchitectureEnum, String> _parseDownloadLinks(
      final dynamic data) {
    final result = <ApkArchitectureEnum, String>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) mapData = decoded;
      } on FormatException catch (e, st) {
        Log.error('Failed to parse download links JSON', e: e, st: st);
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final architecture = _architectureFromString(item.key.toString());
        if (architecture != null) {
          result[architecture] = item.value?.toString() ?? '';
        }
      }
    }

    return result;
  }

  // =========================
  // SQLITE
  // =========================

  /// Factory to create `ApkVersionModel` from SQLite data.
  factory ApkVersionModel.fromSqlite(final Map<String, dynamic> map) {
    return ApkVersionModel(
      id: map[ColumnNames.id] as String? ?? '',
      releaseNotes: map[ColumnNames.releaseNotes] as String? ?? '',
      latestVersion: map[ColumnNames.latestVersion] as String? ?? '',
      youtubeTutorial: map[ColumnNames.youtubeTutorial] as String? ?? '',
      isUpdateRequired: (map[ColumnNames.isUpdateRequired] as int? ?? 0) == 1,
      isDeleted: (map[ColumnNames.isDeleted] as int? ?? 0) == 1,
      latestBuildNumber:
          _parseBuildNumber(map[ColumnNames.latestBuildNumber]),
      downloadLinks: _parseDownloadLinks(map[ColumnNames.downloadLinks]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts the model to a Map for SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.releaseNotes: releaseNotes,
      ColumnNames.latestVersion: latestVersion,
      ColumnNames.youtubeTutorial: youtubeTutorial,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.latestBuildNumber: jsonEncode(
        latestBuildNumber.map((final key, final value) => MapEntry(key.name, value)),
      ),
      ColumnNames.downloadLinks: jsonEncode(
        downloadLinks.map((final key, final value) => MapEntry(key.name, value)),
      ),
      ColumnNames.isUpdateRequired: isUpdateRequired ? 1 : 0,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  /// Factory to create `ApkVersionModel` from Firebase data.
  factory ApkVersionModel.fromFirebase(
      final String id, final Map<String, dynamic> map) {
    return ApkVersionModel(
      id: id,
      releaseNotes: map[ColumnNames.releaseNotes] as String? ?? '',
      latestVersion: map[ColumnNames.latestVersion] as String? ?? '',
      youtubeTutorial: map[ColumnNames.youtubeTutorial] as String? ?? '',
      isUpdateRequired: map[ColumnNames.isUpdateRequired] as bool? ?? false,
      isDeleted: map[ColumnNames.isDeleted] as bool? ?? false,
      latestBuildNumber:
          _parseBuildNumber(map[ColumnNames.latestBuildNumber]),
      downloadLinks: _parseDownloadLinks(map[ColumnNames.downloadLinks]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts the model to a Map for Firestore.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.releaseNotes: releaseNotes,
      ColumnNames.latestVersion: latestVersion,
      ColumnNames.youtubeTutorial: youtubeTutorial,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      if (archivedAt != null)
        ColumnNames.archivedAt: Timestamp.fromDate(archivedAt!),
      ColumnNames.latestBuildNumber: latestBuildNumber.map(
        (final key, final value) => MapEntry(key.name, value),
      ),
      ColumnNames.downloadLinks: downloadLinks.map(
        (final key, final value) => MapEntry(key.name, value),
      ),
      ColumnNames.isUpdateRequired: isUpdateRequired,
      ColumnNames.isDeleted: isDeleted,
    };
  }
}
```

## category_model.dart

```dart
// path: lib/shared/model/category_model.dart
// diperbarui: Memindahkan enum ke file sendiri dan memperbaiki typo.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/model/sub_category_model.dart';

/// Model that represents a transaction category.
class CategoryModel implements HasId {
  @override
  final String id;

  /// The name of the category.
  final String name;

  /// The type of the category (e.g., expense, income).
  final CategoryType type;

  /// A list of sub-categories under this category.
  final List<SubCategoryModel> subCategories;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this category has been deleted (soft delete).
  final bool isDeleted;

  /// The time this category was archived.
  final DateTime? archivedAt;

  /// Main constructor for [CategoryModel].
  CategoryModel({
    final String? id,
    required this.name,
    required this.type,
    this.subCategories = const [],
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CategoryModel created: $id, name: $name');
  }

  /// Creates a copy of [CategoryModel] with some updated fields.
  CategoryModel copyWith({
    final String? id,
    final String? name,
    final CategoryType? type,
    final List<SubCategoryModel>? subCategories,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subCategories: subCategories ?? this.subCategories,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse date values from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Safe helper to parse an enum from a string.
  static T? _safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null || name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    Log.warning('Failed to parse enum for type $T', name);
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor to create [CategoryModel] from SQLite data.
  factory CategoryModel.fromSqlite(final Map<String, dynamic> map) {
    List<SubCategoryModel> parseSubCategories(final dynamic data) {
      if (data == null) return [];
      try {
        if (data is String && data.isNotEmpty) {
          final list = jsonDecode(data) as List<dynamic>;
          return list
              .map((final item) {
                if (item is Map<String, dynamic>) {
                  return SubCategoryModel.fromSqlite(item);
                }
                return null;
              })
              .whereType<SubCategoryModel>()
              .toList();
        }
        return [];
      } on FormatException catch (e, st) {
        Log.error('Failed to parse subcategories from JSON', e: e, st: st);
        return [];
      }
    }

    return CategoryModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      type: _safeParseEnum(CategoryType.values, map[ColumnNames.type]) ??
          CategoryType.expense,
      subCategories: parseSubCategories(map[ColumnNames.subCategoryId]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts [CategoryModel] to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    final data = {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.type: type.name,
      ColumnNames.subCategoryId: jsonEncode(
        subCategories.map((final sub) => sub.toSqlite()).toList(),
      ),
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
    return data;
  }

  /// Factory constructor to create [CategoryModel] from Firebase data.
  factory CategoryModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    List<SubCategoryModel> parseSubCategories(final dynamic subCategoryData) {
      if (subCategoryData is List) {
        return subCategoryData
            .map((final item) {
              if (item is Map<String, dynamic>) {
                final String subId =
                    item[ColumnNames.id] as String? ?? const Uuid().v4();
                return SubCategoryModel.fromFirebase(subId, item);
              }
              return null;
            })
            .whereType<SubCategoryModel>()
            .toList();
      }
      return [];
    }

    return CategoryModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      type: _safeParseEnum(CategoryType.values, data[ColumnNames.type]) ??
          CategoryType.expense,
      subCategories: parseSubCategories(data[ColumnNames.subCategoryId]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts [CategoryModel] to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    final data = {
      ColumnNames.name: name,
      ColumnNames.type: type.name,
      ColumnNames.subCategoryId:
          subCategories.map((final sub) => sub.toFirebase()).toList(),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
    return data;
  }
}
```

## customer_model.dart

```dart
// path: lib/shared/model/customer_model.dart
// new file: Refactored from pelanggan_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model representing a customer's data.
class CustomerModel implements HasId {
  @override
  final String id;

  /// The name of the customer.
  final String name;

  /// The phone number of the customer.
  final String phone;

  /// The address of the customer.
  final String address;

  /// The password for the customer's account.
  final String password;

  /// The MAC address of the customer's device.
  final String macAddress;

  /// A flag indicating if the customer has been soft-deleted.
  final bool isDeleted;

  /// The timestamp of the last update.
  final DateTime? updatedAt;

  /// The timestamp of when the customer was archived.
  final DateTime? archivedAt;

  /// Creates a new instance of the [CustomerModel].
  CustomerModel({
    final String? id,
    required this.name,
    required this.phone,
    required this.address,
    required this.password,
    this.macAddress = '',
    this.isDeleted = false,
    this.updatedAt,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CustomerModel created: $id, name: $name');
  }

  /// Creates a copy of the [CustomerModel] with updated fields.
  CustomerModel copyWith({
    final String? id,
    final String? name,
    final String? phone,
    final String? address,
    final String? password,
    final String? macAddress,
    final bool? isDeleted,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      macAddress: macAddress ?? this.macAddress,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Parses a dynamic value into a [DateTime] object.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    Log.warning('Unrecognized DateTime format: $value');
    return null;
  }

  /// Parses a dynamic value into a boolean.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    Log.warning('Unrecognized Boolean format, defaulting to false: $value');
    return false;
  }

  /// Creates a [CustomerModel] from a SQLite map.
  factory CustomerModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating CustomerModel from SQLite: ${map[ColumnNames.id]}');
    return CustomerModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      phone: map[ColumnNames.phone] as String? ?? '',
      address: map[ColumnNames.address] as String? ?? '',
      password: map[ColumnNames.password] as String? ?? '',
      macAddress: map[ColumnNames.macAddress] as String? ?? '',
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts the [CustomerModel] to a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.phone: phone,
      ColumnNames.address: address,
      ColumnNames.password: password,
      ColumnNames.macAddress: macAddress,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [CustomerModel] from a Firebase document.
  factory CustomerModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    Log.info('Creating CustomerModel from Firebase: $id');
    return CustomerModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      phone: data[ColumnNames.phone] as String? ?? '',
      address: data[ColumnNames.address] as String? ?? '',
      password: data[ColumnNames.password] as String? ?? '',
      macAddress: data[ColumnNames.macAddress] as String? ?? '',
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts the [CustomerModel] to a map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.name: name,
      ColumnNames.phone: phone,
      ColumnNames.address: address,
      ColumnNames.password: password,
      ColumnNames.macAddress: macAddress,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
```

## feedback_model.dart

```dart
// path: lib/shared/model/feedback_model.dart
// diperbarui: Mengganti nama variabel ke bahasa Inggris dan memperbaiki metode toFirebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for feedback data from users.
class FeedbackModel implements HasId {
  @override
  final String id;

  /// The content of the feedback.
  final String content;

  /// The date the feedback was created.
  final DateTime? date;

  /// The ID of the user who submitted the feedback.
  final String userId;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this feedback has been deleted (soft delete).
  final bool isDeleted;

  /// The time this feedback was archived.
  final DateTime? archivedAt;

  /// Constructor to create a [FeedbackModel] instance.
  FeedbackModel({
    final String? id,
    required this.content,
    this.date,
    required this.userId,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('FeedbackModel created: $id, userId: $userId');
  }

  /// Creates a copy of [FeedbackModel] with some updated fields.
  FeedbackModel copyWith({
    final String? id,
    final String? content,
    final DateTime? date,
    final String? userId,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Parses a date value from various data types.
  static DateTime? parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    Log.warning('Failed to parse date: $dateValue');
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Creates a [FeedbackModel] instance from SQLite data.
  factory FeedbackModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating FeedbackModel from SQLite: ${map[ColumnNames.id]}');
    return FeedbackModel(
      id: map[ColumnNames.id] as String?,
      content: map[ColumnNames.content] as String? ?? '',
      userId: map[ColumnNames.userId] as String? ?? '',
      date: parseDateTime(map[ColumnNames.date]),
      updatedAt: parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts [FeedbackModel] to a Map format for SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.content: content,
      ColumnNames.userId: userId,
      ColumnNames.date: date?.millisecondsSinceEpoch,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [FeedbackModel] instance from Firebase data.
  factory FeedbackModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating FeedbackModel from Firebase: $id');
    return FeedbackModel(
      id: id,
      content: data[ColumnNames.content] as String? ?? '',
      userId: data[ColumnNames.userId] as String? ?? '',
      date: parseDateTime(data[ColumnNames.date]),
      updatedAt: parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts [FeedbackModel] to a Map format for Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.content: content,
      ColumnNames.userId: userId,
      ColumnNames.date: date != null ? Timestamp.fromDate(date!.toUtc()) : null,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!.toUtc()) : null,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
```

## has_id.dart

```dart
// path: lib/shared/model/has_id.dart
// new file: Refactored from memiliki_id.dart to use English naming conventions.

/// An interface for models that have an ID property.
///
/// All models in the application that require a unique identity
/// should implement this interface.
///
/// Example:
/// ```dart
/// class UserModel implements HasId {
///   @override
///   final String id;
///
///   UserModel({required this.id});
/// }
/// ```
abstract class HasId {
  /// The unique ID for each model.
  ///
  /// Typically uses a UUID v4 or an ID from the database.
  String get id;
}
```

## order_model.dart

```dart
// path: lib/shared/model/order_model.dart
// new file: Renamed from pesanan_model.dart and refactored to English.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for order data.
class OrderModel implements HasId {
  @override
  final String id;

  /// The ID of the customer who placed the order.
  final String customerId;

  /// The ID of the package ordered.
  final String packageId;

  /// The date the order was created.
  final DateTime date;

  /// The status of the order (e.g., "new", "processing", "completed").
  final String status;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this order has been deleted (soft delete).
  final bool isDeleted;

  /// The time this order was archived.
  final DateTime? archivedAt;

  /// Constructor for `OrderModel`.
  OrderModel({
    final String? id,
    required this.customerId,
    required this.packageId,
    required this.date,
    required this.status,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('OrderModel created: $id for customer $customerId');
  }

  /// Creates a copy of `OrderModel` with some modified values.
  OrderModel copyWith({
    final String? id,
    final String? customerId,
    final String? packageId,
    final DateTime? date,
    final String? status,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      date: date ?? this.date,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse date values from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Creates an `OrderModel` instance from SQLite map data.
  factory OrderModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating OrderModel from SQLite: ${map[ColumnNames.id]}');
    return OrderModel(
      id: map[ColumnNames.id] as String? ?? '',
      customerId: map[ColumnNames.customerId] as String? ?? '',
      packageId: map[ColumnNames.packageId] as String? ?? '',
      date: _parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      status: map[ColumnNames.status] as String? ?? 'new',
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts `OrderModel` to a Map format for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.date: date.millisecondsSinceEpoch,
      ColumnNames.status: status,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `OrderModel` instance from Firebase map data.
  factory OrderModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating OrderModel from Firebase: $id');
    return OrderModel(
      id: id,
      customerId: data[ColumnNames.customerId] as String? ?? '',
      packageId: data[ColumnNames.packageId] as String? ?? '',
      date: _parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
      status: data[ColumnNames.status] as String? ?? 'new',
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts `OrderModel` to a Map format for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.date: Timestamp.fromDate(date.toUtc()),
      ColumnNames.status: status,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
```

## package_model.dart

```dart
// path: lib/shared/model/package_model.dart
// refactored: Complete rewrite to align with project conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for a package offered.
class PackageModel implements HasId {
  @override
  final String id;

  /// The name of the package.
  final String name;

  /// The price of the package.
  final int price;

  /// The duration of the package.
  final int duration;

  /// The type of duration for the package.
  final DurationType type;

  /// The number of points given as a reward for purchasing this package.
  final int rewardPoints;

  /// The number of points required to redeem this package.
  final int redemptionPoints;

  /// The status of whether this package is public or not.
  final bool isPublic;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this package has been deleted (soft delete).
  final bool isDeleted;

  /// The time this package was archived.
  final DateTime? archivedAt;

  /// Constructor for `PackageModel`.
  PackageModel({
    final String? id,
    required this.name,
    required this.price,
    required this.duration,
    required this.type,
    this.rewardPoints = 0,
    this.redemptionPoints = 0,
    this.isPublic = true,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('PackageModel created: $id, name: $name');
  }

  /// Creates a copy of this [PackageModel] with modified values.
  PackageModel copyWith({
    final String? id,
    final String? name,
    final int? price,
    final int? duration,
    final DurationType? type,
    final int? rewardPoints,
    final int? redemptionPoints,
    final bool? isPublic,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      redemptionPoints: redemptionPoints ?? this.redemptionPoints,
      isPublic: isPublic ?? this.isPublic,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final Object? value) {
    if (value == true || value == 1) return true;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Helper to parse DurationType from a string.
  static DurationType _parseType(final dynamic value) {
    return DurationType.values.firstWhere(
      (final e) => e.name == value,
      orElse: () => DurationType.days, // Default value
    );
  }

  /// Creates a `PackageModel` instance from SQLite map data.
  factory PackageModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating PackageModel from SQLite: ${map[ColumnNames.id]}');
    return PackageModel(
      id: map[ColumnNames.id] as String?,
      name: map[ColumnNames.name] as String? ?? '',
      price: map[ColumnNames.price] as int? ?? 0,
      duration: map[ColumnNames.duration] as int? ?? 0,
      type: _parseType(map[ColumnNames.type]),
      rewardPoints: map[ColumnNames.rewardPoints] as int? ?? 0,
      redemptionPoints: map[ColumnNames.redemptionPoints] as int? ?? 0,
      isPublic: _parseBool(map[ColumnNames.isPublic]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts `PackageModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.price: price,
      ColumnNames.duration: duration,
      ColumnNames.type: type.name,
      ColumnNames.rewardPoints: rewardPoints,
      ColumnNames.redemptionPoints: redemptionPoints,
      ColumnNames.isPublic: isPublic ? 1 : 0,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a `PackageModel` instance from Firebase map data.
  factory PackageModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating PackageModel from Firebase: $id');
    return PackageModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      price: data[ColumnNames.price] as int? ?? 0,
      duration: data[ColumnNames.duration] as int? ?? 0,
      type: _parseType(data[ColumnNames.type]),
      rewardPoints: data[ColumnNames.rewardPoints] as int? ?? 0,
      redemptionPoints: data[ColumnNames.redemptionPoints] as int? ?? 0,
      isPublic: _parseBool(data[ColumnNames.isPublic]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts `PackageModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.name: name,
      ColumnNames.price: price,
      ColumnNames.duration: duration,
      ColumnNames.type: type.name,
      ColumnNames.rewardPoints: rewardPoints,
      ColumnNames.redemptionPoints: redemptionPoints,
      ColumnNames.isPublic: isPublic,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
```

## save_result_model.dart

```dart
// path: lib/shared/model/save_result_model.dart
// new file: Refactored from hasil_simpan_model.dart to use English naming conventions.

import 'package:wifi/shared/debug/log.dart';

/// A generic model to represent the result of a save or update operation.
class SaveResultModel<T> {
  /// Indicates whether the operation was successful.
  final bool success;

  /// A message providing more detail about the operation's result.
  final String message;

  /// Optional data that may be returned upon a successful operation.
  final T? data;

  /// Constructor for `SaveResultModel`.
  SaveResultModel({
    required this.success,
    required this.message,
    this.data,
  }) {
    Log.info('SaveResultModel created: success=$success, message=$message');
  }
}
```

## settings_model.dart

```dart
// path: lib/shared/model/settings_model.dart
// new file: Refactored from pengaturan_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Global ID for the settings document.
const String globalSettingsId = 'global_config';

/// Model for application settings.
class SettingsModel implements HasId {
  @override
  final String id;

  /// The interval in hours for auto-sync.
  final int autoSyncInterval;

  /// The number of days after which archived data is auto-deleted.
  final int autoDeleteArchiveDays;

  /// A flag indicating if the application is in maintenance mode.
  final bool maintenanceMode;

  /// Information about the maintenance mode.
  final String maintenanceInfo;

  /// The timestamp of the last update.
  final DateTime? updatedAt;

  /// Constructor for `SettingsModel`.
  SettingsModel({
    this.id = globalSettingsId,
    this.autoSyncInterval = 24,
    this.autoDeleteArchiveDays = 30,
    this.maintenanceMode = false,
    this.maintenanceInfo = '',
    this.updatedAt,
  });

  /// Creates a copy of this `SettingsModel` with some modified values.
  SettingsModel copyWith({
    final String? id,
    final int? autoSyncInterval,
    final int? autoDeleteArchiveDays,
    final bool? maintenanceMode,
    final String? maintenanceInfo,
    final DateTime? updatedAt,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
      autoDeleteArchiveDays:
          autoDeleteArchiveDays ?? this.autoDeleteArchiveDays,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceInfo: maintenanceInfo ?? this.maintenanceInfo,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Creates a `SettingsModel` instance from SQLite map data.
  factory SettingsModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating SettingsModel from SQLite');
    return SettingsModel(
      autoSyncInterval: map[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays:
          map[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: (map[ColumnNames.maintenanceMode] as int? ?? 0) == 1,
      maintenanceInfo: map[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode ? 1 : 0,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a `SettingsModel` instance from Firebase map data.
  factory SettingsModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating SettingsModel from Firebase');
    return SettingsModel(
      id: data[ColumnNames.id] as String? ?? globalSettingsId,
      autoSyncInterval: data[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays: data[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: data[ColumnNames.maintenanceMode] as bool? ?? false,
      maintenanceInfo: data[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
    };
  }
}
```

## sub_category_model.dart

```dart
// path: lib/shared/model/sub_category_model.dart
// diperbarui: Mengganti impor dan menambahkan logging.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/category_model.dart' show CategoryModel;
import 'package:wifi/shared/model/has_id.dart';

/// Model yang merepresentasikan sebuah sub-kategori.
///
/// Setiap sub-kategori selalu berada di bawah sebuah [CategoryModel] induk.
class SubCategoryModel implements HasId {
  /// ID unik dari sub-kategori, biasanya dibuat menggunakan UUID.
  @override
  final String id;

  /// Nama dari sub-kategori.
  final String name;

  /// ID dari [CategoryModel] induk.
  final String categoryId;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? updatedAt;

  /// Penanda untuk soft-delete (penghapusan sementara).
  final bool isDeleted;

  /// Waktu saat data ini diarsipkan.
  final DateTime? archivedAt;

  /// Konstruktor utama untuk membuat instance [SubCategoryModel].
  SubCategoryModel({
    final String? id,
    required this.name,
    required this.categoryId,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('SubCategoryModel dibuat: $name ($id)');
  }

  /// Membuat salinan dari instance [SubCategoryModel] ini dengan beberapa nilai yang diubah.
  SubCategoryModel copyWith({
    final String? id,
    final String? name,
    final String? categoryId,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return SubCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Fungsi bantuan untuk mem-parsing nilai dinamis menjadi DateTime.
  static DateTime? parseDateTime(final dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return null;
  }

  /// Fungsi bantuan untuk mem-parsing nilai dinamis menjadi boolean secara aman.
  static bool parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [SubCategoryModel] dari data SQLite.
  factory SubCategoryModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Membuat SubCategoryModel dari SQLite: ${map[ColumnNames.id]}');
    return SubCategoryModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      categoryId: map[ColumnNames.categoryId] as String? ?? '',
      updatedAt: parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: parseBool(map[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi instance [SubCategoryModel] ini menjadi Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Mengonversi SubCategoryModel ke format SQLite: $id');
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.categoryId: categoryId,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor untuk membuat [SubCategoryModel] dari data Firebase.
  factory SubCategoryModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    Log.info('Membuat SubCategoryModel dari Firebase: $id');
    return SubCategoryModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      categoryId: data[ColumnNames.categoryId] as String? ?? '',
      updatedAt: parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: parseBool(data[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi instance [SubCategoryModel] ini menjadi Map untuk disimpan di Firebase.
  /// ID disertakan karena sub-kategori disimpan sebagai daftar di dalam dokumen kategori.
  Map<String, dynamic> toFirebase() {
    Log.info('Mengonversi SubCategoryModel ke format Firebase: $id');
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.categoryId: categoryId,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
```

## transaction_model.dart

```dart
// path: lib/shared/model/transaction_model.dart
// new file: Refactored from transaksi_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model that represents a single transaction in the application.
class TransactionModel implements HasId {
  @override
  final String id;

  /// The date and time when the transaction was created.
  final DateTime date;

  /// A description or note about the transaction.
  final String description;

  /// The amount of the transaction.
  final double amount;

  /// The type of transaction (e.g., income, expense, transfer, subscription).
  final TransactionType type;

  /// The ID of the source wallet.
  final String walletId;

  /// The ID of the main category of the transaction.
  final String categoryId;

  /// The ID of the destination wallet, only used for transfer transactions.
  final String? destinationWalletId;

  /// The ID of the customer associated with this transaction.
  final String? customerId;

  /// The ID of the package, if this is a subscription activation.
  final String? packageId;

  /// The ID of the sub-category of the transaction.
  final String? subCategoryId;

  /// The payment status of the transaction (e.g., paid, unpaid).
  final PaymentStatus paymentStatus;

  /// The number of points earned from this transaction.
  final int earnedPoints;

  /// The number of points used in this transaction.
  final int usedPoints;

  /// The last time this data was updated.
  final DateTime? updatedAt;

  /// The time this data was archived.
  final DateTime? archivedAt;

  /// A flag indicating if this data has been deleted (soft delete).
  final bool isDeleted;

  /// The duration of the subscription package (e.g., 30).
  final int? packageDuration;

  /// The type of duration for the package (e.g., day, month).
  final DurationType? durationType;

  /// The start date of the subscription period.
  final DateTime? startDate;

  /// The end date of the subscription period.
  final DateTime? endDate;

  /// A flag indicating if this is a new package activation.
  final bool isActivated;

  /// Main constructor for creating a [TransactionModel] instance.
  TransactionModel({
    final String? id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.walletId,
    required this.categoryId,
    this.destinationWalletId,
    this.customerId,
    this.packageId,
    this.subCategoryId,
    this.paymentStatus = PaymentStatus.unpaid,
    this.earnedPoints = 0,
    this.usedPoints = 0,
    this.updatedAt,
    this.archivedAt,
    this.isDeleted = false,
    this.packageDuration,
    this.durationType,
    this.startDate,
    this.endDate,
    this.isActivated = false,
  }) : id = id ?? const Uuid().v4() {
    Log.info('TransactionModel created: $id, type: ${type.name}');
  }

  /// Creates a copy of this [TransactionModel] with some modified values.
  TransactionModel copyWith({
    final String? id,
    final DateTime? date,
    final String? description,
    final double? amount,
    final TransactionType? type,
    final String? walletId,
    final String? categoryId,
    final String? destinationWalletId,
    final String? customerId,
    final String? packageId,
    final String? subCategoryId,
    final PaymentStatus? paymentStatus,
    final int? earnedPoints,
    final int? usedPoints,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
    final bool? isDeleted,
    final int? packageDuration,
    final DurationType? durationType,
    final DateTime? startDate,
    final DateTime? endDate,
    final bool? isActivated,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      destinationWalletId: destinationWalletId ?? this.destinationWalletId,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      usedPoints: usedPoints ?? this.usedPoints,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      packageDuration: packageDuration ?? this.packageDuration,
      durationType: durationType ?? this.durationType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  /// Safe helper to parse an enum from a string.
  static T? _safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null || name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    Log.warning('Failed to parse enum for type $T', name);
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor to create [TransactionModel] from SQLite data.
  factory TransactionModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating TransactionModel from SQLite: ${map[ColumnNames.id]}');
    return TransactionModel(
      id: map[ColumnNames.id] as String? ?? '',
      date: _parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      description: map[ColumnNames.description] as String? ?? '',
      amount: (map[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, map[ColumnNames.type]) ??
          TransactionType.expense,
      walletId: map[ColumnNames.walletId] as String? ?? '',
      categoryId: map[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: map[ColumnNames.destinationWalletId] as String?,
      customerId: map[ColumnNames.customerId] as String?,
      packageId: map[ColumnNames.packageId] as String?,
      subCategoryId: map[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            map[ColumnNames.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (map[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (map[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      packageDuration: (map[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, map[ColumnNames.durationType]),
      startDate: _parseDateTime(map[ColumnNames.startDate]),
      endDate: _parseDateTime(map[ColumnNames.endDate]),
      isActivated: _parseBool(map[ColumnNames.isActivated]),
    );
  }

  /// Converts this [TransactionModel] to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.date: date.millisecondsSinceEpoch, // INTEGER
      ColumnNames.description: description,
      ColumnNames.amount: amount,
      ColumnNames.type: type.name,
      ColumnNames.walletId: walletId,
      ColumnNames.categoryId: categoryId,
      ColumnNames.destinationWalletId: destinationWalletId,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.subCategoryId: subCategoryId,
      ColumnNames.paymentStatus: paymentStatus.name,
      ColumnNames.earnedPoints: earnedPoints,
      ColumnNames.usedPoints: usedPoints,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate: startDate?.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate?.millisecondsSinceEpoch,
      ColumnNames.isActivated: isActivated ? 1 : 0,
    };
  }

  /// Factory constructor to create [TransactionModel] from Firebase data.
  factory TransactionModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating TransactionModel from Firebase: $id');
    return TransactionModel(
      id: id,
      date: _parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
      description: data[ColumnNames.description] as String? ?? '',
      amount: (data[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, data[ColumnNames.type]) ??
          TransactionType.expense,
      walletId: data[ColumnNames.walletId] as String? ?? '',
      categoryId: data[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: data[ColumnNames.destinationWalletId] as String?,
      customerId: data[ColumnNames.customerId] as String?,
      packageId: data[ColumnNames.packageId] as String?,
      subCategoryId: data[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            data[ColumnNames.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (data[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (data[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
      isDeleted: data[ColumnNames.isDeleted] as bool? ?? false,
      packageDuration: (data[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, data[ColumnNames.durationType]),
      startDate: _parseDateTime(data[ColumnNames.startDate]),
      endDate: _parseDateTime(data[ColumnNames.endDate]),
      isActivated: data[ColumnNames.isActivated] as bool? ?? false,
    );
  }

  /// Converts this [TransactionModel] to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      // 'id' is not stored here as it is the document ID
      ColumnNames.date: Timestamp.fromDate(date),
      ColumnNames.description: description,
      ColumnNames.amount: amount,
      ColumnNames.type: type.name,
      ColumnNames.walletId: walletId,
      ColumnNames.categoryId: categoryId,
      ColumnNames.destinationWalletId: destinationWalletId,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.subCategoryId: subCategoryId,
      ColumnNames.paymentStatus: paymentStatus.name,
      ColumnNames.earnedPoints: earnedPoints,
      ColumnNames.usedPoints: usedPoints,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate:
          startDate != null ? Timestamp.fromDate(startDate!) : null,
      ColumnNames.endDate: endDate != null ? Timestamp.fromDate(endDate!) : null,
      ColumnNames.isActivated: isActivated,
    };
  }
}
```

## upload_status_model.dart

```dart
// path: lib/shared/model/upload_status_model.dart

import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';

/// Model ini merepresentasikan satu baris tunggal dalam tabel `upload_status`.
/// Tujuannya adalah untuk bertindak sebagai "bendera" global yang menandakan
/// apakah ada perubahan lokal yang perlu diunggah ke server.
class UploadStatusModel {
  /// Nama tabel di database SQLite.
  static const String tableName = 'upload_status';

  /// Kunci unik untuk baris status `need_upload`.
  static const String idNeedUpload = 'need_upload';

  /// ID unik untuk baris ini, yang juga merupakan kuncinya (misalnya, 'need_upload').
  final String id;

  /// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
  /// `false` jika tidak.
  final bool needUpload;

  /// Waktu terakhir kali status `needUpload` diubah, disimpan sebagai milidetik sejak epoch.
  final DateTime? updatedAt;

  /// Konstruktor untuk `UploadStatusModel`.
  const UploadStatusModel({
    required this.id,
    required this.needUpload,
    this.updatedAt,
  });

  /// Membuat instance UploadStatusModel dengan logging.
  factory UploadStatusModel.create({
    required final String id,
    required final bool needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel dibuat: id=$id, needUpload=$needUpload');
    return UploadStatusModel(
      id: id,
      needUpload: needUpload,
      updatedAt: updatedAt,
    );
  }

  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory UploadStatusModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Memulai konversi dari SQLite Map ke UploadStatusModel');

    final updatedAtEpoch = map[ColumnNames.updatedAt] as int?;

    final model = UploadStatusModel(
      // Menggunakan ColumnNames.id untuk konsistensi
      id: map[ColumnNames.id] as String,
      // Database SQLite tidak punya tipe boolean, jadi kita simpan sebagai string ('0' atau '1') di kolom 'value'.
      needUpload: map[ColumnNames.value] == '1',
      // Konversi dari milidetik epoch kembali ke DateTime.
      updatedAt: updatedAtEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtEpoch)
          : null,
    );

    Log.info(
        'Konversi ke UploadStatusModel berhasil: id=${model.id}, needUpload=${model.needUpload}');
    return model;
  }

  /// Konversi dari model ke Map untuk disimpan ke database SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Memulai konversi UploadStatusModel ke SQLite Map: id=$id');

    final map = <String, dynamic>{
      ColumnNames.id: id,
      // Simpan sebagai string '0' atau '1' di kolom 'value'
      ColumnNames.value: needUpload ? '1' : '0',
      // Konversi DateTime ke milidetik sejak epoch agar bisa disimpan di SQLite sebagai INTEGER.
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };

    Log.info('Konversi ke SQLite Map berhasil: $map');
    return map;
  }

  /// Membuat salinan dari model ini dengan nilai yang diperbarui.
  UploadStatusModel copyWith({
    final String? id,
    final bool? needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel.copyWith: id=$id, needUpload=$needUpload');

    return UploadStatusModel(
      id: id ?? this.id,
      needUpload: needUpload ?? this.needUpload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UploadStatusModel(id: $id, needUpload: $needUpload, updatedAt: $updatedAt)';
  }
}
```

## wallet_model.dart

```dart
// path: lib/shared/model/wallet_model.dart
// new file: Refactored from dompet_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Data model for a wallet entity in the application.
class WalletModel implements HasId {
  /// A unique ID for each wallet, generated automatically if not provided.
  @override
  final String id;

  /// The user-defined name for this wallet. This is required.
  final String name;

  /// The current balance of the wallet.
  final double balance;

  /// Timestamp of when this data was last updated on the server or locally.
  final DateTime? updatedAt;

  /// Soft delete status. If `true`, the wallet is considered deleted.
  final bool isDeleted;

  /// Timestamp of when this wallet was archived. `null` if not archived.
  final DateTime? archivedAt;

  /// Creates an instance of [WalletModel].
  WalletModel({
    final String? id,
    required this.name,
    required this.balance,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4();

  /// Creates a copy of [WalletModel] with updated fields.
  WalletModel copyWith({
    final String? id,
    final String? name,
    final double? balance,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Internal helper to parse a date value from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Creates a [WalletModel] instance from a SQLite map.
  factory WalletModel.fromSqlite(final Map<String, dynamic> map) {
    return WalletModel(
      id: map[ColumnNames.id] as String?,
      name: (map[ColumnNames.name] as String?) ?? '',
      balance: (map[ColumnNames.balance] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: map[ColumnNames.isDeleted] == 1,
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts this [WalletModel] instance into a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.balance: balance,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [WalletModel] instance from a Firestore document.
  factory WalletModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return WalletModel(
      id: id,
      name: (data[ColumnNames.name] as String?) ?? '',
      balance: (data[ColumnNames.balance] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: (data[ColumnNames.isDeleted] as bool?) ?? false,
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts this [WalletModel] instance into a map for Firestore storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.balance: balance,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}





# base_operation
// path: lib/shared/operasi/base_operation.dart
// diubah: Menambahkan parameter `fromServer` untuk memutus siklus sinkronisasi.
// diubah: Mengganti StatusUnggahOperasi menjadi UploadStatusOperasi.
// diubah: Mengganti nama class dari OperasiDasar menjadi BaseOperation.

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/upload_status_operasi.dart';

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
class BaseOperation {
  final DatabaseHelper _dbHelper;
  final UploadStatusOperasi _uploadStatusOperasi;

  /// Konstruktor untuk `BaseOperation`.
  ///
  /// Memungkinkan injeksi dependensi untuk `DatabaseHelper` dan `UploadStatusOperasi`
  /// untuk memfasilitasi pengujian.
  BaseOperation({
    @visibleForTesting final DatabaseHelper? dbHelper,
    @visibleForTesting final UploadStatusOperasi? uploadStatusOperasi,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _uploadStatusOperasi = uploadStatusOperasi ?? UploadStatusOperasi() {
    Log.info('BaseOperation instance dibuat.');
  }

  /// Menjalankan `action` di dalam sebuah transaksi database.
  ///
  /// Jika [fromServer] bernilai `false`, maka akan menandai status `needUpload`
  /// menjadi `true` untuk sinkronisasi data ke server.
  Future<T> _runInTransaction<T>(
    final Future<T> Function(Transaction) action, {
    final bool fromServer = false,
  }) async {
    Log.info(
      '[TRANSAKSI DIMULAI] Memulai proses eksekusi dalam wrapper transaksi.',
    );

    try {
      final db = await _dbHelper.database;
      return await db.transaction((final txn) async {
        Log.info(
          '[TRANSAKSI AKTIF] Blok transaksi telah dimulai. Instance: ${txn.runtimeType}',
        );

        try {
          if (!fromServer) {
            Log.info(
              '[TRANSAKSI AKTIF] Menandai status `needUpload` menjadi TRUE (operasi lokal).',
            );
            await _uploadStatusOperasi.setNeedUpload(true, transaction: txn);
            Log.info(
              '[TRANSAKSI AKTIF] Status `needUpload` berhasil ditandai.',
            );
          } else {
            Log.info(
              '[TRANSAKSI AKTIF] Melewati penandaan `needUpload` (operasi dari server).',
            );
          }

          final result = await action(txn);
          Log.info(
            '[TRANSAKSI AKTIF] Aksi utama berhasil dieksekusi. Hasil: ${result.runtimeType}',
          );

          Log.info(
            '[TRANSAKSI COMMIT] Transaksi akan di-commit.',
          );
          return result;
        } catch (e, st) {
          Log.error(
            '[TRANSAKSI GAGAL DI DALAM] Error di dalam blok transaksi.',
            e: e,
            st: st,
          );
          rethrow;
        }
      });
    } catch (e, st) {
      Log.error(
        '[TRANSAKSI GAGAL DI LUAR] Gagal memulai atau menyelesaikan transaksi.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menjalankan operasi database yang kompleks di dalam sebuah transaksi.
  Future<T> runComplexOperation<T>(
    final Future<T> Function(Transaction txn) customAction, {
    final bool fromServer = false,
  }) async {
    Log.info('Mendelegasikan eksekusi transaksi kompleks');
    return await _runInTransaction(customAction, fromServer: fromServer);
  }

  /// Menyisipkan data baru ke dalam [table].
  Future<void> insert(
    final String table,
    final Map<String, dynamic> data, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai penyisipan data ke tabel: $table');
    try {
      await _runInTransaction(
        (final txn) async {
          final result = await txn.insert(
            table,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          Log.info('INSERT berhasil', {'rowId': result, 'tabel': table});
          return result;
        },
        fromServer: fromServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal menyisipkan data ke tabel: $table',
        e: e,
        st: s,
        data: data,
      );
      rethrow;
    }
  }

  /// Memperbarui data di [table] berdasarkan [id].
  Future<void> update(
    final String table,
    final Map<String, dynamic> data,
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai pembaruan data di tabel: $table', {
      'id': id,
      'data': data,
    });
    try {
      await _runInTransaction(
        (final txn) async {
          final rowsAffected = await txn.update(
            table,
            data,
            where: 'id = ?',
            whereArgs: [id],
          );
          if (rowsAffected == 0) {
            Log.warning(
              'Update selesai tapi tidak ada baris yang berubah (ID tidak ditemukan)',
              {'id': id, 'tabel': table},
            );
          } else {
            Log.info(
              'UPDATE berhasil',
              {'rowsAffected': rowsAffected, 'id': id},
            );
          }
          return rowsAffected;
        },
        fromServer: fromServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui data di tabel: $table',
        e: e,
        st: s,
        data: {'id': id, 'payload': data},
      );
      rethrow;
    }
  }

  /// Menghapus data dari [table] berdasarkan [id].
  Future<void> delete(final String table, final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai penghapusan data', {'tabel': table, 'id': id});
    try {
      await _runInTransaction(
        (final txn) async {
          final rowsDeleted = await txn.delete(
            table,
            where: 'id = ?',
            whereArgs: [id],
          );
          if (rowsDeleted == 0) {
            Log.warning('Delete selesai tapi tidak ada data yang terhapus', {
              'id': id,
              'tabel': table,
            });
          } else {
            Log.info('DELETE berhasil', {'rowsDeleted': rowsDeleted, 'id': id});
          }
          return rowsDeleted;
        },
        fromServer: fromServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal menghapus data di tabel: $table',
        e: e,
        st: s,
        data: {'id': id},
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan data dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final String table,
    final List<Map<String, dynamic>> dataList, {
    final bool fromServer = false,
  }) async {
    if (dataList.isEmpty) {
      Log.warning('Daftar data batch kosong, operasi dibatalkan', {
        'tabel': table,
      });
      return;
    }
    Log.info('Memulai batch operation', {
      'tabel': table,
      'totalItem': dataList.length,
      'fromServer': fromServer,
    });
    try {
      await _runInTransaction(
        (final txn) async {
          final batch = txn.batch();
          int validCount = 0;
          for (int i = 0; i < dataList.length; i++) {
            final data = dataList[i];
            if (data.isNotEmpty) {
              batch.insert(
                table,
                data,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
              validCount++;
            }
          }
          Log.info('Melakukan commit batch...', {'validCount': validCount});
          await batch.commit(noResult: true);
          Log.info('Batch operation sukses');
        },
        fromServer: fromServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal melakukan batch operation di tabel: $table',
        e: e,
        st: s,
        data: {'totalItem': dataList.length},
      );
      rethrow;
    }
  }
}

# upload_status_operasi
// path: lib/shared/operasi/upload_status_operasi.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/upload_status_model.dart';

/// Kelas ini mengelola satu flag tunggal di database: apakah ada
/// data yang perlu diunggah ke server atau tidak.
class UploadStatusOperasi {
  final DatabaseHelper _dbHelper;

  /// Konstruktor untuk `UploadStatusOperasi`.
  UploadStatusOperasi({@visibleForTesting final DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance {
    Log.info('UploadStatusOperasi instance dibuat.');
  }

  /// Mengatur status `needUpload`.
  Future<void> setNeedUpload(
    final bool needUpload, {
    final Transaction? transaction,
  }) async {
    Log.info('Memulai setNeedUpload: needUpload=$needUpload');
    final db = transaction ?? await _dbHelper.database;
    final model = UploadStatusModel(
      id: UploadStatusModel.idNeedUpload,
      needUpload: needUpload,
      updatedAt: DateTime.now().toUtc(),
    );
    await db.insert(
      UploadStatusModel.tableName,
      model.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    Log.info('setNeedUpload berhasil: needUpload=$needUpload');
  }

  /// Membaca status `needUpload`.
  /// Mengembalikan true jika flag diatur, selain itu false.
  Future<bool> getNeedUpload() async {
    Log.info('Memulai getNeedUpload');
    final db = await _dbHelper.database;
    final result = await db.query(
      UploadStatusModel.tableName,
      where: 'id = ?',
      whereArgs: [UploadStatusModel.idNeedUpload],
    );
    if (result.isNotEmpty) {
      final needUpload = UploadStatusModel.fromSqlite(result.first).needUpload;
      Log.info('getNeedUpload berhasil: needUpload=$needUpload');
      return needUpload;
    }
    Log.info('getNeedUpload: tidak ada data, mengembalikan false');
    return false;
  }

  /// Mereset status `needUpload` menjadi false setelah unggah berhasil.
  Future<void> resetNeedUpload() async {
    Log.info('Memulai resetNeedUpload');
    await setNeedUpload(false);
    Log.info('resetNeedUpload berhasil');
  }

  /// Mendapatkan model UploadStatusModel lengkap, termasuk waktu terakhir diperbarui.
  Future<UploadStatusModel?> getUploadStatusModel() async {
    Log.info('Memulai getUploadStatusModel');
    final db = await _dbHelper.database;
    final result = await db.query(
      UploadStatusModel.tableName,
      where: 'id = ?',
      whereArgs: [UploadStatusModel.idNeedUpload],
    );
    if (result.isNotEmpty) {
      final model = UploadStatusModel.fromSqlite(result.first);
      Log.info('getUploadStatusModel berhasil: needUpload=${model.needUpload}');
      return model;
    }
    Log.info('getUploadStatusModel: tidak ada data, mengembalikan null');
    return null;
  }
}

# settings_model
// path: lib/shared/model/settings_model.dart
// new file: Refactored from pengaturan_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Global ID for the settings document.
const String globalSettingsId = 'global_config';

/// Model for application settings.
class SettingsModel implements HasId {
  @override
  final String id;

  /// The interval in hours for auto-sync.
  final int autoSyncInterval;

  /// The number of days after which archived data is auto-deleted.
  final int autoDeleteArchiveDays;

  /// A flag indicating if the application is in maintenance mode.
  final bool maintenanceMode;

  /// Information about the maintenance mode.
  final String maintenanceInfo;

  /// The timestamp of the last update.
  final DateTime? updatedAt;

  /// Constructor for `SettingsModel`.
  SettingsModel({
    this.id = globalSettingsId,
    this.autoSyncInterval = 24,
    this.autoDeleteArchiveDays = 30,
    this.maintenanceMode = false,
    this.maintenanceInfo = '',
    this.updatedAt,
  });

  /// Creates a copy of this `SettingsModel` with some modified values.
  SettingsModel copyWith({
    final String? id,
    final int? autoSyncInterval,
    final int? autoDeleteArchiveDays,
    final bool? maintenanceMode,
    final String? maintenanceInfo,
    final DateTime? updatedAt,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
      autoDeleteArchiveDays:
          autoDeleteArchiveDays ?? this.autoDeleteArchiveDays,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceInfo: maintenanceInfo ?? this.maintenanceInfo,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Creates a `SettingsModel` instance from SQLite map data.
  factory SettingsModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating SettingsModel from SQLite');
    return SettingsModel(
      autoSyncInterval: map[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays:
          map[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: (map[ColumnNames.maintenanceMode] as int? ?? 0) == 1,
      maintenanceInfo: map[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode ? 1 : 0,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a `SettingsModel` instance from Firebase map data.
  factory SettingsModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating SettingsModel from Firebase');
    return SettingsModel(
      id: data[ColumnNames.id] as String? ?? globalSettingsId,
      autoSyncInterval: data[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays: data[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: data[ColumnNames.maintenanceMode] as bool? ?? false,
      maintenanceInfo: data[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
    };
  }
}

## upload_status_model
// path: lib/shared/model/upload_status_model.dart

import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';

/// Model ini merepresentasikan satu baris tunggal dalam tabel `upload_status`.
/// Tujuannya adalah untuk bertindak sebagai "bendera" global yang menandakan
/// apakah ada perubahan lokal yang perlu diunggah ke server.
class UploadStatusModel {
  /// Nama tabel di database SQLite.
  static const String tableName = 'upload_status';

  /// Kunci unik untuk baris status `need_upload`.
  static const String idNeedUpload = 'need_upload';

  /// ID unik untuk baris ini, yang juga merupakan kuncinya (misalnya, 'need_upload').
  final String id;

  /// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
  /// `false` jika tidak.
  final bool needUpload;

  /// Waktu terakhir kali status `needUpload` diubah, disimpan sebagai milidetik sejak epoch.
  final DateTime? updatedAt;

  /// Konstruktor untuk `UploadStatusModel`.
  const UploadStatusModel({
    required this.id,
    required this.needUpload,
    this.updatedAt,
  });

  /// Membuat instance UploadStatusModel dengan logging.
  factory UploadStatusModel.create({
    required final String id,
    required final bool needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel dibuat: id=$id, needUpload=$needUpload');
    return UploadStatusModel(
      id: id,
      needUpload: needUpload,
      updatedAt: updatedAt,
    );
  }

  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory UploadStatusModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Memulai konversi dari SQLite Map ke UploadStatusModel');

    final updatedAtEpoch = map[ColumnNames.updatedAt] as int?;

    final model = UploadStatusModel(
      // Menggunakan ColumnNames.id untuk konsistensi
      id: map[ColumnNames.id] as String,
      // Database SQLite tidak punya tipe boolean, jadi kita simpan sebagai string ('0' atau '1') di kolom 'value'.
      needUpload: map[ColumnNames.value] == '1',
      // Konversi dari milidetik epoch kembali ke DateTime.
      updatedAt: updatedAtEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtEpoch)
          : null,
    );

    Log.info(
        'Konversi ke UploadStatusModel berhasil: id=${model.id}, needUpload=${model.needUpload}');
    return model;
  }

  /// Konversi dari model ke Map untuk disimpan ke database SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Memulai konversi UploadStatusModel ke SQLite Map: id=$id');

    final map = <String, dynamic>{
      ColumnNames.id: id,
      // Simpan sebagai string '0' atau '1' di kolom 'value'
      ColumnNames.value: needUpload ? '1' : '0',
      // Konversi DateTime ke milidetik sejak epoch agar bisa disimpan di SQLite sebagai INTEGER.
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };

    Log.info('Konversi ke SQLite Map berhasil: $map');
    return map;
  }

  /// Membuat salinan dari model ini dengan nilai yang diperbarui.
  UploadStatusModel copyWith({
    final String? id,
    final bool? needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel.copyWith: id=$id, needUpload=$needUpload');

    return UploadStatusModel(
      id: id ?? this.id,
      needUpload: needUpload ?? this.needUpload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UploadStatusModel(id: $id, needUpload: $needUpload, updatedAt: $updatedAt)';
  }
}

## sqlite.dart
// path: lib/admin/data/sqlite.dart
// diubah: Menaikkan versi DB ke 48, menambahkan kolom `diperbarui` ke `status_aplikasi`.
// ditambah: Menambahkan dokumentasi untuk anggota publik untuk memperbaiki peringatan analisis.

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas pembantu untuk mengelola database SQLite.
class DatabaseHelper {
  /// Instance tunggal dari DatabaseHelper.
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // diubah: Versi dinaikkan ke 48 untuk menambahkan kolom `diperbarui` ke `status_aplikasi`.
  static const int _databaseVersion = 48;

  DatabaseHelper._internal() {
    Log.info('DatabaseHelper instance dibuat (singleton _internal).');
  }

  /// Atur ulang instance database (hanya untuk pengujian).
  void debugSetDatabaseNull() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _database = null;
    }
  }

  // --- DEFINISI TABEL (diperbarui di bawah) ---

  /// Mendapatkan instance database.
  Future<Database> get database async {
    Log.info('Memulai proses akses properti database getter.');
    if (_database != null) {
      Log.info('Instance database sudah ada di memori, mengembalikan...');
      return _database!;
    }

    Log.info('Instance database belum ada, memanggil _initDB().');
    try {
      _database = await _initDB();
      Log.info('Database berhasil diinisialisasi dan di-cache.');
      return _database!;
    } on Exception catch (e, st) {
      Log.error('Gagal total mendapatkan instance database.', e: e, st: st);
      rethrow;
    }
  }

  Future<Database> _initDB() async {
    Log.info('Memulai inisialisasi database (_initDB).');
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        Log.info('Mode TEST terdeteksi. Menggunakan database in-memory.');
        return databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: createTables,
            onUpgrade: _onUpgrade,
          ),
        );
      }

      Log.info('Mode PRODUKSI/DEBUG. Menggunakan database fisik.');
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, 'mydatabase.db');
      Log.info('Path database: $path');

      Log.info('Membuka database dengan versi $_databaseVersion...');
      return openDatabase(
        path,
        version: _databaseVersion,
        onCreate: createTables,
        onUpgrade: _onUpgrade,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal membuka atau membuat database.', e: e, st: st);
      rethrow;
    }
  }

  Future<void> _onUpgrade(
      final Database db, final int oldVersion, final int newVersion) async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES UPGRADE DATABASE (IDEMPOTEN)');
    Log.info('Versi database lama: $oldVersion');
    Log.info('Versi database baru: $newVersion');
    Log.info('========================================');

    final batch = db.batch();

    if (oldVersion < 45) {
      Log.info('[MIGRASI v45] Menjalankan migrasi untuk versi < 45.');
      await _migrateToV45(db);
    }

    if (oldVersion < 47) {
      Log.info(
          '[MIGRASI v47] Memulai migrasi skema untuk memperbaiki tabel `kritik_saran` (destruktif).');
      final List<String> daftarTabel = [
        'kategori',
        'sub_kategori',
        'paket',
        'pelanggan',
        'pelanggan_aktif',
        'transaksi',
        'dompet',
        'kritik_saran',
        'pesanan',
        'versi_apk_user',
        'pengaturan',
        'status_unggah',
        'pesan',
        'status_aplikasi',
      ];

      Log.warning(
          '[MIGRASI v47] Proses ini akan menghapus dan membuat ulang tabel. Data lokal akan direset.');

      for (final namaTabel in daftarTabel) {
        batch.execute('DROP TABLE IF EXISTS $namaTabel');
        Log.info('[MIGRASI v47] Jadwalkan DROP TABLE untuk `$namaTabel`.');
      }

      _createAllTables(batch);
      Log.info(
          '[MIGRASI v47] Menjadwalkan pembuatan ulang semua tabel dengan skema baru.');
    }

    if (oldVersion < 48) {
      Log.info(
          '[MIGRASI v48] Menambahkan kolom `diperbarui` ke tabel `status_aplikasi`.');
      batch
          .execute('ALTER TABLE status_aplikasi ADD COLUMN diperbarui INTEGER');
    }

    try {
      await batch.commit(noResult: true);
      Log.info('========================================');
      Log.info('PROSES UPGRADE DATABASE SELESAI');
      Log.info(
          'Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.');
      Log.info('========================================');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan upgrade database dari versi $oldVersion ke versi $newVersion.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  Future<void> _migrateToV45(final Database db) async {
    Log.info(
      '[MIGRASI v45] Menangani tabel "pengaturan" untuk memastikan PRIMARY KEY.',
    );
    await db.execute('DROP TABLE IF EXISTS pengaturan');
    await db.execute(_tabelPengaturan);
    Log.info('[MIGRASI v45] Tabel `pengaturan` berhasil dibuat ulang.');
  }

  /// Membuat tabel-tabel database.
  Future<void> createTables(final Database db, final int version) async {
    Log.info('========================================');
    Log.info(
        'MEMULAI PEMBUATAN TABEL DATABASE (onCreate) UNTUK VERSI $version');
    Log.info('========================================');
    final batch = db.batch();
    _createAllTables(batch);
    try {
      await batch.commit(noResult: true);
      Log.info('========================================');
      Log.info('PROSES PEMBUATAN TABEL & INDEX SELESAI');
      Log.info('========================================');
    } on Exception catch (e, st) {
      Log.error('Gagal total saat membuat tabel atau index.', e: e, st: st);
      rethrow;
    }
  }

  void _createAllTables(final Batch batch) {
    batch.execute(_tabelKategori);
    batch.execute(_tabelSubKategori);
    batch.execute(_tabelPaket);
    batch.execute(_tabelPelanggan);
    batch.execute(_tabelPelangganAktif);
    batch.execute(tabelTransaksi);
    batch.execute(tabelDompet);
    batch.execute(_tabelKritikSaran);
    batch.execute(_tabelPesanan);
    batch.execute(tabelVersiApkUser);
    batch.execute(_tabelPengaturan);
    batch.execute(_tabelStatusUnggah);
    batch.execute(_tabelStatusAplikasi);
    batch.execute(_tabelPesan);
    Log.info('Semua 14 definisi tabel ditambahkan ke batch.');

    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaksi_dompet ON transaksi(id_dompet)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaksi_isDeleted ON transaksi(isDeleted)');
    Log.info('Semua 3 definisi index ditambahkan ke batch.');
  }

  /// String SQL untuk membuat tabel versi_apk_user.
  static const String tabelVersiApkUser = '''
      CREATE TABLE versi_apk_user(
        id TEXT PRIMARY KEY,
        catatan_rilis TEXT NOT NULL,
        nomor_build_terbaru TEXT NOT NULL,
        tautan_unduhan TEXT NOT NULL,
        versi_terbaru TEXT NOT NULL,
        wajib_update INTEGER NOT NULL,
        youtube_tutorial TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER,
        diperbarui INTEGER
      )
    ''';

  /// String SQL untuk membuat tabel dompet.
  static const String tabelDompet = '''
      CREATE TABLE dompet(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER
      )
    ''';

  /// String SQL untuk membuat tabel transaksi.
  static const String tabelTransaksi = '''
      CREATE TABLE transaksi(
        id TEXT PRIMARY KEY,
        keterangan TEXT NOT NULL,
        jumlah REAL NOT NULL,
        tanggal INTEGER NOT NULL,
        tipe TEXT NOT NULL,
        id_dompet TEXT,
        id_kategori TEXT,
        id_sub_kategori TEXT,
        id_pelanggan TEXT,
        id_paket TEXT,
        diperbarui INTEGER,
        diarsipkan INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        id_dompet_tujuan TEXT,
        poin_yang_dihasilkan INTEGER NOT NULL DEFAULT 0,
        poin_yang_digunakan INTEGER NOT NULL DEFAULT 0,
        status_pembayaran TEXT,
        durasi_paket INTEGER,
        tipe_durasi_paket TEXT,
        tanggal_mulai INTEGER,
        tanggal_berakhir INTEGER,
        aktivasi_paket INTEGER DEFAULT 0
      )
    ''';

  static const String _tabelStatusUnggah = '''
    CREATE TABLE status_unggah(
      tabel TEXT PRIMARY KEY,
      status INTEGER NOT NULL,
      ids TEXT NOT NULL,
      diperbarui INTEGER
    )
  ''';

  // diubah: Menambahkan kolom `diperbarui`
  static const String _tabelStatusAplikasi = '''
    CREATE TABLE status_aplikasi(
      id TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      diperbarui INTEGER
    )
  ''';

  static const String _tabelPesan = '''
    CREATE TABLE pesan(
      id TEXT PRIMARY KEY,
      isi TEXT NOT NULL,
      tanggal INTEGER NOT NULL,
      status TEXT NOT NULL
    )
  ''';

  static const String _tabelPengaturan = '''
    CREATE TABLE pengaturan(
      id TEXT PRIMARY KEY,
      interval_sinkronisasi_otomatis INTEGER NOT NULL DEFAULT 24,
      hapus_otomatis_data_arsip INTEGER NOT NULL DEFAULT 30,
      diperbarui INTEGER,
      mode_pemeliharaan INTEGER NOT NULL DEFAULT 0,
      info_pemeliharaan TEXT
    )
  ''';

  static const String _tabelKategori = '''
      CREATE TABLE kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        tipe TEXT NOT NULL,
        id_sub_kategori TEXT,
        diperbarui INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER
      )
    ''';

  static const String _tabelSubKategori = '''
      CREATE TABLE sub_kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        id_kategori TEXT NOT NULL,
        diperbarui INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER,
        FOREIGN KEY (id_kategori) REFERENCES kategori (id) ON DELETE CASCADE
      )
    ''';

  static const String _tabelPaket = '''
      CREATE TABLE paket(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        harga INTEGER NOT NULL,
        durasi INTEGER NOT NULL,
        tipe TEXT NOT NULL,
        jumlahPoin INTEGER NOT NULL DEFAULT 0,
        diperbarui INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER,
        poin_hadiah INTEGER NOT NULL DEFAULT 0,
        poin_penukaran INTEGER NOT NULL DEFAULT 0,
        isPublic INTEGER NOT NULL DEFAULT 1
      )
    ''';

  static const String _tabelPelanggan = '''
      CREATE TABLE pelanggan(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        telepon TEXT NOT NULL,
        alamat TEXT NOT NULL,
        password TEXT NOT NULL,
        mac_address TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'aktif', 
        diperbarui INTEGER,      
        diarsipkan INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0       
      )
    ''';

  static const String _tabelPelangganAktif = '''
      CREATE TABLE pelanggan_aktif(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        id_transaksi TEXT,
        tanggal_mulai INTEGER,
        tanggal_berakhir INTEGER,
        status TEXT NOT NULL,
        diperbarui INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_transaksi) REFERENCES transaksi (id) ON DELETE SET NULL
      )
    ''';

  static const String _tabelKritikSaran = '''
      CREATE TABLE kritik_saran(
        id TEXT PRIMARY KEY,
        isi TEXT NOT NULL,
        tanggal INTEGER NOT NULL,
        userId TEXT NOT NULL,
        diperbarui INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER,
        FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
      )
    ''';

  static const String _tabelPesanan = '''
      CREATE TABLE pesanan(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        tanggal INTEGER NOT NULL,
        status TEXT,
        diperbarui INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE
      )
    ''';
}

## column_names
// path: lib/shared/constant/column_names.dart
// Berkas ini berisi daftar nama kolom database untuk konsistensi di seluruh aplikasi.

// TODO: Lengkapi semua nama kolom dari setiap tabel di sqlite.dart.

/// Kelas abstrak yang berisi konstanta untuk nama kolom database.
abstract final class ColumnNames {
  /// Nama kolom untuk ID unik.
  static const String id = 'id';

  /// Nama kolom untuk status hapus (soft delete).
  static const String isDeleted = 'is_deleted';

  /// Nama kolom untuk waktu pembaruan terakhir.
  static const String updatedAt = 'updated_at';

  /// Nama kolom untuk waktu pengarsipan.
  static const String archivedAt = 'archived_at';

  /// Nama kolom untuk nama (misalnya, nama kategori, nama dompet).
  static const String name = 'name';

  /// Nama kolom untuk saldo dompet.
  static const String balance = 'balance';

  /// Nama kolom untuk deskripsi atau keterangan.
  static const String description = 'description';

  /// Nama kolom untuk jumlah transaksi.
  static const String amount = 'amount';

  /// Nama kolom untuk tanggal.
  static const String date = 'date';

  /// Nama kolom untuk tipe (misalnya, tipe transaksi, tipe kategori).
  static const String type = 'type';

  /// Nama kolom untuk ID dompet.
  static const String walletId = 'wallet_id';

  /// Nama kolom untuk ID kategori.
  static const String categoryId = 'category_id';

  /// Nama kolom untuk ID sub-kategori.
  static const String subCategoryId = 'sub_category_id';

  /// Nama kolom untuk ID pelanggan.
  static const String customerId = 'customer_id';

  /// Nama kolom untuk ID paket.
  static const String packageId = 'package_id';
  
  /// Nama kolom untuk ID transaksi.
  static const String transactionId = 'transaction_id';

  /// Nama kolom untuk ID dompet tujuan (untuk transfer).
  static const String destinationWalletId = 'destination_wallet_id';

  /// Nama kolom untuk poin yang diperoleh.
  static const String earnedPoints = 'earned_points';

  /// Nama kolom untuk poin yang digunakan.
  static const String usedPoints = 'used_points';

  /// Nama kolom untuk status pembayaran.
  static const String paymentStatus = 'payment_status';

  /// Nama kolom untuk durasi paket.
  static const String packageDuration = 'package_duration';

  /// Nama kolom untuk tipe durasi (misalnya, hari, bulan).
  static const String durationType = 'duration_type';

  /// Nama kolom untuk tanggal mulai.
  static const String startDate = 'start_date';

  /// Nama kolom untuk tanggal berakhir.
  static const String endDate = 'end_date';

  /// Nama kolom untuk status aktivasi paket.
  static const String isActivated = 'is_activated';

  /// Nama kolom untuk harga.
  static const String price = 'price';

  /// Nama kolom untuk durasi.
  static const String duration = 'duration';

  /// Nama kolom untuk poin hadiah.
  static const String rewardPoints = 'reward_points';

  /// Nama kolom untuk poin penukaran.
  static const String redemptionPoints = 'redemption_points';

  /// Nama kolom untuk status publik (apakah paket dapat dilihat publik).
  static const String isPublic = 'is_public';

  /// Nama kolom untuk nomor telepon.
  static const String phone = 'phone';

  /// Nama kolom untuk alamat.
  static const String address = 'address';

  /// Nama kolom untuk kata sandi.
  static const String password = 'password';

  /// Nama kolom untuk alamat MAC.
  static const String macAddress = 'mac_address';

  /// Nama kolom untuk status umum.
  static const String status = 'status';

  /// Nama kolom untuk isi (misalnya, isi kritik dan saran).
  static const String content = 'content';

  /// Nama kolom untuk ID pengguna.
  static const String userId = 'user_id';

  /// Nama kolom untuk catatan rilis.
  static const String releaseNotes = 'release_notes';

  /// Nama kolom untuk nomor build terbaru.
  static const String latestBuildNumber = 'latest_build_number';

  /// Nama kolom untuk tautan unduhan.
  static const String downloadLinks = 'download_links';

  /// Nama kolom untuk versi terbaru.
  static const String latestVersion = 'latest_version';

  /// Nama kolom untuk status pembaruan paksa.
  static const String isUpdateRequired = 'is_update_required';

  /// Nama kolom untuk tautan tutorial YouTube.
  static const String youtubeTutorial = 'youtube_tutorial';

  /// Nama kolom untuk interval sinkronisasi otomatis.
  static const String autoSyncInterval = 'auto_sync_interval';

  /// Nama kolom untuk interval penghapusan arsip otomatis (dalam hari).
  static const String autoDeleteArchiveDays = 'auto_delete_archive_days';

  /// Nama kolom untuk mode pemeliharaan.
  static const String maintenanceMode = 'maintenance_mode';

  /// Nama kolom untuk informasi pemeliharaan.
  static const String maintenanceInfo = 'maintenance_info';

  /// Nama kolom untuk nama tabel.
  static const String tableName = 'table_name';

  /// Nama kolom untuk daftar ID.
  static const String ids = 'ids';

  /// Nama kolom untuk nilai generik.
  static const String value = 'value';
}


## snackbar_util.dart

// path: lib/shared/utils/snackbar_util.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Tipe SnackBar yang tersedia.
enum SnackBarType {
  /// SnackBar sukses dengan latar hijau.
  success,

  /// SnackBar error dengan latar merah.
  error,

  /// SnackBar peringatan dengan latar oranye.
  warning,

  /// SnackBar informasi dengan latar biru.
  info,
}

/// Kelas utilitas untuk menampilkan SnackBar dengan gaya yang konsisten dan logging otomatis.
class SnackBarUtil {
  /// Fungsi internal untuk menampilkan SnackBar dan mencatat log.
  static void _show(
    final BuildContext context,
    final String message, {
    final SnackBarType type = SnackBarType.info,
  }) {
    // Mencatat pesan ke log berdasarkan tipenya
    final logMessage = '[SNACKBAR] Tipe: ${type.name}, Pesan: $message';
    switch (type) {
      case SnackBarType.success:
        Log.info(logMessage);
        break;
      case SnackBarType.error:
        Log.error(logMessage);
        break;
      case SnackBarType.warning:
        Log.warning(logMessage);
        break;
      case SnackBarType.info:
        Log.info(logMessage);
        break;
    }

    // Jangan tampilkan snackbar jika context sudah tidak valid setelah logging
    if (!context.mounted) return;

    // Tentukan warna berdasarkan tipe snackbar
    Color backgroundColor;
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue;
        break;
    }

    // Buat dan tampilkan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  /// Menampilkan SnackBar dengan tipe success.
  static void success(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.success);
  }

  /// Menampilkan SnackBar dengan tipe error.
  static void error(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.error);
  }

  /// Menampilkan SnackBar dengan tipe warning.
  static void warning(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.warning);
  }

  /// Menampilkan SnackBar dengan tipe info.
  static void info(final BuildContext context, final String message) {
    _show(context, message);
  }
}

## log.dart

// path: lib/shared/debug/log.dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Kelas utilitas untuk logging yang terstruktur dan berwarna.
class Log {
  static const String _green = '\x1B[38;5;76m';
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';

  static final Random _random = Random();

  static String _buatKodeUnik() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (final _) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  static String _formatData(final Object? data) {
    if (data == null) return '';

    Object? customEncoder(final Object? object) {
      if (object is DateTime) {
        return object.toIso8601String();
      }
      if (object is Timestamp) {
        return object.toDate().toIso8601String();
      }
      try {
        return (object as dynamic).toJson();
      } on Exception {
        return object.toString();
      }
    }

    try {
      if (data is Map || data is List) {
        final encoder = JsonEncoder.withIndent('  ', customEncoder);
        return '\nData: ${encoder.convert(data)}';
      }
      return '\nData: $data';
    } on Exception {
      return '\nData: $data';
    }
  }

  /// Mencatat pesan informasi.
  static void info(final String message, [final Object? data]) {
    _logCustom(
      message: '$message${_formatData(data)}',
      name: '✅',
      color: _green,
      level: 800,
    );
  }

  /// Mencatat pesan peringatan.
  static void warning(final String message, [final Object? data]) {
    _logCustom(
      message: '$message${_formatData(data)}',
      name: '⚠️',
      color: _yellow,
      level: 900,
    );
  }

  /// Mencatat pesan error.
  static void error(
    final String message, {
    final Object? e,
    final StackTrace? st,
    final Object? data,
  }) {
    _logCustom(
      message: '$message${_formatData(data)}',
      name: '❌',
      color: _red,
      level: 1000,
      e: e,
      st: st,
    );
  }

  /// Mencatat panggilan API.
  static void api(
    final String path,
    final Map<String, dynamic> data, {
    required final String method,
  }) {
    final String id = _buatKodeUnik();
    _logCustom(
      message: '[$method][$id] $path${_formatData(data)}',
      name: '🌐',
      color: _cyan,
      level: 500,
    );
  }

  static void _logCustom({
    required final String message,
    required final String name,
    required final String color,
    required final int level,
    final Object? e,
    final StackTrace? st,
  }) {
    if (!kDebugMode) return;

    final trace = StackTrace.current.toString().split('\n');
    final String callerRow = trace.length > 2 ? trace[2] : 'Unknown';
    final match = RegExp(r'#2\s+(.+)\s+\((.+)\)').firstMatch(callerRow);

    String location = '';
    if (match != null) {
      final methodCaller = match.group(1);
      final fileInfo = match.group(2);
      location = '[ $methodCaller ] - $fileInfo';
    }

    dev.log(
      '$color$message - $location$_reset',
      name: name,
      level: level,
      time: DateTime.now(),
      error: e,
      stackTrace: st,
    );
  }
}
# apk_architecture_enum.dart
// path: lib/shared/enum/apk_architecture_enum.dart

/// Jenis arsitektur aplikasi yang didukung.
enum ApkArchitectureEnum {
  /// Aplikasi 32-bit.
  bit32,

  /// Aplikasi 64-bit.
  bit64,

  /// Aplikasi universal (mendukung 32-bit dan 64-bit).
  universal,

  /// Aplikasi untuk arsitektur ARM64.
  arm64,

  /// Aplikasi untuk arsitektur x86_64.
  x86_64,
}

# category_type_enum.dart
// path: lib/shared/enum/category_type_enum.dart

/// Enum untuk mendefinisikan tipe-tipe kategori transaksi.
enum CategoryType {
  /// Mewakili transaksi yang menambah saldo (pemasukan).
  income,

  /// Mewakili transaksi yang mengurangi saldo (pengeluaran).
  expense,

  /// Mewakili transaksi transfer dana antar dompet.
  transfer,
}

# duration_type_enum.dart
// path: lib/shared/enum/duration_type_enum.dart
// new file: Created to store the DurationType enum.

/// Enum untuk jenis durasi sebuah paket.
enum DurationType {
  /// Durasi dalam menit.
  minutes,

  /// Durasi dalam jam.
  hours,

  /// Durasi dalam hari.
  days,

  /// Durasi dalam bulan.
  months,
}

# payment_status_enum.dart
// path: lib/shared/enum/payment_status_enum.dart

/// Enum untuk status pembayaran transaksi atau tagihan.
enum PaymentStatus {
  /// Status lunas, pembayaran telah diselesaikan.
  paid,

  /// Status belum lunas, pembayaran masih tertunda.
  unpaid,

  /// Status jatuh tempo, pembayaran sudah melewati batas waktu.
  overdue,
}

# table_name_enum.dart
// path: lib/shared/enum/table_name_enum.dart

/// Enum yang merepresentasikan nama-nama tabel dalam database.
/// Digunakan untuk sinkronisasi dan operasi terkait database lainnya.
enum TableName {
  /// Tabel kategori.
  category,

  /// Tabel sub-kategori.
  subCategory,

  /// Tabel paket.
  package,

  /// Tabel pelanggan.
  customer,

  /// Tabel pelanggan aktif.
  activeCustomer,

  /// Tabel transaksi.
  transaction,

  /// Tabel dompet.
  wallet,

  /// Tabel kritik dan saran.
  feedback,

  /// Tabel pesanan.
  order,

  /// Tabel versi APK pengguna.
  userApkVersion,

  /// Tabel pengaturan.
  setting,

  /// Tabel status unggah.
  uploadStatus,

  /// Tabel pesan.
  message,

  /// Tabel status aplikasi.
  appStatus,
}

# transaction_type_enum.dart
// path: lib/shared/enum/transaction_type_enum.dart

/// Enum untuk tipe-tipe transaksi.
enum TransactionType {
  /// Untuk transaksi pemasukan.
  income,

  /// Untuk transaksi pengeluaran.
  expense,

  /// Untuk transaksi transfer.
  transfer,
}
