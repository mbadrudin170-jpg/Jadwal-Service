// path: lib/fitur/dompet/operasi/dompet_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas untuk operasi terkait data dompet di Firebase.
class DompetOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOpFirebase;
  final String _namaKoleksi = NamaTabel.dompet;

  DompetOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOpFirebase,
  }) : _firestore = firestore,
       _baseOpFirebase = baseOpFirebase {
    Log.info('DompetOpFirebase diinisialisasi.');
  }

  CollectionReference get _koleksiDompet => _firestore.collection(_namaKoleksi);

  // ============================================================
  // OPERASI TULIS (WRITE)
  // ============================================================

  /// Menambahkan dompet baru ke Firebase.
  Future<void> tambahDompet(DompetModel dompet) async {
    Log.info('Menambahkan dompet baru ke Firebase - ID: ${dompet.id}');
    try {
      await _baseOpFirebase.sisipkan(
        _namaKoleksi,
        dompet.id,
        dompet.toFirebase(),
      );
      Log.info('Dompet berhasil ditambahkan - ID: ${dompet.id}');
    } catch (e, s) {
      Log.error('Gagal menambahkan dompet - ID: ${dompet.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui dompet yang sudah ada di Firebase.
  Future<void> perbaruiDompet(DompetModel dompet) async {
    Log.info('Memperbarui dompet di Firebase - ID: ${dompet.id}');
    try {
      await _baseOpFirebase.update(
        _namaKoleksi,
        dompet.id,
        dompet.toFirebase(),
      );
      Log.info('Dompet berhasil diperbarui - ID: ${dompet.id}');
    } catch (e, s) {
      Log.error('Gagal memperbarui dompet - ID: ${dompet.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada dompet di Firebase.
  Future<void> softDeleteDompet(String id) async {
    Log.info('Soft delete dompet di Firebase - ID: $id');
    try {
      await _baseOpFirebase.softDelete(_namaKoleksi, id);
      Log.info('Soft delete dompet berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete dompet - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menghapus dompet secara permanen dari Firebase.
  Future<void> hapusPermanenDompet(String id) async {
    Log.warning('Menghapus dompet secara permanen - ID: $id');
    try {
      await _baseOpFirebase.hapusPermanen(_namaKoleksi, id);
      Log.info('Dompet berhasil dihapus permanen - ID: $id');
    } catch (e, s) {
      Log.error('Gagal menghapus permanen dompet - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui banyak dompet sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatch(List<DompetModel> daftarDompet) async {
    if (daftarDompet.isEmpty) {
      Log.info('Daftar dompet kosong, batch dibatalkan.');
      return;
    }

    Log.info('Memulai batch insert/update untuk ${daftarDompet.length} dompet');
    try {
      final dataList = daftarDompet.map((item) => item.toFirebase()).toList();
      await _baseOpFirebase.insertOrUpdateBatch(
        _namaKoleksi,
        dataList,
        NamaKolom.id,
      );
      Log.info('Batch ${daftarDompet.length} dompet berhasil diproses');
    } catch (e, st) {
      Log.error('Gagal memproses batch dompet', e: e, s: st);
      rethrow;
    }
  }

  // ============================================================
  // OPERASI BACA (READ)
  // ============================================================

  /// Mengambil semua dompet dari Firebase.
  Future<List<DompetModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua dompet dari Firebase');
    try {
      Query query = _koleksiDompet;
      if (!tampilkanYangDiarsip) {
        query = query.where(NamaKolom.dihapus, isEqualTo: false);
      }

      final querySnapshot = await query.get();
      final hasil = querySnapshot.docs.map((doc) {
        // ✅ Perbaikan: Cast data ke Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        return DompetModel.fromFirebase(doc.id, data);
      }).toList();

      Log.info('Berhasil mengambil ${hasil.length} dompet dari Firebase');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil semua dompet dari Firebase', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dompet berdasarkan ID dari Firebase.
  Future<DompetModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mengambil dompet berdasarkan ID dari Firebase: $id');
    try {
      final doc = await _koleksiDompet.doc(id).get();
      if (doc.exists) {
        Log.info('Dompet ditemukan - ID: $id');
        // ✅ Perbaikan: Cast data ke Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        return DompetModel.fromFirebase(doc.id, data);
      }
      Log.info('Dompet tidak ditemukan - ID: $id');
      return null;
    } catch (e, s) {
      Log.error('Gagal mengambil dompet - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil beberapa dompet berdasarkan daftar ID.
  Future<List<DompetModel>> ambilBerdasarkanIds(List<String> ids) async {
    if (ids.isEmpty) {
      Log.info('Daftar ID kosong, mengembalikan list kosong');
      return [];
    }

    Log.info('Mengambil ${ids.length} dompet berdasarkan ID dari Firebase');
    try {
      final hasil = <DompetModel>[];
      for (final id in ids) {
        final dompet = await ambilBerdasarkanId(id);
        if (dompet != null) {
          hasil.add(dompet);
        }
      }
      Log.info('Berhasil mengambil ${hasil.length} dari ${ids.length} dompet');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil dompet berdasarkan IDs', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dompet berdasarkan nama (pencarian).
  Future<List<DompetModel>> ambilBerdasarkanNama(String nama) async {
    Log.info('Mencari dompet dengan nama: $nama');
    try {
      final querySnapshot = await _koleksiDompet
          .where(NamaKolom.nama, isEqualTo: nama)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .get();

      final hasil = querySnapshot.docs.map((doc) {
        // ✅ Perbaikan: Cast data ke Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        return DompetModel.fromFirebase(doc.id, data);
      }).toList();

      Log.info('Ditemukan ${hasil.length} dompet dengan nama: $nama');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mencari dompet dengan nama: $nama', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dompet dengan saldo di atas nilai tertentu.
  Future<List<DompetModel>> ambilDompetSaldoDiatas(double saldoMin) async {
    Log.info('Mengambil dompet dengan saldo > $saldoMin');
    try {
      final querySnapshot = await _koleksiDompet
          .where(NamaKolom.saldo, isGreaterThan: saldoMin)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.saldo, descending: true)
          .get();

      final hasil = querySnapshot.docs.map((doc) {
        // ✅ Perbaikan: Cast data ke Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        return DompetModel.fromFirebase(doc.id, data);
      }).toList();

      Log.info('Ditemukan ${hasil.length} dompet dengan saldo > $saldoMin');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil dompet dengan saldo > $saldoMin', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil total saldo semua dompet.
  Future<double> ambilTotalSaldo() async {
    Log.info('Menghitung total saldo semua dompet');
    try {
      final querySnapshot = await _koleksiDompet
          .where(NamaKolom.dihapus, isEqualTo: false)
          .get();

      var totalSaldo = 0.0;
      for (final doc in querySnapshot.docs) {
        // ✅ Perbaikan: Cast data ke Map<String, dynamic> dan gunakan null check
        final data = doc.data() as Map<String, dynamic>;
        totalSaldo += (data[NamaKolom.saldo] as num?)?.toDouble() ?? 0.0;
      }

      Log.info('Total saldo semua dompet: $totalSaldo');
      return totalSaldo;
    } catch (e, s) {
      Log.error('Gagal menghitung total saldo', e: e, s: s);
      rethrow;
    }
  }

  // ============================================================
  // STREAM (REALTIME)
  // ============================================================

  /// Stream dompet berdasarkan ID (real-time).
  Stream<DompetModel?> ambilStreamBerdasarkanId(String id) {
    Log.info('Memulai stream dompet - ID: $id');
    return _koleksiDompet
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            // ✅ Perbaikan: Cast data ke Map<String, dynamic>
            final data = snapshot.data() as Map<String, dynamic>;
            return DompetModel.fromFirebase(snapshot.id, data);
          }
          return null;
        })
        .handleError((Object e, StackTrace s) {
          Log.error('Error pada stream dompet - ID: $id', e: e, s: s);
          return null;
        });
  }

  /// Stream semua dompet (real-time).
  Stream<List<DompetModel>> ambilStreamSemua() {
    Log.info('Memulai stream semua dompet');
    return _koleksiDompet
        .where(NamaKolom.dihapus, isEqualTo: false)
        .orderBy(NamaKolom.nama)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // ✅ Perbaikan: Cast data ke Map<String, dynamic>
            final data = doc.data() as Map<String, dynamic>;
            return DompetModel.fromFirebase(doc.id, data);
          }).toList();
        })
        .handleError((Object e, StackTrace s) {
          Log.error('Error pada stream semua dompet', e: e, s: s);
          return <DompetModel>[];
        });
  }
}
