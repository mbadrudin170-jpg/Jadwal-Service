# Dokumentasi Fitur: investasi

## Daftar file

- [lib/fitur/investasi/model/dividen_model.dart](../../lib/fitur/investasi/model/dividen_model.dart)
- [lib/fitur/investasi/model/investasi_model.dart](../../lib/fitur/investasi/model/investasi_model.dart)
- [lib/fitur/investasi/operasi/investasi_op_firebase.dart](../../lib/fitur/investasi/operasi/investasi_op_firebase.dart)
- [lib/fitur/investasi/operasi/investasi_op_global.dart](../../lib/fitur/investasi/operasi/investasi_op_global.dart)
- [lib/fitur/investasi/operasi/investasi_op_sqlite.dart](../../lib/fitur/investasi/operasi/investasi_op_sqlite.dart)
- [lib/fitur/investasi/page/daftar_investor.dart](../../lib/fitur/investasi/page/daftar_investor.dart)
- [lib/fitur/investasi/page/detail_investor.dart](../../lib/fitur/investasi/page/detail_investor.dart)
- [lib/fitur/investasi/page/form_saham.dart](../../lib/fitur/investasi/page/form_saham.dart)
- [lib/fitur/investasi/page/portofolio.dart](../../lib/fitur/investasi/page/portofolio.dart)
- [lib/fitur/investasi/page/ringkasan_saham.dart](../../lib/fitur/investasi/page/ringkasan_saham.dart)
- [lib/fitur/investasi/provider/investasi_provider.dart](../../lib/fitur/investasi/provider/investasi_provider.dart)

## Isi file

### File: `lib/fitur/investasi/model/dividen_model.dart`
```dart
// path: lib/fitur/investasi/model/dividen_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'dividen_model.freezed.dart';

@freezed
abstract class DividenModel with _$DividenModel implements HasId {
  const DividenModel._();
  const factory DividenModel({
    required String id,
    required String idInvestasi, // ID investasi terkait
    required String idInvestor, // ID pelanggan investor
    required double jumlahDividen,
    required DateTime tanggalPembagian,
    required bool sudahDibayar,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? diperbaruiPada,
  }) = _DividenModel;

  // ---------- SQLite ----------
  factory DividenModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating DividenModel from SQLite: ${map[NamaKolom.id]}');
    return DividenModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      idInvestasi: map[NamaKolom.idInvestasi] as String? ?? '',
      idInvestor: map[NamaKolom.idInvestor] as String? ?? '',
      jumlahDividen: (map[NamaKolom.jumlahDividen] as num?)?.toDouble() ?? 0.0,
      tanggalPembagian:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalPembagian]) ??
          DateTime.now(),
      sudahDibayar: ParserUtil.parseBool(map[NamaKolom.sudahDibayar]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idInvestasi: idInvestasi,
      NamaKolom.idInvestor: idInvestor,
      NamaKolom.jumlahDividen: jumlahDividen,
      NamaKolom.tanggalPembagian: tanggalPembagian.millisecondsSinceEpoch,
      NamaKolom.sudahDibayar: sudahDibayar ? 1 : 0,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  // ---------- Firebase ----------
  factory DividenModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating DividenModel from Firebase: $id');
    return DividenModel(
      id: id,
      idInvestasi: data[NamaKolom.idInvestasi] as String? ?? '',
      idInvestor: data[NamaKolom.idInvestor] as String? ?? '',
      jumlahDividen: (data[NamaKolom.jumlahDividen] as num?)?.toDouble() ?? 0.0,
      tanggalPembagian:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalPembagian]) ??
          DateTime.now(),
      sudahDibayar: ParserUtil.parseBool(data[NamaKolom.sudahDibayar]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.idInvestasi: idInvestasi,
      NamaKolom.idInvestor: idInvestor,
      NamaKolom.jumlahDividen: jumlahDividen,
      NamaKolom.tanggalPembagian: Timestamp.fromDate(tanggalPembagian),
      NamaKolom.sudahDibayar: sudahDibayar,
      NamaKolom.dihapus: diHapus,
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        diperbaruiPada ?? DateTime.now(),
      ),
    };
  }
}
```

### File: `lib/fitur/investasi/model/investasi_model.dart`
```dart
// path: lib/fitur/investasi/model/investasi_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'investasi_model.freezed.dart';

@freezed
abstract class InvestasiModel with _$InvestasiModel implements HasId {
  const InvestasiModel._();
  const factory InvestasiModel({
    required String id,
    required String idInvestor, // ID pelanggan dengan role investor
    required String idTransaksi, // ID transaksi terkait
    required double jumlahModal, // Jumlah modal yang ditanamkan (Rupiah)
    required int jumlahLembar, // Jumlah lembar/saham yang dibeli
    DateTime? tanggalInvestasi,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? diperbaruiPada,
  }) = _InvestasiModel;

  // ---------- SQLite ----------
  factory InvestasiModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating InvestasiModel from SQLite: ${map[NamaKolom.id]}');
    return InvestasiModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      idInvestor: map[NamaKolom.idInvestor] as String? ?? '',
      idTransaksi: map[NamaKolom.idTransaksi] as String? ?? '',
      jumlahModal: (map[NamaKolom.jumlahModal] as num?)?.toDouble() ?? 0.0,
      jumlahLembar: (map[NamaKolom.jumlahLembar] as int?) ?? 0,
      tanggalInvestasi: ParserUtil.parseDateTime(
        map[NamaKolom.tanggalInvestasi],
      ),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idInvestor: idInvestor,
      NamaKolom.idTransaksi: idTransaksi,
      NamaKolom.jumlahModal: jumlahModal,
      NamaKolom.jumlahLembar: jumlahLembar,
      NamaKolom.tanggalInvestasi: tanggalInvestasi?.millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  // ---------- Firebase ----------
  factory InvestasiModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating InvestasiModel from Firebase: $id');
    return InvestasiModel(
      id: id,
      idInvestor: data[NamaKolom.idInvestor] as String? ?? '',
      idTransaksi: data[NamaKolom.idTransaksi] as String? ?? '',
      jumlahModal: (data[NamaKolom.jumlahModal] as num?)?.toDouble() ?? 0.0,
      jumlahLembar: (data[NamaKolom.jumlahLembar] as int?) ?? 0,
      tanggalInvestasi: ParserUtil.parseDateTime(
        data[NamaKolom.tanggalInvestasi],
      ),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.idInvestor: idInvestor,
      NamaKolom.idTransaksi: idTransaksi,
      NamaKolom.jumlahModal: jumlahModal,
      NamaKolom.jumlahLembar: jumlahLembar,
      NamaKolom.tanggalInvestasi: Timestamp.fromDate(
        tanggalInvestasi ?? DateTime.now(),
      ),
      NamaKolom.dihapus: diHapus,
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        diperbaruiPada ?? DateTime.now(),
      ),
    };
  }
}
```

### File: `lib/fitur/investasi/operasi/investasi_op_firebase.dart`
```dart
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
```

### File: `lib/fitur/investasi/operasi/investasi_op_global.dart`
```dart
// path: lib/fitur/investasi/operasi/investasi_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_firebase.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

/// Kelas global untuk operasi investasi dan dividen.
/// Menentukan apakah menggunakan SQLite (admin) atau Firebase (user) berdasarkan role.
class InvestasiOpGlobal {
  final Ref ref;

  InvestasiOpGlobal({required this.ref});

  InvestasiOpSqlite get _investasiOpSqlite =>
      ref.read(investasiOpSqliteProvider);
  InvestasiOpFirebase get _investasiOpFirebase =>
      ref.read(investasiOpFirebaseProvider);

  // ============================================================
  // INVESTASI
  // ============================================================

  /// Menambahkan investasi baru.
  Future<void> tambahInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin menambah investasi ke SQLite: ${investasi.id}',
      );
      await _investasiOpSqlite.tambahInvestasi(
        investasi,
        dariServer: dariServer,
      );
    } else {
      Log.info(
        '[InvestasiOpGlobal] User menambah investasi ke Firebase: ${investasi.id}',
      );
      await _investasiOpFirebase.tambahInvestasi(investasi);
    }
  }

  /// Mengambil semua investasi.
  Future<List<InvestasiModel>> ambilSemuaInvestasi({
    bool tampilkanYangDiarsip = false,
  }) async {
    if (ref.isAdmin) {
      Log.info('[InvestasiOpGlobal] Admin mengambil investasi dari SQLite');
      return await _investasiOpSqlite.ambilSemuaInvestasi(
        tampilkanYangDiarsip: tampilkanYangDiarsip,
      );
    } else {
      Log.info('[InvestasiOpGlobal] User mengambil investasi dari Firebase');
      return await _investasiOpFirebase.ambilSemuaInvestasi(
        tampilkanYangDiarsip: tampilkanYangDiarsip,
      );
    }
  }

  /// Mengambil investasi berdasarkan ID.
  Future<InvestasiModel?> ambilInvestasiById(String id) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil investasi ID: $id dari SQLite',
      );
      return await _investasiOpSqlite.ambilInvestasiById(id);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil investasi ID: $id dari Firebase',
      );
      return await _investasiOpFirebase.ambilInvestasiById(id);
    }
  }

  /// Mengambil investasi berdasarkan ID investor.
  Future<List<InvestasiModel>> ambilInvestasiByIdInvestor(
    String idInvestor,
  ) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil investasi untuk investor ID: $idInvestor dari SQLite',
      );
      return await _investasiOpSqlite.ambilInvestasiByIdInvestor(idInvestor);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil investasi untuk investor ID: $idInvestor dari Firebase',
      );
      return await _investasiOpFirebase.ambilInvestasiByIdInvestor(idInvestor);
    }
  }

  /// Memperbarui investasi.
  Future<void> perbaruiInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin memperbarui investasi di SQLite: ${investasi.id}',
      );
      await _investasiOpSqlite.perbaruiInvestasi(
        investasi,
        dariServer: dariServer,
      );
    } else {
      Log.info(
        '[InvestasiOpGlobal] User memperbarui investasi di Firebase: ${investasi.id}',
      );
      await _investasiOpFirebase.perbaruiInvestasi(investasi);
    }
  }

  /// Soft delete investasi.
  Future<void> softDeleteInvestasi(String id, {bool dariServer = false}) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin soft delete investasi di SQLite: $id',
      );
      await _investasiOpSqlite.softDeleteInvestasi(id, dariServer: dariServer);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User soft delete investasi di Firebase: $id',
      );
      await _investasiOpFirebase.softDeleteInvestasi(id);
    }
  }

  // ============================================================
  // DIVIDEN
  // ============================================================

  /// Menambahkan dividen baru.
  Future<void> tambahDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin menambah dividen ke SQLite: ${dividen.id}',
      );
      await _investasiOpSqlite.tambahDividen(dividen, dariServer: dariServer);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User menambah dividen ke Firebase: ${dividen.id}',
      );
      await _investasiOpFirebase.tambahDividen(dividen);
    }
  }

  /// Mengambil semua dividen.
  Future<List<DividenModel>> ambilSemuaDividen({
    bool tampilkanYangDiarsip = false,
  }) async {
    if (ref.isAdmin) {
      Log.info('[InvestasiOpGlobal] Admin mengambil dividen dari SQLite');
      return await _investasiOpSqlite.ambilSemuaDividen(
        tampilkanYangDiarsip: tampilkanYangDiarsip,
      );
    } else {
      Log.info('[InvestasiOpGlobal] User mengambil dividen dari Firebase');
      return await _investasiOpFirebase.ambilSemuaDividen(
        tampilkanYangDiarsip: tampilkanYangDiarsip,
      );
    }
  }

  /// Mengambil dividen berdasarkan ID.
  Future<DividenModel?> ambilDividenById(String id) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil dividen ID: $id dari SQLite',
      );
      return await _investasiOpSqlite.ambilDividenById(id);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil dividen ID: $id dari Firebase',
      );
      return await _investasiOpFirebase.ambilDividenById(id);
    }
  }

  /// Mengambil dividen berdasarkan ID investor.
  Future<List<DividenModel>> ambilDividenByIdInvestor(String idInvestor) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil dividen untuk investor ID: $idInvestor dari SQLite',
      );
      return await _investasiOpSqlite.ambilDividenByIdInvestor(idInvestor);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil dividen untuk investor ID: $idInvestor dari Firebase',
      );
      return await _investasiOpFirebase.ambilDividenByIdInvestor(idInvestor);
    }
  }

  /// Mengambil dividen berdasarkan ID investasi.
  Future<List<DividenModel>> ambilDividenByIdInvestasi(
    String idInvestasi,
  ) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin mengambil dividen untuk investasi ID: $idInvestasi dari SQLite',
      );
      return await _investasiOpSqlite.ambilDividenByIdInvestasi(idInvestasi);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User mengambil dividen untuk investasi ID: $idInvestasi dari Firebase',
      );
      return await _investasiOpFirebase.ambilDividenByIdInvestasi(idInvestasi);
    }
  }

  /// Memperbarui dividen.
  Future<void> perbaruiDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin memperbarui dividen di SQLite: ${dividen.id}',
      );
      await _investasiOpSqlite.perbaruiDividen(dividen, dariServer: dariServer);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User memperbarui dividen di Firebase: ${dividen.id}',
      );
      await _investasiOpFirebase.perbaruiDividen(dividen);
    }
  }

  /// Soft delete dividen.
  Future<void> softDeleteDividen(String id, {bool dariServer = false}) async {
    if (ref.isAdmin) {
      Log.info('[InvestasiOpGlobal] Admin soft delete dividen di SQLite: $id');
      await _investasiOpSqlite.softDeleteDividen(id, dariServer: dariServer);
    } else {
      Log.info('[InvestasiOpGlobal] User soft delete dividen di Firebase: $id');
      await _investasiOpFirebase.softDeleteDividen(id);
    }
  }

  /// Menandai dividen sebagai sudah dibayar.
  Future<void> tandaiDividenDibayar(
    String id, {
    bool dariServer = false,
  }) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin menandai dividen dibayar di SQLite: $id',
      );
      await _investasiOpSqlite.tandaiDividenDibayar(id, dariServer: dariServer);
    } else {
      Log.info(
        '[InvestasiOpGlobal] User menandai dividen dibayar di Firebase: $id',
      );
      await _investasiOpFirebase.tandaiDividenDibayar(id);
    }
  }

  /// Menyisipkan atau memperbarui banyak investasi sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatch(
    List<InvestasiModel> daftarInvestasi, {
    bool dariServer = false,
  }) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin batch investasi ke SQLite: ${daftarInvestasi.length} item',
      );
      await _investasiOpSqlite.sisipkanAtauPerbaruiBatch(
        daftarInvestasi,
        dariServer: dariServer,
      );
    } else {
      Log.info(
        '[InvestasiOpGlobal] User batch investasi ke Firebase: ${daftarInvestasi.length} item',
      );
      await _investasiOpFirebase.sisipkanAtauPerbaruiBatch(daftarInvestasi);
    }
  }

  /// Menyisipkan atau memperbarui banyak dividen sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatchDividen(
    List<DividenModel> daftarDividen, {
    bool dariServer = false,
  }) async {
    if (ref.isAdmin) {
      Log.info(
        '[InvestasiOpGlobal] Admin batch dividen ke SQLite: ${daftarDividen.length} item',
      );
      await _investasiOpSqlite.sisipkanAtauPerbaruiBatchDividen(
        daftarDividen,
        dariServer: dariServer,
      );
    } else {
      Log.info(
        '[InvestasiOpGlobal] User batch dividen ke Firebase: ${daftarDividen.length} item',
      );
      await _investasiOpFirebase.sisipkanAtauPerbaruiBatchDividen(
        daftarDividen,
      );
    }
  }
}

/// Provider global untuk InvestasiOpGlobal.
final investasiOpGlobalProvider = Provider<InvestasiOpGlobal>((ref) {
  return InvestasiOpGlobal(ref: ref);
});
```

### File: `lib/fitur/investasi/operasi/investasi_op_sqlite.dart`
```dart
// path: lib/fitur/investasi/operasi/investasi_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class InvestasiOpSqlite {
  final SqliteDatabase _sqliteDb;
  final BaseOpSqlite _baseOpSqlite;

  InvestasiOpSqlite({
    required SqliteDatabase sqliteDb,
    required BaseOpSqlite baseOpSqlite,
  }) : _sqliteDb = sqliteDb,
       _baseOpSqlite = baseOpSqlite {
    Log.info('InvestasiOpSqlite diinisialisasi.');
  }

  // ============================================================
  // OPERASI INVESTASI
  // ============================================================

  /// Menambahkan investasi baru
  Future<void> tambahInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    Log.info('Menambahkan investasi baru - ID: ${investasi.id}');
    try {
      final data = investasi.toSqlite();
      await _baseOpSqlite.sisipkan(
        NamaTabel.investasi,
        data,
        dariServer: dariServer,
      );
      Log.info('Investasi berhasil ditambahkan - ID: ${investasi.id}');
    } catch (e, s) {
      Log.error(
        'Gagal menambahkan investasi - ID: ${investasi.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil semua investasi
  Future<List<InvestasiModel>> ambilSemuaInvestasi({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua data investasi');
    try {
      final db = await _sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.investasi,
        where: query,
        orderBy: '${NamaKolom.tanggalInvestasi} DESC',
      );
      final hasil = maps.map(InvestasiModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} data investasi');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil data investasi', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil investasi berdasarkan ID
  Future<InvestasiModel?> ambilInvestasiById(String id) async {
    Log.info('Mengambil investasi berdasarkan ID: $id');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.investasi,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        Log.info('Investasi ditemukan - ID: $id');
        return InvestasiModel.fromSqlite(maps.first);
      }
      Log.info('Investasi tidak ditemukan - ID: $id');
      return null;
    } catch (e, s) {
      Log.error('Gagal mengambil investasi - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil investasi berdasarkan ID investor
  Future<List<InvestasiModel>> ambilInvestasiByIdInvestor(
    String idInvestor,
  ) async {
    Log.info('Mengambil investasi untuk investor - ID: $idInvestor');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.investasi,
        where: '${NamaKolom.idInvestor} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [idInvestor],
        orderBy: '${NamaKolom.tanggalInvestasi} DESC',
      );
      final hasil = maps.map(InvestasiModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} investasi untuk investor');
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil investasi untuk investor - ID: $idInvestor',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Memperbarui investasi
  Future<void> perbaruiInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui investasi - ID: ${investasi.id}');
    try {
      final data = investasi.toSqlite();
      await _baseOpSqlite.update(
        NamaTabel.investasi,
        data,
        investasi.id,
        dariServer: dariServer,
      );
      Log.info('Investasi berhasil diperbarui - ID: ${investasi.id}');
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui investasi - ID: ${investasi.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Soft delete investasi
  Future<void> softDeleteInvestasi(String id, {bool dariServer = false}) async {
    Log.info('Soft delete investasi - ID: $id');
    try {
      await _baseOpSqlite.softDelete(
        NamaTabel.investasi,
        id,
        dariServer: dariServer,
      );
      Log.info('Soft delete investasi berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete investasi - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  // ============================================================
  // OPERASI DIVIDEN
  // ============================================================

  /// Menambahkan dividen baru
  Future<void> tambahDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    Log.info('Menambahkan dividen baru - ID: ${dividen.id}');
    try {
      final data = dividen.toSqlite();
      await _baseOpSqlite.sisipkan(
        NamaTabel.dividen,
        data,
        dariServer: dariServer,
      );
      Log.info('Dividen berhasil ditambahkan - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error('Gagal menambahkan dividen - ID: ${dividen.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua dividen
  Future<List<DividenModel>> ambilSemuaDividen({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua data dividen');
    try {
      final db = await _sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.dividen,
        where: query,
        orderBy: '${NamaKolom.tanggalPembagian} DESC',
      );
      final hasil = maps.map(DividenModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} data dividen');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil data dividen', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID
  Future<DividenModel?> ambilDividenById(String id) async {
    Log.info('Mengambil dividen berdasarkan ID: $id');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.dividen,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        Log.info('Dividen ditemukan - ID: $id');
        return DividenModel.fromSqlite(maps.first);
      }
      Log.info('Dividen tidak ditemukan - ID: $id');
      return null;
    } catch (e, s) {
      Log.error('Gagal mengambil dividen - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID investor
  Future<List<DividenModel>> ambilDividenByIdInvestor(String idInvestor) async {
    Log.info('Mengambil dividen untuk investor - ID: $idInvestor');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.dividen,
        where: '${NamaKolom.idInvestor} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [idInvestor],
        orderBy: '${NamaKolom.tanggalPembagian} DESC',
      );
      final hasil = maps.map(DividenModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} dividen untuk investor');
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil dividen untuk investor - ID: $idInvestor',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID investasi
  Future<List<DividenModel>> ambilDividenByIdInvestasi(
    String idInvestasi,
  ) async {
    Log.info('Mengambil dividen untuk investasi - ID: $idInvestasi');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.dividen,
        where: '${NamaKolom.idInvestasi} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [idInvestasi],
        orderBy: '${NamaKolom.tanggalPembagian} DESC',
      );
      final hasil = maps.map(DividenModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} dividen untuk investasi');
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil dividen untuk investasi - ID: $idInvestasi',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Memperbarui dividen
  Future<void> perbaruiDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui dividen - ID: ${dividen.id}');
    try {
      final data = dividen.toSqlite();
      await _baseOpSqlite.update(
        NamaTabel.dividen,
        data,
        dividen.id,
        dariServer: dariServer,
      );
      Log.info('Dividen berhasil diperbarui - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error('Gagal memperbarui dividen - ID: ${dividen.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Soft delete dividen
  Future<void> softDeleteDividen(String id, {bool dariServer = false}) async {
    Log.info('Soft delete dividen - ID: $id');
    try {
      await _baseOpSqlite.softDelete(
        NamaTabel.dividen,
        id,
        dariServer: dariServer,
      );
      Log.info('Soft delete dividen berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete dividen - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menandai dividen sebagai sudah dibayar
  Future<void> tandaiDividenDibayar(
    String id, {
    bool dariServer = false,
  }) async {
    Log.info('Menandai dividen sudah dibayar - ID: $id');
    try {
      await _baseOpSqlite.update(
        NamaTabel.dividen,
        {
          NamaKolom.sudahDibayar: 1,
          NamaKolom.diperbaruiPada: DateTime.now().millisecondsSinceEpoch,
        },
        id,
        dariServer: dariServer,
      );
      Log.info('Dividen berhasil ditandai sudah dibayar - ID: $id');
    } catch (e, s) {
      Log.error('Gagal menandai dividen sudah dibayar - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui beberapa investasi sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatch(
    List<InvestasiModel> daftarInvestasi, {
    bool dariServer = false,
  }) async {
    if (daftarInvestasi.isEmpty) {
      Log.info('Daftar investasi kosong, batch dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${daftarInvestasi.length} investasi',
    );
    try {
      final data = daftarInvestasi
          .map(
            (item) => item.copyWith(diperbaruiPada: DateTime.now()).toSqlite(),
          )
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        NamaTabel.investasi,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch ${daftarInvestasi.length} investasi berhasil diproses');
    } catch (e, st) {
      Log.error('Gagal memproses batch investasi', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui beberapa dividen sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatchDividen(
    List<DividenModel> daftarDividen, {
    bool dariServer = false,
  }) async {
    if (daftarDividen.isEmpty) {
      Log.info('Daftar dividen kosong, batch dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${daftarDividen.length} dividen',
    );
    try {
      final data = daftarDividen
          .map(
            (item) => item.copyWith(diperbaruiPada: DateTime.now()).toSqlite(),
          )
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        NamaTabel.dividen,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch ${daftarDividen.length} dividen berhasil diproses');
    } catch (e, st) {
      Log.error('Gagal memproses batch dividen', e: e, s: st);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/investasi/page/daftar_investor.dart`
```dart
// path: lib/fitur/investasi/page/daftar_investor.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/investasi/page/detail_investor.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class DaftarInvestor extends ConsumerWidget {
  const DaftarInvestor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    final pelangganAsync = ref.watch(pelangganProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Investor')),
      body: investasiAsync.when(
        data: (investasi) {
          return pelangganAsync.when(
            data: (listPelanggan) {
              final daftarInvestor =
                  listPelanggan.ambilBerdasarkanRole(AppRole.investor)
                    ..sort((a, b) {
                      final lembarA = investasi.getTotalLembarInvestor(a.id);
                      final lembarB = investasi.getTotalLembarInvestor(b.id);
                      return lembarB.compareTo(lembarA);
                    });

              if (daftarInvestor.isEmpty) {
                return const Center(child: Text('Belum ada investor'));
              }

              return ListView.builder(
                itemCount: daftarInvestor.length,
                itemBuilder: (context, index) {
                  final investor = daftarInvestor[index];
                  final totalLembar = investasi.getTotalLembarInvestor(
                    investor.id,
                  );
                  final totalModal = investasi.getTotalModalInvestor(
                    investor.id,
                  );

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              DetailInvestor(idInvestor: investor.id),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            investor.nama.isNotEmpty ? investor.nama[0] : '?',
                          ),
                        ),
                        title: Text(
                          investor.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Total Modal: ${FormatUang.formatMataUang(totalModal)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$totalLembar',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              'Lembar',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(TIcons.error, size: 60, color: Colors.red),
                  gapH16,
                  Text('Error: $error', textAlign: TextAlign.center),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TIcons.error, size: 60, color: Colors.red),
              gapH16,
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
```

### File: `lib/fitur/investasi/page/detail_investor.dart`
```dart
// path: lib/fitur/investasi/page/detail_investor.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/page/form_saham.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class DetailInvestor extends ConsumerWidget {
  final String idInvestor;
  const DetailInvestor({super.key, required this.idInvestor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    final pelangganAsync = ref.watch(pelangganProvider);

    return investasiAsync.when(
      data: (investasi) {
        return pelangganAsync.when(
          data: (listPelanggan) {
            final investor = listPelanggan.ambilBerdasarkanId(idInvestor);
            if (investor == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Detail Investor')),
                body: const Center(child: Text('Investor tidak ditemukan')),
              );
            }
            final totalLembar = investasi.getTotalLembarInvestor(investor.id);
            final totalModal = investasi.getTotalModalInvestor(investor.id);
            final totalDividen = investasi.getTotalDividenDiterimaInvestor(
              investor.id,
            );
            final returnPersentase = totalModal > 0
                ? (totalDividen / totalModal) * 100
                : 0.0;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Detail Investor'),
                // Hapus actions (tombol tambah)
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profil Investor
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child: Text(
                                investor.nama.isNotEmpty
                                    ? investor.nama[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            gapH12,
                            Text(
                              investor.nama,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            gapH4,
                            Text(
                              investor.telepon,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            gapH4,
                            Text(
                              investor.alamat,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    gapH16,
                    // Ringkasan Investasi
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Investasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            gapH12,
                            _buildInfoRow(
                              'Total Modal',
                              FormatUang.formatMataUang(totalModal),
                              icon: TIcons.money,
                            ),
                            gapH8,
                            _buildInfoRow(
                              'Total Lembar',
                              totalLembar.toString(),
                              icon: TIcons.points,
                            ),
                            gapH8,
                            _buildInfoRow(
                              'Total Dividen',
                              FormatUang.formatMataUang(totalDividen),
                              icon: TIcons.success,
                              color: Colors.green,
                            ),
                            gapH8,
                            _buildInfoRow(
                              'Return (%)',
                              '${returnPersentase.toStringAsFixed(2)}%',
                              icon: TIcons.star,
                              color: returnPersentase >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                    gapH16,
                    // Daftar Investasi
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daftar Investasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            gapH12,
                            _buildDaftarInvestasi(
                              investasi.ambilInvestasiByIdInvestor(investor.id),
                              context,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Detail Investor')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(TIcons.error, size: 60, color: Colors.red),
                  gapH16,
                  Text('Error: $error', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Detail Investor')),
            body: const Center(child: CircularProgressIndicator()),
          ),
        );
      },
      error: (e, s) => Scaffold(
        appBar: AppBar(title: const Text('Detail Investor')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TIcons.error, size: 60, color: Colors.red),
              gapH16,
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detail Investor')),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, size: 20, color: Colors.grey.shade600),
            gapW8,
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDaftarInvestasi(
    List<InvestasiModel> daftarInvestasi,
    BuildContext context,
  ) {
    if (daftarInvestasi.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Belum ada investasi'),
        ),
      );
    }

    return Column(
      children: daftarInvestasi.map((investasi) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investasi.idTransaksi,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      investasi.tanggalInvestasi != null
                          ? FormatTanggal.formatDasar(
                              investasi.tanggalInvestasi!,
                            )
                          : '-',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    gapH4,
                    Row(
                      children: [
                        Text(
                          FormatUang.formatMataUang(investasi.jumlahModal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        gapW8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${investasi.jumlahLembar} lembar',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => FormSaham(
                        idInvestasi: investasi.id,
                        idInvestor: investasi.idInvestor,
                      ),
                    ),
                  );
                },
                icon: const Icon(TIcons.edit, size: 20, color: Colors.blue),
                tooltip: 'Edit Investasi',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
```

### File: `lib/fitur/investasi/page/form_saham.dart`
```dart
// path: lib/fitur/investasi/page/form_saham.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_angka.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';
import 'package:wifi/shared/widget/pemilih_tanggal_waktu_widget.dart';

class FormSaham extends ConsumerStatefulWidget {
  final String? idInvestasi;
  final String? idInvestor;
  const FormSaham({super.key, this.idInvestasi, this.idInvestor});

  @override
  ConsumerState<FormSaham> createState() => _FormSahamState();
}

class _FormSahamState extends ConsumerState<FormSaham> {
  final _formKey = GlobalKey<FormState>();
  final _idTransaksiController = TextEditingController();
  final _jumlahModalController = TextEditingController();
  final _jumlahLembarController = TextEditingController();
  final _idTransaksiFocusNode = FocusNode();
  final _jumlahModalFocusNode = FocusNode();
  final _jumlahLembarFocusNode = FocusNode();

  DateTime? _tanggalInvestasi;
  TimeOfDay? _waktuInvestasi;
  bool _menyimpan = false;
  bool get _modeEdit => widget.idInvestasi != null;

  @override
  void initState() {
    super.initState();
    _tanggalInvestasi = DateTime.now();
    _waktuInvestasi = TimeOfDay.fromDateTime(DateTime.now());

    if (_modeEdit) {
      final investasi = ref
          .read(investasiProvider)
          .value
          ?.ambilInvestasiById(widget.idInvestasi!);
      if (investasi != null) {
        _idTransaksiController.text = investasi.idTransaksi;
        _jumlahModalController.text = investasi.jumlahModal.toString();
        _jumlahLembarController.text = investasi.jumlahLembar.toString();
        _tanggalInvestasi = investasi.tanggalInvestasi ?? DateTime.now();
        _waktuInvestasi = investasi.tanggalInvestasi != null
            ? TimeOfDay.fromDateTime(investasi.tanggalInvestasi!)
            : TimeOfDay.fromDateTime(DateTime.now());
      }
    }
  }

  @override
  void dispose() {
    _idTransaksiController.dispose();
    _jumlahModalController.dispose();
    _jumlahLembarController.dispose();
    _idTransaksiFocusNode.dispose();
    _jumlahModalFocusNode.dispose();
    _jumlahLembarFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalInvestasi ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _tanggalInvestasi = picked);
    }
  }

  Future<void> _pilihWaktu() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _waktuInvestasi ?? TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _waktuInvestasi = picked);
    }
  }

  Future<void> _pilihTransaksi() async {
    final transaksiState = ref.read(transaksiOpProvider);
    if (!transaksiState.hasValue) {
      ToastUtil.warning(context, 'Data transaksi belum tersedia');
      return;
    }

    final daftarTransaksi = transaksiState.value!.transaksi;
    if (daftarTransaksi.isEmpty) {
      ToastUtil.warning(context, 'Belum ada transaksi');
      return;
    }

    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Transaksi'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: daftarTransaksi.length > 20
                  ? 20
                  : daftarTransaksi.length,
              itemBuilder: (context, index) {
                final transaksi = daftarTransaksi[index];
                return ListTile(
                  title: Text(
                    transaksi.deskripsi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'ID: ${transaksi.id}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    FormatUang.formatMataUang(transaksi.jumlah),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _idTransaksiController.text = transaksi.id;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simpan() async {
    if (_menyimpan) return;
    if (!_formKey.currentState!.validate()) return;

    final idInvestor = widget.idInvestor;
    if (idInvestor == null || idInvestor.isEmpty) {
      ToastUtil.error(context, 'ID Investor tidak ditemukan');
      return;
    }

    setState(() => _menyimpan = true);

    try {
      final tanggal = DateTime(
        _tanggalInvestasi!.year,
        _tanggalInvestasi!.month,
        _tanggalInvestasi!.day,
        _waktuInvestasi!.hour,
        _waktuInvestasi!.minute,
      );

      final investasi = InvestasiModel(
        id: _modeEdit ? widget.idInvestasi! : const Uuid().v4(),
        idInvestor: idInvestor,
        idTransaksi: _idTransaksiController.text.trim(),
        jumlahModal: double.parse(_jumlahModalController.text),
        jumlahLembar: int.parse(_jumlahLembarController.text),
        tanggalInvestasi: tanggal,
      );

      final notifier = ref.read(investasiProvider.notifier);
      if (_modeEdit) {
        await notifier.perbaruiInvestasi(investasi);
        if (mounted) {
          ToastUtil.success(context, 'Investasi berhasil diperbarui');
        }
      } else {
        await notifier.tambahInvestasi(investasi);
        if (mounted) {
          ToastUtil.success(context, 'Investasi berhasil ditambahkan');
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e, s) {
      Log.error('Gagal menyimpan investasi', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Investasi' : 'Tambah Investasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InputTeks(
                      controller: _idTransaksiController,
                      focusNode: _idTransaksiFocusNode,
                      nextFocusNode: _jumlahModalFocusNode,
                      label: 'ID Transaksi',
                      prefixIcon: TIcons.receiptLong,
                    ),
                  ),
                  IconButton(
                    onPressed: _pilihTransaksi,
                    icon: const Icon(TIcons.search),
                    tooltip: 'Pilih Transaksi',
                  ),
                ],
              ),
              gapH16,
              InputAngka(
                controller: _jumlahModalController,
                focusNode: _jumlahModalFocusNode,
                nextFocusNode: _jumlahLembarFocusNode,
                label: 'Jumlah Modal',
                prefixIcon: TIcons.money,
              ),
              gapH16,
              InputAngka(
                controller: _jumlahLembarController,
                focusNode: _jumlahLembarFocusNode,
                label: 'Jumlah Lembar',
                prefixIcon: TIcons.points,
                textInputAction: TextInputAction.done,
              ),
              gapH16,
              PemilihTanggalWaktuWidget(
                tanggalTerpilih: _tanggalInvestasi,
                waktuTerpilih: _waktuInvestasi,
                onPilihTanggal: _pilihTanggal,
                onPilihWaktu: _pilihWaktu,
                teksLabel: 'Tanggal Investasi',
              ),
              gapH24,
              ElevatedButton(
                onPressed: _menyimpan ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _menyimpan
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/investasi/page/portofolio.dart`
```dart
// path: lib/fitur/investasi/page/portofolio.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unggah_data.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/user/providers/user_provider.dart';

/// Halaman portofolio untuk investor.
class HalamanPortofolio extends ConsumerWidget {
  const HalamanPortofolio({super.key});

  Future<void> _unggahDataDummy(WidgetRef ref) async {
    try {
      await ref.read(layananUnggahDataProvider).unggahSemuaData();
    } on Exception catch (e, s) {
      Log.error('Error di unggahDataDummy: $e', e: e, s: s);
      // Error handling opsional
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInvestor = ref.isInvestor;
    if (!isInvestor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Portofolio')),
        body: const Center(
          child: Text('Anda tidak memiliki akses ke halaman ini.'),
        ),
      );
    }

    final userId = ref.watch(userIdProvider).value;
    Log.info('UserId saat ini: $userId');
    if (userId == null || userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Portofolio')),
        body: const Center(child: Text('Silakan login terlebih dahulu.')),
      );
    }

    // ============================================================
    // 1. AMBIL DATA DARI PROVIDER
    // ============================================================
    final investasiAsync = ref.watch(investasiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Portofolio Saya')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(investasiProvider.notifier).refresh();
        },
        child: investasiAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(TIcons.errorOutlined, size: 60, color: Colors.red),
                gapH16,
                const TeksIsiBesar(
                  'Gagal memuat data portofolio.',
                  warna: Colors.red,
                ),
                gapH8,
                TeksIsiSedang('Error: $err'),
                gapH16,
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(investasiProvider.notifier).refresh(),
                  icon: const Icon(TIcons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
          data: (state) {
            // ============================================================
            // 2. AMBIL DATA INVESTOR DARI STATE
            // ============================================================
            final daftarInvestasi = state.ambilInvestasiByIdInvestor(userId);
            final daftarDividen = state.ambilDividenByIdInvestor(userId);
            final lembarBeredar = state.getTotalLembarBeredar();
            final totalLembarUser = state.getTotalLembarInvestor(userId);
            final totalModal = daftarInvestasi.fold(
              0.0,
              (sum, i) => sum + i.jumlahModal,
            );
            final totalDividenDiterima = daftarDividen
                .where((d) => d.sudahDibayar)
                .fold(0.0, (sum, d) => sum + d.jumlahDividen);

            // ============================================================
            // 3. CEK APAKAH ADA DATA
            // ============================================================
            if (daftarInvestasi.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      TIcons.warningAmber,
                      size: 60,
                      color: Colors.orange,
                    ),
                    gapH16,
                    const TeksIsiBesar('Belum ada investasi.'),
                    const TeksIsiSedang(
                      'Mulai investasi sekarang untuk melihat portofolio.',
                    ),
                    if (kDebugMode) ...[
                      gapH16,
                      TextButton(
                        onPressed: () {
                          _unggahDataDummy(ref);
                        },
                        child: const Text('DaftarKandataDummy'),
                      ),
                    ],
                  ],
                ),
              );
            }

            // ============================================================
            // 4. TAMPILKAN UI
            // ============================================================
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Ringkasan
                  _buildKartuRingkasan(
                    namaInvestor:
                        'Investor', // Bisa diambil dari data pelanggan
                    totalModal: totalModal,
                    persentase: (totalLembarUser / lembarBeredar),
                    totalDividenDiterima: totalDividenDiterima,
                  ),
                  gapH24,
                  _buildDetailKepemilikan(
                    totalModal: totalModal,
                    persentase: (totalLembarUser / lembarBeredar),
                    totalDividenDiterima: totalDividenDiterima,
                    totalLembar: totalLembarUser.toString(),
                  ),
                  gapH24,

                  // Daftar Investasi
                  _buildDaftarInvestasi(daftarInvestasi),
                  gapH24,

                  // Riwayat Dividen
                  _buildRiwayatDividen(daftarDividen),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET KARTU RINGKASAN
  // ============================================================

  Widget _buildKartuRingkasan({
    required String namaInvestor,
    required double totalModal,
    required double persentase,
    required double totalDividenDiterima,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: TColors.primaryColor.withAlpha(25),
                  radius: 28,
                  child: const Icon(
                    TIcons.person,
                    size: 32,
                    color: TColors.primaryColor,
                  ),
                ),
                gapW16,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeksJudulSedang(namaInvestor, tebalFont: FontWeight.bold),
                    TeksIsiKecil(
                      'ID Investor: ${DateTime.now().millisecondsSinceEpoch}',
                    ),
                  ],
                ),
              ],
            ),
            gapH16,
            const Divider(),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksIsiKecil('Total Modal', warna: Colors.grey),
                      TeksJudulSedang(
                        FormatUang.formatMataUang(totalModal),
                        tebalFont: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const TeksIsiKecil('Persentase', warna: Colors.grey),
                      TeksJudulSedang(
                        '${(persentase * 100).toStringAsFixed(1)}%',
                        tebalFont: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH12,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksIsiKecil(
                        'Dividen Diterima',
                        warna: Colors.grey,
                      ),
                      TeksJudulSedang(
                        FormatUang.formatMataUang(totalDividenDiterima),
                        tebalFont: FontWeight.bold,
                        warna: Colors.green,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TeksIsiKecil('Dividen Berikutnya', warna: Colors.grey),
                      TeksJudulSedang(
                        'Belum ditentukan',
                        tebalFont: FontWeight.bold,
                        warna: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET DETAIL KEPEMILIKAN
  // ============================================================

  Widget _buildDetailKepemilikan({
    required double totalModal,
    required double persentase,
    required double totalDividenDiterima,
    required String totalLembar,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(TIcons.points, color: TColors.primaryColor),
                gapW8,
                TeksJudulKecil(
                  'Detail Kepemilikan',
                  tebalFont: FontWeight.bold,
                ),
              ],
            ),
            gapH16,
            _buildBarisDetail(
              'Modal Disetor',
              FormatUang.formatMataUang(totalModal),
            ),
            _buildBarisDetail(
              'Persentase',
              '${(persentase * 100).toStringAsFixed(1)}%',
            ),
            _buildBarisDetail('Total Lembar', totalLembar),

            _buildBarisDetail(
              'Total Dividen',
              FormatUang.formatMataUang(totalDividenDiterima),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET DAFTAR INVESTASI
  // ============================================================

  Widget _buildDaftarInvestasi(List<InvestasiModel> daftarInvestasi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(TIcons.money, color: TColors.primaryColor),
                gapW8,
                TeksJudulKecil('Daftar Investasi', tebalFont: FontWeight.bold),
              ],
            ),
            gapH16,
            if (daftarInvestasi.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: TeksIsiSedang(
                    'Belum ada investasi.',
                    warna: Colors.grey,
                  ),
                ),
              )
            else
              ...daftarInvestasi.map(_buildItemInvestasi),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInvestasi(InvestasiModel investasi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksIsiSedang(
                  'ID Transaksi: ${investasi.idTransaksi}',
                  tebalFont: FontWeight.w500,
                ),
                TeksIsiKecil(
                  'Tanggal: ${FormatTanggal.formatDasar(investasi.tanggalInvestasi ?? DateTime.now())}',
                  warna: Colors.grey,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TeksIsiSedang(
                FormatUang.formatMataUang(investasi.jumlahModal),
                tebalFont: FontWeight.bold,
                warna: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET RIWAYAT DIVIDEN
  // ============================================================

  Widget _buildRiwayatDividen(List<DividenModel> daftarDividen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(TIcons.history, color: TColors.primaryColor),
                gapW8,
                TeksJudulKecil('Riwayat Dividen', tebalFont: FontWeight.bold),
              ],
            ),
            gapH16,
            if (daftarDividen.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: TeksIsiSedang(
                    'Belum ada riwayat dividen.',
                    warna: Colors.grey,
                  ),
                ),
              )
            else
              ...daftarDividen.map(_buildItemDividen),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDividen(DividenModel dividen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: dividen.sudahDibayar ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksIsiSedang(
                  dividen.sudahDibayar ? 'Sudah Dibayar' : 'Belum Dibayar',
                  tebalFont: FontWeight.w500,
                  warna: dividen.sudahDibayar ? Colors.green : Colors.orange,
                ),
                TeksIsiKecil(
                  FormatTanggal.formatDasar(dividen.tanggalPembagian),
                  warna: Colors.grey,
                ),
              ],
            ),
          ),
          TeksIsiSedang(
            FormatUang.formatMataUang(dividen.jumlahDividen),
            tebalFont: FontWeight.bold,
            warna: dividen.sudahDibayar ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET HELPER
  // ============================================================

  Widget _buildBarisDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TeksIsiSedang(label, warna: Colors.grey.shade700),
          TeksIsiSedang(value, tebalFont: FontWeight.w500),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/investasi/page/ringkasan_saham.dart`
```dart
// path: lib/fitur/investasi/page/ringkasan_saham.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/investasi/page/daftar_investor.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class RingkasanSaham extends ConsumerWidget {
  const RingkasanSaham({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    final pelangganAsync = ref.watch(pelangganProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Saham')),
      body: investasiAsync.when(
        data: (investasi) {
          final totalLembar = investasi.getTotalLembarBeredar();
          final totalAset = investasi.getTotalAsetPerusahaan();
          final totalDividenDiterima = investasi.totalDividenDiterima;
          final totalDividenBelumDibayar = investasi.totalDividenBelumDibayar;
          final returnPersentase = totalAset > 0
              ? (totalDividenDiterima / totalAset) * 100
              : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Perusahaan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH16,
                        _buildInfoRow(
                          'Total Aset',
                          FormatUang.formatMataUang(totalAset),
                          icon: TIcons.money,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Total Lembar Saham',
                          totalLembar.toString(),
                          icon: TIcons.points,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Dividen Diterima',
                          FormatUang.formatMataUang(totalDividenDiterima),
                          icon: TIcons.success,
                          color: Colors.green,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Dividen Belum Dibayar',
                          FormatUang.formatMataUang(totalDividenBelumDibayar),
                          icon: TIcons.warning,
                          color: Colors.orange,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Return (%)',
                          '${returnPersentase.toStringAsFixed(2)}%',
                          icon: TIcons.star,
                          color: returnPersentase >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                gapH16,
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Distribusi Kepemilikan Saham',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH12,
                        pelangganAsync.when(
                          data: (listInvestor) => _buildPieChartKepemilikan(
                            investasi,
                            listInvestor.daftarPelanggan,
                          ),
                          error: (error, stackTrace) =>
                              const Text('Gagal memuat data investor'),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    ),
                  ),
                ),
                gapH16,
                _buildRingkasanTambahan(investasi),
                gapH16,
                _buildGrafikPertumbuhanAset(investasi),
                gapH16,
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistik Tambahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH12,
                        _buildInfoRow(
                          'Jumlah Investasi',
                          investasi.jumlahInvestasi.toString(),
                          icon: TIcons.listAlt,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Jumlah Dividen',
                          investasi.jumlahDividen.toString(),
                          icon: TIcons.history,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Rata-rata Modal per Investasi',
                          FormatUang.formatMataUang(
                            investasi.jumlahInvestasi > 0
                                ? totalAset / investasi.jumlahInvestasi
                                : 0,
                          ),
                          icon: TIcons.info,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const DaftarInvestor(),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: pelangganAsync.when(
                        data: (listInvestor) {
                          final daftarInvestor =
                              listInvestor.ambilBerdasarkanRole(
                                AppRole.investor,
                              )..sort((a, b) {
                                final lembarA = investasi
                                    .getTotalLembarInvestor(a.id);
                                final lembarB = investasi
                                    .getTotalLembarInvestor(b.id);
                                return lembarB.compareTo(
                                  lembarA,
                                ); // descending (terbanyak ke terkecil)
                              });
                          if (daftarInvestor.isEmpty) {
                            return const Center(
                              child: Text('Belum ada investor'),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daftar Investor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              gapH12,
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: daftarInvestor.length > 5
                                    ? 5
                                    : daftarInvestor.length,
                                itemBuilder: (context, index) {
                                  final investor = daftarInvestor[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(investor.nama),
                                        Text(
                                          investasi
                                              .getTotalLembarInvestor(
                                                investor.id,
                                              )
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                        error: (error, stackTrace) =>
                            Center(child: Text('Error: $error')),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TIcons.error, size: 60, color: Colors.red),
              gapH16,
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildRingkasanTambahan(InvestasiState investasi) {
    final totalLembar = investasi.getTotalLembarBeredar();
    final totalAset = investasi.getTotalAsetPerusahaan();
    final hargaPerLembar = totalLembar > 0 ? totalAset / totalLembar : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Tambahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            gapH12,
            // path: lib/fitur/investasi/page/ringkasan_saham.dart

            // Di dalam _buildRingkasanTambahan
            _buildInfoRow(
              'Harga per Lembar',
              FormatUang.formatMataUang(hargaPerLembar),
              icon: TIcons.money,
              color: Colors.blue, // Tambahkan warna
            ),
            _buildInfoRow(
              'Kapitalisasi Pasar',
              FormatUang.formatMataUang(totalAset),
              icon: TIcons.points,
              color: Colors.purple, // Tambahkan warna
            ),
          ],
        ),
      ),
    );
  }
  // path: lib/fitur/investasi/page/ringkasan_saham.dart

  // Tambahkan method ini untuk grafik pertumbuhan aset
  Widget _buildGrafikPertumbuhanAset(InvestasiState investasi) {
    // Ambil data investasi yang sudah ada
    final daftarInvestasi = investasi.daftarInvestasi;

    if (daftarInvestasi.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pertumbuhan Aset (6 Bulan Terakhir)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              gapH12,
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Belum ada data investasi untuk grafik.'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Kelompokkan investasi per bulan
    final asetPerBulan = <DateTime, double>{};
    for (final inv in daftarInvestasi) {
      final bulan = DateTime(
        inv.tanggalInvestasi!.year,
        inv.tanggalInvestasi!.month,
      );
      asetPerBulan[bulan] = (asetPerBulan[bulan] ?? 0) + inv.jumlahModal;
    }

    // Ambil 6 bulan terakhir
    final sortedKeys = asetPerBulan.keys.toList()..sort();
    final last6Months = sortedKeys.length > 6
        ? sortedKeys.sublist(sortedKeys.length - 6)
        : sortedKeys;

    if (last6Months.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = last6Months.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), asetPerBulan[entry.value]!);
    }).toList();

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = maxY * 0.8; // Tampilkan dari 80% dari nilai maks

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pertumbuhan Aset (6 Bulan Terakhir)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            gapH12,
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY * 1.05,
                  gridData: const FlGridData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          Colors.blueGrey.withAlpha(200),
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          return LineTooltipItem(
                            FormatUang.formatMataUang(touchedSpot.y),
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < last6Months.length) {
                            return Text(
                              '${last6Months[index].month}/${last6Months[index].year.toString().substring(2)}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            (value / 1000000).toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 35,
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withAlpha(50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // Tambahkan method ini di dalam class RingkasanSaham

  Widget _buildPieChartLegend(List<({String nama, int lembar})> dataInvestor) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: dataInvestor.map((item) {
        final index = dataInvestor.indexOf(item);
        final color = Colors.primaries[index % Colors.primaries.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            gapW4,
            Text(
              '${item.nama} (${item.lembar} lembar)',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPieChartKepemilikan(
    InvestasiState investasi,
    List<PelangganModel> daftarInvestor,
  ) {
    final totalLembar = investasi.getTotalLembarBeredar();
    if (totalLembar == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Belum ada data kepemilikan saham.')),
      );
    }

    final dataInvestor = daftarInvestor
        .where(
          (p) =>
              p.role == AppRole.investor &&
              investasi.getTotalLembarInvestor(p.id) > 0,
        )
        .map(
          (p) => (nama: p.nama, lembar: investasi.getTotalLembarInvestor(p.id)),
        )
        .toList();

    final totalLembarValid = dataInvestor.fold<int>(
      0,
      (sum, item) => sum + item.lembar,
    );

    if (totalLembarValid == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Belum ada investor yang memiliki saham.')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: PieChart(
            PieChartData(
              sections: dataInvestor.map((item) {
                final persentase = (item.lembar / totalLembarValid) * 100;
                return PieChartSectionData(
                  title: '${persentase.toStringAsFixed(1)}%',
                  value: item.lembar.toDouble(),
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color:
                      Colors.primaries[dataInvestor.indexOf(item) %
                          Colors.primaries.length],
                  radius: 80,
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        gapH12,
        _buildPieChartLegend(dataInvestor),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (icon != null)
                Icon(icon, size: 20, color: Colors.grey.shade600),
              gapW8,
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
```

### File: `lib/fitur/investasi/provider/investasi_provider.dart`
```dart
// path: lib/fitur/investasi/provider/investasi_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'investasi_provider.freezed.dart';
part 'investasi_provider.g.dart';

@freezed
abstract class InvestasiState with _$InvestasiState {
  const InvestasiState._();
  const factory InvestasiState({
    @Default([]) List<InvestasiModel> daftarInvestasi,
    @Default([]) List<DividenModel> daftarDividen,
    @Default(0) int jumlahInvestasi,
    @Default(0) int jumlahDividen,
    @Default(0.0) double totalModal,
    @Default(0.0) double totalDividenDiterima,
    @Default(0.0) double totalDividenBelumDibayar,
  }) = _InvestasiState;

  InvestasiModel? ambilInvestasiById(String id) {
    try {
      return daftarInvestasi.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  List<InvestasiModel> ambilInvestasiByIdInvestor(String idInvestor) {
    return daftarInvestasi.where((i) => i.idInvestor == idInvestor).toList();
  }

  List<DividenModel> ambilDividenByIdInvestor(String idInvestor) {
    return daftarDividen.where((d) => d.idInvestor == idInvestor).toList();
  }

  List<DividenModel> ambilDividenByIdInvestasi(String idInvestasi) {
    return daftarDividen.where((d) => d.idInvestasi == idInvestasi).toList();
  }

  double getTotalModalInvestor(String idInvestor) {
    return daftarInvestasi
        .where((i) => i.idInvestor == idInvestor)
        .fold(0.0, (sum, i) => sum + i.jumlahModal);
  }

  double getTotalDividenDiterimaInvestor(String idInvestor) {
    return daftarDividen
        .where((d) => d.idInvestor == idInvestor && d.sudahDibayar)
        .fold(0.0, (sum, d) => sum + d.jumlahDividen);
  }

  double getTotalDividenBelumDibayarInvestor(String idInvestor) {
    return daftarDividen
        .where((d) => d.idInvestor == idInvestor && !d.sudahDibayar)
        .fold(0.0, (sum, d) => sum + d.jumlahDividen);
  }

  int getTotalLembarInvestor(String idInvestor) {
    return daftarInvestasi
        .where((i) => i.idInvestor == idInvestor)
        .fold(0, (sum, i) => sum + i.jumlahLembar);
  }

  int getTotalLembarBeredar() {
    return daftarInvestasi.fold(0, (sum, i) => sum + i.jumlahLembar);
  }

  double getTotalAsetPerusahaan() {
    return daftarInvestasi.fold(0.0, (sum, i) => sum + i.jumlahModal);
  }
}

@riverpod
class InvestasiNotifier extends _$InvestasiNotifier {
  late InvestasiOpGlobal _investasiOp;

  @override
  FutureOr<InvestasiState> build() {
    _investasiOp = ref.read(investasiOpGlobalProvider);
    return _loadData();
  }

  Future<InvestasiState> _loadData() async {
    Log.info('Memuat data investasi dan dividen');
    try {
      final results = await Future.wait([
        _investasiOp.ambilSemuaInvestasi(),
        _investasiOp.ambilSemuaDividen(),
      ]);

      final daftarInvestasi = results[0] as List<InvestasiModel>;
      final daftarDividen = results[1] as List<DividenModel>;

      final totalModal = daftarInvestasi.fold(
        0.0,
        (sum, i) => sum + i.jumlahModal,
      );
      final totalDividenDiterima = daftarDividen
          .where((d) => d.sudahDibayar)
          .fold(0.0, (sum, d) => sum + d.jumlahDividen);
      final totalDividenBelumDibayar = daftarDividen
          .where((d) => !d.sudahDibayar)
          .fold(0.0, (sum, d) => sum + d.jumlahDividen);

      return InvestasiState(
        daftarInvestasi: daftarInvestasi,
        daftarDividen: daftarDividen,
        jumlahInvestasi: daftarInvestasi.length,
        jumlahDividen: daftarDividen.length,
        totalModal: totalModal,
        totalDividenDiterima: totalDividenDiterima,
        totalDividenBelumDibayar: totalDividenBelumDibayar,
      );
    } catch (e, s) {
      Log.error('Gagal memuat data investasi', e: e, s: s);
      rethrow;
    }
  }

  Future<void> refresh() async {
    Log.info('Menyegarkan data investasi');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _loadData();
    });
  }

  Future<void> tambahInvestasi(InvestasiModel investasi) async {
    if (!state.hasValue) return;
    Log.info('Menambahkan investasi baru - ID: ${investasi.id}');

    try {
      await _investasiOp.tambahInvestasi(investasi);
      final currentData = state.requireValue;
      final updatedList = [...currentData.daftarInvestasi, investasi];
      state = AsyncData(
        currentData.copyWith(
          daftarInvestasi: updatedList,
          jumlahInvestasi: updatedList.length,
          totalModal: updatedList.fold(0.0, (sum, i) => sum + i.jumlahModal),
        ),
      );
      Log.info('Investasi berhasil ditambahkan - ID: ${investasi.id}');
    } catch (e, s) {
      Log.error('Gagal menambahkan investasi', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbaruiInvestasi(InvestasiModel investasi) async {
    if (!state.hasValue) return;
    Log.info('Memperbarui investasi - ID: ${investasi.id}');

    try {
      await _investasiOp.perbaruiInvestasi(investasi);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarInvestasi.map((i) {
        return i.id == investasi.id ? investasi : i;
      }).toList();

      state = AsyncData(
        currentData.copyWith(
          daftarInvestasi: updatedList,
          totalModal: updatedList.fold(0.0, (sum, i) => sum + i.jumlahModal),
        ),
      );
      Log.info('Investasi berhasil diperbarui - ID: ${investasi.id}');
    } catch (e, s) {
      Log.error('Gagal memperbarui investasi', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteInvestasi(String id) async {
    if (!state.hasValue) return;
    Log.info('Soft delete investasi - ID: $id');

    try {
      await _investasiOp.softDeleteInvestasi(id);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarInvestasi
          .where((i) => i.id != id)
          .toList();

      state = AsyncData(
        currentData.copyWith(
          daftarInvestasi: updatedList,
          jumlahInvestasi: updatedList.length,
          totalModal: updatedList.fold(0.0, (sum, i) => sum + i.jumlahModal),
        ),
      );
      Log.info('Soft delete investasi berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete investasi', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tambahDividen(DividenModel dividen) async {
    if (!state.hasValue) return;
    Log.info('Menambahkan dividen baru - ID: ${dividen.id}');

    try {
      await _investasiOp.tambahDividen(dividen);
      final currentData = state.requireValue;
      final updatedList = [...currentData.daftarDividen, dividen];

      state = AsyncData(
        currentData.copyWith(
          daftarDividen: updatedList,
          jumlahDividen: updatedList.length,
          totalDividenDiterima: updatedList
              .where((d) => d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
          totalDividenBelumDibayar: updatedList
              .where((d) => !d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
        ),
      );
      Log.info('Dividen berhasil ditambahkan - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error('Gagal menambahkan dividen', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbaruiDividen(DividenModel dividen) async {
    if (!state.hasValue) return;
    Log.info('Memperbarui dividen - ID: ${dividen.id}');

    try {
      await _investasiOp.perbaruiDividen(dividen);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarDividen.map((d) {
        return d.id == dividen.id ? dividen : d;
      }).toList();

      state = AsyncData(
        currentData.copyWith(
          daftarDividen: updatedList,
          totalDividenDiterima: updatedList
              .where((d) => d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
          totalDividenBelumDibayar: updatedList
              .where((d) => !d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
        ),
      );
      Log.info('Dividen berhasil diperbarui - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error('Gagal memperbarui dividen', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteDividen(String id) async {
    if (!state.hasValue) return;
    Log.info('Soft delete dividen - ID: $id');

    try {
      await _investasiOp.softDeleteDividen(id);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarDividen
          .where((d) => d.id != id)
          .toList();

      state = AsyncData(
        currentData.copyWith(
          daftarDividen: updatedList,
          jumlahDividen: updatedList.length,
          totalDividenDiterima: updatedList
              .where((d) => d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
          totalDividenBelumDibayar: updatedList
              .where((d) => !d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
        ),
      );
      Log.info('Soft delete dividen berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete dividen', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tandaiDividenDibayar(String id) async {
    if (!state.hasValue) return;
    Log.info('Menandai dividen sudah dibayar - ID: $id');

    try {
      await _investasiOp.tandaiDividenDibayar(id);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarDividen.map((d) {
        if (d.id == id) {
          return d.copyWith(sudahDibayar: true);
        }
        return d;
      }).toList();

      state = AsyncData(
        currentData.copyWith(
          daftarDividen: updatedList,
          totalDividenDiterima: updatedList
              .where((d) => d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
          totalDividenBelumDibayar: updatedList
              .where((d) => !d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
        ),
      );
      Log.info('Dividen berhasil ditandai sudah dibayar - ID: $id');
    } catch (e, s) {
      Log.error('Gagal menandai dividen sudah dibayar', e: e, s: s);
      rethrow;
    }
  }

  void invalidate() {
    ref.invalidateSelf();
  }
}

@riverpod
Future<({List<InvestasiModel> investasi, List<DividenModel> dividen})>
detailInvestorInvestasi(Ref ref, String idInvestor) async {
  final state = await ref.watch(investasiProvider.future);
  return (
    investasi: state.ambilInvestasiByIdInvestor(idInvestor),
    dividen: state.ambilDividenByIdInvestor(idInvestor),
  );
}

@riverpod
Future<double> totalModalInvestor(Ref ref, String idInvestor) async {
  final state = await ref.watch(investasiProvider.future);
  return state.getTotalModalInvestor(idInvestor);
}

@riverpod
Future<double> totalDividenInvestor(Ref ref, String idInvestor) async {
  final state = await ref.watch(investasiProvider.future);
  return state.getTotalDividenDiterimaInvestor(idInvestor);
}
```

