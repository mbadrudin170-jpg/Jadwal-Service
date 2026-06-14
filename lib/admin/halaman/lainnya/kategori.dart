// path: lib/admin/halaman/lainnya/kategori.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/form_kategori.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/kategori_op_sqlite.dart';
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
  late final KategoriOpSqlite _categoryOperation;
  late final SubKategoriOpSqlite _subCategoryOperation;
  late Future<List<KategoriModel>> _categoryListFuture;
  TipeKategori _selectedType = TipeKategori.income;
  bool _isEdit = false;
  bool _isArchiveMode = false;

  @override
  void initState() {
    super.initState();
    _categoryOperation = ref.read(kategoriOpSqliteProvider);
    _subCategoryOperation = ref.read(subKategoriOpSqliteProvider);
    Log.info('Menginisialisasi halaman Kategori');
    _loadCategories();
  }

  Future<List<KategoriModel>> _loadCategoriesAndHandleErrors() async {
    try {
      return await _categoryOperation.getAll();
    } on Exception catch (e, st) {
      Log.error('Gagal memuat data kategori', e: e, s: st);
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

  Future<void> _navigateToEditCategory(final KategoriModel category) async {
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

  Future<void> _softDeleteCategory(final KategoriModel category) async {
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
      Log.error('Gagal soft delete kategori ID: ${category.id}', e: e, s: st);
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
          e: e, s: st);
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
      Log.error('Gagal melakukan soft delete semua kategori', e: e, s: st);
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
                    setState(() => _selectedType = TipeKategori.income),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == TipeKategori.income
                      ? Colors.green
                      : Colors.grey,
                ),
                child: const Text('Pemasukan'),
              ),
              ElevatedButton(
                onPressed: () =>
                    setState(() => _selectedType = TipeKategori.expense),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == TipeKategori.expense
                      ? context.colorScheme.error
                      : Colors.grey,
                ),
                child: const Text('Pengeluaran'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<KategoriModel>>(
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
