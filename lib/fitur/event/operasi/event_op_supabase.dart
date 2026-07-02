// path: lib/fitur/event/operasi/event_op_supabase.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

class EventOpSupabase {
  EventOpSupabase({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;
  final String _tabelEvent = NamaTabel.event;
  final SupabaseClient _supabase;

  Future<List<EventModel>> ambilSemuaEvent() async {
    Log.info('EventOpSupabase: Mengambil semua data pengumuman');
    try {
      Log.info('1️⃣ Membangun query...');
      final query = _supabase.from(_tabelEvent).select();
      Log.info('2️⃣ Eksekusi query ke Supabase...');
      final response = await query;
      Log.info('3️⃣ Response diterima, jumlah data: ${response.length}');

      return response.map((data) {
        Log.info('4️⃣ Mapping data: ${data[NamaKolom.id]}');
        return EventModel.fromSupabase(
          data[NamaKolom.id]?.toString() ?? '',
          data,
        );
      }).toList();
    } catch (e, s) {
      Log.error('❌ Gagal ambil data pengumuman', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil aliran data (Stream) pengumuman secara realtime (Versi Asinkron Aman).
  Stream<List<EventModel>> ambilRealtimeStream() async* {
    Log.info('EventOpSupabase: Membuka stream realtime untuk $_tabelEvent');

    // Gunakan yield* untuk mengalirkan data tanpa mengunci thread utama
    yield* _supabase
        .from(_tabelEvent)
        .stream(primaryKey: [NamaKolom.id])
        .handleError((Object e, StackTrace s) {
          Log.error('❌ Error di dalam stream: $e', e: e, s: s);
        })
        .map((response) {
          Log.info(
            '⚡ Realtime: Menerima ${response.length} data pengumuman terbaru',
          );
          return response.map((data) {
            return EventModel.fromSupabase(
              data[NamaKolom.id]?.toString() ?? '',
              data,
            );
          }).toList();
        });
  }

  Future<EventModel?> ambilEventAktif() async {
    /// Mengambil pengumuman yang sedang aktif.
    Log.info('EventOpSupabase: Mengambil pengumuman aktif');
    try {
      final respon = await _supabase
          .from(_tabelEvent)
          .select()
          .eq(NamaKolom.statusAktif, true)
          .limit(1);
      Log.info('$respon $_tabelEvent');

      if (respon.isEmpty) {
        return null;
      }

      final data = respon.first;
      Log.info('$data $_tabelEvent');
      return EventModel.fromSupabase(
        data[NamaKolom.id]?.toString() ?? '',
        data,
      );
    } catch (e, s) {
      Log.error('Gagal mengambil pengumuman aktif dari Supabase', e: e, s: s);
      rethrow;
    }
  }

  Future<EventModel?> ambilBerdasarkanId(String id) async {
    /// Mengambil pengumuman berdasarkan ID.
    Log.info('EventOpSupabase: Mengambil pengumuman berdasarkan id: $id');
    try {
      final respon = await _supabase
          .from(_tabelEvent)
          .select()
          .eq(NamaKolom.id, id)
          .limit(1);

      if (respon.isEmpty) {
        Log.warning('Pengumuman dengan id: $id tidak ditemukan');
        return null;
      }
      final data = respon.first;
      Log.info('Pengumuman ditemukan: $data');
      return EventModel.fromSupabase(
        data[NamaKolom.id]?.toString() ?? '',
        data,
      );
    } catch (e, s) {
      Log.error('Gagal mengambil pengumuman dengan id: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menambahkan data pengumuman baru ke Supabase.
  Future<void> tambahEvent(EventModel event) async {
    Log.info('EventOpSupabase: Membuat pengumuman baru ${event.id}');
    try {
      final dataPayload = event.toSupabase();
      await _supabase.from(_tabelEvent).insert(dataPayload);
    } catch (e, s) {
      Log.error('Gagal membuat pengumuman di Supabase', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui data pengumuman yang sudah ada di Supabase.
  Future<void> perbaruiEvent(EventModel event) async {
    Log.info('EventOpSupabase: Memperbarui pengumuman ${event.id}');
    try {
      final dataPayload = event.toSupabase();
      await _supabase
          .from(_tabelEvent)
          .update(dataPayload)
          .eq(NamaKolom.id, event.id);
    } catch (e, s) {
      Log.error('Gagal memperbarui pengumuman di Supabase', e: e, s: s);
      rethrow;
    }
  }

  /// Menghapus pengumuman secara permanen berdasarkan ID.
  Future<void> hapusEvent(String id) async {
    Log.warning('EventOpSupabase: Menghapus pengumuman $id');
    try {
      await _supabase.from(_tabelEvent).delete().eq(NamaKolom.id, id);
    } catch (e, s) {
      Log.error('Gagal menghapus pengumuman di Supabase', e: e, s: s);
      rethrow;
    }
  }
}

/// Provider Riverpod untuk `EventOpSupabase`.
final eventOpSupabaseProvider = Provider<EventOpSupabase>((ref) {
  return EventOpSupabase();
});
