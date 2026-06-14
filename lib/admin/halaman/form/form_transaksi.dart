// path: lib/admin/halaman/form/transaction_form.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/kategori_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/date_time_picker_widget.dart';

/// Halaman form untuk menambah atau mengubah data transaksi.
///
/// Form ini mendukung tiga jenis transaksi: pemasukan, pengeluaran, dan transfer.
/// Logika UI akan beradaptasi berdasarkan tipe transaksi yang dipilih.
class FormTransaksi extends ConsumerStatefulWidget {
  /// Data transaksi yang akan diedit. Jika `null`, form akan berada dalam mode tambah baru.
  final TransaksiModel? transaksi;

  /// Membuat instance dari [FormTransaksi].
  const FormTransaksi({super.key, this.transaksi});

  @override
  ConsumerState<FormTransaksi> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends ConsumerState<FormTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _jumlahFocusNode = FocusNode();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  KategoriModel? _selectedKategori;
  SubCategoryModel? _selectedSubKategori;
  TransactionType _tipe = TransactionType.income;
  DompetModel? _selectedDompet;
  DompetModel? _selectedDompetTujuan;

  late final DompetOpSqlite _dompetOpSlite;
  late final KategoriOpSqlite _kategoriOpSqlite;
  late final TransaksiOpsqlite _transaksiOpSqlite;

  List<KategoriModel> _kategoriList = [];
  List<DompetModel> _dompetList = [];
  List<KategoriModel> _kategoriFiltered = [];

  bool get _isEditMode => widget.transaksi != null;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Menginisialisasi FormTransaksiPage dalam mode: ${_isEditMode ? "Edit" : "Tambah"}.',
    );
    _dompetOpSlite = ref.read(dompetOpSqliteProvider);
    _kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    _transaksiOpSqlite = ref.read(transaksiOpSqliteProvider);
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    Log.info('Memulai pemuatan data awal (dompet & kategori).');
    setState(() => _isLoading = true);

    try {
      final dompetList = await _dompetOpSlite.getAll();
      Log.info('Berhasil memuat ${dompetList.length} dompet.');
      final kategoriList = await _kategoriOpSqlite.getAll();
      Log.info('Berhasil memuat ${kategoriList.length} kategori.');

      if (!mounted) return;

      setState(() {
        _dompetList = dompetList;
        _kategoriList = kategoriList;
      });

      if (_isEditMode) {
        Log.info(
          'Mode Edit: Mempopulasikan form dengan data transaksi ID: ${widget.transaksi!.id}',
        );
        final trx = widget.transaksi!;
        _tipe = trx.type;
        _keteranganController.text = trx.description;
        _jumlahController.text = trx.amount.abs().toString();
        _selectedDate = trx.date;
        _selectedTime = TimeOfDay.fromDateTime(trx.date);
        _selectedDompet = _dompetList.firstWhere(
          (final d) => d.id == trx.walletId,
          orElse: () {
            Log.warning(
              'Dompet asal dengan ID ${trx.walletId} tidak ditemukan. Menggunakan dompet pertama dari daftar.',
            );
            return _dompetList.first;
          },
        );

        if (trx.type == TransactionType.transfer &&
            trx.destinationWalletId != null) {
          _selectedDompetTujuan = _dompetList.firstWhere(
            (final d) => d.id == trx.destinationWalletId,
            orElse: () {
              Log.warning(
                'Dompet tujuan dengan ID ${trx.destinationWalletId} tidak ditemukan. Menggunakan dompet pertama dari daftar.',
              );
              return _dompetList.first;
            },
          );
        }

        _filterKategoriInternal();

        if (trx.categoryId.isNotEmpty) {
          _selectedKategori =
              _kategoriFiltered.cast<KategoriModel?>().firstWhere(
            (final k) => k?.id == trx.categoryId,
            orElse: () {
              Log.warning(
                'Kategori dengan ID ${trx.categoryId} tidak ditemukan setelah filter.',
              );
              return null;
            },
          );

          if (trx.idSubKategori != null && _selectedKategori != null) {
            _selectedSubKategori = _selectedKategori!.subCategories
                .cast<SubCategoryModel?>()
                .firstWhere(
              (final sk) => sk?.id == trx.idSubKategori,
              orElse: () {
                Log.warning(
                  'Sub-kategori dengan ID ${trx.idSubKategori} tidak ditemukan.',
                );
                return null;
              },
            );
          }
        }
        Log.info('Selesai mempopulasikan form untuk mode Edit.');
      } else {
        Log.info(
          'Mode Tambah: Mejalankan filter kategori awal untuk tipe Pemasukan.',
        );
        Log.info('Mode Tambah: Mengisi default tanggal/waktu sekarang.');
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.fromDateTime(DateTime.now());
        _filterKategoriInternal();
      }
    } on Exception catch (e, s) {
      Log.error('Gagal total saat memuat data awal.', e: e, s: s);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memuat data penting: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Log.info('Pemuatan data awal selesai. isLoading diatur ke false.');
      }
    }
  }

  void _filterKategoriInternal() {
    final tipeSebelum = _kategoriFiltered.length;

    if (_tipe == TransactionType.transfer) {
      _kategoriFiltered = [];
      Log.info('Tipe transaksi adalah Transfer, kategori dikosongkan.');
      return;
    }

    final tipeKategoriTarget = _tipe == TransactionType.income
        ? TipeKategori.income
        : TipeKategori.expense;

    _kategoriFiltered =
        _kategoriList.where((final k) => k.type == tipeKategoriTarget).toList();
    Log.info(
      'Kategori difilter untuk tipe: ${_tipe.name}. Jumlah: $tipeSebelum -> ${_kategoriFiltered.length}.',
    );
  }

  void _filterKategori() {
    setState(() {
      Log.info(
        'Tipe transaksi diubah, memfilter ulang kategori dan mereset pilihan kategori.',
      );
      _filterKategoriInternal();
      _selectedKategori = null;
      _selectedSubKategori = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    Log.info('Memilih tanggal, saat ini: $_selectedDate');
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      Log.info('Tanggal dipilih: ${FormatDate.formatDateBasic(picked)}');
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    Log.info('Memilih waktu, saat ini: $_selectedTime');
    final initial = _selectedTime ?? TimeOfDay.fromDateTime(DateTime.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      Log.info('Waktu dipilih: ${picked.hour}:${picked.minute}');
    }
  }

  Future<void> _simpanForm() async {
    Log.info('Tombol "Simpan" ditekan.');
    if (_formKey.currentState!.validate()) {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _isSaving = true);
      final DateTime combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final double jumlah = double.parse(_jumlahController.text).abs();
      final transaksi = TransaksiModel(
        id: _isEditMode ? widget.transaksi!.id : const Uuid().v4(),
        description: _keteranganController.text,
        amount: jumlah,
        date: combinedDateTime,
        type: _tipe,
        walletId: _selectedDompet!.id,
        destinationWalletId: _tipe == TransactionType.transfer
            ? _selectedDompetTujuan?.id
            : null,
        categoryId: _selectedKategori?.id ?? '',
        idSubKategori: _selectedSubKategori?.id,
      );

      Log.info('Model Transaksi yang akan disimpan: ${transaksi.toSqlite()}');

      try {
        if (_isEditMode) {
          Log.info(
            'Menjalankan operasi UPDATE untuk transaksi ID: ${transaksi.id}',
          );
          await _transaksiOpSqlite.updateTransaction(
            widget.transaksi!.id,
            transaksi,
          );
        } else {
          Log.info('Menjalankan operasi CREATE untuk transaksi baru.');
          await _transaksiOpSqlite.tambahTransaksi(transaksi);
        }
        ref.invalidate(transaksiOpSqliteProvider);
        if (!mounted) return;
        Log.info(
          'Penyimpanan berhasil. Menutup form dan kembali dengan hasil true.',
        );

        final isOnline =
            await ref.read(koneksiInternetServiceProvider).cekKoneksiLokal();
        if (isOnline) {
          final syncCheckService = ref.read(syncCheckServiceProvider);
          syncCheckService.runSyncCheck();
          if (mounted) {
            ToastUtil.success(
                context, 'Transaksi berhasil disimpan dan disinkronkan.');
          }
        } else {
          if (mounted) {
            ToastUtil.info(context,
                'Transaksi disimpan lokal. Sinkronisasi akan dilakukan saat online.');
          }
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menyimpan transaksi ke database.',
          e: e,
          s: s,
        );
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal menyimpan transaksi: $e');
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
          Log.info('Proses penyimpanan selesai. isSaving diatur ke false.');
        }
      }
    } else {
      Log.warning(
        'Form tidak valid. Proses penyimpanan dibatalkan. Silakan periksa error di UI.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI FormTransaksiPage. isLoading: $_isLoading, isSaving: $_isSaving',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: SegmentedButton<TransactionType>(
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                switch (_tipe) {
                                  case TransactionType.income:
                                    return Colors.green.withAlpha(51);
                                  case TransactionType.expense:
                                    return Colors.red.withAlpha(51);
                                  case TransactionType.transfer:
                                    return Colors.blue.withAlpha(51);
                                }
                              }
                              return Colors.transparent;
                            },
                          ),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                switch (_tipe) {
                                  case TransactionType.income:
                                    return Colors.green;
                                  case TransactionType.expense:
                                    return Colors.red;
                                  case TransactionType.transfer:
                                    return Colors.blue;
                                }
                              }
                              return Colors.grey;
                            },
                          ),
                          side: WidgetStateProperty.resolveWith<BorderSide>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                switch (_tipe) {
                                  case TransactionType.income:
                                    return const BorderSide(
                                        color: Colors.green);
                                  case TransactionType.expense:
                                    return const BorderSide(color: Colors.red);
                                  case TransactionType.transfer:
                                    return const BorderSide(color: Colors.blue);
                                }
                              }
                              return const BorderSide(color: Colors.grey);
                            },
                          ),
                        ),
                        segments: TransactionType.values.map((
                          TransactionType tipe,
                        ) {
                          return ButtonSegment<TransactionType>(
                            value: tipe,
                            label: Text(tipe.displayName.toUpperCase()),
                          );
                        }).toList(),
                        selected: <TransactionType>{_tipe},
                        onSelectionChanged:
                            (Set<TransactionType> newSelection) {
                          setState(() {
                            Log.info(
                              'Tipe transaksi diubah menjadi: ${newSelection.first.name}',
                            );
                            _tipe = newSelection.first;
                            _filterKategori();
                            _selectedDompetTujuan = null;
                          });
                        },
                      ),
                    ),
                    TextFormField(
                      controller: _keteranganController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_jumlahFocusNode);
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Keterangan tidak boleh kosong'
                          : null,
                    ),
                    TextFormField(
                      controller: _jumlahController,
                      focusNode: _jumlahFocusNode,
                      decoration: const InputDecoration(labelText: 'Jumlah'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Format jumlah tidak valid';
                        }
                        return null;
                      },
                    ),
                    gapH24,
                    DateTimePickerWidget(
                      selectedDate: _selectedDate,
                      selectedTime: _selectedTime,
                      onSelectDate: () => _selectDate(context),
                      onSelectTime: () => _selectTime(context),
                    ),

                    DropdownButtonFormField<DompetModel>(
                      key: ValueKey<DompetModel?>(_selectedDompet),
                      initialValue: _selectedDompet,
                      decoration: const InputDecoration(labelText: 'Dompet'),
                      items: _dompetList.map((dompet) {
                        return DropdownMenuItem(
                          value: dompet,
                          child: Text(dompet.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        Log.info(
                          'Pengguna memilih dompet: ${val?.name ?? "null"}',
                        );
                        setState(() => _selectedDompet = val);
                      },
                      validator: (val) =>
                          val == null ? 'Dompet harus dipilih' : null,
                    ),
                    if (_tipe == TransactionType.transfer)
                      DropdownButtonFormField<DompetModel>(
                        key: ValueKey<DompetModel?>(_selectedDompetTujuan),
                        initialValue: _selectedDompetTujuan,
                        decoration: const InputDecoration(
                          labelText: 'Dompet Tujuan',
                        ),
                        items: _dompetList.map((dompet) {
                          return DropdownMenuItem(
                            value: dompet,
                            child: Text(dompet.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          Log.info(
                            'Pengguna memilih dompet tujuan: ${val?.name ?? "null"}',
                          );
                          setState(() => _selectedDompetTujuan = val);
                        },
                        validator: (val) {
                          if (val == null) return 'Dompet tujuan harus dipilih';
                          if (val == _selectedDompet) {
                            return 'Dompet tidak boleh sama';
                          }
                          return null;
                        },
                      ),
                    // diubah: Menampilkan kategori hanya jika tipe bukan transfer
                    if (_tipe != TransactionType.transfer &&
                        _kategoriFiltered.isNotEmpty)
                      DropdownButtonFormField<KategoriModel>(
                        key: ValueKey<KategoriModel?>(_selectedKategori),
                        initialValue: _selectedKategori,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: _kategoriFiltered.map((kategori) {
                          return DropdownMenuItem(
                            value: kategori,
                            child: Text(kategori.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          Log.info(
                            'Pengguna memilih kategori: ${val?.name ?? "null"}',
                          );
                          setState(() {
                            _selectedKategori = val;
                            _selectedSubKategori = null;
                          });
                        },
                        validator: (val) =>
                            val == null ? 'Kategori harus dipilih' : null,
                      ),
                    if (_selectedKategori != null &&
                        _selectedKategori!.subCategories.isNotEmpty)
                      DropdownButtonFormField<SubCategoryModel>(
                        key: ValueKey<SubCategoryModel?>(_selectedSubKategori),
                        initialValue: _selectedSubKategori,
                        decoration: const InputDecoration(
                          labelText: 'Sub Kategori',
                        ),
                        items: _selectedKategori!.subCategories.map((sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          Log.info(
                            'Pengguna memilih sub-kategori: ${val?.name ?? "null"}',
                          );
                          setState(() => _selectedSubKategori = val);
                        },
                        validator: (val) =>
                            val == null ? 'Sub Kategori harus dipilih' : null,
                      ),
                    gapH20,
                    ElevatedButton(
                      onPressed: _isSaving ? null : _simpanForm,
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    Log.info(
      'Menjalankan dispose di FormTransaksiPage. Membersihkan controllers.',
    );
    _jumlahController.dispose();
    _keteranganController.dispose();
    _jumlahFocusNode.dispose();
    super.dispose();
  }
}
