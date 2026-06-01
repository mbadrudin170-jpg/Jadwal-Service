// path: lib/admin/halaman/detail/apk_version_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/apk_version_operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class ApkVersionDetailPage extends ConsumerStatefulWidget {
  final ApkVersionModel apkVersion;
  final ApkVersionOperation? operation;

  const ApkVersionDetailPage({
    super.key,
    required this.apkVersion,
    this.operation,
  });

  @override
  ConsumerState<ApkVersionDetailPage> createState() =>
      _ApkVersionDetailPageState();
}

class _ApkVersionDetailPageState extends ConsumerState<ApkVersionDetailPage> {
  late ApkVersionModel _currentApkVersion;
  late final ApkVersionOperation _apkVersionOperation;

  @override
  void initState() {
    super.initState();
    _currentApkVersion = widget.apkVersion;
    _apkVersionOperation =
        widget.operation ?? ref.read(apkVersionOperationProvider);
  }

  Future<void> _navigateToEditForm() async {
    Log.info(
        'Tombol edit APK ditekan, versi=${_currentApkVersion.latestVersion}');
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
      final freshData = allData.firstWhere(
        (final data) => data.id == _currentApkVersion.id,
        orElse: () => _currentApkVersion,
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
            icon: const Icon(TIcons.edit),
            tooltip: 'Edit Data',
            onPressed: _navigateToEditForm,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.p16),
        children: [
          _buildInfoRow('Versi Terbaru', _currentApkVersion.latestVersion),
          _buildInfoRow('Wajib Update',
              _currentApkVersion.isUpdateRequired ? 'Ya' : 'Tidak'),
          _buildInfoRow('Catatan Rilis', _currentApkVersion.releaseNotes),
          gapH16,
          Text(
            'Nomor Build Terbaru',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._currentApkVersion.latestBuildNumber.entries.map(
            (final entry) =>
                _buildInfoRow(entry.key.name, entry.value.toString()),
          ),
          gapH16,
          Text(
            'Tautan Unduhan',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._currentApkVersion.downloadLinks.entries.map(
            (final entry) => _buildInfoRow(entry.key.name, entry.value),
          ),
          gapH16,
          _buildInfoRow('Youtube Tutorial', _currentApkVersion.youtubeTutorial),
        ],
      ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            ': ',
            style: context.textTheme.bodyMedium,
          ),
          Flexible(
            child: Text(
              value,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
