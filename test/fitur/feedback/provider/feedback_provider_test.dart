// path: test/fitur/feedback/provider/feedback_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart';

class MockFeedbackOperation extends Mock implements FeedbackOpSqlite {}

void main() {
  late MockFeedbackOperation mockFeedbackOperation;
  late ProviderContainer container;

  final tFeedback1 = FeedbackModel(
    id: '1',
    title: 'Feedback 1',
    description: 'Description 1',
    userId: 'user1',
  );
  final tFeedback2 = FeedbackModel(
    id: '2',
    title: 'Feedback 2',
    description: 'Description 2',
    userId: 'user2',
  );

  setUp(() {
    mockFeedbackOperation = MockFeedbackOperation();
    container = ProviderContainer(
      overrides: [
        feedbackOperationProvider.overrideWithValue(mockFeedbackOperation),
      ],
    );
  });

  group('activeFeedbackList Provider', () {
    test('01. harus mengembalikan daftar feedback aktif', () async {
      when(() => mockFeedbackOperation.getAllActiveFeedback())
          .thenAnswer((_) async => [tFeedback1, tFeedback2]);

      final result = await container.read(activeFeedbackListProvider.future);

      expect(result, [tFeedback1, tFeedback2]);
      verify(() => mockFeedbackOperation.getAllActiveFeedback()).called(1);
    });

    test('02. harus throw exception jika gagal mengambil data', () async {
      final exception = Exception('Failed to fetch feedback');
      when(() => mockFeedbackOperation.getAllActiveFeedback())
          .thenThrow(exception);

      expect(
        () => container.read(activeFeedbackListProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('feedbackDetail Provider', () {
    test('01. harus mengembalikan detail feedback berdasarkan ID', () async {
      when(() => mockFeedbackOperation.getById('1'))
          .thenAnswer((_) async => tFeedback1);

      final result = await container.read(feedbackDetailProvider('1').future);

      expect(result, tFeedback1);
      verify(() => mockFeedbackOperation.getById('1')).called(1);
    });

    test('02. harus throw exception jika feedback tidak ditemukan', () async {
      final exception = Exception('Feedback not found');
      when(() => mockFeedbackOperation.getById('3')).thenThrow(exception);

      expect(
        () => container.read(feedbackDetailProvider('3').future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
