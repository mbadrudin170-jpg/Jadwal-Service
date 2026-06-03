// path: lib/shared/operasi/firebase_operasi/event_op_supabase.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Menggunakan Supabase SDK
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/event_model.dart';

/// Operasi database khusus untuk data Pengumuman (Event) menggunakan Supabase.
class EventOpSupabase {
  EventOpSupabase();

  // Mengambil nama tabel dari konstanta enum Anda (misal: 'events' atau 'announcements')
  final String _tableName = TableNameValue.get(TableName.events);

  /// Helper untuk mendapatkan instance Supabase Client
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Mengambil semua data pengumuman dari Supabase, diurutkan dari yang terbaru.
  Future<List<EventModel>> getAll() async {
    Log.info('EventOpSupabase: Mengambil semua data pengumuman');
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .order(ColumnNames.createdAt,
              ascending: false); // Sesuaikan snake_case kolom database Anda

      // Petakan data dari map json Supabase ke EventModel
      // Jika method model Anda masih bernama fromFirebase, silakan sesuaikan/mapping key-nya
      return response
          .map((data) => EventModel.fromSupabase(
              data[ColumnNames.id]?.toString() ?? '', data))
          .toList();
    } catch (e, s) {
      Log.error('Gagal mengambil semua data pengumuman dari Supabase',
          e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil satu pengumuman yang aktif saja.
  Future<EventModel?> getActive() async {
    Log.info('EventOpSupabase: Mengambil pengumuman aktif');
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .eq(ColumnNames.isActive,
              true) // Sesuaikan penamaan kolom boolean aktif di Supabase Anda
          .limit(1);

      if (response.isEmpty) {
        return null;
      }

      final data = response.first;
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
      // Supabase menggunakan metode .upsert() langsung dengan menyuplai payload Map data.
      // Pastikan data id dikirim agar Supabase tahu data tersebut harus diupdate jika id sudah ada.
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
