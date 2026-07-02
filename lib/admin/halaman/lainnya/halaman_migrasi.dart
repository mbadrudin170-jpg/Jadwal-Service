// path: lib/admin/halaman/lainnya/halaman_migrasi.dart
// Diperbarui: Tombol dinonaktifkan permanen & snackbar otomatis setelah migrasi.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/services/firebase_migration/firebase_migration_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk menjalankan alat migrasi data Firebase.
///
/// Halaman ini menampilkan antarmuka sederhana yang memungkinkan pengguna
/// memulai proses migrasi skema database Firestore dari versi lama ke versi
/// terbaru menggunakan [FirebaseMigrationService].
///
/// Tombol migrasi akan dinonaktifkan secara permanen setelah migrasi berhasil
/// dilakukan. Selama migrasi berjalan, tombol juga dinonaktifkan untuk
/// mencegah pemanggilan ganda.
///
/// Penggunaan:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const HalamanMigrasi()),
/// );
/// ```
class HalamanMigrasi extends StatefulWidget {
  /// Membuat [HalamanMigrasi] baru.
  const HalamanMigrasi({super.key});

  @override
  State<HalamanMigrasi> createState() => _HalamanMigrasiState();
}

class _HalamanMigrasiState extends State<HalamanMigrasi> {
  /// Layanan migrasi yang menangani semua logika pembaruan skema Firestore.
  final FirebaseMigrationService _migrationService = FirebaseMigrationService();

  /// Menandakan apakah proses migrasi sedang berjalan.
  bool _isMigrating = false;

  /// Menandakan apakah migrasi telah selesai dan berhasil.
  /// Digunakan untuk menonaktifkan tombol secara permanen setelah sukses.
  bool _migrationCompletedSuccessfully = false;

  /// Memulai proses migrasi setelah konfirmasi pengguna.
  ///
  /// Jika migrasi sedang berjalan, menampilkan peringatan dan mengabaikan
  /// permintaan. Menampilkan dialog progres [_MigrationProgressDialog] yang
  /// akan menangani pembaruan status dan log secara real-time.
  Future<void> _runMigration() async {
    info('Tombol "Jalankan Migrasi Data" ditekan oleh pengguna.');
    if (_isMigrating) {
      warning('Migrasi sudah berjalan, tindakan dicegah.');
      ToastUtil.warning(context, 'Migrasi sedang berjalan, harap tunggu.');
      return;
    }

    setState(() {
      _isMigrating = true;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _MigrationProgressDialog(
          migrationService: _migrationService,
          onComplete: (bool hasError) {
            info(
              'Migrasi selesai, dialog ditutup. Status error: $hasError',
            );
            if (mounted) {
              setState(() {
                _isMigrating = false;
                if (!hasError) {
                  _migrationCompletedSuccessfully = true;
                  ToastUtil.success(context, 'Migrasi berhasil dilakukan.');
                } else {
                  ToastUtil.error(
                    context,
                    'Migrasi gagal, cek log untuk detail.',
                  );
                }
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    info('Membangun UI HalamanMigrasi.');

    // Tombol dinonaktifkan jika migrasi sedang berjalan atau sudah berhasil.
    final bool isButtonDisabled =
        _isMigrating || _migrationCompletedSuccessfully;

    Widget buttonIcon;
    String buttonText;

    if (_migrationCompletedSuccessfully) {
      buttonIcon = const Icon(Icons.check);
      buttonText = 'Migrasi Selesai';
    } else if (_isMigrating) {
      buttonIcon = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
      buttonText = 'Sedang bermigrasi...';
    } else {
      buttonIcon = const Icon(Icons.sync);
      buttonText = 'Jalankan Migrasi Data';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Alat Migrasi Data Firebase')),
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
            gapH32,
            ElevatedButton.icon(
              onPressed: isButtonDisabled ? null : _runMigration,
              icon: buttonIcon,
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog yang menampilkan progres migrasi Firebase secara real-time.
///
/// Dialog ini tidak dapat ditutup selama proses migrasi berlangsung.
/// Pengguna hanya dapat menutupnya setelah migrasi selesai atau gagal.
/// Log progres ditampilkan dalam area yang dapat digulir.
class _MigrationProgressDialog extends StatefulWidget {
  /// Layanan migrasi yang akan menjalankan proses.
  final FirebaseMigrationService migrationService;

  /// Callback yang dipanggil ketika migrasi selesai (berhasil atau gagal).
  ///
  /// Parameter [hasError] bernilai `true` jika terjadi kesalahan selama proses.
  final void Function(bool hasError) onComplete;

  /// Membuat [_MigrationProgressDialog].
  const _MigrationProgressDialog({
    required this.migrationService,
    required this.onComplete,
  });

  @override
  State<_MigrationProgressDialog> createState() =>
      _MigrationProgressDialogState();
}

class _MigrationProgressDialogState extends State<_MigrationProgressDialog> {
  /// Daftar log yang akan ditampilkan kepada pengguna.
  final List<String> _logs = [];

  /// Status terkini dari proses migrasi (ditampilkan di atas log).
  String _currentStatus = 'Memulai analisis migrasi...';

  /// Menandakan apakah proses migrasi telah selesai (berhasil atau gagal).
  bool _isDone = false;

  /// Menandakan apakah terjadi kesalahan selama migrasi.
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    info('Dialog progress migrasi dibuka, memulai proses asinkron.');
    unawaited(_startMigration());
  }

  /// Memulai dan memantau proses migrasi.
  ///
  /// Memanggil [FirebaseMigrationService.runAllMigrations] dan memperbarui
  /// UI berdasarkan progres yang diterima. Menangani kesalahan yang terjadi
  /// dan memanggil [widget.onComplete] setelah selesai.
  Future<void> _startMigration() async {
    try {
      final logs = await widget.migrationService.runAllMigrations(_onProgress);
      setState(() {
        _logs.addAll(logs);
        _currentStatus = '✅ Semua migrasi selesai dengan sukses.';
        _isDone = true;
        _hasError = false;
      });
      info('Migrasi selesai tanpa error. Total log: ${logs.length}');
    } on Exception catch (e, st) {
      error('Migrasi gagal total', e: e, s: st);
      setState(() {
        _currentStatus = '❌ Gagal melakukan migrasi: $e';
        _isDone = true;
        _hasError = true;
      });
    } finally {
      widget.onComplete(_hasError);
    }
  }

  /// Callback yang dipanggil setiap kali ada progres baru dari layanan migrasi.
  ///
  /// [message] berisi deskripsi langkah yang sedang dikerjakan.
  void _onProgress(String message) {
    info('Progress migrasi: $message');
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
          if (!_isDone) gapH12,
          Text(
            _isDone
                ? (_hasError ? 'Migrasi Gagal' : 'Migrasi Selesai')
                : 'Sedang Bermigrasi',
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStatus,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _logs
                      .map(
                        (final log) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
      ],
    );
  }
}
