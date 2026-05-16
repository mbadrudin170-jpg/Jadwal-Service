// path: lib/admin/halaman/lainnya/kategori.dart
// Fitur: Manajemen Kategori
// Tujuan: Menampilkan, menambah, mengedit, dan mengarsipkan kategori dan sub-kategori pemasukan/pengeluaran.
//
// Daftar Fungsi:
// - _loadKategori(): Memuat daftar kategori dari database.
// - _tambahKategori(): Navigasi ke halaman form untuk menambah kategori baru.
// - _tampilkanDialogKonfirmasi(): Menampilkan dialog konfirmasi generik.
// - _arsipkanKategoriUtama(): Mengarsipkan kategori utama setelah konfirmasi.
// - _arsipkanSubKategori(): Mengarsipkan sub-kategori setelah konfirmasi.

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/form_kategori.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/category_operasi.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Halaman untuk mengelola kategori pemasukan dan pengeluaran.
///
/// Halaman ini memungkinkan admin untuk melihat daftar kategori,
/// memfilter berdasarkan tipe (pemasukan/pengeluaran), serta
/// melakukan operasi tambah, edit, dan arsip pada kategori dan sub-kategori.
class KategoriPage extends StatefulWidget {
  /// Konstruktor untuk membuat instance [KategoriPage].
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final CategoryOperation _kategoriOperasi = CategoryOperation();
  late Future<List<CategoryModel>> _listaKategoriFuture;
  CategoryType _selectedTipe = CategoryType.income;
  bool _isEdit = false;
  bool _isArsipMode = false;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Kategori');
    _loadKategori();
  }

  void _loadKategori() {
    Log.info('Memuat data kategori dari database');
    setState(() {
      _listaKategoriFuture = _kategoriOperasi.getCategories().then((final data) {
        final int totalSubKategori = data.fold(
          0,
          (final sum, final kat) => sum + kat.subCategories.length,
        );
        Log.info(
          'Berhasil memuat ${data.length} kategori utama dengan total $totalSubKategori sub-kategori',
        );
        for (var kat in data) {
          Log.info(
            'Kategori: ${kat.name} (ID: ${kat.id}, Tipe: ${kat.type.name}, Sub: ${kat.subCategories.length}, Diarsipkan: ${kat.archivedAt != null ? "Ya" : "Tidak"})',
          );
        }
        return data;
      })
          // diubah: Menambahkan tipe eksplisit Object dan StackTrace pada error handling.
          // Alasan: Untuk memenuhi aturan analisis statis yang ketat dan menghindari error 'inference_failure' dan 'argument_type_not_assignable'.
          .catchError((final Object e, final StackTrace st) {
        Log.error(
          'Gagal memuat data kategori dari database',
          e: e,
          st: st,
        );
        // diubah: Melempar error dengan tipe yang benar.
        // Alasan: Mengikuti praktik terbaik penanganan error setelah tipenya dipastikan.
        throw Exception(e);
      });
    });
  }

  Future<void> _tambahKategori() async {
    Log.info('Navigasi ke Form Tambah Kategori');
    // diubah: Menambahkan tipe eksplisit <bool> pada Navigator.push dan MaterialPageRoute.
    // Alasan: Untuk memenuhi aturan 'inference_failure_on_instance_creation' karena halaman form mengembalikan nilai boolean.
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (final context) => const FormKategoriPage()),
    );
    if (result ?? false) {
      Log.info(
        'Kategori baru berhasil ditambahkan, menyegarkan daftar kategori',
      );
      _loadKategori();
    } else {
      Log.info('Kembali dari Form Tambah Kategori tanpa menambah data');
    }
  }

  Future<bool> _tampilkanDialogKonfirmasi(final String judul, final String konten) async {
    Log.info('Menampilkan dialog konfirmasi: "$judul"');
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text(judul),
          content: Text(konten),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Log.info('Dialog "$judul" - User memilih Batal');
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Log.info('Dialog "$judul" - User memilih Ya');
                Navigator.of(context).pop(true);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
    Log.info(
      'Hasil konfirmasi dialog "$judul": ${konfirmasi ?? false ? "Ya" : "Batal"}',
    );
    return konfirmasi ?? false;
  }

  Future<void> _arsipkanKategoriUtama(final CategoryModel kategori) async {
    Log.info(
      'Memproses pengarsipan kategori utama: ${kategori.name} (ID: ${kategori.id})',
    );
    final bool konfirmasi = await _tampilkanDialogKonfirmasi(
      'Arsipkan Kategori',
      'Anda yakin ingin mengarsipkan "${kategori.name}"? Kategori ini tidak akan bisa digunakan lagi.',
    );
    if (!mounted || !konfirmasi) {
      Log.info(
        'Pengarsipan kategori ${kategori.name} dibatalkan (konfirmasi: $konfirmasi, mounted: $mounted)',
      );
      return;
    }

    try {
      Log.info(
        'Mengarsipkan kategori utama ID: ${kategori.id}, nama: ${kategori.name}',
      );
      final kategoriDiperbarui = kategori.copyWith(archivedAt: DateTime.now());
      await _kategoriOperasi.updateCategory(kategoriDiperbarui);
      Log.info(
        'Kategori ${kategori.name} (ID: ${kategori.id}) berhasil diarsipkan pada ${kategoriDiperbarui.archivedAt}',
      );

      if (!mounted) return;
      SnackBarUtil.success(context, 'Kategori berhasil diarsipkan.');
      _loadKategori();
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengarsipkan kategori ID: ${kategori.id}, nama: ${kategori.name}',
        e: e,
        st: st,
      );
      if (!mounted) return;
      SnackBarUtil.error(context, 'Gagal mengarsipkan kategori: $e');
    }
  }

  Future<void> _arsipkanSubKategori(
    final CategoryModel kategoriInduk,
    final SubCategoryModel subKategori,
  ) async {
    Log.info(
      'Memproses pengarsipan sub-kategori: ${subKategori.name} (ID: ${subKategori.id}) dari kategori induk: ${kategoriInduk.name}',
    );
    final bool konfirmasi = await _tampilkanDialogKonfirmasi(
      'Arsipkan Sub-Kategori',
      'Anda yakin ingin mengarsipkan sub-kategori "${subKategori.name}"?',
    );
    if (!mounted || !konfirmasi) {
      Log.info(
        'Pengarsipan sub-kategori ${subKategori.name} dibatalkan (konfirmasi: $konfirmasi, mounted: $mounted)',
      );
      return;
    }

    try {
      Log.info(
        'Mengarsipkan sub-kategori ID: ${subKategori.id}, nama: ${subKategori.name}',
      );
      final subKategoriDiperbarui = subKategori.copyWith(
        archivedAt: DateTime.now(),
      );
      final daftarSubKategoriBaru = kategoriInduk.subCategories.map((final sub) {
        return sub.id == subKategori.id ? subKategoriDiperbarui : sub;
      }).toList();
      final kategoriIndukDiperbarui = kategoriInduk.copyWith(
        subCategories: daftarSubKategoriBaru,
        updatedAt: DateTime.now(),
      );

      await _kategoriOperasi.updateCategory(kategoriIndukDiperbarui);
      Log.info(
        'Sub-kategori ${subKategori.name} (ID: ${subKategori.id}) berhasil diarsipkan, kategori induk ${kategoriInduk.name} diperbarui',
      );

      if (!mounted) return;
      SnackBarUtil.success(context, 'Sub-kategori berhasil diarsipkan.');
      _loadKategori();
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengarsipkan sub-kategori ID: ${subKategori.id}, nama: ${subKategori.name}',
        e: e,
        st: st,
      );
      if (!mounted) return;
      SnackBarUtil.error(context, 'Gagal mengarsipkan sub-kategori: $e');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman Kategori (Mode Edit: $_isEdit, Mode Arsip: $_isArsipMode, Filter Tipe: ${_selectedTipe.name})',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            tooltip: _isArsipMode ? 'Selesai' : 'Arsipkan',
            onPressed: () {
              setState(() {
                _isArsipMode = !_isArsipMode;
                if (_isArsipMode) {
                  _isEdit = false;
                  Log.info('Mode ARSIP diaktifkan, Mode EDIT dinonaktifkan');
                } else {
                  Log.info('Mode ARSIP dinonaktifkan');
                }
              });
            },
            icon: Icon(_isArsipMode ? Icons.check : Icons.archive_outlined),
          ),
          IconButton(
            tooltip: _isEdit ? 'Selesai' : 'Edit',
            onPressed: () {
              setState(() {
                _isEdit = !_isEdit;
                if (_isEdit) {
                  _isArsipMode = false;
                  Log.info('Mode EDIT diaktifkan, Mode ARSIP dinonaktifkan');
                } else {
                  Log.info('Mode EDIT dinonaktifkan');
                }
              });
            },
            icon: Icon(_isEdit ? Icons.check : Icons.edit_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Log.info('Filter tipe diubah ke PEMASUKAN');
                  setState(() => _selectedTipe = CategoryType.income);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTipe == CategoryType.income
                      ? Colors.green
                      : Colors.grey,
                ),
                child: const Text('Pemasukan'),
              ),
              ElevatedButton(
                onPressed: () {
                  Log.info('Filter tipe diubah ke PENGELUARAN');
                  setState(() => _selectedTipe = CategoryType.expense);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTipe == CategoryType.expense
                      ? Colors.red
                      : Colors.grey,
                ),
                child: const Text('Pengeluaran'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<CategoryModel>>(
              future: _listaKategoriFuture,
              builder: (final context, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  Log.error(
                    'Terjadi error saat memuat data kategori di FutureBuilder',
                    e: snapshot.error,
                    st: snapshot.stackTrace,
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  Log.info(
                    'Data kategori kosong, tidak ada kategori ditemukan',
                  );
                  return const Center(
                    child: Text('Tidak ada kategori ditemukan.'),
                  );
                } else {
                  final filteredKategori = snapshot.data!
                      .where(
                        (final k) => k.type == _selectedTipe && k.archivedAt == null,
                      )
                      .toList();

                  Log.info(
                    'Menampilkan ${filteredKategori.length} kategori dengan tipe ${_selectedTipe.name} (total data: ${snapshot.data!.length}, difilter: ${snapshot.data!.length - filteredKategori.length} diarsipkan/beda tipe)',
                  );

                  return ListView.builder(
                    itemCount: filteredKategori.length,
                    itemBuilder: (final context, final index) {
                      final kategori = filteredKategori[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          title: Text(kategori.name),
                          trailing: _isEdit
                              ? IconButton(
                                  onPressed: () async {
                                    Log.info(
                                      'Navigasi ke Form Edit Kategori Utama: ${kategori.name} (ID: ${kategori.id})',
                                    );
                                    // diubah: Menambahkan tipe eksplisit <bool> pada Navigator.push dan MaterialPageRoute.
                                    // Alasan: Untuk memenuhi aturan 'inference_failure_on_instance_creation' karena halaman form mengembalikan nilai boolean.
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute<bool>(
                                        builder: (final context) => FormKategoriPage(
                                          kategori: kategori,
                                        ),
                                      ),
                                    );
                                    if (result ?? false) {
                                      Log.info(
                                        'Kategori ${kategori.name} berhasil diedit, menyegarkan daftar',
                                      );
                                      _loadKategori();
                                    } else {
                                      Log.info(
                                        'Kembali dari Form Edit Kategori tanpa perubahan',
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.edit),
                                )
                              : _isArsipMode
                                  ? IconButton(
                                      onPressed: () =>
                                          _arsipkanKategoriUtama(kategori),
                                      icon: const Icon(Icons.archive),
                                    )
                                  : null,
                          children: kategori.subCategories
                              .where((final sub) => sub.archivedAt == null)
                              .map((final sub) {
                            return ListTile(
                              title: Text(sub.name),
                              trailing: _isEdit
                                  ? IconButton(
                                      onPressed: () async {
                                        Log.info(
                                          'Navigasi ke Form Edit Sub-Kategori: ${sub.name} (ID: ${sub.id})',
                                        );
                                        // diubah: Menambahkan tipe eksplisit <bool> pada Navigator.push dan MaterialPageRoute.
                                        // Alasan: Untuk memenuhi aturan 'inference_failure_on_instance_creation' karena halaman form mengembalikan nilai boolean.
                                        final result =
                                            await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute<bool>(
                                            builder: (final context) =>
                                                FormKategoriPage(
                                              subKategori: sub,
                                              idKategoriInduk: kategori.id,
                                            ),
                                          ),
                                        );
                                        if (result ?? false) {
                                          Log.info(
                                            'Sub-kategori ${sub.name} berhasil diedit, menyegarkan daftar',
                                          );
                                          _loadKategori();
                                        } else {
                                          Log.info(
                                            'Kembali dari Form Edit Sub-Kategori tanpa perubahan',
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.edit),
                                    )
                                  : _isArsipMode
                                      ? IconButton(
                                          onPressed: () => _arsipkanSubKategori(
                                            kategori,
                                            sub,
                                          ),
                                          icon: const Icon(Icons.archive),
                                        )
                                      : null,
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahKategori,
        child: const Icon(Icons.add),
      ),
    );
  }
}
