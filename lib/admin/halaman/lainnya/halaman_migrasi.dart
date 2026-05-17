
// path: lib/admin/halaman/lainnya/halaman_migrasi.dart
// Diperbarui: Memperbaiki semua warning linter.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/services/firebase_migration/firebase_migration_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Halaman untuk alat migrasi data Firebase.
///
/// Halaman ini menyediakan antarmuka untuk menjalankan [FirebaseMigrationService],
/// yang bertanggung jawab untuk memperbarui skema database Firestore ke versi terbaru.
/// Proses ini melibatkan perubahan nama koleksi dan kolom agar sesuai dengan standar
/// yang telah ditentukan (snake_case).
class HalamanMigrasi extends StatefulWidget {
  /// Konstruktor untuk HalamanMigrasi.
  const HalamanMigrasi({super.key});

  @override
  State<HalamanMigrasi> createState() => _HalamanMigrasiState();
}

class _HalamanMigrasiState extends State<HalamanMigrasi> {
  final FirebaseMigrationService _migrationService = FirebaseMigrationService();
  bool _isMigrating = false;

  Future<void> _runMigration() async {
    Log.info('Tombol "Jalankan Migrasi Data" ditekan oleh pengguna.');

    if (_isMigrating) {
      Log.warning('Migrasi sudah berjalan, tindakan dicegah.');
      SnackBarUtil.warning(context, 'Migrasi sedang berjalan, harap tunggu.');
      return;
    }

    setState(() {
      _isMigrating = true;
    });

    // Menampilkan dialog progress
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (final BuildContext dialogContext) {
        return _MigrationProgressDialog(
          migrationService: _migrationService,
          onComplete: () {
            Log.info('Migrasi selesai, dialog progress ditutup.');
            if (mounted) {
              setState(() {
                _isMigrating = false;
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI HalamanMigrasi.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alat Migrasi Data Firebase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Migrasi skema data dari versi lama ke versi terbaru.\n'
              'Proses ini akan mengubah struktur dokumen di Firestore.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isMigrating ? null : _runMigration,
              icon: _isMigrating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(_isMigrating
                  ? 'Sedang bermigrasi...'
                  : 'Jalankan Migrasi Data'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog progress migrasi.
class _MigrationProgressDialog extends StatefulWidget {
  final FirebaseMigrationService migrationService;
  final VoidCallback onComplete;

  const _MigrationProgressDialog({
    required this.migrationService,
    required this.onComplete,
  });

  @override
  State<_MigrationProgressDialog> createState() =>
      _MigrationProgressDialogState();
}

class _MigrationProgressDialogState extends State<_MigrationProgressDialog> {
  final List<String> _logs = [];
  String _currentStatus = 'Memulai analisis migrasi...';
  bool _isDone = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Log.info('Dialog progress migrasi dibuka, memulai proses asinkron.');
    // Tidak perlu await di initState, gunakan unawaited
    unawaited(_startMigration());
  }

  Future<void> _startMigration() async {
    try {
      final logs = await widget.migrationService.runAllMigrations(_onProgress);
      setState(() {
        _logs.addAll(logs);
        _currentStatus = '✅ Semua migrasi selesai dengan sukses.';
        _isDone = true;
        _hasError = false;
      });
      Log.info('Migrasi selesai tanpa error. Total log: ${logs.length}');
    } on Exception catch (e, st) {
      Log.error('Migrasi gagal total', e: e, st: st);
      setState(() {
        _currentStatus = '❌ Gagal melakukan migrasi: $e';
        _isDone = true;
        _hasError = true;
      });
    } finally {
      widget.onComplete();
    }
  }

  void _onProgress(final String message) {
    Log.info('Progress migrasi: $message');
    setState(() {
      _currentStatus = message;
      _logs.add('[INFO] $message');
    });
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          if (!_isDone)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (!_isDone) const SizedBox(width: 12),
          Text(_isDone
              ? (_hasError ? 'Migrasi Gagal' : 'Migrasi Selesai')
              : 'Sedang Bermigrasi'),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentStatus,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _logs
                      .map((final log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(log,
                                style: const TextStyle(
                                    fontFamily: 'monospace', fontSize: 11)),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_isDone)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!_hasError) {
                SnackBarUtil.success(context, 'Migrasi berhasil dilakukan.');
              } else {
                SnackBarUtil.error(
                    context, 'Migrasi gagal, cek log untuk detail.');
              }
            },
            child: const Text('Tutup'),
          ),
      ],
    );
  }
}
