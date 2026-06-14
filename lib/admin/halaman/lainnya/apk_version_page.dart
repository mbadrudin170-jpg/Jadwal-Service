// path: lib/admin/halaman/lainnya/apk_version_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/apk_version_detail.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Enum untuk menentukan kriteria pengurutan daftar versi APK.
enum SortOrder {
  /// Terbaru ke terlama
  buildZA,

  /// Terlama ke terbaru
  buildAZ,

  /// Versi Z-A
  versionZA,

  /// Versi A-Z
  versionAZ,
}

/// Halaman untuk mengelola versi APK yang tersedia untuk pengguna.
class ApkVersionPage extends ConsumerStatefulWidget {
  /// Operasi untuk berinteraksi dengan data versi APK.
  final ApkVersionOperation? operation;

  /// Halaman untuk mengelola versi APK yang tersedia untuk pengguna.
  const ApkVersionPage({super.key, this.operation});

  @override
  ConsumerState<ApkVersionPage> createState() => _ApkVersionPageState();
}

class _ApkVersionPageState extends ConsumerState<ApkVersionPage> {
  late final ApkVersionOperation _apkVersionOperation;
  List<VersiApkModel> _apkVersionList = [];
  bool _isLoading = true;
  String? _error;
  SortOrder _currentSort = SortOrder.buildZA;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Versi APK User');
    _apkVersionOperation = ref.read(apkVersionOperationProvider);
    unawaited(_loadData());
  }

  void _sortList() {
    Log.info('Mengurutkan data berdasarkan: ${_getSortName(_currentSort)}');
    _apkVersionList.sort((final a, final b) {
      final buildA = a.latestBuildNumber[ArsitekturApk.universal] ?? 0;
      final buildB = b.latestBuildNumber[ArsitekturApk.universal] ?? 0;

      switch (_currentSort) {
        case SortOrder.buildZA:
          return buildB.compareTo(buildA);
        case SortOrder.buildAZ:
          return buildA.compareTo(buildB);
        case SortOrder.versionZA:
          return b.latestVersion.compareTo(a.latestVersion);
        case SortOrder.versionAZ:
          return a.latestVersion.compareTo(b.latestVersion);
      }
    });
  }

  Future<void> _loadData() async {
    Log.info('Memuat data versi APK aktif');
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final versionList = await _apkVersionOperation.getAllActiveApkVersions();
      Log.info('Berhasil memuat ${versionList.length} data versi APK aktif');
      if (!mounted) return;
      setState(() {
        _apkVersionList = versionList;
        _sortList();
        _isLoading = false;
      });
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data versi APK', e: e, s: s);
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toDetail(final VersiApkModel apkVersion) async {
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (final context) => ApkVersionDetailPage(
          apkVersion: apkVersion,
          operation: _apkVersionOperation,
        ),
      ),
    );
    Log.info('Kembali dari detail, memuat ulang data.');
    unawaited(_loadData());
  }

  Future<void> _toEditForm(final VersiApkModel apkVersion) async {
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => ApkVersionForm(
          apkVersion: apkVersion,
          operasi: _apkVersionOperation,
        ),
      ),
    );
    if ((result ?? false) && mounted) {
      ToastUtil.success(context, 'Data berhasil diperbarui.');
      unawaited(_loadData());
    }
  }

  Future<void> _toAddForm() async {
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            ApkVersionForm(operasi: _apkVersionOperation),
      ),
    );
    if ((result ?? false) && mounted) {
      ToastUtil.success(context, 'Data baru berhasil ditambahkan.');
      unawaited(_loadData());
    }
  }

  Future<void> _showSortDialog() async {
    if (!mounted) return;
    final newSort = await showDialog<SortOrder>(
      context: context,
      builder: (final context) {
        return _SortDialog(currentSort: _currentSort);
      },
    );
    if (newSort != null && newSort != _currentSort) {
      setState(() {
        _currentSort = newSort;
        _sortList();
      });
    }
  }

  Future<void> _showOptionsDialog(final VersiApkModel version) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (final c) => SimpleDialog(
        title: Text('Opsi Versi ${version.latestVersion}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(c);
              unawaited(_toEditForm(version));
            },
            child: const ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(c);
              unawaited(_showArchiveDialog(version));
            },
            child: const ListTile(
              leading: Icon(Icons.archive),
              title: Text('Arsipkan'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showArchiveDialog(final VersiApkModel version) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (final c) => AlertDialog(
        title: const Text('Arsipkan Versi APK?'),
        content: Text(
            'Anda yakin ingin mengarsipkan versi ${version.latestVersion}?'),
        actions: [
          TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(c, false)),
          TextButton(
              child: const Text('Arsipkan'),
              onPressed: () => Navigator.pop(c, true)),
        ],
      ),
    );
    if (confirm ?? false) {
      unawaited(_softDelete(version));
    }
  }

  Future<void> _softDelete(final VersiApkModel version) async {
    Log.info('Memulai proses soft delete untuk ID: ${version.id}');
    try {
      await _apkVersionOperation.softDelete(version.id);
      if (!mounted) return;
      setState(() {
        _apkVersionList.removeWhere((final v) => v.id == version.id);
      });
      ToastUtil.success(
          context, 'Versi ${version.latestVersion} berhasil diarsipkan.');
    } on Exception catch (e, s) {
      Log.error('Gagal soft delete data ID: ${version.id}', e: e, s: s);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan: $e');
    }
  }

  Future<void> _softDeleteAll() async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (final c) => AlertDialog(
        title: const Text('Arsipkan Semua Versi?'),
        content: const Text(
            'Anda yakin ingin mengarsipkan semua versi APK yang aktif?'),
        actions: [
          TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(c, false)),
          TextButton(
              child: const Text('Arsipkan Semua'),
              onPressed: () => Navigator.pop(c, true)),
        ],
      ),
    );

    if (confirm ?? false) {
      Log.info('Memulai proses soft delete untuk semua versi APK aktif');
      try {
        final count = await _apkVersionOperation.softDeleteAll();
        if (!mounted) return;
        ToastUtil.success(context, 'Berhasil mengarsipkan $count versi APK.');
        unawaited(_loadData());
      } on Exception catch (e, s) {
        Log.error('Gagal soft delete semua versi APK', e: e, s: s);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal mengarsipkan semua: $e');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Versi APK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: _softDeleteAll,
            tooltip: 'Arsipkan Semua',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toAddForm,
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_apkVersionList.isEmpty) {
      return const Center(child: Text('Tidak ada data versi APK.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _apkVersionList.length,
        itemBuilder: (final context, final index) {
          final apkVersion = _apkVersionList[index];
          final buildUniversal =
              apkVersion.latestBuildNumber[ArsitekturApk.universal] ?? 0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                'Versi: ${apkVersion.latestVersion} (Build: $buildUniversal)',
              ),
              subtitle: Text(
                apkVersion.releaseNotes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _toDetail(apkVersion),
              onLongPress: () => _showOptionsDialog(apkVersion),
            ),
          );
        },
      ),
    );
  }
}

/// Dialog untuk memilih kriteria pengurutan.
class _SortDialog extends StatefulWidget {
  /// Dialog untuk memilih kriteria pengurutan.
  const _SortDialog({required this.currentSort});

  /// Kriteria pengurutan saat ini.
  final SortOrder currentSort;

  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  late SortOrder _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Urutkan Berdasarkan'),
      content: RadioGroup<SortOrder>(
        groupValue: _selectedSort,
        onChanged: (final SortOrder? value) {
          if (value != null) {
            setState(() {
              _selectedSort = value;
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortOrder.values.map((final order) {
            return RadioListTile<SortOrder>(
              title: Text(_getSortName(order)),
              value: order,
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(_selectedSort),
        ),
      ],
    );
  }
}

/// Mendapatkan nama yang dapat dibaca manusia dari [SortOrder].
String _getSortName(final SortOrder order) {
  switch (order) {
    case SortOrder.buildZA:
      return 'Build (Terbaru ke Terlama)';
    case SortOrder.buildAZ:
      return 'Build (Terlama ke Terbaru)';
    case SortOrder.versionZA:
      return 'Versi (Z-A)';
    case SortOrder.versionAZ:
      return 'Versi (A-Z)';
  }
}

/// Helper widget for radio group since it's not standard in Flutter
class RadioGroup<T> extends StatelessWidget {
  /// Nilai grup saat ini.
  final T groupValue;

  /// Callback saat nilai berubah.
  final ValueChanged<T?> onChanged;

  /// Widget anak.
  final Widget child;

  /// Helper widget for radio group since it's not standard in Flutter
  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(final BuildContext context) {
    return child;
  }
}
