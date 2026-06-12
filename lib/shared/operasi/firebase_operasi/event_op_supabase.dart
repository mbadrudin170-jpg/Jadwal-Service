// path: lib/shared/operasi/firebase_operasi/event_op_supabase.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/event_model.dart';

class EventOpSupabase {
  EventOpSupabase({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  final String _tableName = TableNameValue.get(TableName.events);
  final SupabaseClient _supabase;

  // path: lib/shared/operasi/firebase_operasi/event_op_supabase.dart
// path: lib/shared/operasi/firebase_operasi/event_op_supabase.dart
  Future<List<EventModel>> getAll() async {
    Log.info('EventOpSupabase: Mengambil semua data pengumuman');
    try {
      Log.info('1️⃣ Membangun query...');
      final query = _supabase.from(_tableName).select();
      Log.info('2️⃣ Eksekusi query ke Supabase...');
      final List<Map<String, dynamic>> response = await query;
      Log.info('3️⃣ Response diterima, jumlah data: ${response.length}');

      return response.map((data) {
        Log.info('4️⃣ Mapping data: ${data[ColumnNames.id]}');
        return EventModel.fromSupabase(
            data[ColumnNames.id]?.toString() ?? '', data);
      }).toList();
    } catch (e, s) {
      Log.error('❌ Gagal ambil data pengumuman', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil aliran data (Stream) pengumuman secara realtime (Versi Asinkron Aman).
  Stream<List<EventModel>> getRealtimeStream() async* {
    Log.info('EventOpSupabase: Membuka stream realtime untuk $_tableName');

    // Gunakan yield* untuk mengalirkan data tanpa mengunci thread utama
    yield* _supabase.from(_tableName).stream(
        primaryKey: [ColumnNames.id]).handleError((Object e, StackTrace s) {
      Log.error('❌ Error di dalam stream: $e', e: e, st: s);
    }).map((List<Map<String, dynamic>> response) {
      Log.info(
          '⚡ Realtime: Menerima ${response.length} data pengumuman terbaru');
      return response.map((data) {
        return EventModel.fromSupabase(
          data[ColumnNames.id]?.toString() ?? '',
          data,
        );
      }).toList();
    });
  }

  Future<EventModel?> getActive() async {
    Log.info('EventOpSupabase: Mengambil pengumuman aktif');
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .eq(ColumnNames.isActive, true)
          .limit(1);
      Log.info('$response $_tableName');

      if (response.isEmpty) {
        return null;
      }

      final data = response.first;
      Log.info('$data $_tableName');
      return EventModel.fromSupabase(
          data[ColumnNames.id]?.toString() ?? '', data);
    } catch (e, s) {
      Log.error('Gagal mengambil pengumuman aktif dari Supabase', e: e, st: s);
      rethrow;
    }
  }

  Future<EventModel?> getById(String id) async {
    Log.info('EventOpSupabase: Mengambil pengumuman berdasarkan id: $id');
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .eq(ColumnNames.id, id)
          .limit(1);

      if (response.isEmpty) {
        Log.warning('Pengumuman dengan id: $id tidak ditemukan');
        return null;
      }

      final data = response.first;
      Log.info('Pengumuman ditemukan: $data');
      return EventModel.fromSupabase(
          data[ColumnNames.id]?.toString() ?? '', data);
    } catch (e, s) {
      Log.error('Gagal mengambil pengumuman dengan id: $id', e: e, st: s);
      rethrow;
    }
  }

  /// Menambahkan data pengumuman baru ke Supabase.
  Future<void> addEvent(final EventModel event) async {
    Log.info('EventOpSupabase: Membuat pengumuman baru ${event.id}');
    try {
      final Map<String, dynamic> dataPayload = event.toSupabase();
      await _supabase.from(_tableName).insert(dataPayload);
    } catch (e, s) {
      Log.error('Gagal membuat pengumuman di Supabase', e: e, st: s);
      rethrow;
    }
  }

  /// Memperbarui data pengumuman yang sudah ada di Supabase.
  Future<void> update(final EventModel event) async {
    Log.info('EventOpSupabase: Memperbarui pengumuman ${event.id}');
    try {
      final Map<String, dynamic> dataPayload = event.toSupabase();
      await _supabase
          .from(_tableName)
          .update(dataPayload)
          .eq(ColumnNames.id, event.id);
    } catch (e, s) {
      Log.error('Gagal memperbarui pengumuman di Supabase', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus pengumuman secara permanen berdasarkan ID.
  Future<void> deleteEvent( String id) async {
    Log.warning('EventOpSupabase: Menghapus pengumuman $id');
    try {
      await _supabase.from(_tableName).delete().eq(ColumnNames.id, id);
    } catch (e, s) {
      Log.error('Gagal menghapus pengumuman di Supabase', e: e, st: s);
      rethrow;
    }
  }
}

/// Provider Riverpod untuk `EventOpSupabase`.
final eventOpSupabaseProvider = Provider<EventOpSupabase>((ref) {
  return EventOpSupabase();
});
