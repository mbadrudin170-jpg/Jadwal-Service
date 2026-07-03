# Dokumentasi Fitur: feedback

## Daftar file

- [lib/fitur/feedback/model/feedback_model.dart](../../lib/fitur/feedback/model/feedback_model.dart)
- [lib/fitur/feedback/operasi/feedback_op_firebase.dart](../../lib/fitur/feedback/operasi/feedback_op_firebase.dart)
- [lib/fitur/feedback/operasi/feedback_op_global.dart](../../lib/fitur/feedback/operasi/feedback_op_global.dart)
- [lib/fitur/feedback/operasi/feedback_op_sqlite.dart](../../lib/fitur/feedback/operasi/feedback_op_sqlite.dart)
- [lib/fitur/feedback/page/feedback_detail.dart](../../lib/fitur/feedback/page/feedback_detail.dart)
- [lib/fitur/feedback/page/feedback_page.dart](../../lib/fitur/feedback/page/feedback_page.dart)
- [lib/fitur/feedback/page/form_feedback.dart](../../lib/fitur/feedback/page/form_feedback.dart)
- [lib/fitur/feedback/provider/feedback_provider.dart](../../lib/fitur/feedback/provider/feedback_provider.dart)

## Isi file

### File: `lib/fitur/feedback/model/feedback_model.dart`
```dart
// path: lib/fitur/feedback/model/feedback_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'feedback_model.freezed.dart';

@freezed
abstract class FeedbackModel with _$FeedbackModel implements HasId {
  const FeedbackModel._();

  const factory FeedbackModel({
    required String id,
    required String pesan,
    DateTime? tanggal,
    required String userId,
    DateTime? diperbaruiPada,
    @Default(false) bool dihapus,
    DateTime? diarsipkanPada,
  }) = _FeedbackModel;

  factory FeedbackModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating FeedbackModel from SQLite: ${map[NamaKolom.id]}');
    return FeedbackModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      pesan: map[NamaKolom.pesan] as String? ?? '',
      userId: map[NamaKolom.userId] as String? ?? '',
      tanggal: ParserUtil.parseDateTime(map[NamaKolom.tanggal]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      dihapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.pesan: pesan,
      NamaKolom.userId: userId,
      NamaKolom.tanggal: (tanggal ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: dihapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  factory FeedbackModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Creating FeedbackModel from Firebase: $id');
    return FeedbackModel(
      id: id,
      pesan: data[NamaKolom.pesan] as String? ?? '',
      userId: data[NamaKolom.userId] as String? ?? '',
      tanggal: ParserUtil.parseDateTime(data[NamaKolom.tanggal]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      dihapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.pesan: pesan,
      NamaKolom.userId: userId,
      NamaKolom.tanggal: tanggal != null
          ? Timestamp.fromDate(tanggal!.toUtc())
          : DateTime.now().toUtc(),
      NamaKolom.dihapus: dihapus,
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

### File: `lib/fitur/feedback/operasi/feedback_op_firebase.dart`
```dart
// path: lib/fitur/feedback/operasi/feedback_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class FeedbackOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOpFirebase;
  final String _namaKoleksi = NamaTabel.feedback;

  FeedbackOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOpFirebase,
  }) : _firestore = firestore,
       _baseOpFirebase = baseOpFirebase {
    Log.info('FeedbackOpFirebase diinisialisasi.');
  }

  CollectionReference get _koleksi => _firestore.collection(_namaKoleksi);

  Future<void> tambah(FeedbackModel feedback) async {
    Log.info('Mendelegasikan pembuatan feedback baru...');

    final data = feedback.toFirebase();
    data[NamaKolom.tanggal] = FieldValue.serverTimestamp();
    await _baseOpFirebase.tambah(_namaKoleksi, data);
  }

  Future<void> perbarui(FeedbackModel feedback) async {
    Log.info('Mendelegasikan pembaruan feedback: ${feedback.id}');

    final data = feedback.toFirebase();
    data.remove(NamaKolom.id);
    data.remove(NamaKolom.tanggal);
    await _baseOpFirebase.update(_namaKoleksi, feedback.id, data);
    Log.info('Berhasil memperbarui feedback ID: ${feedback.id}');
  }

  Future<void> delete(final String id) async {
    Log.warning('Mendelegasikan penghapusan permanen feedback: $id');
    await _baseOpFirebase.hapusPermanen(_namaKoleksi, id);
  }

  Future<void> softDelete(String id) async {
    Log.info('Mendelegasikan soft delete feedback: $id');
    await _baseOpFirebase.softDelete(_namaKoleksi, id);
  }

  Future<List<FeedbackModel>> ambilSemua() async {
    try {
      Log.info('Mengambil semua feedback aktif dari Firestore');
      final querySnapshot = await _koleksi
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();

      Log.info('Berhasil mengambil ${querySnapshot.docs.length} feedback');
      return querySnapshot.docs.map((doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } on FirebaseException catch (e, s) {
      Log.error('Gagal mengambil semua feedback dari Firestore', e: e, s: s);
      rethrow;
    } on Exception catch (e, s) {
      Log.error('Error umum saat mengambil semua feedback', e: e, s: s);
      rethrow;
    }
  }

  Future<FeedbackModel?> ambilBerdasarkanId(String id) async {
    try {
      Log.info('Mengambil feedback berdasarkan ID: $id');
      final doc = await _koleksi.doc(id).get();
      if (doc.exists) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }
      return null;
    } on FirebaseException catch (e, s) {
      Log.error('Gagal mengambil feedback berdasarkan ID: $id', e: e, s: s);
      rethrow;
    } on Exception catch (e, s) {
      Log.error(
        'Error umum saat mengambil feedback berdasarkan ID: $id',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  Future<List<FeedbackModel>> ambilBerdasarkanUser(String userId) async {
    try {
      Log.info('Memuat feedback untuk userId: $userId');

      final querySnapshot = await _koleksi
          .where(NamaKolom.userId, isEqualTo: userId)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal mengambil feedback berdasarkan userId: $userId',
        e: e,
        s: s,
      );
      rethrow;
    } on Exception catch (e, s) {
      Log.error(
        'Error umum saat mengambil feedback berdasarkan userId: $userId',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}
```

### File: `lib/fitur/feedback/operasi/feedback_op_global.dart`
```dart
// path lib/fitur/feedback/operasi/feedback_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_firebase.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

final feedbackOpGlobalProvider = Provider<FeedbackOpGlobal>((ref) {
  return FeedbackOpGlobal(ref: ref);
});

class FeedbackOpGlobal {
  final Ref ref;

  FeedbackOpGlobal({required this.ref});
  FeedbackOpSqlite get _feedbackOpSqlite => ref.read(feedbackOpSqliteProvider);
  FeedbackOpFirebase get _feedbackOpFirebase =>
      ref.read(feedbackOpFirebaseProvider);

  Future<void> tambah(FeedbackModel feedback) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _feedbackOpSqlite.tambah(feedback);
      } else {
        await _feedbackOpFirebase.tambah(feedback);
      }
      _invalidateTabelFeedback();
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(FeedbackModel feedback) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _feedbackOpSqlite.perbarui(feedback);
      } else {
        await _feedbackOpFirebase.perbarui(feedback);
      }
      _invalidateTabelFeedback();
    } on Exception catch (e, s) {
      Log.error('Error diperbarui: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDelete(String id) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _feedbackOpSqlite.softDelete(id);
      } else {
        await _feedbackOpFirebase.softDelete(id);
      }
      _invalidateTabelFeedback();
    } on Exception catch (e, s) {
      Log.error('Error di softDelete: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<FeedbackModel?> ambilBerdasarkanId(String id) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        return await _feedbackOpSqlite.ambilBerdasarkanId(id);
      } else {
        return await _feedbackOpFirebase.ambilBerdasarkanId(id);
      }
    } on Exception catch (e, s) {
      Log.error('Error di ambilBerdasarkanId: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<List<FeedbackModel>> ambilSemua(String userId) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        return await _feedbackOpSqlite.ambilSemua();
      } else {
        return await _feedbackOpFirebase.ambilBerdasarkanUser(userId);
      }
    } on Exception catch (e, s) {
      Log.error('Error di ambilSemua: $e', e: e, s: s);
      rethrow;
    }
  }

  void _invalidateTabelFeedback() {
    ref.read(feedbackProvider.notifier).invalidateTabelFeedback();
  }
}
```

### File: `lib/fitur/feedback/operasi/feedback_op_sqlite.dart`
```dart
// path: lib/fitur/feedback/operasi/feedback_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class FeedbackOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite baseOpSqlite;
  final String _namaTabel = NamaTabel.feedback;

  FeedbackOpSqlite({required this.sqliteDb, required this.baseOpSqlite});

  Future<void> tambah(
    final FeedbackModel feedback, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai createFeedback untuk data: ${feedback.toSqlite()}');
    try {
      final data = feedback
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();

      await baseOpSqlite.sisipkan(_namaTabel, data, dariServer: dariServer);
      Log.info('Berhasil membuat kritik_saran dengan ID: ${feedback.id}');
    } on Exception catch (e, st) {
      Log.error('Gagal saat createFeedback', e: e, s: st);
      rethrow;
    }
  }

  Future<void> perbarui(
    final FeedbackModel feedback, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai updateFeedback untuk ID: ${feedback.id}');
    try {
      final data = feedback
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();

      await baseOpSqlite.update(
        _namaTabel,
        data,
        feedback.id,
        dariServer: dariServer,
      );
      Log.info('Berhasil memperbarui feedback dengan ID: ${feedback.id}');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat updateFeedback untuk ID: ${feedback.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<List<FeedbackModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info(
      'Memulai getAllFeedback (mengambil semua, diurutkan berdasarkan tanggal terbaru).',
    );
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      final daftarFeedback = List.generate(
        maps.length,
        (i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${daftarFeedback.length} data kritik_saran.',
      );
      return daftarFeedback;
    } catch (e, st) {
      Log.error('Gagal saat getAllFeedback', e: e, s: st);
      rethrow;
    }
  }

  Future<FeedbackModel> ambilBerdasarkanId(final String id) async {
    Log.info('Memulai getFeedbackById untuk ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final data = FeedbackModel.fromSqlite(maps.first);
        Log.info(
          'Kritik & saran dengan ID: $id ditemukan. Data: ${data.toSqlite()}',
        );
        return data;
      } else {
        Log.error('Kritik & saran dengan ID $id tidak ditemukan.');
        throw Exception('ID $id tidak ditemukan');
      }
    } catch (e, st) {
      Log.error('Gagal saat getFeedbackById untuk ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<int> ambilTotalFeedback() async {
    Log.info('Mulai mengambil jumlah feedback baru.');
    try {
      final daftarFeedback = await ambilSemua();
      final jumlah = daftarFeedback.length;
      Log.info('Jumlah feedback baru yang dihitung: $jumlah');
      return jumlah;
    } catch (e, st) {
      Log.error('Gagal mengambil jumlah feedback baru.', e: e, s: st);
      rethrow;
    }
  }

  Future<List<FeedbackModel>> ambilPerubahan(
    DateTime sinkronisasiTerakhir,
  ) async {
    Log.info(
      'Memulai getChanges kritik_saran sejak: ${sinkronisasiTerakhir.toIso8601String()}',
    );
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.diperbaruiPada} > ?',
        whereArgs: [sinkronisasiTerakhir.millisecondsSinceEpoch],
      );
      final daftarFeedback = List.generate(
        maps.length,
        (i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Ditemukan ${daftarFeedback.length} perubahan kritik_saran sejak ${sinkronisasiTerakhir.toIso8601String()}',
      );
      return daftarFeedback;
    } catch (e, st) {
      Log.error('Gagal saat getChanges kritik_saran', e: e, s: st);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<FeedbackModel> daftarFeedback, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai insertOrUpdateBatch untuk ${daftarFeedback.length} item kritik_saran.',
    );
    if (daftarFeedback.isEmpty) {
      Log.warning(
        'List item untuk batch kosong, tidak ada operasi yang dilakukan.',
      );
      return;
    }
    try {
      final data = daftarFeedback
          .map(
            (final item) => item
                .copyWith(diperbaruiPada: DateTime.now().toUtc())
                .toSqlite(),
          )
          .toList();
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan insertOrUpdateBatch untuk ${daftarFeedback.length} item.',
      );
    } catch (e, st) {
      Log.error('Gagal saat insertOrUpdateBatch kritik_saran', e: e, s: st);
      rethrow;
    }
  }

  Future<void> hapus(final String id, {final bool fromServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai deleteFeedback (hard delete) untuk ID: $id',
    );
    try {
      await baseOpSqlite.delete(_namaTabel, id, dariServer: fromServer);
      Log.info('Berhasil menghapus permanen kritik_saran dengan ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat deleteFeedback untuk ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk feedback ID: $id');
    try {
      await baseOpSqlite.softDelete(_namaTabel, id, dariServer: fromServer);
      Log.info('Berhasil soft delete feedback ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat soft delete feedback ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAll({final bool fromServer = false}) async {
    Log.info('Memulai soft delete untuk semua feedback');
    try {
      final count = await baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua feedback. Total: $count item.');
      return count;
    } catch (e, st) {
      Log.error('Gagal saat soft delete semua feedback', e: e, s: st);
      rethrow;
    }
  }

  Future<void> deleteAll({final bool dariServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai deleteAllFeedback. Ini adalah operasi destruktif.',
    );
    try {
      await baseOpSqlite.operasiKompleks<int>((txn) async {
        final count = await txn.delete(_namaTabel);
        Log.info(
          'Berhasil deleteAllFeedback. Total baris yang dihapus: $count',
        );
        return count;
      }, dariServer: dariServer);
    } catch (e, st) {
      Log.error('Gagal saat deleteAllFeedback', e: e, s: st);
      rethrow;
    }
  }

  Future<List<FeedbackModel>> ambilBerdasarkanIds(List<String> ids) async {
    Log.info('Memulai getFeedbackByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
        'List ID untuk getFeedbackByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: 'id IN (${List.filled(ids.length, '?').join(',')})',
        whereArgs: ids,
      );
      final daftarFeedback = List.generate(
        maps.length,
        (i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${daftarFeedback.length} data kritik_saran dari ${ids.length} ID yang diminta.',
      );
      return daftarFeedback;
    } catch (e, st) {
      Log.error('Gagal saat getFeedbackByIds', e: e, s: st);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/feedback/page/feedback_detail.dart`
```dart
// path lib/fitur/feedback/page/feedback_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_global.dart';
import 'package:wifi/fitur/feedback/page/form_feedback.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';

class FeedbackDetail extends ConsumerStatefulWidget {
  final String id;

  const FeedbackDetail({super.key, required this.id});

  @override
  ConsumerState<FeedbackDetail> createState() => _FeedbackDetailState();
}

class _FeedbackDetailState extends ConsumerState<FeedbackDetail> {
  FeedbackOpGlobal get _feedbackOpGlobal => ref.read(feedbackOpGlobalProvider);
  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman detail feedback dengan ID: ${widget.id}');
    // ✅ Hapus _loadData() karena tidak berguna
  }

  Future<void> _softDeletedFeedback() async {
    Log.info('Menampilkan dialog konfirmasi penghapusan feedback.');

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Log.warning('Pengguna membatalkan penghapusan.');
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Log.info('Pengguna mengonfirmasi penghapusan.');
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if ((konfirmasi ?? false) && mounted) {
      try {
        unawaited(
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Menghapus feedback...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await _feedbackOpGlobal.softDelete(widget.id);
        if (mounted) {
          Navigator.pop(context); // Tutup loading dialog
          ToastUtil.success(context, 'Feedback berhasil dihapus');
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        }
      } catch (e, st) {
        Log.error('Gagal menghapus feedback', e: e, s: st);
        if (mounted) {
          Navigator.pop(context); // Tutup loading dialog
          ToastUtil.error(context, 'Gagal menghapus: $e');
        }
      }
    }
  }

  void _navigasiKeDetail(FeedbackModel feedback) {
    try {
      unawaited(
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => FormFeedback(feedback: feedback),
          ),
        ),
      );
    } on Exception catch (e, s) {
      Log.error('Error di navigasiKeDetail: $e', e: e, s: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman detail feedback.');
    final detailFeedbackAsync = ref.watch(detailFeedbackProvider(widget.id));
    return detailFeedbackAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        Log.error('Gagal memuat detail feedback', e: e, s: s);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Gagal memuat data: $e', textAlign: TextAlign.center),
          ),
        );
      },
      data: (feedback) {
        if (feedback == null) {
          return const Center(child: Text('Tidak ada feedback ditemukan'));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Feedback'),
            actions: [
              IconButton(
                onPressed: () => _navigasiKeDetail(feedback),
                icon: const Icon(TIcons.edit),
                tooltip: 'Edit',
              ),
              // ✅ Perbaiki akses isAdmin
              IconButton(
                icon: const Icon(TIcons.delete),
                onPressed: _softDeletedFeedback,
                tooltip: 'Hapus Feedback',
              ),
            ],
          ),
          body: _buildContent(context, feedback),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FeedbackModel feedback) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_pin,
                    color: Theme.of(context).colorScheme.primary,
                    size: TSizes.p12,
                  ),
                  gapH12,
                  Expanded(
                    child: NamaPelangganWidget(
                      idPelanggan: feedback.userId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              gapH12,
              const Text(
                'Pesan:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              gapH8,
              Text(
                feedback.pesan,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const Divider(height: 40),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  feedback.tanggal != null
                      ? FormatWaktuLengkap.formatSingkat(feedback.tanggal!)
                      : 'Tanggal tidak tersedia',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/feedback/page/feedback_page.dart`
```dart
// path lib/fitur/feedback/page/feedback_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_global.dart';
import 'package:wifi/fitur/feedback/page/feedback_detail.dart';
import 'package:wifi/fitur/feedback/page/form_feedback.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart'; // Import provider baru Anda
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  List<FeedbackModel> _hasilFilter = [];
  Map<String, String> _mapNamaUser = {};
  bool _mencari = false;
  final TextEditingController _mencariController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Kritik & Saran');
    _mencariController.addListener(_syncFilterOnly);
    unawaited(_loadPelangganMapping());
  }

  @override
  void dispose() {
    Log.info('Menutup halaman Kritik & Saran');
    _mencariController.removeListener(_syncFilterOnly);
    _mencariController.dispose();
    super.dispose();
  }

  /// Memuat data pelanggan sekali saja untuk mapping ID -> Nama
  Future<void> _loadPelangganMapping() async {
    try {
      final pelangganList = await ref
          .read(pelangganOpSqliteProvider)
          .ambilSemua();
      if (mounted) {
        setState(() {
          _mapNamaUser = {for (final p in pelangganList) p.id: p.nama};
        });
      }
    } catch (e) {
      Log.error('Gagal memuat mapping pelanggan', e: e);
    }
  }

  /// Fungsi pembantu untuk memfilter data lokal berdasarkan query pencarian
  void _applyFilter(List<FeedbackModel> allFeedback) {
    final query = _mencariController.text.toLowerCase();
    _hasilFilter = allFeedback.where((item) {
      final isi = item.pesan.toLowerCase();
      final namaPengirim = _mapNamaUser[item.userId]?.toLowerCase() ?? '';
      return isi.contains(query) || namaPengirim.contains(query);
    }).toList();
  }

  void _syncFilterOnly() {
    setState(() {});
  }

  Future<void> _hapusFeedback(FeedbackModel feedback) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if ((konfirmasi ?? false) && mounted) {
      Log.info('Memproses penghapusan kritik/saran ID: ${feedback.id}');
      try {
        await ref.read(feedbackOpGlobalProvider).softDelete(feedback.id);
        if (mounted) {
          ToastUtil.success(context, 'Kritik dan saran berhasil dihapus');
        }
      } catch (e, st) {
        Log.error(
          'Gagal menghapus kritik/saran ID: ${feedback.id}',
          e: e,
          s: st,
        );
        if (mounted) {
          ToastUtil.error(context, 'Gagal menghapus: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackAsync = ref.watch(daftarFeedbackAktifProvider);
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(daftarFeedbackAktifProvider.future),
        child: feedbackAsync.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) {
            Log.error('Gagal memuat data kritik dan saran', e: e, s: st);
            return Center(child: Text('Gagal memuat data: $e'));
          },
          data: (semuaFeedback) {
            _applyFilter(semuaFeedback);
            if (_hasilFilter.isEmpty) {
              return Center(
                child: Text(
                  _mencariController.text.isNotEmpty
                      ? 'Tidak ada hasil ditemukan.'
                      : 'Belum ada kritik dan saran.',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _hasilFilter.length,
              itemBuilder: (context, index) {
                final feedback = _hasilFilter[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () async {
                      unawaited(
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                FeedbackDetail(id: feedback.id),
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _hapusFeedback(feedback),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NamaPelangganWidget(idPelanggan: feedback.userId),
                          gapH12,
                          Text(
                            feedback.pesan,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              feedback.tanggal != null
                                  ? FormatWaktuLengkap.formatSingkat(
                                      feedback.tanggal!,
                                    )
                                  : 'Tanggal tidak tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => const FormFeedback()),
        ),
        label: const Text('Beri Masukan'),
        icon: const Icon(TIcons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _mencari ? _buildSearchField() : const Text('Kritik & Saran'),
      actions: _mencari ? _buildSearchActions() : _buildDefaultActions(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _mencariController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Cari...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
    );
  }

  List<Widget> _buildSearchActions() {
    return [
      IconButton(
        icon: const Icon(TIcons.close),
        onPressed: () {
          Log.info('Menutup mode pencarian.');
          if (mounted) {
            setState(() {
              _mencari = false;
            });
          }
          _mencariController.clear();
        },
        tooltip: 'Tutup Pencarian',
      ),
    ];
  }

  List<Widget> _buildDefaultActions() {
    return [
      IconButton(
        icon: const Icon(TIcons.search),
        onPressed: () {
          Log.info('Membuka mode pencarian.');
          if (mounted) {
            setState(() {
              _mencari = true;
            });
          }
        },
        tooltip: 'Cari',
      ),
    ];
  }
}
```

### File: `lib/fitur/feedback/page/form_feedback.dart`
```dart
// path lib/fitur/feedback/page/form_feedback.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_global.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/providers/user_provider.dart';

class FormFeedback extends ConsumerStatefulWidget {
  final FeedbackModel? feedback;
  const FormFeedback({super.key, this.feedback});

  @override
  ConsumerState<FormFeedback> createState() => _FormFeedbackState();
}

class _FormFeedbackState extends ConsumerState<FormFeedback> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;
  bool get _modeEdit => widget.feedback != null;

  @override
  void initState() {
    super.initState();
    if (widget.feedback != null) {
      _feedbackController.text = widget.feedback!.pesan;
    }
  }

  Future<void> _simpanForm() async {
    final userId = ref.watch(userIdProvider).value ?? '';
    final feedbackOp = ref.read(feedbackOpGlobalProvider);
    if (ref.isUser && userId.isEmpty) {
      ToastUtil.warning(context, 'Silakan login terlebih dahulu');
      return;
    }
    final isOnline = await ref
        .read(koneksiInternetServiceProvider)
        .cekInternet();
    if (ref.isUser && !isOnline) {
      if (mounted) {
        ToastUtil.error(context, 'Cek koneksi internet Anda');
      }
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (_modeEdit) {
          final updateFeedback = FeedbackModel(
            id: widget.feedback?.id ?? const Uuid().v4(),
            pesan: _feedbackController.text,
            userId: userId,
          );
          await feedbackOp.perbarui(updateFeedback);
        } else {
          final tambahFeedback = FeedbackModel(
            id: const Uuid().v4(),
            pesan: _feedbackController.text,
            userId: userId,
          );
          await feedbackOp.tambah(tambahFeedback);
        }
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (mounted) {
          ToastUtil.success(
            context,
            'Terima kasih! Masukan Anda telah disimpan.',
          );
          Navigator.of(context).pop();
        }
      } catch (e, s) {
        Log.error('Gagal mengirim kritik dan saran', e: e, s: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengirim masukan: \$e');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Masukan' : 'Beri Masukan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Tulis masukan Anda di sini',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mohon jangan biarkan kolom ini kosong.';
                  }
                  return null;
                },
              ),
              gapH20,
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanForm,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.feedback != null
                            ? 'Simpan Perubahan'
                            : 'Kirim Masukan',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/feedback/provider/feedback_provider.dart`
```dart
// path: lib/fitur/feedback/provider/feedback_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_global.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/providers/user_provider.dart';

part 'feedback_provider.g.dart';
part 'feedback_provider.freezed.dart';

@freezed
abstract class FeedbackState with _$FeedbackState {
  const factory FeedbackState({
    @Default([]) List<FeedbackModel> daftarFeedback,
    @Default(0) int jumlahFeedback,
  }) = _FeedbackState;
}

@Riverpod(keepAlive: true)
class Feedback extends _$Feedback {
  FeedbackOpSqlite get _feedbackOpSqlite => ref.read(feedbackOpSqliteProvider);
  @override
  FutureOr<FeedbackState> build() {
    return _loadData();
  }

  Future<FeedbackState> _loadData() async {
    final daftarFeedback = await _feedbackOpSqlite.ambilSemua();
    final jumlahFeedback = await _feedbackOpSqlite.ambilTotalFeedback();
    return FeedbackState(
      jumlahFeedback: jumlahFeedback,
      daftarFeedback: daftarFeedback,
    );
  }

  Future<void> refresh() async {
    Log.info('[StatistikNotifier] Refresh dipicu oleh UI.');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _loadData(); // ✅ Kembalikan hasil _loadData()
    });
    Log.info('[StatistikNotifier] Refresh selesai.');
  }

  void invalidateTabelFeedback() {
    ref.invalidateSelf();
    ref.invalidate(detailFeedbackProvider);
    ref.invalidate(daftarFeedbackAktifProvider);
  }
}

@riverpod
Future<List<FeedbackModel>> daftarFeedbackAktif(Ref ref) async {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null) return [];
  final feedbackOpSqlite = ref.watch(feedbackOpGlobalProvider);
  return await feedbackOpSqlite.ambilSemua(userId);
}

@riverpod
Future<FeedbackModel?> detailFeedback(Ref ref, String id) async {
  final feedbackOpSqlite = ref.watch(feedbackOpGlobalProvider);
  return await feedbackOpSqlite.ambilBerdasarkanId(id);
}
```

