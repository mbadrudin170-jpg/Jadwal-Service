// path: lib/admin/halaman/form/category_form.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/category_operation.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman form untuk menambah atau mengedit kategori dan sub-kategori.
class CategoryForm extends StatefulWidget {
  /// Model kategori yang akan diedit. Jika null, maka form akan membuat kategori baru.
  final CategoryModel? kategori;

  /// Model sub-kategori yang akan diedit.
  final SubCategoryModel? subKategori;

  /// ID kategori induk untuk membuat sub-kategori baru.
  final String? idKategoriInduk;

  /// Konstruktor untuk CategoryForm.
  const CategoryForm({
    super.key,
    this.kategori,
    this.subKategori,
    this.idKategoriInduk,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final CategoryOperation _kategoriOperasi = CategoryOperation();

  late CategoryType _tipe;
  late TextEditingController _namaController;
  final _namaFocusNode = FocusNode();

  final List<TextEditingController> _subKategoriControllers = [];
  final List<SubCategoryModel?> _subKategoriModels = [];

  bool get _isEditMode => widget.kategori != null || widget.subKategori != null;
  bool get _isSubKategoriMode =>
      widget.subKategori != null || widget.idKategoriInduk != null;

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.kategori != null || widget.subKategori != null;
    final isSubKategoriMode =
        widget.subKategori != null || widget.idKategoriInduk != null;

    Log.info(
      '''Membuat state untuk CategoryForm. Mode: ${isEditMode ? "EDIT" : "TAMBAH BARU"}, Jenis: ${isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}, ${widget.kategori != null ? "Kategori: ${widget.kategori!.name} (ID: ${widget.kategori!.id})" : ""}${widget.subKategori != null ? "Sub-Kategori: ${widget.subKategori!.name} (ID: ${widget.subKategori!.id})" : ""}${widget.idKategoriInduk != null ? "ID Kategori Induk: ${widget.idKategoriInduk}" : ""}''',
    );

    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman CategoryForm');
    Log.info('========================================');

    Log.info(
      'Membuat TextEditingController untuk input nama.',
    );
    _namaController = TextEditingController();
    Log.info(
      'TextEditingController berhasil dibuat.',
    );

    Log.info('Membuat FocusNode untuk input nama.');
    Log.info('FocusNode berhasil dibuat: ${_namaFocusNode.hashCode}');

    if (widget.kategori != null) {
      Log.info('MODE EDIT KATEGORI UTAMA terdeteksi.');
      Log.info('Data kategori yang akan diedit:');
      Log.info('  - ID: ${widget.kategori!.id}');
      Log.info('  - Nama: ${widget.kategori!.name}');
      Log.info('  - Tipe: ${widget.kategori!.type}');
      Log.info(
        '  - Jumlah Sub-Kategori: ${widget.kategori!.subCategories.length}',
      );
      Log.info('  - Diperbarui: ${widget.kategori!.updatedAt}');
      Log.info('  - isDeleted: ${widget.kategori!.isDeleted}');
      Log.info('  - Diarsipkan: ${widget.kategori!.archivedAt ?? "NULL"}');

      Log.info(
        'Mengisi TextEditingController dengan nama kategori: "${widget.kategori!.name}"',
      );
      _namaController.text = widget.kategori!.name;
      _tipe = widget.kategori!.type;
      Log.info('Tipe kategori diatur ke: ${widget.kategori!.type}');

      Log.info('Memuat sub-kategori yang sudah ada untuk diedit.');
      for (final sub in widget.kategori!.subCategories) {
        _subKategoriControllers.add(TextEditingController(text: sub.name));
        _subKategoriModels.add(sub);
      }
      Log.info('${_subKategoriControllers.length} sub-kategori dimuat.');
    } else if (widget.subKategori != null) {
      Log.info('MODE EDIT SUB-KATEGORI terdeteksi.');
      Log.info('Data sub-kategori yang akan diedit:');
      Log.info('  - ID: ${widget.subKategori!.id}');
      Log.info('  - Nama: ${widget.subKategori!.name}');
      Log.info('  - ID Kategori Induk: ${widget.subKategori!.categoryId}');
      Log.info('  - Diperbarui: ${widget.subKategori!.updatedAt}');

      Log.info(
        'Mengisi TextEditingController dengan nama sub-kategori: "${widget.subKategori!.name}"',
      );
      _namaController.text = widget.subKategori!.name;
      // FIX: Inisialisasi _tipe untuk menghindari LateInitializationError.
      // Nilai ini tidak digunakan saat menyimpan sub-kategori, jadi aman diatur ke default.
      _tipe = CategoryType.income;
      Log.info(
          'Tipe kategori diatur ke default: $_tipe (tidak relevan untuk edit sub-kategori).');
    } else {
      Log.info(
        'MODE TAMBAH BARU terdeteksi.',
      );
      Log.info('Form akan membuat kategori baru dengan:');
      Log.info('  - ID: Akan digenerate otomatis menggunakan UUID v4');
      Log.info('  - Tipe Default: income');
      Log.info('  - Nama: Dari input pengguna');
      Log.info('  - Sub-Kategori: Opsional, bisa ditambahkan multiple');
      Log.info('  - Diperbarui: Akan diatur oleh lapisan Operasi Data');

      Log.info('Mengatur tipe default ke income.');
      _tipe = CategoryType.income;
      Log.info('Tipe kategori diatur ke: $_tipe');

      Log.info('Menambahkan field input sub-kategori pertama secara default.');
      _tambahInputSubKategori();
    }

    Log.info(
      'Inisialisasi CategoryForm selesai. Siap menerima input dari pengguna.',
    );
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman CategoryForm');
    Log.info('Membersihkan resource:');
    Log.info('  - Mendispose TextEditingController utama (_namaController)');
    Log.info('  - Mendispose FocusNode (_namaFocusNode)');
    Log.info(
      '  - Mendispose ${_subKategoriControllers.length} TextEditingController sub-kategori',
    );
    Log.info('========================================');

    _namaController.dispose();
    _namaFocusNode.dispose();

    for (int i = 0; i < _subKategoriControllers.length; i++) {
      Log.info('  Mendispose sub-kategori controller ke-${i + 1}');
      _subKategoriControllers[i].dispose();
    }

    Log.info('Semua resource berhasil dibersihkan.');
    super.dispose();
  }

  void _tambahInputSubKategori() {
    Log.info('========================================');
    Log.info('AKSI: Menambahkan field input sub-kategori baru');
    Log.info(
      'Jumlah field sub-kategori sebelum ditambah: ${_subKategoriControllers.length}',
    );
    Log.info('========================================');

    setState(() {
      _subKategoriControllers.add(TextEditingController());
      _subKategoriModels.add(null);
    });

    Log.info('Field sub-kategori baru berhasil ditambahkan.');
    Log.info(
      'Jumlah field sub-kategori sekarang: ${_subKategoriControllers.length}',
    );
    Log.info('Index field baru: ${_subKategoriControllers.length - 1}');
  }

  void _hapusInputSubKategori(final int index) {
    Log.info('========================================');
    Log.info('AKSI: Menghapus field input sub-kategori');
    Log.info('Index yang akan dihapus: $index');
    Log.info(
      'Jumlah field sub-kategori sebelum dihapus: ${_subKategoriControllers.length}',
    );

    if (index >= 0 && index < _subKategoriControllers.length) {
      Log.info(
        'Nilai field sebelum dihapus: "${_subKategoriControllers[index].text}"',
      );
    } else {
      Log.warning(
        'Index $index tidak valid. Jumlah field: ${_subKategoriControllers.length}',
      );
    }
    Log.info('========================================');

    setState(() {
      Log.info('Mendispose controller pada index $index.');
      _subKategoriControllers[index].dispose();
      Log.info('Menghapus controller dari list.');
      _subKategoriControllers.removeAt(index);
      _subKategoriModels.removeAt(index);
    });

    Log.info('Field sub-kategori berhasil dihapus.');
    Log.info(
      'Jumlah field sub-kategori sekarang: ${_subKategoriControllers.length}',
    );
  }

  Future<void> _saveForm() async {
    Log.info('========================================');
    Log.info('AKSI: Tombol Simpan Ditekan');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info(
      'Jenis: ${_isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}',
    );
    Log.info('Nama yang akan disimpan: "${_namaController.text}"');
    if (!_isSubKategoriMode || !_isEditMode) {
      Log.info('Tipe kategori: $_tipe');
    }
    Log.info('========================================');

    Log.info('Memvalidasi form...');
    if (_formKey.currentState!.validate()) {
      Log.info('Validasi form BERHASIL. Semua input valid.');

      try {
        if (_isEditMode && widget.subKategori != null) {
          Log.info('========================================');
          Log.info('PROSES UPDATE SUB-KATEGORI (MODE EDIT SUB-KATEGORI)');
          Log.info('========================================');

          final String parentCategoryId = widget.subKategori!.categoryId;

          Log.info('Data sub-kategori sebelum update:');
          Log.info('  - ID: ${widget.subKategori!.id}');
          Log.info('  - Nama Lama: ${widget.subKategori!.name}');
          Log.info('  - Nama Baru: ${_namaController.text}');
          Log.info('  - ID Kategori Induk: $parentCategoryId');

          Log.info(
            'Mengambil data kategori induk dengan ID: $parentCategoryId',
          );
          final kategoriInduk = await _kategoriOperasi
              .getCategoryById(parentCategoryId) as CategoryModel?;

          if (kategoriInduk == null) {
            throw Exception('Kategori induk tidak ditemukan.');
          }

          Log.info(
            'Kategori induk ditemukan: ${kategoriInduk.name} (memiliki ${kategoriInduk.subCategories.length} sub-kategori).',
          );
          Log.info(
            'Mencari index sub-kategori dengan ID: ${widget.subKategori!.id} dalam daftar sub-kategori.',
          );

          final subKategoriIndex = kategoriInduk.subCategories
              .indexWhere((final s) => s.id == widget.subKategori!.id);

          if (subKategoriIndex != -1) {
            Log.info('Sub-kategori ditemukan pada index: $subKategoriIndex');
            Log.info(
              'Nama sub-kategori sebelum update: "${kategoriInduk.subCategories[subKategoriIndex].name}"',
            );

            Log.info(
              'Membuat salinan sub-kategori dengan nama baru.',
            );
            final subKategoriDiperbarui =
                kategoriInduk.subCategories[subKategoriIndex].copyWith(
              name: _namaController.text,
            );

            Log.info(
              'Mengganti sub-kategori pada index $subKategoriIndex dengan data baru.',
            );
            kategoriInduk.subCategories[subKategoriIndex] =
                subKategoriDiperbarui;

            Log.info(
              'Memanggil _kategoriOperasi.updateCategory() untuk menyimpan perubahan kategori induk.',
            );
            await _kategoriOperasi.updateCategory(kategoriInduk);

            Log.info('Update sub-kategori BERHASIL.');
            Log.info(
              'Nama sub-kategori berubah dari "${widget.subKategori!.name}" menjadi "${_namaController.text}"',
            );
          } else {
            Log.error(
              'Sub-kategori dengan ID ${widget.subKategori!.id} tidak ditemukan dalam daftar sub-kategori kategori induk.',
            );
            throw Exception('Sub-kategori tidak ditemukan untuk diedit.');
          }
        } else if (_isEditMode && widget.kategori != null) {
          Log.info('========================================');
          Log.info('PROSES UPDATE KATEGORI UTAMA (MODE EDIT KATEGORI)');
          Log.info('========================================');

          Log.info('Memproses daftar sub-kategori untuk update...');
          final List<SubCategoryModel> newSubCategoryList = [];
          for (int i = 0; i < _subKategoriControllers.length; i++) {
            final controller = _subKategoriControllers[i];
            final originalModel = _subKategoriModels[i];

            if (controller.text.isNotEmpty) {
              if (originalModel != null) {
                // Ini adalah sub-kategori yang sudah ada yang mungkin telah diedit
                newSubCategoryList
                    .add(originalModel.copyWith(name: controller.text));
              } else {
                // Ini adalah sub-kategori baru
                newSubCategoryList.add(SubCategoryModel(
                  name: controller.text,
                  categoryId: widget.kategori!.id,
                ));
              }
            }
          }

          final kategoriDiperbarui = widget.kategori!.copyWith(
            name: _namaController.text,
            type: _tipe,
            subCategories: newSubCategoryList,
          );

          Log.info(
            'Memanggil _kategoriOperasi.updateCategory() untuk menyimpan perubahan.',
          );
          await _kategoriOperasi.updateCategory(kategoriDiperbarui);

          Log.info('Update kategori utama BERHASIL.');
        } else {
          Log.info('========================================');
          Log.info('PROSES TAMBAH KATEGORI BARU (MODE TAMBAH)');
          Log.info('========================================');

          Log.info('Menggenerate UUID v4 untuk ID kategori baru.');
          final String kategoriId = const Uuid().v4();
          Log.info('UUID berhasil digenerate: $kategoriId');

          Log.info(
            'Memproses ${_subKategoriControllers.length} field input sub-kategori.',
          );

          int subKategoriKosong = 0;
          int subKategoriTerisi = 0;

          final List<SubCategoryModel> subKategoriList =
              _subKategoriControllers.where((final controller) {
            final isEmpty = controller.text.isEmpty;
            if (isEmpty) {
              subKategoriKosong++;
              Log.info(
                '  Sub-kategori dengan nilai "${controller.text}" akan DIABAIKAN karena kosong.',
              );
            } else {
              subKategoriTerisi++;
              Log.info(
                '  Sub-kategori dengan nilai "${controller.text}" akan DISIMPAN.',
              );
            }
            return !isEmpty;
          }).map((final controller) {
            return SubCategoryModel(
              name: controller.text,
              categoryId: kategoriId,
            );
          }).toList();

          Log.info(
            'Ringkasan sub-kategori: $subKategoriTerisi akan disimpan, $subKategoriKosong diabaikan.',
          );

          Log.info('Membuat objek CategoryModel baru.');
          final kategoriBaru = CategoryModel(
            id: kategoriId,
            name: _namaController.text,
            type: _tipe,
            subCategories: subKategoriList,
          );

          Log.info('Objek CategoryModel berhasil dibuat:');
          Log.info('  - ID: ${kategoriBaru.id}');
          Log.info('  - Nama: ${kategoriBaru.name}');
          Log.info('  - Tipe: ${kategoriBaru.type}');
          Log.info(
            '  - Jumlah Sub-Kategori: ${kategoriBaru.subCategories.length}',
          );
          Log.info('  - Diperbarui: Akan diatur oleh lapisan Operasi Data.');

          Log.info(
            'Memanggil _kategoriOperasi.createCategory() untuk menyimpan kategori baru.',
          );
          await _kategoriOperasi.createCategory(kategoriBaru);
        }

        if (!mounted) {
          Log.warning(
            'Widget sudah tidak mounted setelah penyimpanan berhasil. Tidak dapat menampilkan SnackBar atau melakukan Navigator.pop.',
          );
          return;
        }

        final hasConnection = await InternetConnectionService().checkConnection();
        if (hasConnection) {
          await SyncCheckService().runSyncCheck();
          if (mounted) {
            ToastUtil.success(
                context, 'Kategori berhasil disimpan dan disinkronkan.');
          }
        } else {
          if (mounted) {
            ToastUtil.info(context,
                'Koneksi offline. Data disimpan lokal dan akan disinkronkan saat online.');
          }
        }

        Navigator.pop(context, true);
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menyimpan ${_isSubKategoriMode ? 'sub-kategori' : 'kategori'}. Proses ${_isEditMode ? 'update' : 'create'} mengalami kegagalan. Kemungkinan penyebab: koneksi database gagal, constraint violation, data tidak valid, atau terjadi error saat operasi database.',
          e: e,
          st: s,
        );

        if (!mounted) {
          Log.warning(
            'Widget sudah tidak mounted setelah error. Tidak dapat menampilkan SnackBar error.',
          );
          return;
        }

        Log.info(
          'Widget masih mounted. Menampilkan SnackBar error ke pengguna.',
        );
        ToastUtil.error(context, 'Gagal menyimpan: $e');
        Log.info('SnackBar error telah ditampilkan.');
      }
    } else {
      Log.warning('Validasi form GAGAL. Terdapat input yang tidak valid.');
      Log.warning(
        'Kemungkinan penyebab: Nama kategori/sub-kategori kosong atau tidak memenuhi kriteria validasi.',
      );
      Log.info('Form tidak akan disimpan sampai semua input valid.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    String judul = 'Form Kategori';
    if (_isEditMode && widget.kategori != null) judul = 'Edit Kategori';
    if (_isEditMode && widget.subKategori != null) judul = 'Edit Sub-Kategori';
    if (!_isEditMode && widget.idKategoriInduk != null) {
      judul = 'Tambah Sub-Kategori';
    }
    if (!_isEditMode && widget.kategori == null && widget.subKategori == null) {
      judul = 'Tambah Kategori Baru';
    }

    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI CategoryForm');
    Log.info('Judul halaman: "$judul"');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info(
      'Jenis: ${_isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}',
    );
    Log.info('Nama di controller: "${_namaController.text}"');
    // Log.info('Tipe terpilih: $_tipe');
    Log.info('Jumlah field sub-kategori: ${_subKategoriControllers.length}');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(judul),
        leading: BackButton(
          onPressed: () {
            Log.info(
              'NAVIGASI: Tombol Kembali ditekan. Kembali ke halaman sebelumnya dengan result false (tidak ada perubahan).',
            );
            Navigator.pop(context, false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  decoration: InputDecoration(
                    labelText: _isSubKategoriMode
                        ? 'Nama Sub-Kategori'
                        : 'Nama Kategori',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (final _) {
                    Log.info(
                      'INPUT: Field nama disubmit melalui keyboard (TextInputAction.done).',
                    );
                    Log.info('Nilai yang disubmit: "${_namaController.text}"');
                    Log.info('Menghilangkan fokus dari input.');
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: (final value) {
                    Log.info(
                      'INPUT: Nama ${_isSubKategoriMode ? "sub-kategori" : "kategori"} berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (final value) {
                    Log.info(
                      'VALIDASI: Memvalidasi input nama. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Nama kosong.');
                      return 'Nama tidak boleh kosong';
                    }
                    Log.info('VALIDASI BERHASIL: Nama valid.');
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (!_isSubKategoriMode) ...[
                  DropdownButtonFormField<CategoryType>(
                    initialValue: _tipe,
                    decoration: const InputDecoration(
                      labelText: 'Tipe',
                      border: OutlineInputBorder(),
                    ),
                    items: CategoryType.values
                        .where((final type) =>
                            type == CategoryType.income ||
                            type == CategoryType.expense)
                        .map((final CategoryType category) {
                      Log.info(
                          'Membuat DropdownMenuItem untuk: ${category.displayName}');

                      return DropdownMenuItem<CategoryType>(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }).toList(),
                    onChanged: (final CategoryType? newValue) {
                      if (newValue != null) {
                        Log.info('DROPDOWN: Tipe kategori diubah.');
                        Log.info('  - Tipe Lama: $_tipe');
                        Log.info('  - Tipe Baru: $newValue');
                        setState(() {
                          _tipe = newValue;
                        });
                        Log.info('State _tipe berhasil diperbarui ke: $_tipe');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (!_isSubKategoriMode) ...[
                  const Text(
                    'Sub-Kategori',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subKategoriControllers.length,
                    itemBuilder: (final context, final index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _subKategoriControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Nama Sub-Kategori ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (final value) {
                                  Log.info(
                                    'INPUT: Sub-kategori ke-${index + 1} berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Log.info(
                                  'AKSI: Tombol hapus sub-kategori ke-${index + 1} ditekan.',
                                );
                                _hapusInputSubKategori(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Log.info(
                          'AKSI: Tombol "Tambah Input" sub-kategori ditekan.',
                        );
                        _tambahInputSubKategori();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Input'),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Log.info('AKSI: Tombol Simpan ditekan oleh pengguna.');
                    await _saveForm();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
