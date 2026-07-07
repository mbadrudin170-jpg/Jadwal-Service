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
      if (ref.isAdmin) {
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
      if (ref.isAdmin) {
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
      if (ref.isAdmin) {
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
      if (ref.isAdmin) {
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
      if (ref.isAdmin) {
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
