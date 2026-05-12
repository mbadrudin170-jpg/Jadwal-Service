// path: lib/data/operasi/kritik_saran_operasi.dart
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KritikSaranOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  Future<void> createKritikSaran(KritikSaranModel kritikSaran) async {
    Log.info('Memulai createKritikSaran untuk data: ${kritikSaran.toSqlite()}');
    try {
      final now = DateTime.now();
      final data = kritikSaran.toSqlite()
        ..['diperbarui'] = now.toIso8601String();

      await _operasiDasar.sisipkan('kritik_saran', data);
      Log.info('Berhasil membuat kritik_saran dengan ID: ${kritikSaran.id}');
    } catch (e, st) {
      Log.error('Gagal saat createKritikSaran', error: e, stackTrace: st);
      rethrow;
    }
  }

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
        (i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listKritik.length} data kritik_saran.');
      return listKritik;
    } catch (e, st) {
      Log.error('Gagal saat getKritikSaran', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<KritikSaranModel> getKritikSaranById(String id) async {
    Log.info('Memulai getKritikSaranById untuk ID: $id');
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
          'Kritik & saran dengan ID: $id ditemukan. Data: ${data.toSqlite()}',
        );
        return data;
      } else {
        Log.error('Kritik & saran dengan ID $id tidak ditemukan.');
        throw Exception('ID $id tidak ditemukan');
      }
    } catch (e, st) {
      Log.error(
        'Gagal saat getKritikSaranById untuk ID: $id',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<List<KritikSaranModel>> getPerubahan(DateTime lastSync) async {
    Log.info(
      'Memulai getPerubahan kritik_saran sejak: ${lastSync.toIso8601String()}',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'diperbarui > ?',
        whereArgs: [lastSync.toIso8601String()],
      );
      final listKritik = List.generate(
        maps.length,
        (i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Ditemukan ${listKritik.length} perubahan kritik_saran sejak ${lastSync.toIso8601String()}.',
      );
      return listKritik;
    } catch (e, st) {
      Log.error(
        'Gagal saat getPerubahan kritik_saran',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<KritikSaranModel> daftarKritikSaran,
  ) async {
    Log.info(
      'Memulai sisipkanAtauPerbaruiBatch untuk ${daftarKritikSaran.length} item kritik_saran.',
    );
    if (daftarKritikSaran.isEmpty) {
      Log.warning(
        'List item untuk batch kosong, tidak ada operasi yang dilakukan.',
      );
      return;
    }
    try {
      final data = daftarKritikSaran.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('kritik_saran', data);
      Log.info(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${daftarKritikSaran.length} item.',
      );
    } catch (e, st) {
      Log.error(
        'Gagal saat sisipkanAtauPerbaruiBatch kritik_saran',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> hapusKritikSaran(String id) async {
    Log.warning(
      'PERINGATAN: Memulai hapusKritikSaran (hard delete) untuk ID: $id',
    );
    try {
      await _operasiDasar.hapus('kritik_saran', id);
      Log.info('Berhasil menghapus permanen kritik_saran dengan ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat hapusKritikSaran untuk ID: $id',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> hapusSemuaKritikSaran() async {
    Log.warning(
      'PERINGATAN: Memulai hapusSemuaKritikSaran. Ini adalah operasi destruktif yang akan menghapus semua kritik & saran secara permanen.',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        int count = await txn.delete('kritik_saran');
        Log.info(
          'Berhasil hapusSemuaKritikSaran. Total baris yang dihapus permanen: $count',
        );
        return count;
      });
    } catch (e, st) {
      Log.error('Gagal saat hapusSemuaKritikSaran', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> hapusByUserId(String userId) async {
    Log.warning(
      'PERINGATAN: Memulai hapusByUserId (hard delete) untuk semua kritik & saran dari userId: $userId',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final deletedCount = await txn.delete(
          'kritik_saran',
          where: 'userId = ?',
          whereArgs: [userId],
        );
        Log.info(
          'Berhasil menghapus $deletedCount kritik & saran dari user: $userId',
        );
        return deletedCount;
      });
    } catch (e, st) {
      Log.error(
        'Gagal saat hapusByUserId untuk userId: $userId',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  static Future<List<KritikSaranModel>> unduhDataDariFirebase() async {
    Log.info('Memulai pengunduhan data dari Firestore koleksi: kritik_saran.');
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('kritik_saran')
          .get();
      final List<KritikSaranModel> data = snapshot.docs
          .map(
            (doc) => KritikSaranModel.fromFirebase(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();

      Log.info(
        'Berhasil mengunduh ${data.length} data kritik dan saran dari Firebase.',
      );
      return data;
    } catch (e, st) {
      Log.error(
        'Gagal mengunduh data kritik dan saran dari Firebase',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  Future<List<KritikSaranModel>> getKritikSaranByIds(List<String> ids) async {
    Log.info('Memulai getKritikSaranByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
        'List ID untuk getKritikSaranByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final listKritik = List.generate(
        maps.length,
        (i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${listKritik.length} data kritik_saran dari ${ids.length} ID yang diminta.',
      );
      return listKritik;
    } catch (e, st) {
      Log.error('Gagal saat getKritikSaranByIds', error: e, stackTrace: st);
      rethrow;
    }
  }
}
