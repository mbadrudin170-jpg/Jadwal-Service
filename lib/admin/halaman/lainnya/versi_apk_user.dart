// path: lib/admin/halaman/lainnya/versi_apk_user.dart
// diubah: Memperbaiki discarded_futures dengan unawaited.
// diubah: Peringatan 'deprecated_member_use' untuk RadioListTile ditekan sementara.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/detail_versi_apk_user.dart';
import 'package:wifi/admin/halaman/form/form_versi_apk_user.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/arsitektur_apk_enum.dart';
import 'package:wifi/shared/model/versi_apk_user_model.dart';
import 'package:wifi/shared/operasi/versi_apk_user_operasi.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Enum untuk menentukan kriteria pengurutan daftar versi APK.
enum Urutan {
  /// Urutkan berdasarkan nomor build dari Z ke A (terbaru ke terlama).
  buildZA,

  /// Urutkan berdasarkan nomor build dari A ke Z (terlama ke terbaru).
  buildAZ,

  /// Urutkan berdasarkan nomor versi dari Z ke A.
  versiZA,

  /// Urutkan berdasarkan nomor versi dari A ke Z.
  versiAZ,
}

/// Halaman untuk mengelola versi APK yang tersedia untuk pengguna.
///
/// Admin dapat melihat, menambah, mengedit, mengarsipkan, dan mengurutkan
/// daftar versi APK yang akan ditampilkan kepada pengguna.
class VersiApkUserPage extends StatefulWidget {
  /// Operasi database untuk mengelola data versi APK. Jika null,
  /// instance baru akan dibuat.
  final VersiApkUserOperasi? operasi;

  /// Membuat instance dari [VersiApkUserPage].
  const VersiApkUserPage({super.key, this.operasi});

  @override
  State<VersiApkUserPage> createState() => _VersiApkUserPageState();
}

class _VersiApkUserPageState extends State<VersiApkUserPage> {
  late final VersiApkUserOperasi _versiApkUserOperasi;
  List<VersiApkUserModel> _daftarVersiApk = [];
  bool _isLoading = true;
  String? _error;
  Urutan _urutanSaatIni = Urutan.buildZA;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Versi APK User');
    _versiApkUserOperasi = widget.operasi ?? VersiApkUserOperasi();
    Log.info(
      'Menggunakan operasi: ${widget.operasi != null ? "dari parameter" : "instance baru"}',
    );
    unawaited(_loadData());
  }

  void _urutkanList() {
    Log.info(
      'Mengurutkan ${_daftarVersiApk.length} data berdasarkan: ${_getNamaUrutan(_urutanSaatIni)}',
    );

    _daftarVersiApk.sort((final a, final b) {
      final buildA = a.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
      final buildB = b.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;

      switch (_urutanSaatIni) {
        case Urutan.buildZA:
          Log.info(
            'Pengurutan Build Z-A: membandingkan build $buildB vs $buildA',
          );
          return buildB.compareTo(buildA);
        case Urutan.buildAZ:
          Log.info(
            'Pengurutan Build A-Z: membandingkan build $buildA vs $buildB',
          );
          return buildA.compareTo(buildB);
        case Urutan.versiZA:
          Log.info(
            'Pengurutan Versi Z-A: membandingkan ${b.versiTerbaru} vs ${a.versiTerbaru}',
          );
          return b.versiTerbaru.compareTo(a.versiTerbaru);
        case Urutan.versiAZ:
          Log.info(
            'Pengurutan Versi A-Z: membandingkan ${a.versiTerbaru} vs ${b.versiTerbaru}',
          );
          return a.versiTerbaru.compareTo(b.versiTerbaru);
      }
    });

    // Log 5 data teratas setelah pengurutan
    Log.info('5 data teratas setelah pengurutan:');
    for (int i = 0;
        i < (_daftarVersiApk.length < 5 ? _daftarVersiApk.length : 5);
        i++) {
      final v = _daftarVersiApk[i];
      Log.info(
        '  ${i + 1}. ID: ${v.id}, Versi: ${v.versiTerbaru}, Build Universal: ${v.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
      );
    }

    Log.info('Pengurutan selesai');
  }

  Future<void> _loadData() async {
    Log.info('Memuat data versi APK aktif dari database');
    if (!mounted) {
      Log.warning('Widget tidak mounted, membatalkan load data');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      Log.info('Set state: isLoading=true, error=null');
    });

    try {
      final daftarVersi = await _versiApkUserOperasi.ambilSemuaVersiApkAktif();
      Log.info('Berhasil memuat ${daftarVersi.length} data versi APK aktif');

      // Log detail setiap versi APK
      for (var versi in daftarVersi) {
        final buildUniversal =
            versi.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
        final bit_32 = versi.nomorBuildTerbaru[ArsitekturApkEnum.bit_32] ?? 0;
        final bit_64 = versi.nomorBuildTerbaru[ArsitekturApkEnum.bit_64] ?? 0;
        Log.info(
          'Versi APK ID: ${versi.id}, Versi: ${versi.versiTerbaru}, Build Universal: $buildUniversal, Build ARM64: $bit_32, Build X86_64: $bit_64, Catatan: ${versi.catatanRilis.length > 50 ? "${versi.catatanRilis.substring(0, 50)}..." : versi.catatanRilis}',
        );
      }

      if (!mounted) {
        Log.warning('Widget tidak mounted setelah fetch, membatalkan setState');
        return;
      }

      setState(() {
        _daftarVersiApk = daftarVersi;
        _urutkanList();
        _isLoading = false;
        Log.info(
          'Set state: daftarVersiApk=${_daftarVersiApk.length} data, isLoading=false',
        );
      });
    } on Exception catch (e, s) {
      Log.error(
        'Gagal memuat data versi APK dari database',
        e: e,
        st: s,
      );
      if (!mounted) {
        Log.warning('Widget tidak mounted setelah error, membatalkan setState');
        return;
      }
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
        Log.info('Set state: error="$_error", isLoading=false');
      });
    }
  }

  void _perbaruiAtauTambahItem(final VersiApkUserModel item) {
    Log.info(
      'Memperbarui/menambah item lokal - ID: ${item.id}, Versi: ${item.versiTerbaru}',
    );
    final index = _daftarVersiApk.indexWhere((final v) => v.id == item.id);
    setState(() {
      if (index != -1) {
        Log.info(
          'Item ditemukan di index $index, mengganti data lama dengan data baru',
        );
        Log.info(
          'Data lama - Versi: ${_daftarVersiApk[index].versiTerbaru}, Build: ${_daftarVersiApk[index].nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
        );
        Log.info(
          'Data baru - Versi: ${item.versiTerbaru}, Build: ${item.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
        );
        _daftarVersiApk[index] = item;
      } else {
        Log.info(
          'Item baru, menambahkan ke dalam daftar (sebelumnya ${_daftarVersiApk.length} data)',
        );
        _daftarVersiApk.add(item);
        Log.info('Daftar sekarang berisi ${_daftarVersiApk.length} data');
      }
      _urutkanList();
    });
  }

  Future<void> _keDetail(final VersiApkUserModel versiApk) async {
    Log.info(
      'Navigasi ke halaman Detail Versi APK - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
    );
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (final context) => DetailVersiApkUser(versiApk: versiApk),
      ),
    );
    Log.info('Kembali dari halaman Detail Versi APK ID: ${versiApk.id}');
  }

  Future<void> _keFormEdit(final VersiApkUserModel versiApk) async {
    Log.info(
      'Navigasi ke Form Edit Versi APK - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
    );
    final hasil = await Navigator.push<VersiApkUserModel>(
      context,
      MaterialPageRoute(
        builder: (final context) => FormVersiApkUser(
          versiApkUser: versiApk,
          operasi: _versiApkUserOperasi,
        ),
      ),
    );

    if (hasil != null && mounted) {
      Log.info(
        'Menerima hasil edit dari Form - ID: ${hasil.id}, Versi: ${hasil.versiTerbaru}',
      );
      _perbaruiAtauTambahItem(hasil);
    } else if (hasil == null) {
      Log.info('Kembali dari Form Edit tanpa perubahan data');
    } else {
      Log.info('Widget tidak mounted, mengabaikan hasil edit');
    }
  }

  Future<void> _keFormTambah() async {
    Log.info('Navigasi ke Form Tambah Versi APK');
    final hasil = await Navigator.push<VersiApkUserModel>(
      context,
      MaterialPageRoute(
        builder: (final context) => FormVersiApkUser(operasi: _versiApkUserOperasi),
      ),
    );

    if (hasil != null && mounted) {
      Log.info(
        'Menerima data versi baru dari Form - ID: ${hasil.id}, Versi: ${hasil.versiTerbaru}',
      );
      _perbaruiAtauTambahItem(hasil);
    } else if (hasil == null) {
      Log.info('Kembali dari Form Tambah tanpa membuat data baru');
    } else {
      Log.info('Widget tidak mounted, mengabaikan data baru');
    }
  }

  Future<void> _tampilkanDialogUrutkan() async {
    Log.info(
      'Menampilkan dialog pengurutan, urutan saat ini: ${_getNamaUrutan(_urutanSaatIni)}',
    );
    final urutanBaru = await showDialog<Urutan>(
      context: context,
      builder: (final BuildContext context) {
        Urutan? selectedUrutan = _urutanSaatIni;
        return StatefulBuilder(
          builder: (final context, final setStateDialog) {
            return AlertDialog(
              title: const Text('Urutkan Berdasarkan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: Urutan.values.map((final urutan) {
                  return RadioListTile<Urutan>(
                    title: Text(_getNamaUrutan(urutan)),
                    value: urutan,
                    // ignore: deprecated_member_use, temporary solution until RadioGroup is implemented.
                    groupValue: selectedUrutan,
                    // ignore: deprecated_member_use, temporary solution until RadioGroup is implemented.
                    onChanged: (final Urutan? value) {
                      if (value != null) {
                        setStateDialog(() {
                          selectedUrutan = value;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Log.info('Dialog urutkan dibatalkan oleh user');
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Log.info(
                      'User mengonfirmasi urutan: ${selectedUrutan != null ? _getNamaUrutan(selectedUrutan!) : "null"}',
                    );
                    Navigator.of(context).pop(selectedUrutan);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (urutanBaru != null && urutanBaru != _urutanSaatIni) {
      Log.info(
        'Mengubah urutan dari ${_getNamaUrutan(_urutanSaatIni)} ke ${_getNamaUrutan(urutanBaru)}',
      );
      setState(() {
        _urutanSaatIni = urutanBaru;
        _urutkanList();
      });
    } else if (urutanBaru == _urutanSaatIni) {
      Log.info(
        'User memilih urutan yang sama (${_getNamaUrutan(_urutanSaatIni)}), tidak ada perubahan',
      );
    } else {
      Log.info('Dialog ditutup tanpa memilih urutan');
    }
  }

  String _getNamaUrutan(final Urutan urutan) {
    switch (urutan) {
      case Urutan.buildZA:
        return 'Build (Terbaru ke Terlama)';
      case Urutan.buildAZ:
        return 'Build (Terlama ke Terbaru)';
      case Urutan.versiZA:
        return 'Versi (Z-A)';
      case Urutan.versiAZ:
        return 'Versi (A-Z)';
    }
  }

  Future<void> _tampilkanDialogOpsi(final VersiApkUserModel versi) async {
    Log.info(
      'Menampilkan dialog opsi untuk Versi: ${versi.versiTerbaru} (ID: ${versi.id})',
    );
    await showDialog<void>(
      context: context,
      builder: (final c) => SimpleDialog(
        title: Text('Opsi Versi ${versi.versiTerbaru}'),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Log.info('Opsi Edit dipilih untuk Versi: ${versi.versiTerbaru}');
              Navigator.pop(c);
              await _keFormEdit(versi);
            },
            child: const ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Log.info(
                'Opsi Arsipkan dipilih untuk Versi: ${versi.versiTerbaru}',
              );
              Navigator.pop(c);
              await _tampilkanDialogArsip(versi);
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

  Future<void> _tampilkanDialogArsip(final VersiApkUserModel versi) async {
    Log.info(
      'Menampilkan dialog konfirmasi arsip untuk ID: ${versi.id}, Versi: ${versi.versiTerbaru}',
    );
    await showDialog<void>(
      context: context,
      builder: (final c) => AlertDialog(
        title: const Text('Arsipkan Versi APK?'),
        content: Text(
          'Anda yakin ingin mengarsipkan versi ${versi.versiTerbaru}? Data yang diarsipkan tidak akan ditampilkan di daftar aktif.',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Log.info(
                'Pengarsipan versi ${versi.versiTerbaru} dibatalkan oleh user',
              );
              Navigator.pop(c);
            },
          ),
          TextButton(
            child: const Text('Arsipkan'),
            onPressed: () async {
              Log.info(
                'User mengonfirmasi pengarsipan versi ${versi.versiTerbaru}',
              );
              Navigator.pop(c);
              await _arsipkan(versi.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _arsipkan(final String id) async {
    Log.info('Memulai proses pengarsipan untuk ID: $id');

    // Cari data sebelum dihapus untuk logging
    final dataSebelumArsip =
        _daftarVersiApk.where((final v) => v.id == id).firstOrNull;
    if (dataSebelumArsip != null) {
      Log.info(
        'Data yang akan diarsipkan - Versi: ${dataSebelumArsip.versiTerbaru}, Build: ${dataSebelumArsip.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
      );
    }

    try {
      await _versiApkUserOperasi.arsipkanVersiApkUser(id);
      Log.info('Data ID: $id berhasil diarsipkan di database');

      if (!mounted) {
        Log.warning(
          'Widget tidak mounted setelah arsip berhasil, membatalkan update UI',
        );
        return;
      }

      setState(() {
        final jumlahSebelum = _daftarVersiApk.length;
        _daftarVersiApk.removeWhere((final v) => v.id == id);
        Log.info(
          'Data dihapus dari daftar lokal: $jumlahSebelum -> ${_daftarVersiApk.length} data',
        );
      });

      if (mounted) {
        SnackBarUtil.success(
          context,
          'Versi ${dataSebelumArsip?.versiTerbaru ?? id} berhasil diarsipkan.',
        );
        Log.info('SnackBar sukses ditampilkan');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal mengarsipkan data ID: $id', e: e, st: s);
      if (!mounted) {
        Log.warning('Widget tidak mounted setelah error arsip');
        return;
      }
      SnackBarUtil.error(
        context,
        'Gagal mengarsipkan: $e',
      );
      Log.info('SnackBar error ditampilkan');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI VersiApkUserPage - Data: ${_daftarVersiApk.length}, Loading: $_isLoading, Error: ${_error != null ? "Ya" : "Tidak"}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Versi APK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info('Kembali ke halaman sebelumnya dari Versi APK User');
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () async {
              Log.info('Icon sort pada AppBar ditekan');
              await _tampilkanDialogUrutkan();
            },
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Log.info('FAB Tambah Versi APK ditekan');
          await _keFormTambah();
        },
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    Log.info(
      'Membangun konten body - isLoading: $_isLoading, error: ${_error != null}, dataCount: ${_daftarVersiApk.length}',
    );

    if (_isLoading) {
      Log.info('Menampilkan CircularProgressIndicator (loading)');
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      Log.info('Menampilkan pesan error: $_error');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_daftarVersiApk.isEmpty) {
      Log.info('Daftar versi APK kosong, menampilkan placeholder');
      return const Center(child: Text('Tidak ada data versi APK.'));
    }

    Log.info('Menampilkan ListView dengan ${_daftarVersiApk.length} item');
    return RefreshIndicator(
      onRefresh: () async {
        Log.info('User melakukan pull-to-refresh pada daftar versi APK');
        await _loadData();
        Log.info('Pull-to-refresh selesai, data berhasil dimuat ulang');
      },
      child: ListView.builder(
        itemCount: _daftarVersiApk.length,
        itemBuilder: (final context, final index) {
          final versiApk = _daftarVersiApk[index];
          final buildUniversal =
              versiApk.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;

          Log.info(
            'Membangun item ke-${index + 1} dari ${_daftarVersiApk.length} - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}, Build: $buildUniversal',
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                'Versi: ${versiApk.versiTerbaru} (Build: $buildUniversal)',
              ),
              subtitle: Text(
                versiApk.catatanRilis,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                Log.info(
                  'Tap pada item index $index - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
                );
                await _keDetail(versiApk);
              },
              onLongPress: () async {
                Log.info(
                  'LongPress pada item index $index - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
                );
                await _tampilkanDialogOpsi(versiApk);
              },
            ),
          );
        },
      ),
    );
  }
}
