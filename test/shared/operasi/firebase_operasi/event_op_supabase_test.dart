// path: test/shared/operasi/firebase_operasi/event_op_supabase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';

import 'event_op_supabase_test.mocks.dart';

@GenerateMocks([
  SupabaseClient,
  SupabaseQueryBuilder,
  PostgrestFilterBuilder,
  PostgrestTransformBuilder,
])
void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder<List<Map<String, dynamic>>> mockFilterBuilder;
  late EventOpSupabase eventOpSupabase;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder =
        MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();

    eventOpSupabase = EventOpSupabase(supabase: mockSupabaseClient);

    when(mockSupabaseClient.from(any)).thenAnswer((_) => mockQueryBuilder);
    when(mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
  });

  final event1Map = <String, dynamic>{
    ColumnNames.id: 'event-1',
    ColumnNames.imageUrl: 'http://example.com/image1.png',
    ColumnNames.isActive: true,
    ColumnNames.createdAt: DateTime(2023, 8, 17).toIso8601String(),
    ColumnNames.startDate: DateTime(2023, 8).toIso8601String(),
    ColumnNames.endDate: DateTime(2023, 8, 31).toIso8601String(),
    ColumnNames.updatedAt: DateTime(2023, 8, 18).toIso8601String(),
  };

  final event2Map = <String, dynamic>{
    ColumnNames.id: 'event-2',
    ColumnNames.imageUrl: 'http://example.com/image2.png',
    ColumnNames.isActive: false,
    ColumnNames.createdAt: DateTime(2024).toIso8601String(),
    ColumnNames.startDate: DateTime(2024).toIso8601String(),
    ColumnNames.endDate: DateTime(2024, 1, 31).toIso8601String(),
    ColumnNames.updatedAt: null,
  };

  group('EventOpSupabase Final Tests', () {
    group('getAll', () {
      test('harus mengembalikan daftar EventModel jika Supabase berhasil',
          () async {
        final mockTransformBuilder =
            MockPostgrestTransformBuilder<List<Map<String, dynamic>>>();

        when(mockFilterBuilder.order(ColumnNames.createdAt, ascending: false))
            .thenAnswer((_) => mockTransformBuilder);

        // ✅ Stub untuk timeout, bukan then
        when(mockTransformBuilder.timeout(any))
            .thenAnswer((_) async => [event2Map, event1Map]);

        final result = await eventOpSupabase.getAll();

        expect(result, isA<List<EventModel>>());
        expect(result.length, 2);
        expect(result.first.id, 'event-2');
        expect(result.last.imageUrl, 'http://example.com/image1.png');
      });

      test('harus melempar exception jika Supabase gagal', () {
        when(mockFilterBuilder.order(ColumnNames.createdAt, ascending: false))
            .thenThrow(Exception('Supabase Error'));

        expect(() => eventOpSupabase.getAll(), throwsA(isA<Exception>()));
      });
    });

    group('getActive', () {
      test('harus mengembalikan EventModel jika ada pengumuman aktif',
          () async {
        when(mockFilterBuilder.eq(ColumnNames.isActive, true))
            .thenAnswer((_) => mockFilterBuilder);

        final mockTransformBuilder =
            MockPostgrestTransformBuilder<List<Map<String, dynamic>>>();
        when(mockFilterBuilder.limit(1))
            .thenAnswer((_) => mockTransformBuilder);

        // PERBAIKAN: Tambahkan anyNamed('onError')
        when(mockTransformBuilder.then(any, onError: anyNamed('onError')))
            .thenAnswer((invocation) async {
          final callback = invocation.positionalArguments.first as Function(
              List<Map<String, dynamic>>);
          return callback([event1Map]);
        });

        final result = await eventOpSupabase.getActive();

        expect(result, isA<EventModel>());
        expect(result?.id, 'event-1');
        expect(result?.isActive, true);
      });

      test('harus mengembalikan null jika pengumuman aktif tidak ditemukan',
          () async {
        when(mockFilterBuilder.eq(ColumnNames.isActive, true))
            .thenAnswer((_) => mockFilterBuilder);

        final mockTransformBuilder =
            MockPostgrestTransformBuilder<List<Map<String, dynamic>>>();
        when(mockFilterBuilder.limit(1))
            .thenAnswer((_) => mockTransformBuilder);

        // PERBAIKAN: Tambahkan anyNamed('onError')
        when(mockTransformBuilder.then(any, onError: anyNamed('onError')))
            .thenAnswer((invocation) async {
          final callback = invocation.positionalArguments.first as Function(
              List<Map<String, dynamic>>);
          return callback([]);
        });

        final result = await eventOpSupabase.getActive();
        expect(result, isNull);
      });
    });

    group('upsert', () {
      test('harus memanggil upsert di Supabase dengan data yang benar',
          () async {
        final String eventId = event1Map[ColumnNames.id]?.toString() ?? '';
        final eventModel = EventModel.fromSupabase(eventId, event1Map);
        final dataPayload = eventModel.toSupabase();

        final mockUpsertBuilder =
            MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();

        when(mockQueryBuilder.upsert(dataPayload))
            .thenAnswer((_) => mockUpsertBuilder);

        // PERBAIKAN: Tambahkan anyNamed('onError')
        when(mockUpsertBuilder.then(any, onError: anyNamed('onError')))
            .thenAnswer((invocation) async {
          final callback = invocation.positionalArguments.first as Function(
              List<Map<String, dynamic>>);
          return callback([]);
        });

        await eventOpSupabase.upsert(eventModel);

        verify(mockQueryBuilder.upsert(dataPayload)).called(1);
      });
    });

    group('deleteEvent', () {
      test('harus memanggil delete dan eq di Supabase dengan ID yang benar',
          () async {
        const eventId = 'event-to-delete';
        final mockDeleteBuilder =
            MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();

        when(mockQueryBuilder.delete()).thenAnswer((_) => mockDeleteBuilder);
        when(mockDeleteBuilder.eq(ColumnNames.id, eventId))
            .thenAnswer((_) => mockDeleteBuilder);

        // PERBAIKAN: Tambahkan anyNamed('onError')
        when(mockDeleteBuilder.then(any, onError: anyNamed('onError')))
            .thenAnswer((invocation) async {
          final callback = invocation.positionalArguments.first as Function(
              List<Map<String, dynamic>>);
          return callback([]);
        });

        await eventOpSupabase.deleteEvent(eventId);

        verify(mockQueryBuilder.delete()).called(1);
        verify(mockDeleteBuilder.eq(ColumnNames.id, eventId)).called(1);
      });
    });
  });
}
