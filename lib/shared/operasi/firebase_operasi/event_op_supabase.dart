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
      final List<Map<String, dynamic>> response =
          await query.timeout(const Duration(seconds: 10));
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

  /// Menambahkan atau memperbarui (upsert) data pengumuman di Supabase.
  Future<void> upsert(final EventModel event) async {
    Log.info('EventOpSupabase: Upsert pengumuman ${event.id}');
    try {
      final Map<String, dynamic> dataPayload = event.toSupabase();
      await _supabase.from(_tableName).upsert(dataPayload);
    } catch (e, s) {
      Log.error('Gagal melakukan upsert pengumuman di Supabase', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus pengumuman secara permanen berdasarkan ID.
  Future<void> deleteEvent(final String id) async {
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
