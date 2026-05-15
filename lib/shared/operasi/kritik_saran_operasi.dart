// path: lib/shared/operasi/kritik_saran_operasi.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu dan memperbaiki path.
// diubah: Menambahkan konstruktor untuk dependency injection (DI) agar bisa di-test.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

/// Kelas untuk operasi terkait data kritik dan saran di database lokal.
class KritikSaranOperasi {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [OperasiDasar] untuk operasi CRUD dasar.
  @visibleForTesting
  final OperasiDasar operasiDasar;

  /// Konstruktor untuk [KritikSaranOperasi].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [operasiDasar]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  KritikSaranOperasi({
    final DatabaseHelper? dbHelper,
    final OperasiDasar? operasiDasar,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        operasiDasar = operasiDasar ?? OperasiDasar();

  /// Menyimpan [KritikSaranModel] baru ke dalam database.
  Future<void> createKritikSaran(
    final KritikSaranModel kritikSaran, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai createKritikSaran untuk data: \${kritikSaran.toSqlite()}');
    try {
      final data =
          kritikSaran.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();

      await operasiDasar.sisipkan(
        'kritik_saran',
        data,
        dariServer: dariServer,
      );
      Log.info('Berhasil membuat kritik_saran dengan ID: \${kritikSaran.id}');
    } catch (e, st) {
      Log.error('Gagal saat createKritikSaran', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua kritik dan saran dari database, diurutkan berdasarkan tanggal terbaru.
  Future<List<KritikSaranModel>> getKritikSaran() async {
    Log.info(
      'Memulai getKritikSaran (mengambil semua, diurutkan berdasarkan tanggal terbaru).',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        orderBy: 'tanggal DESC',
      );
      final listKritik = List.generate(
        maps.length,
        (final i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil \${listKritik.length} data kritik_saran.');
      return listKritik;
    } catch (e, st) {
      Log.error('Gagal saat getKritikSaran', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [KritikSaranModel] berdasarkan [id].
  Future<KritikSaranModel> getKritikSaranById(final String id) async {
    Log.info('Memulai getKritikSaranById untuk ID: \$id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final data = KritikSaranModel.fromSqlite(maps.first);
        Log.info(
          'Kritik & saran dengan ID: \$id ditemukan. Data: \${data.toSqlite()}',
        );
        return data;
      } else {
        Log.error('Kritik & saran dengan ID \$id tidak ditemukan.');
        throw Exception('ID \$id tidak ditemukan');
      }
    } catch (e, st) {
      Log.error(
        'Gagal saat getKritikSaranById untuk ID: \$id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil semua kritik dan saran yang telah diubah sejak [lastSync].
  Future<List<KritikSaranModel>> getPerubahan(final DateTime lastSync) async {
    Log.info(
      'Memulai getPerubahan kritik_saran sejak: \${lastSync.toIso8601String()}',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'diperbarui > ?',
        whereArgs: [lastSync.millisecondsSinceEpoch],
      );
      final listKritik = List.generate(
        maps.length,
        (final i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Ditemukan \${listKritik.length} perubahan kritik_saran sejak \${lastSync.toIso8601String()}',
      );
      return listKritik;
    } catch (e, st) {
      Log.error(
        'Gagal saat getPerubahan kritik_saran',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [KritikSaranModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<KritikSaranModel> daftarKritikSaran, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai sisipkanAtauPerbaruiBatch untuk \${daftarKritikSaran.length} item kritik_saran.',
    );
    if (daftarKritikSaran.isEmpty) {
      Log.warning(
        'List item untuk batch kosong, tidak ada operasi yang dilakukan.',
      );
      return;
    }
    try {
      final data = daftarKritikSaran
          .map(
            (final item) =>
                item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await operasiDasar.sisipkanAtauPerbaruiBatch(
        'kritik_saran',
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk \${daftarKritikSaran.length} item.',
      );
    } catch (e, st) {
      Log.error(
        'Gagal saat sisipkanAtauPerbaruiBatch kritik_saran',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus [KritikSaranModel] dari database secara permanen.
  Future<void> hapusKritikSaran(final String id, {final bool dariServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai hapusKritikSaran (hard delete) untuk ID: \$id',
    );
    try {
      await operasiDasar.hapus('kritik_saran', id, dariServer: dariServer);
      Log.info('Berhasil menghapus permanen kritik_saran dengan ID: \$id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat hapusKritikSaran untuk ID: \$id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus semua kritik dan saran dari database secara permanen.
  Future<void> hapusSemuaKritikSaran({final bool dariServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai hapusSemuaKritikSaran. Ini adalah operasi destruktif.',
    );
    try {
      await operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final int count = await txn.delete('kritik_saran');
          Log.info(
            'Berhasil hapusSemuaKritikSaran. Total baris yang dihapus: \$count',
          );
          return count;
        },
        dariServer: dariServer,
      );
    } catch (e, st) {
      Log.error('Gagal saat hapusSemuaKritikSaran', e: e, st: st);
      rethrow;
    }
  }

  /// Menghapus semua kritik dan saran dari seorang pengguna berdasarkan [userId].
  Future<void> hapusByUserId(final String userId, {final bool dariServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai hapusByUserId (hard delete) untuk userId: \$userId',
    );
    try {
      await operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final deletedCount = await txn.delete(
            'kritik_saran',
            where: 'userId = ?',
            whereArgs: [userId],
          );
          Log.info(
            'Berhasil menghapus \$deletedCount kritik & saran dari user: \$userId',
          );
          return deletedCount;
        },
        dariServer: dariServer,
      );
    } catch (e, st) {
      Log.error(
        'Gagal saat hapusByUserId untuk userId: \$userId',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengunduh semua data kritik dan saran dari Firebase.
  static Future<List<KritikSaranModel>> unduhDataDariFirebase() async {
    Log.info('Memulai pengunduhan data dari Firestore koleksi: kritik_saran.');
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('kritik_saran').get();
      final List<KritikSaranModel> data = snapshot.docs
          .map(
            (final doc) => KritikSaranModel.fromFirebase(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();

      Log.info(
        'Berhasil mengunduh \${data.length} data kritik dan saran dari Firebase.',
      );
      return data;
    }on Exception catch (e, st) {
      Log.error(
        'Gagal mengunduh data kritik dan saran dari Firebase',
        e: e,
        st: st,
      );
      return [];
    }
  }

  /// Mengambil beberapa [KritikSaranModel] berdasarkan daftar [ids].
  Future<List<KritikSaranModel>> getKritikSaranByIds(final List<String> ids) async {
    Log.info('Memulai getKritikSaranByIds untuk \${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
        'List ID untuk getKritikSaranByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'id IN (${List.filled(ids.length, '?').join(',')})',
        whereArgs: ids,
      );
      final listKritik = List.generate(
        maps.length,
        (final i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil \${listKritik.length} data kritik_saran dari \${ids.length} ID yang diminta.',
      );
      return listKritik;
    } catch (e, st) {
      Log.error('Gagal saat getKritikSaranByIds', e: e, st: st);
      rethrow;
    }
  }
}
