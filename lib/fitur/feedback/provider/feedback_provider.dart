// path: lib/fitur/feedback/provider/feedback_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';

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
    state = await AsyncValue.guard(_loadData);
    Log.info('[StatistikNotifier] Refresh selesai.');
  }
}

@riverpod
Future<List<FeedbackModel>> daftarFeedbackAktif(Ref ref) async {
  final feedbackOpSqlite = ref.watch(feedbackOpSqliteProvider);
  return await feedbackOpSqlite.ambilSemua();
}

@riverpod
Future<FeedbackModel> detailFeedback(Ref ref, String id) async {
  final feedbackOpSqlite = ref.watch(feedbackOpSqliteProvider);
  return await feedbackOpSqlite.ambilBerdasarkanId(id);
}
