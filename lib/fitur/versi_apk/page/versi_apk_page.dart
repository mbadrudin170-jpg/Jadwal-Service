import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart';
import 'package:wifi/fitur/versi_apk/page/detail_versi_apk.dart';
import 'package:wifi/fitur/versi_apk/page/form_versi_apk.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';

enum UrutanSortir { buildZA, buildAZ, versionZA, versionAZ }

class VersiApkPage extends ConsumerStatefulWidget {
  final VersiApkOpSqlite? operation;
  const VersiApkPage({super.key, this.operation});
  @override
  ConsumerState<VersiApkPage> createState() => _VersiApkState();
}

class _VersiApkState extends ConsumerState<VersiApkPage> {
  late final VersiApkOpSqlite _versiApkOpSqlite;
  List<VersiApkModel> _daftarVersiApk = [];
  bool _loading = true;
  String? _error;
  UrutanSortir _currentSort = UrutanSortir.buildZA;
  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Versi APK User');
    _versiApkOpSqlite = ref.read(versiApkOpSqliteProvider);
    unawaited(_loadData());
  }

  void _sortList() {
    Log.info('Mengurutkan data berdasarkan: ${_getSortName(_currentSort)}');
    _daftarVersiApk.sort((final a, final b) {
      final buildA = a.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0;
      final buildB = b.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0;
      switch (_currentSort) {
        case UrutanSortir.buildZA:
          return buildB.compareTo(buildA);
        case UrutanSortir.buildAZ:
          return buildA.compareTo(buildB);
        case UrutanSortir.versionZA:
          return b.versiTerkahir.compareTo(a.versiTerkahir);
        case UrutanSortir.versionAZ:
          return a.versiTerkahir.compareTo(b.versiTerkahir);
      }
    });
  }

  Future<void> _loadData() async {
    Log.info('Memuat data versi APK aktif');
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final daftarVersi = await _versiApkOpSqlite.ambilSemuaVersiApkAktif();
      Log.info('Berhasil memuat ${daftarVersi.length} data versi APK aktif');
      if (!mounted) return;
      setState(() {
        _daftarVersiApk = daftarVersi;
        _sortList();
        _loading = false;
      });
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data versi APK', e: e, s: s);
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _loading = false;
      });
    }
  }

  Future<void> _navigasiKeDetail(VersiApkModel versiApk) async {
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (final context) => DetailVersiApk(
          versiApk: versiApk,
          versiApkOPSqlite: _versiApkOpSqlite,
        ),
      ),
    );
    Log.info('Kembali dari detail, memuat ulang data.');
    unawaited(_loadData());
  }

  Future<void> _navigasiKeEdit(VersiApkModel versiApk) async {
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormVersiApk(
          versiApk: versiApk,
          versiApkOpSqlite: _versiApkOpSqlite,
        ),
      ),
    );
    if ((result ?? false) && mounted) {
      ToastUtil.success(context, 'Data berhasil diperbarui.');
      unawaited(_loadData());
    }
  }

  Future<void> _navigasiKeForm() async {
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            FormVersiApk(versiApkOpSqlite: _versiApkOpSqlite),
      ),
    );
    if ((result ?? false) && mounted) {
      ToastUtil.success(context, 'Data baru berhasil ditambahkan.');
      unawaited(_loadData());
    }
  }

  Future<void> _tampilkanDialogUrutan() async {
    if (!mounted) return;
    final newSort = await showDialog<UrutanSortir>(
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

  Future<void> _showOptionsDialog(VersiApkModel versi) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text('Opsi Versi ${versi.versiTerkahir}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(c);
              unawaited(_navigasiKeEdit(versi));
            },
            child: const ListTile(
              leading: Icon(TIcons.edit),
              title: Text('Edit'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(c);
              unawaited(_showArchiveDialog(versi));
            },
            child: const ListTile(
              leading: Icon(TIcons.archive),
              title: Text('Arsipkan'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showArchiveDialog(VersiApkModel versi) async {
    if (!mounted) return;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Arsipkan Versi APK?'),
        content: Text(
          'Anda yakin ingin mengarsipkan versi ${versi.versiTerkahir}?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(c, false),
          ),
          TextButton(
            child: const Text('Arsipkan'),
            onPressed: () => Navigator.pop(c, true),
          ),
        ],
      ),
    );
    if (konfirmasi ?? false) {
      unawaited(_softDelete(versi));
    }
  }

  Future<void> _softDelete(final VersiApkModel version) async {
    Log.info('Memulai proses soft delete untuk ID: ${version.id}');
    try {
      await _versiApkOpSqlite.softDelete(version.id);
      if (!mounted) return;
      setState(() {
        _daftarVersiApk.removeWhere((final v) => v.id == version.id);
      });
      ToastUtil.success(
        context,
        'Versi ${version.versiTerkahir} berhasil diarsipkan.',
      );
    } on Exception catch (e, s) {
      Log.error('Gagal soft delete data ID: ${version.id}', e: e, s: s);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan: $e');
    }
  }

  Future<void> _softDeleteAll() async {
    if (!mounted) return;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Arsipkan Semua Versi?'),
        content: const Text(
          'Anda yakin ingin mengarsipkan semua versi APK yang aktif?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(c, false),
          ),
          TextButton(
            child: const Text('Arsipkan Semua'),
            onPressed: () => Navigator.pop(c, true),
          ),
        ],
      ),
    );

    if (konfirmasi ?? false) {
      Log.info('Memulai proses soft delete untuk semua versi APK aktif');
      try {
        final count = await _versiApkOpSqlite.softDeleteAll();
        if (!mounted) return;
        ToastUtil.success(context, 'Berhasil mengarsipkan $count versi APK.');
        unawaited(_loadData());
      } catch (e, s) {
        Log.error('Gagal soft delete semua versi APK', e: e, s: s);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal mengarsipkan semua: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _tampilkanDialogUrutan,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigasiKeForm,
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
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

    if (_daftarVersiApk.isEmpty) {
      return const Center(child: Text('Tidak ada data versi APK.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _daftarVersiApk.length,
        itemBuilder: (context, index) {
          final apkVersion = _daftarVersiApk[index];
          final buildUniversal =
              apkVersion.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                'Versi: ${apkVersion.versiTerkahir} (Build: $buildUniversal)',
              ),
              subtitle: Text(
                apkVersion.catatanRilis,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _navigasiKeDetail(apkVersion),
              onLongPress: () => _showOptionsDialog(apkVersion),
            ),
          );
        },
      ),
    );
  }
}

class _SortDialog extends StatefulWidget {
  const _SortDialog({required this.currentSort});
  final UrutanSortir currentSort;

  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  late UrutanSortir _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Urutkan Berdasarkan'),
      content: RadioGroup<UrutanSortir>(
        groupValue: _selectedSort,
        onChanged: (final UrutanSortir? value) {
          if (value != null) {
            setState(() {
              _selectedSort = value;
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: UrutanSortir.values.map((final order) {
            return RadioListTile<UrutanSortir>(
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

String _getSortName(final UrutanSortir order) {
  switch (order) {
    case UrutanSortir.buildZA:
      return 'Build (Terbaru ke Terlama)';
    case UrutanSortir.buildAZ:
      return 'Build (Terlama ke Terbaru)';
    case UrutanSortir.versionZA:
      return 'Versi (Z-A)';
    case UrutanSortir.versionAZ:
      return 'Versi (A-Z)';
  }
}

class RadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;
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
