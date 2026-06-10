// path: lib/admin/halaman/lainnya/category.dart
// Fitur: Manajemen Kategori
// diubah: Menggunakan ToastUtil sesuai instruksi.
// diubah: Mengganti implementasi arsip manual dengan memanggil metode softDelete dari operasi yang relevan.
// diubah: Menambahkan fungsi dan tombol untuk softDeleteAll.
// diubah: Memperbaiki logika arsip sub-kategori agar memanggil SubCategoryOperation.
// diperbaiki: Memperbaiki error use_build_context_synchronously dengan memindahkan logika async ke method terpisah.
// diperbaiki: Menghilangkan unnecessary_string_escapes warnings.
// diperbaiki: Menambahkan final pada parameter dan dokumentasi untuk member publik.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/category_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/sub_category_operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

/// State untuk [CategoryPage].
class _CategoryPageState extends ConsumerState<CategoryPage> {
  late final CategoryOperation _categoryOperation;
  late final SubCategoryOperation _subCategoryOperation;
  late Future<List<CategoryModel>> _categoryListFuture;
  CategoryType _selectedType = CategoryType.income;
  bool _isEdit = false;
  bool _isArchiveMode = false;

  @override
  void initState() {
    super.initState();
    _categoryOperation = ref.read(categoryOperationProvider);
    _subCategoryOperation = ref.read(subCategoryOperationProvider);
    Log.info('Menginisialisasi halaman Kategori');
    _loadCategories();
  }

  Future<List<CategoryModel>> _loadCategoriesAndHandleErrors() async {
    try {
      return await _categoryOperation.getCategories();
    } on Exception catch (e, st) {
      Log.error('Gagal memuat data kategori', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data kategori: $e');
      }
      rethrow;
    }
  }

  void _loadCategories() {
    Log.info('Memuat data kategori dari database');
    setState(() {
      _categoryListFuture = _loadCategoriesAndHandleErrors();
    });
  }

  Future<void> _addCategory() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (final context) => const CategoryForm()),
    );
    if (result ?? false) {
      if (!mounted) return;
      Log.info('Kategori baru berhasil ditambahkan, memuat ulang daftar.');
      ToastUtil.success(context, 'Kategori berhasil ditambahkan.');
      _loadCategories();
    }
  }

  Future<void> _navigateToEditCategory(final CategoryModel category) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => CategoryForm(kategori: category),
      ),
    );
    if (result ?? false) {
      if (!mounted) return;
      _loadCategories();
    }
  }

  Future<void> _navigateToEditSubCategory(
    final SubCategoryModel subCategory,
    final String categoryId,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => CategoryForm(
          subKategori: subCategory,
          idKategoriInduk: categoryId,
        ),
      ),
    );
    if (result ?? false) {
      if (!mounted) return;
      _loadCategories();
    }
  }

  Future<bool> _showConfirmDialog(
      final String title, final String content) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
    return confirm ?? false;
  }

  Future<void> _softDeleteCategory(final CategoryModel category) async {
    final confirm = await _showConfirmDialog(
      'Arsipkan Kategori',
      'Anda yakin ingin mengarsipkan "${category.name}"? Ini juga akan mengarsipkan semua sub-kategorinya.',
    );
    if (!mounted || !confirm) return;

    try {
      await _categoryOperation.softDelete(category.id);
      if (!mounted) return;
      ToastUtil.success(
          context, 'Kategori "${category.name}" berhasil diarsipkan.');
      _loadCategories();
    } on Exception catch (e, st) {
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan kategori: $e');
      Log.error('Gagal soft delete kategori ID: ${category.id}', e: e, st: st);
    }
  }

  Future<void> _softDeleteSubCategory(
      final SubCategoryModel subCategory) async {
    final confirm = await _showConfirmDialog(
      'Arsipkan Sub-Kategori',
      'Anda yakin ingin mengarsipkan sub-kategori "${subCategory.name}"?',
    );
    if (!mounted || !confirm) return;

    try {
      await _subCategoryOperation.softDelete(subCategory.id);
      if (!mounted) return;
      ToastUtil.success(
          context, 'Sub-kategori "${subCategory.name}" berhasil diarsipkan.');
      _loadCategories();
    } on Exception catch (e, st) {
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan sub-kategori: $e');
      Log.error('Gagal soft delete sub-kategori ID: ${subCategory.id}',
          e: e, st: st);
    }
  }

  Future<void> _softDeleteAll() async {
    final confirm = await _showConfirmDialog(
      'Arsipkan Semua Kategori',
      'Anda yakin ingin mengarsipkan SEMUA kategori? Tindakan ini akan mengarsipkan semua kategori dan sub-kategorinya.',
    );
    if (!mounted || !confirm) return;

    try {
      final count = await _categoryOperation.softDeleteAll();
      if (!mounted) return;
      ToastUtil.success(context, 'Berhasil mengarsipkan $count kategori.');
      _loadCategories();
    } on Exception catch (e, st) {
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan semua kategori: $e');
      Log.error('Gagal melakukan soft delete semua kategori', e: e, st: st);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          if (_isArchiveMode)
            IconButton(
              tooltip: 'Arsipkan Semua',
              onPressed: _softDeleteAll,
              icon: const Icon(TIcons.packages),
            ),
          IconButton(
            tooltip: _isArchiveMode ? 'Selesai' : 'Arsipkan',
            onPressed: () => setState(() {
              _isArchiveMode = !_isArchiveMode;
              if (_isArchiveMode) _isEdit = false;
            }),
            icon: Icon(_isArchiveMode ? TIcons.check : TIcons.archive),
          ),
          IconButton(
            tooltip: _isEdit ? 'Selesai' : 'Edit',
            onPressed: () => setState(() {
              _isEdit = !_isEdit;
              if (_isEdit) _isArchiveMode = false;
            }),
            icon: Icon(_isEdit ? TIcons.check : TIcons.edit),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () =>
                    setState(() => _selectedType = CategoryType.income),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == CategoryType.income
                      ? Colors.green
                      : Colors.grey,
                ),
                child: const Text('Pemasukan'),
              ),
              ElevatedButton(
                onPressed: () =>
                    setState(() => _selectedType = CategoryType.expense),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == CategoryType.expense
                      ? context.colorScheme.error
                      : Colors.grey,
                ),
                child: const Text('Pengeluaran'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<CategoryModel>>(
              future: _categoryListFuture,
              builder: (final _, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada kategori ditemukan.'));
                }

                final filteredKategori = snapshot.data!
                    .where((final k) =>
                        k.type == _selectedType && k.archivedAt == null)
                    .toList();

                return ListView.builder(
                  itemCount: filteredKategori.length,
                  itemBuilder: (final _, final index) {
                    final kategori = filteredKategori[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text(kategori.name),
                        trailing: _isEdit
                            ? IconButton(
                                icon: const Icon(TIcons.edit),
                                onPressed: () =>
                                    _navigateToEditCategory(kategori),
                              )
                            : _isArchiveMode
                                ? IconButton(
                                    icon: const Icon(TIcons.archive),
                                    onPressed: () =>
                                        _softDeleteCategory(kategori),
                                  )
                                : null,
                        children: kategori.subCategories
                            .where((final sub) => sub.archivedAt == null)
                            .map((final sub) {
                          return ListTile(
                            title: Text(sub.name),
                            trailing: _isEdit
                                ? IconButton(
                                    icon: const Icon(TIcons.edit),
                                    onPressed: () => _navigateToEditSubCategory(
                                        sub, kategori.id),
                                  )
                                : _isArchiveMode
                                    ? IconButton(
                                        icon: const Icon(TIcons.archive),
                                        onPressed: () =>
                                            _softDeleteSubCategory(sub),
                                      )
                                    : null,
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(TIcons.add),
      ),
    );
  }
}
