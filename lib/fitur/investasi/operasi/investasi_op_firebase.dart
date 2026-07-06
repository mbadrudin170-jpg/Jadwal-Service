import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas untuk operasi terkait data investasi dan dividen di Firebase.
class InvestasiOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOpFirebase;

  InvestasiOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOpFirebase,
  }) : _firestore = firestore,
       _baseOpFirebase = baseOpFirebase {
    Log.info('InvestasiOpFirebase diinisialisasi.');
  }

  // ============================================================
  // OPERASI INVESTASI
  // ============================================================

  /// Menambahkan investasi baru ke Firebase
  Future<void> tambahInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    Log.info('Menambahkan investasi baru ke Firebase - ID: ${investasi.id}');
    try {
      await _baseOpFirebase.sisipkan(
        NamaTabel.investasi,
        investasi.id,
        investasi.toFirebase(),
      );
      Log.info(
        'Investasi berhasil ditambahkan ke Firebase - ID: ${investasi.id}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal menambahkan investasi ke Firebase - ID: ${investasi.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil semua investasi dari Firebase
  Future<List<InvestasiModel>> ambilSemuaInvestasi({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua data investasi dari Firebase');
    try {
      Query query = _firestore.collection(NamaTabel.investasi);

      if (!tampilkanYangDiarsip) {
        query = query.where(NamaKolom.dihapus, isEqualTo: false);
      }

      final querySnapshot = await query
          .orderBy(NamaKolom.tanggalInvestasi, descending: true)
          .get();

      final hasil = querySnapshot.docs.map((doc) {
        // doc.data() returns Object (non‑null for QueryDocumentSnapshot)
        // Cast to Map<String, dynamic> for the model factory
        return InvestasiModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      Log.info(
        'Berhasil mengambil ${hasil.length} data investasi dari Firebase',
      );
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil data investasi dari Firebase', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil investasi berdasarkan ID dari Firebase
  Future<InvestasiModel?> ambilInvestasiById(String id) async {
    Log.info('Mengambil investasi berdasarkan ID dari Firebase: $id');
    try {
      final doc = await _firestore
          .collection(NamaTabel.investasi)
          .doc(id)
          .get();

      if (doc.exists) {
        Log.info('Investasi ditemukan di Firebase - ID: $id');
        // doc.data() returns Object? (DocumentSnapshot) – cast it directly
        return InvestasiModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }
      Log.info('Investasi tidak ditemukan di Firebase - ID: $id');
      return null;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil investasi dari Firebase - ID: $id',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil investasi berdasarkan ID investor dari Firebase
  Future<List<InvestasiModel>> ambilInvestasiByIdInvestor(
    String idInvestor,
  ) async {
    Log.info(
      'Mengambil investasi untuk investor dari Firebase - ID: $idInvestor',
    );
    try {
      final querySnapshot = await _firestore
          .collection(NamaTabel.investasi)
          .where(NamaKolom.idInvestor, isEqualTo: idInvestor)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggalInvestasi, descending: true)
          .get();

      final hasil = querySnapshot.docs.map((doc) {
        return InvestasiModel.fromFirebase(doc.id, doc.data());
      }).toList();

      Log.info(
        'Berhasil mengambil ${hasil.length} investasi untuk investor dari Firebase',
      );
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil investasi untuk investor dari Firebase - ID: $idInvestor',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Memperbarui investasi di Firebase
  Future<void> perbaruiInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui investasi di Firebase - ID: ${investasi.id}');
    try {
      await _baseOpFirebase.update(
        NamaTabel.investasi,
        investasi.id,
        investasi.toFirebase(),
      );
      Log.info(
        'Investasi berhasil diperbarui di Firebase - ID: ${investasi.id}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui investasi di Firebase - ID: ${investasi.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Soft delete investasi di Firebase
  Future<void> softDeleteInvestasi(String id, {bool dariServer = false}) async {
    Log.info('Soft delete investasi di Firebase - ID: $id');
    try {
      await _baseOpFirebase.softDelete(NamaTabel.investasi, id);
      Log.info('Soft delete investasi berhasil di Firebase - ID: $id');
    } catch (e, s) {
      Log.error(
        'Gagal soft delete investasi di Firebase - ID: $id',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  // ============================================================
  // OPERASI DIVIDEN
  // ============================================================

  /// Menambahkan dividen baru ke Firebase
  Future<void> tambahDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    Log.info('Menambahkan dividen baru ke Firebase - ID: ${dividen.id}');
    try {
      await _baseOpFirebase.sisipkan(
        NamaTabel.dividen,
        dividen.id,
        dividen.toFirebase(),
      );
      Log.info('Dividen berhasil ditambahkan ke Firebase - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error(
        'Gagal menambahkan dividen ke Firebase - ID: ${dividen.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil semua dividen dari Firebase
  Future<List<DividenModel>> ambilSemuaDividen({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua data dividen dari Firebase');
    try {
      Query query = _firestore.collection(NamaTabel.dividen);

      if (!tampilkanYangDiarsip) {
        query = query.where(NamaKolom.dihapus, isEqualTo: false);
      }

      final querySnapshot = await query
          .orderBy(NamaKolom.tanggalPembagian, descending: true)
          .get();

      final hasil = querySnapshot.docs.map((doc) {
        // doc.data() returns Object (non‑null) – cast to required type
        return DividenModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      Log.info('Berhasil mengambil ${hasil.length} data dividen dari Firebase');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil data dividen dari Firebase', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID dari Firebase
  Future<DividenModel?> ambilDividenById(String id) async {
    Log.info('Mengambil dividen berdasarkan ID dari Firebase: $id');
    try {
      final doc = await _firestore.collection(NamaTabel.dividen).doc(id).get();

      if (doc.exists) {
        Log.info('Dividen ditemukan di Firebase - ID: $id');
        // DocumentSnapshot.data() is Object? – cast directly
        return DividenModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }
      Log.info('Dividen tidak ditemukan di Firebase - ID: $id');
      return null;
    } catch (e, s) {
      Log.error('Gagal mengambil dividen dari Firebase - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID investor dari Firebase
  Future<List<DividenModel>> ambilDividenByIdInvestor(String idInvestor) async {
    Log.info(
      'Mengambil dividen untuk investor dari Firebase - ID: $idInvestor',
    );
    try {
      final querySnapshot = await _firestore
          .collection(NamaTabel.dividen)
          .where(NamaKolom.idInvestor, isEqualTo: idInvestor)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggalPembagian, descending: true)
          .get();

      final hasil = querySnapshot.docs.map((doc) {
        return DividenModel.fromFirebase(doc.id, doc.data());
      }).toList();

      Log.info(
        'Berhasil mengambil ${hasil.length} dividen untuk investor dari Firebase',
      );
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil dividen untuk investor dari Firebase - ID: $idInvestor',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID investasi dari Firebase
  Future<List<DividenModel>> ambilDividenByIdInvestasi(
    String idInvestasi,
  ) async {
    Log.info(
      'Mengambil dividen untuk investasi dari Firebase - ID: $idInvestasi',
    );
    try {
      final querySnapshot = await _firestore
          .collection(NamaTabel.dividen)
          .where(NamaKolom.idInvestasi, isEqualTo: idInvestasi)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggalPembagian, descending: true)
          .get();

      final hasil = querySnapshot.docs.map((doc) {
        return DividenModel.fromFirebase(doc.id, doc.data());
      }).toList();

      Log.info(
        'Berhasil mengambil ${hasil.length} dividen untuk investasi dari Firebase',
      );
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil dividen untuk investasi dari Firebase - ID: $idInvestasi',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Memperbarui dividen di Firebase
  Future<void> perbaruiDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui dividen di Firebase - ID: ${dividen.id}');
    try {
      await _baseOpFirebase.update(
        NamaTabel.dividen,
        dividen.id,
        dividen.toFirebase(),
      );
      Log.info('Dividen berhasil diperbarui di Firebase - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui dividen di Firebase - ID: ${dividen.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Soft delete dividen di Firebase
  Future<void> softDeleteDividen(String id, {bool dariServer = false}) async {
    Log.info('Soft delete dividen di Firebase - ID: $id');
    try {
      await _baseOpFirebase.softDelete(NamaTabel.dividen, id);
      Log.info('Soft delete dividen berhasil di Firebase - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete dividen di Firebase - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menandai dividen sebagai sudah dibayar di Firebase
  Future<void> tandaiDividenDibayar(
    String id, {
    bool dariServer = false,
  }) async {
    Log.info('Menandai dividen sudah dibayar di Firebase - ID: $id');
    try {
      await _baseOpFirebase.update(NamaTabel.dividen, id, {
        NamaKolom.sudahDibayar: true,
        NamaKolom.diperbaruiPada: FieldValue.serverTimestamp(),
      });
      Log.info('Dividen berhasil ditandai sudah dibayar di Firebase - ID: $id');
    } catch (e, s) {
      Log.error(
        'Gagal menandai dividen sudah dibayar di Firebase - ID: $id',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui beberapa investasi sekaligus (batch) di Firebase.
  Future<void> sisipkanAtauPerbaruiBatch(
    List<InvestasiModel> daftarInvestasi, {
    bool dariServer = false,
  }) async {
    if (daftarInvestasi.isEmpty) {
      Log.info('Daftar investasi kosong, batch dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${daftarInvestasi.length} investasi di Firebase',
    );
    try {
      final dataList = daftarInvestasi
          .map((item) => item.toFirebase())
          .toList();

      await _baseOpFirebase.insertOrUpdateBatch(
        NamaTabel.investasi,
        dataList,
        NamaKolom.id,
      );
      Log.info(
        'Batch ${daftarInvestasi.length} investasi berhasil diproses di Firebase',
      );
    } catch (e, st) {
      Log.error('Gagal memproses batch investasi di Firebase', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui beberapa dividen sekaligus (batch) di Firebase.
  Future<void> sisipkanAtauPerbaruiBatchDividen(
    List<DividenModel> daftarDividen, {
    bool dariServer = false,
  }) async {
    if (daftarDividen.isEmpty) {
      Log.info('Daftar dividen kosong, batch dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${daftarDividen.length} dividen di Firebase',
    );
    try {
      final dataList = daftarDividen.map((item) => item.toFirebase()).toList();

      await _baseOpFirebase.insertOrUpdateBatch(
        NamaTabel.dividen,
        dataList,
        NamaKolom.id,
      );
      Log.info(
        'Batch ${daftarDividen.length} dividen berhasil diproses di Firebase',
      );
    } catch (e, st) {
      Log.error('Gagal memproses batch dividen di Firebase', e: e, s: st);
      rethrow;
    }
  }
}
