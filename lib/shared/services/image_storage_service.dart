// path: lib/shared/services/image_storage_service.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/shared/debug/log.dart';

/// Layanan untuk mengelola penyimpanan gambar di Supabase Storage.
class ImageStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengunggah file gambar ke Supabase Storage dan mengembalikan URL publiknya.
  ///
  /// [file] adalah file gambar lokal yang akan diunggah.
  /// [bucket] adalah nama bucket di Supabase (misal: 'announcements').
  Future<String?> uploadImage(File file, String bucket) async {
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    final String path =
        fileName; // Anda bisa menambahkan folder di sini, misal: 'uploads/$fileName'

    Log.info(
        'Memulai proses unggah gambar ke Supabase Storage. Bucket: $bucket, Path: $path');

    try {
      // Mengunggah file ke bucket yang ditentukan
      await _supabase.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Mendapatkan URL publik gambar
      final String publicUrl =
          _supabase.storage.from(bucket).getPublicUrl(path);

      Log.info('Berhasil mengunggah gambar ke Supabase. URL: $publicUrl');
      return publicUrl;
    } on Exception catch (e, st) {
      Log.error('Terjadi kesalahan Supabase Storage saat mengunggah gambar',
          e: e, st: st);
      return null;
    }
  }

  /// Mendapatkan URL publik dari gambar yang sudah ada di bucket PUBLIK.
  ///
  /// [bucket] Nama bucket.
  /// [path] Path file di dalam bucket (contoh: 'folder/gambar.jpg').
  String getImageUrl(String bucket, String path) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// Membuat Signed URL (berlaku sementara) untuk gambar di bucket PRIVAT.
  ///
  /// [bucket] Nama bucket.
  /// [path] Path file di dalam bucket.
  /// [expiresIn] Masa berlaku dalam detik (default 60 detik).
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

  /// Mengunduh gambar sebagai bytes (Uint8List).
  /// Cocok untuk ditampilkan dengan Image.memory() atau disimpan ke file lokal.
  ///
  /// [bucket] Nama bucket.
  /// [path] Path file di dalam bucket.
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

  /// Mendapatkan daftar semua file dalam folder tertentu di bucket.
  ///
  /// [bucket] Nama bucket.
  /// [folder] Path folder (opsional, kosongkan untuk root bucket).
  Future<List<FileObject>?> listFiles(String bucket, {String? folder}) async {
    try {
      final result =
          await _supabase.storage.from(bucket).list(path: folder ?? '');
      Log.info(
          'Berhasil mengambil daftar file dari $bucket/${folder ?? 'root'}');
      return result;
    } catch (e, st) {
      Log.error('Gagal mengambil daftar file', e: e, st: st);
      return null;
    }
  }

  /// Menghapus file dari bucket.
  ///
  /// [bucket] Nama bucket.
  /// [paths] Daftar path file yang akan dihapus.
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
