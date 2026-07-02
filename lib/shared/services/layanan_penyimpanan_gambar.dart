// path: lib/shared/services/layanan_penyimpanan_gambar.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/shared/debug/log.dart';

class LayananPenyimpananGambar {
  final SupabaseClient _klienSupabase;

  LayananPenyimpananGambar({SupabaseClient? klienSupabase})
      : _klienSupabase = klienSupabase ?? Supabase.instance.client;

  Future<String> unggahGambar(File file, String bucket) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    final path = fileName;

    Log.info(
        'Memulai proses unggah gambar ke Supabase Storage. Bucket: $bucket, Path: $path');

    try {
      await _klienSupabase.storage.from(bucket).upload(
            path,
            file,
          );

      final urlPublik =
          _klienSupabase.storage.from(bucket).getPublicUrl(path);

      Log.info('Berhasil mengunggah gambar ke Supabase. URL: $urlPublik');
      return urlPublik;
    } on StorageException catch (e, st) {
      Log.error(
          'Terjadi kesalahan spesifik Supabase Storage saat mengunggah gambar',
          e: e,
          s: st);
      rethrow;
    } catch (e, st) {
      Log.error('Terjadi kesalahan umum saat mengunggah gambar', e: e, s: st);
      rethrow;
    }
  }

  String ambilUrlGambar(String bucket, String path) {
    return _klienSupabase.storage.from(bucket).getPublicUrl(path);
  }

  Future<String?> buatUrlTertanda(String bucket, String path,
      {int expiresIn = 60}) async {
    try {
      final urlTertanda = await _klienSupabase.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);
      Log.info('Berhasil membuat signed URL untuk $bucket/$path');
      return urlTertanda;
    } catch (e, st) {
      Log.error('Gagal membuat signed URL', e: e, s: st);
      return null;
    }
  }

  Future<List<int>?> unduhGambar(String bucket, String path) async {
    try {
      final bytesGambar =
          await _klienSupabase.storage.from(bucket).download(path);
      Log.info(
          'Berhasil mengunduh gambar $bucket/$path (${bytesGambar.length} bytes)');
      return bytesGambar;
    } catch (e, st) {
      Log.error('Gagal mengunduh gambar', e: e, s: st);
      return null;
    }
  }

  Future<List<FileObject>?> daftarFile(String bucket, {String? folder}) async {
    try {
      final hasilDaftar =
          await _klienSupabase.storage.from(bucket).list(path: folder ?? '');
      final namaFolder = folder ?? 'root';
      Log.info('Berhasil mengambil daftar file dari $bucket/$namaFolder');
      return hasilDaftar;
    } catch (e, st) {
      Log.error('Gagal mengambil daftar file', e: e, s: st);
      return null;
    }
  }

  Future<bool> hapusFile(String bucket, List<String> paths) async {
    try {
      await _klienSupabase.storage.from(bucket).remove(paths);
      Log.info('Berhasil menghapus file dari $bucket: $paths');
      return true;
    } catch (e, st) {
      Log.error('Gagal menghapus file', e: e, s: st);
      return false;
    }
  }
}

final layananPenyimpananGambarProvider =
    Provider((ref) => LayananPenyimpananGambar());
