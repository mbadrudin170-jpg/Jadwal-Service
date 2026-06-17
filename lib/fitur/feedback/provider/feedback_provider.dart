// path: lib/fitur/feedback/provider/feedback_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';

part 'feedback_provider.g.dart';

@riverpod
Future<List<FeedbackModel>> daftarFeedbackAktif(Ref ref) async {
  final feedbackOpSqlite = ref.watch(feedbackOpSqliteProvider);
  return await feedbackOpSqlite.ambilSemuaFeedbackAktif();
}

@riverpod
Future<FeedbackModel> detailFeedback(Ref ref, String id) async {
  final feedbackOpSqlite = ref.watch(feedbackOpSqliteProvider);
  return await feedbackOpSqlite.ambilBerdasarkanId(id);
}
