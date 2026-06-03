// path: lib/shared/services/image_storage_service.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/shared/debug/log.dart';

class ImageStorageService {
  final SupabaseClient _supabase;

  ImageStorageService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<String> uploadImage(File file, String bucket) async {
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    final String path = fileName;

    Log.info(
        'Memulai proses unggah gambar ke Supabase Storage. Bucket: $bucket, Path: $path');

    try {
      await _supabase.storage.from(bucket).upload(
            path,
            file,
          );

      final String publicUrl =
          _supabase.storage.from(bucket).getPublicUrl(path);

      Log.info('Berhasil mengunggah gambar ke Supabase. URL: $publicUrl');
      return publicUrl;
    } on StorageException catch (e, st) {
      Log.error(
          'Terjadi kesalahan spesifik Supabase Storage saat mengunggah gambar',
          e: e,
          st: st);
      rethrow;
    } catch (e, st) {
      Log.error('Terjadi kesalahan umum saat mengunggah gambar', e: e, st: st);
      rethrow;
    }
  }

  String getImageUrl(String bucket, String path) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  Future<String?> getSignedImageUrl(String bucket, String path,
      {int expiresIn = 60}) async {
    try {
      final String signedUrl =
          await _supabase.storage.from(bucket).createSignedUrl(path, expiresIn);
      Log.info('Berhasil membuat signed URL untuk $bucket/$path');
      return signedUrl;
    } catch (e, st) {
      Log.error('Gagal membuat signed URL', e: e, st: st);
      return null;
    }
  }

  Future<List<int>?> downloadImage(String bucket, String path) async {
    try {
      final bytes = await _supabase.storage.from(bucket).download(path);
      Log.info(
          'Berhasil mengunduh gambar $bucket/$path (${bytes.length} bytes)');
      return bytes;
    } catch (e, st) {
      Log.error('Gagal mengunduh gambar', e: e, st: st);
      return null;
    }
  }

  Future<List<FileObject>?> listFiles(String bucket, {String? folder}) async {
    try {
      final result =
          await _supabase.storage.from(bucket).list(path: folder ?? '');
      final String folderName = folder ?? 'root';
      Log.info('Berhasil mengambil daftar file dari $bucket/$folderName');
      return result;
    } catch (e, st) {
      Log.error('Gagal mengambil daftar file', e: e, st: st);
      return null;
    }
  }

  Future<bool> deleteFiles(String bucket, List<String> paths) async {
    try {
      await _supabase.storage.from(bucket).remove(paths);
      Log.info('Berhasil menghapus file dari $bucket: $paths');
      return true;
    } catch (e, st) {
      Log.error('Gagal menghapus file', e: e, st: st);
      return false;
    }
  }
}

final imageStorageServiceProvider = Provider((ref) => ImageStorageService());
