// path: lib/admin/halaman/lainnya/apk_version_page.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman dalam navigasi admin.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/apk_version_detail.dart (ApkVersionDetailPage)
//   - lib/admin/halaman/form/apk_version_form.dart (ApkVersionForm)
//   - lib/shared/enum/apk_architecture_enum.dart (ApkArchitectureEnum)
//   - lib/shared/model/apk_version_model.dart (ApkVersionModel)
//   - lib/shared/operasi/apk_version_operation.dart (ApkVersionOperation)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/apk_version_detail.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/apk_version_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Enum untuk menentukan kriteria pengurutan daftar versi APK.
enum SortOrder {
  /// Urutkan berdasarkan nomor build dari Z ke A (terbaru ke terlama).
  buildZA,

  /// Urutkan berdasarkan nomor build dari A ke Z (terlama ke terbaru).
  buildAZ,

  /// Urutkan berdasarkan nomor versi dari Z ke A.
  versionZA,

  /// Urutkan berdasarkan nomor versi dari A ke Z.
  versionAZ,
}

/// Halaman untuk mengelola versi APK yang tersedia untuk pengguna.
///
/// Admin dapat melihat, menambah, mengedit, mengarsipkan, dan mengurutkan
/// daftar versi APK yang akan ditampilkan kepada pengguna.
class ApkVersionPage extends StatefulWidget {
  /// Operasi database untuk mengelola data versi APK. Jika null,
  /// instance baru akan dibuat.
  final ApkVersionOperation? operation;

  /// Membuat instance dari [ApkVersionPage].
  const ApkVersionPage({super.key, this.operation});

  @override
  State<ApkVersionPage> createState() => _ApkVersionPageState();
}

class _ApkVersionPageState extends State<ApkVersionPage> {
  late final ApkVersionOperation _apkVersionOperation;
  List<ApkVersionModel> _apkVersionList = [];
  bool _isLoading = true;
  String? _error;
  SortOrder _currentSort = SortOrder.buildZA;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Versi APK User');
    _apkVersionOperation = widget.operation ?? ApkVersionOperation();
    Log.info(
      'Menggunakan operasi: ${widget.operation != null ? "dari parameter" : "instance baru"}',
    );
    unawaited(_loadData());
  }

  void _sortList() {
    Log.info(
      'Mengurutkan ${_apkVersionList.length} data berdasarkan: ${_getSortName(_currentSort)}',
    );

    _apkVersionList.sort((final a, final b) {
      final buildA = a.latestBuildNumber[ApkArchitectureEnum.universal] ?? 0;
      final buildB = b.latestBuildNumber[ApkArchitectureEnum.universal] ?? 0;

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

    Log.info('Pengurutan selesai');
  }

  Future<void> _loadData() async {
    Log.info('Memuat data versi APK aktif dari database');
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
      Log.error('Gagal memuat data versi APK dari database', e: e, st: s);
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  void _updateOrAddItem(final ApkVersionModel item) {
    Log.info(
      'Memperbarui/menambah item lokal - ID: ${item.id}, Versi: ${item.latestVersion}',
    );
    final index = _apkVersionList.indexWhere((final v) => v.id == item.id);
    setState(() {
      if (index != -1) {
        _apkVersionList[index] = item;
      } else {
        _apkVersionList.add(item);
      }
      _sortList();
    });
  }

  Future<void> _toDetail(final ApkVersionModel apkVersion) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            ApkVersionDetailPage(apkVersion: apkVersion),
      ),
    );
  }

  Future<void> _toEditForm(final ApkVersionModel apkVersion) async {
    final result = await Navigator.push<ApkVersionModel>(
      context,
      MaterialPageRoute(
        builder: (final context) => ApkVersionForm(
          apkVersion: apkVersion,
          operasi: _apkVersionOperation,
        ),
      ),
    );

    if (result != null && mounted) {
      _updateOrAddItem(result);
    }
  }

  Future<void> _toAddForm() async {
    final result = await Navigator.push<ApkVersionModel>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            ApkVersionForm(operasi: _apkVersionOperation),
      ),
    );

    if (result != null && mounted) {
      _updateOrAddItem(result);
    }
  }

  Future<void> _showSortDialog() async {
    SortOrder? selectedSort = _currentSort;
    final newSort = await showDialog<SortOrder>(
      context: context,
      builder: (final BuildContext context) {
        return StatefulBuilder(
          builder: (final context, final setDialogState) {
            return AlertDialog(
              title: const Text('Urutkan Berdasarkan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: SortOrder.values.map((final order) {
                  return RadioListTile<SortOrder>(
                    title: Text(_getSortName(order)),
                    value: order,
                    groupValue: selectedSort,
                    onChanged: (final SortOrder? value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedSort = value;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(selectedSort),
                ),
              ],
            );
          },
        );
      },
    );

    if (newSort != null && newSort != _currentSort) {
      setState(() {
        _currentSort = newSort;
        _sortList();
      });
    }
  }

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

  Future<void> _showOptionsDialog(final ApkVersionModel version) async {
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

  Future<void> _showArchiveDialog(final ApkVersionModel version) async {
    await showDialog<void>(
      context: context,
      builder: (final c) => AlertDialog(
        title: const Text('Arsipkan Versi APK?'),
        content: Text(
          'Anda yakin ingin mengarsipkan versi ${version.latestVersion}?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(c),
          ),
          TextButton(
            child: const Text('Arsipkan'),
            onPressed: () {
              Navigator.pop(c);
              unawaited(_archive(version.id));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _archive(final String id) async {
    Log.info('Memulai proses pengarsipan untuk ID: $id');

    final dataBeforeArchive =
        _apkVersionList.where((final v) => v.id == id).firstOrNull;

    try {
      await _apkVersionOperation.archiveApkVersion(id);

      if (!mounted) return;

      setState(() {
        _apkVersionList.removeWhere((final v) => v.id == id);
      });

      if (mounted) {
        SnackBarUtil.success(
          context,
          'Versi ${dataBeforeArchive?.latestVersion ?? id} berhasil diarsipkan.',
        );
      }
    } on Exception catch (e, s) {
      Log.error('Gagal mengarsipkan data ID: $id', e: e, st: s);
      if (!mounted) return;
      SnackBarUtil.error(context, 'Gagal mengarsipkan: $e');
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
              apkVersion.latestBuildNumber[ApkArchitectureEnum.universal] ?? 0;

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
