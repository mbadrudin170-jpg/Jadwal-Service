// path: lib/admin/halaman/detail/apk_version_detail.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/lainnya/apk_version_page.dart
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/form/apk_version_form.dart (ApkVersionForm)
//   - lib/shared/model/apk_version_model.dart (ApkVersionModel)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/apk_version_operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk menampilkan detail dari sebuah versi APK.
class ApkVersionDetailPage extends StatefulWidget {
  /// Model versi APK yang akan ditampilkan.
  final ApkVersionModel apkVersion;

  /// Operasi database untuk mengelola data versi APK. Jika null,
  /// instance baru akan dibuat.
  final ApkVersionOperation? operation;

  /// Konstruktor untuk ApkVersionDetailPage.
  const ApkVersionDetailPage({
    super.key,
    required this.apkVersion,
    this.operation,
  });

  @override
  State<ApkVersionDetailPage> createState() => _ApkVersionDetailPageState();
}

class _ApkVersionDetailPageState extends State<ApkVersionDetailPage> {
  late ApkVersionModel _currentApkVersion;
  late final ApkVersionOperation _apkVersionOperation;

  @override
  void initState() {
    super.initState();
    _currentApkVersion = widget.apkVersion;
    _apkVersionOperation = widget.operation ?? ApkVersionOperation();
  }

  Future<void> _navigateToEditForm() async {
    Log.info('Tombol edit APK ditekan, versi=${_currentApkVersion.latestVersion}');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => ApkVersionForm(
          apkVersion: _currentApkVersion,
          operasi: _apkVersionOperation,
        ),
      ),
    );

    if ((result ?? false) && mounted) {
      Log.info('Edit APK selesai dengan perubahan, memuat ulang data...');
      unawaited(_reloadData());
    } else {
      Log.info('Edit APK dibatalkan atau tanpa perubahan');
    }
  }

  Future<void> _reloadData() async {
    Log.info('Memuat ulang data untuk ID: ${_currentApkVersion.id}');
    try {
      final allData = await _apkVersionOperation.getAllActiveApkVersions();
      // Temukan data yang baru berdasarkan ID
      final freshData = allData.firstWhere(
        (final data) => data.id == _currentApkVersion.id,
        orElse: () => _currentApkVersion, // Kembali ke data lama jika tidak ditemukan
      );

      if (mounted) {
        setState(() {
          _currentApkVersion = freshData;
        });
        ToastUtil.success(context, 'Data detail telah diperbarui.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal memuat ulang data APK', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat ulang data detail.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun halaman detail versi APK: ${_currentApkVersion.latestVersion}.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.edit),
            tooltip: 'Edit Data',
            onPressed: _navigateToEditForm,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoRow('Versi Terbaru', _currentApkVersion.latestVersion),
          _buildInfoRow(
              'Wajib Update', _currentApkVersion.isUpdateRequired ? 'Ya' : 'Tidak'),
          _buildInfoRow('Catatan Rilis', _currentApkVersion.releaseNotes),
          const SizedBox(height: 16),
          const Text(
            'Nomor Build Terbaru',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ..._currentApkVersion.latestBuildNumber.entries.map(
            (final entry) =>
                _buildInfoRow(entry.key.name, entry.value.toString()),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tautan Unduhan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ..._currentApkVersion.downloadLinks.entries.map(
            (final entry) => _buildInfoRow(entry.key.name, entry.value),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Youtube Tutorial', _currentApkVersion.youtubeTutorial),
        ],
      ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}
