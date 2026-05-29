// path: lib/services/apk_version_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';

class ApkVersionService {
  final _supabase = Supabase.instance.client;
  final String _tableName = TableNameValue.get(TableName.userApkVersion);

  /// Mengambil informasi versi APK terbaru yang aktif.
  Future<ApkVersionModel?> getLatestVersion() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_deleted', false)
          .order('created_at', ascending: false) // Urutkan dari yg terbaru
          .limit(1) // Ambil hanya satu baris
          .single(); // Ubah menjadi satu Map, bukan List

      return ApkVersionModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      // Handle jika tidak ada data ditemukan atau error lain
      Log.error('Error getting latest version from Supabase', data: e.message);
      return null;
    } catch (e, st) {
      Log.error('An unexpected error occurred while fetching latest version', e: e, st: st);
      return null;
    }
  }

  /// Menambahkan versi APK baru ke database.
  Future<void> createVersion(ApkVersionModel version) async {
    try {
      await _supabase.from(_tableName).insert(version.toSupabase());
      Log.info('New APK version created successfully in Supabase.');
    } catch (e, st) {
      Log.error('Error creating version in Supabase', e: e, st: st);
      rethrow;
    }
  }
}
