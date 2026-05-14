// path: lib/admin/halaman/lainnya/pelanggan.dart
// diubah: Menghapus import yang tidak digunakan dan memperbaiki gaya penulisan fungsi.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';

/// Enum untuk menentukan opsi pengurutan daftar pelanggan.
enum OpsiUrut {
  /// Urutkan berdasarkan nama dari A hingga Z.
  namaAZ,

  /// Urutkan berdasarkan nama dari Z hingga A.
  namaZA,
}

/// Halaman untuk menampilkan dan mengelola daftar semua pelanggan.
///
/// Admin dapat mencari, mengurutkan, menambah, mengedit, dan mengarsipkan pelanggan.
class PelangganPage extends StatefulWidget {
  /// Membuat instance dari [PelangganPage].
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<PelangganModel> _allPelanggan = [];
  List<PelangganModel> _filteredPelanggan = [];
  bool _isLoading = true;

  OpsiUrut _opsiUrutSaatIni = OpsiUrut.namaAZ;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Menginisialisasi state untuk PelangganPage. Memanggil _refreshPelangganList untuk pertama kali.',
    );
    unawaited(_refreshPelangganList());
    _searchController.addListener(_filterPelanggan);
  }

  @override
  void dispose() {
    Log.info(
      'Membersihkan resource di PelangganPage. _searchController di-dispose.',
    );
    _searchController.dispose();
    super.dispose();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari nama pelanggan...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            )
          : const Text('Daftar Pelanggan'),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: 'Urutkan',
          onPressed: _showSortDialog,
        ),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            Log.info(
              'Tombol search/close ditekan. Mengubah state _isSearching.',
            );
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                Log.info(
                  'Mode pencarian dinonaktifkan. Membersihkan search controller.',
                );
                _searchController.clear();
              } else {
                Log.info('Mode pencarian diaktifkan.');
              }
            });
          },
        ),
      ],
    );
  }

  Future<void> _showSortDialog() async {
    Log.info('Menampilkan dialog opsi pengurutan.');
    OpsiUrut? groupValue = _opsiUrutSaatIni;
    final OpsiUrut? result = await showDialog<OpsiUrut>(
      context: context,
      builder: (final BuildContext context) {
        return StatefulBuilder(
          builder: (final context, final setState) {
            void handleRadioValueChanged(final OpsiUrut? value) {
              setState(() {
                groupValue = value;
              });
            }

            return AlertDialog(
              title: const Text('Urutkan Berdasarkan'),
              content: RadioGroup<OpsiUrut>(
                groupValue: groupValue,
                onChanged: handleRadioValueChanged,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: const Text('Nama (A-Z)'),
                      leading: const Radio<OpsiUrut>(
                        value: OpsiUrut.namaAZ,
                      ),
                      onTap: () => handleRadioValueChanged(OpsiUrut.namaAZ),
                    ),
                    ListTile(
                      title: const Text('Nama (Z-A)'),
                      leading: const Radio<OpsiUrut>(
                        value: OpsiUrut.namaZA,
                      ),
                      onTap: () => handleRadioValueChanged(OpsiUrut.namaZA),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(groupValue);
                  },
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      _applySort(result);
    }
  }

  void _applySort(final OpsiUrut option) {
    Log.info('Menerapkan pengurutan: $option');
    setState(() {
      _opsiUrutSaatIni = option;
      switch (option) {
        case OpsiUrut.namaAZ:
          _filteredPelanggan.sort(
            (final a, final b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
          );
          break;
        case OpsiUrut.namaZA:
          _filteredPelanggan.sort(
            (final a, final b) => b.nama.toLowerCase().compareTo(a.nama.toLowerCase()),
          );
          break;
      }
    });
  }

  Future<void> _refreshPelangganList() async {
    Log.info(
      'Memulai proses refresh daftar pelanggan. Mengatur _isLoading ke true.',
    );
    if (mounted) setState(() => _isLoading = true);

    try {
      final list = await _pelangganOperasi.getPelanggan();
      Log.info('Berhasil mengambil ${list.length} data pelanggan.');

      if (mounted) {
        setState(() {
          _allPelanggan = list;
          _filteredPelanggan = list;
          _applySort(_opsiUrutSaatIni); // Terapkan urutan yang ada
          _isLoading = false;
          Log.info(
            'State diperbarui dengan daftar pelanggan yang baru. _isLoading diatur ke false.',
          );
        });
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal total saat memuat daftar pelanggan.',
        e: e,
        st: s,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data pelanggan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterPelanggan() {
    final query = _searchController.text.toLowerCase();
    Log.info(
      'Listener _searchController aktif. Memfilter daftar dengan query: "$query".',
    );

    setState(() {
      _filteredPelanggan = _allPelanggan
          .where((final p) => p.nama.toLowerCase().contains(query))
          .toList();
      _applySort(_opsiUrutSaatIni); // Terapkan kembali urutan setelah filter
      Log.info(
        'Filter selesai. Ditemukan ${_filteredPelanggan.length} pelanggan yang cocok.',
      );
    });
  }

  Future<void> _tambahPelanggan() async {
    Log.info(
      'Tombol FAB (+) ditekan. Menavigasi ke FormPelanggan untuk menambah data baru.',
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (final context) => const FormPelanggan()),
    );
    if (result ?? false) {
      Log.info(
        'Kembali dari FormPelanggan dengan hasil sukses (true). Memanggil _refreshPelangganList untuk memuat ulang data.',
      );
      await _refreshPelangganList();
    } else {
      Log.info(
        'Kembali dari FormPelanggan tanpa hasil (false atau null). Tidak ada aksi yang diambil.',
      );
    }
  }

  Future<void> _showDialogOpsi(final PelangganModel pelanggan) async {
    Log.info(
      'Menampilkan dialog opsi (Edit/Arsipkan) untuk pelanggan: ${pelanggan.nama} (ID: ${pelanggan.id}).',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
        return AlertDialog(
          title: Text(pelanggan.nama),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Pelanggan'),
                onTap: () async {
                  Log.info(
                    'Opsi "Edit Pelanggan" dipilih. Menutup dialog dan menavigasi ke FormPelanggan dengan data yang ada.',
                  );
                  Navigator.of(dialogContext).pop();
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (final context) => FormPelanggan(pelanggan: pelanggan),
                    ),
                  );
                  await _refreshPelangganList();
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Arsipkan Pelanggan'),
                onTap: () async {
                  Log.info(
                    'Opsi "Arsipkan Pelanggan" dipilih. Menutup dialog dan memanggil _showDialogArsipkan.',
                  );
                  Navigator.of(dialogContext).pop();
                  await _showDialogArsipkan(pelanggan);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDialogArsipkan(final PelangganModel pelanggan) async {
    Log.info(
      'Menampilkan dialog konfirmasi pengarsipan untuk pelanggan "${pelanggan.nama}".',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan pelanggan "${pelanggan.nama}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Pengguna membatalkan proses pengarsipan.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Arsipkan',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Log.info(
                  'Pengguna mengonfirmasi pengarsipan. Memanggil _arsipkanPelanggan dengan ID: ${pelanggan.id}.',
                );
                Navigator.of(context).pop();
                await _arsipkanPelanggan(pelanggan.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _arsipkanPelanggan(final String id) async {
    Log.info('Memulai proses pengarsipan untuk ID pelanggan: $id.');
    try {
      await _pelangganOperasi.arsipkanPelanggan(id);
      Log.info(
        'Berhasil mengarsipkan pelanggan dengan ID: $id. Memuat ulang daftar dan menampilkan SnackBar.',
      );
      await _refreshPelangganList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pelanggan berhasil diarsipkan.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengarsipkan pelanggan dengan ID: $id.',
        e: e,
        st: s,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengarsipkan pelanggan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI PelangganPage. Status loading: $_isLoading.');
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshPelangganList,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPelanggan,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredPelanggan.isEmpty) {
      Log.info('Membangun UI content: Daftar pelanggan kosong.');
      return Center(
        child: Text(
          _isSearching
              ? 'Pelanggan tidak ditemukan untuk pencarian ini.'
              : 'Belum ada pelanggan. Tekan tombol + untuk menambah.',
          textAlign: TextAlign.center,
        ),
      );
    }

    Log.info(
      'Membangun UI content: Menampilkan ListView dengan ${_filteredPelanggan.length} pelanggan.',
    );
    return ListView.builder(
      itemCount: _filteredPelanggan.length,
      itemBuilder: (final context, final index) {
        final pelanggan = _filteredPelanggan[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              pelanggan.nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(pelanggan.macAddress),
            onTap: () async {
              Log.info(
                'ListTile untuk pelanggan "${pelanggan.nama}" ditekan. Menavigasi ke DetailPelangganPage.',
              );
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (final context) =>
                      DetailPelangganPage(idPelanggan: pelanggan.id),
                ),
              );
            },
            onLongPress: () async {
              Log.info(
                'ListTile untuk pelanggan "${pelanggan.nama}" ditekan lama (long press). Memanggil _showDialogOpsi.',
              );
              await _showDialogOpsi(pelanggan);
            },
          ),
        );
      },
    );
  }
}
