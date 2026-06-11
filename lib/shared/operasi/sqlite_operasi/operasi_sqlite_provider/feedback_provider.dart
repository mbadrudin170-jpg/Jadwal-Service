// path: lib/shared/operasi/sqlite_operasi/operasi_sqlite_provider/feedback_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/feedback_model.dart';

part 'feedback_provider.g.dart';

/// Provider untuk menampung list data aktif di halaman utama (FeedbackPage)
@riverpod
Future<List<FeedbackModel>> activeFeedbackList(Ref ref) async {
  final operation = ref.watch(feedbackOperationProvider);
  return await operation.getAllActiveFeedback();
}

/// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
/// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]
@riverpod
Future<FeedbackModel> feedbackDetail(Ref ref, String id) async {
  final operation = ref.watch(feedbackOperationProvider);
  return await operation.getById(id);
}
