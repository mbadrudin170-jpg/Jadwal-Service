// path: lib/shared/operasi/firebase_operasi/event_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Operasi Firebase khusus untuk data Pengumuman (Event).
class EventOpFirebase extends BaseOpFirebase {
  /// Konstruktor untuk EventOpFirebase.
  EventOpFirebase({super.firestore, super.statusOp});

  final String _collection = TableNameValue.get(TableName.event);

  /// Mengambil semua data pengumuman dari Firebase.
  Future<List<EventModel>> getAll() async {
    Log.info('EventOpFirebase: Mengambil semua data pengumuman');
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((final doc) => EventModel.fromFirebase(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e, s) {
      Log.error('Gagal mengambil semua data pengumuman', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil pengumuman yang aktif saja.
  Future<EventModel?> getActive() async {
    Log.info('EventOpFirebase: Mengambil pengumuman aktif');
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return EventModel.fromFirebase(doc.id, doc.data());
    } on FirebaseException catch (e, s) {
      Log.error('Gagal mengambil pengumuman aktif', e: e, st: s);
      rethrow;
    }
  }

  /// Menambahkan atau memperbarui pengumuman.
  Future<void> upsert(final EventModel event) async {
    Log.info('EventOpFirebase: Upsert pengumuman ${event.id}');
    try {
      await insert(_collection, event.id, event.toFirebase());
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan upsert pengumuman', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus pengumuman secara permanen.
  Future<void> deleteEvent(final String id) async {
    Log.warning('EventOpFirebase: Menghapus pengumuman $id');
    try {
      await delete(_collection, id);
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menghapus pengumuman', e: e, st: s);
      rethrow;
    }
  }
}

/// Provider Riverpod untuk `EventOpFirebase`.
final eventOpFirebaseProvider = Provider<EventOpFirebase>((ref) {
  return EventOpFirebase();
});
