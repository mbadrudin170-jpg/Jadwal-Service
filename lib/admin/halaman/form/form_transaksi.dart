// path: lib/admin/halaman/form/form_transaksi.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/kategori_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Halaman form untuk menambah atau mengubah data transaksi.
///
/// Form ini mendukung tiga jenis transaksi: pemasukan, pengeluaran, dan transfer.
/// Logika UI akan beradaptasi berdasarkan tipe transaksi yang dipilih.
class FormTransaksiPage extends StatefulWidget {
  /// Data transaksi yang akan diedit. Jika `null`, form akan berada dalam mode tambah baru.
  final TransaksiModel? transaksi;

  /// Membuat instance dari [FormTransaksiPage].
  const FormTransaksiPage({super.key, this.transaksi});

  @override
  State<FormTransaksiPage> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends State<FormTransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime _tanggal = DateTime.now();

  KategoriModel? _selectedKategori;
  SubKategoriModel? _selectedSubKategori;
  TipeTransaksiEnum _tipe = TipeTransaksiEnum.pemasukan;
  DompetModel? _selectedDompet;
  DompetModel? _selectedDompetTujuan;

  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();

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
    unawaited(_loadAndPopulateInitialData());
  }

  Future<void> _loadAndPopulateInitialData() async {
    Log.info('Memulai pemuatan data awal (dompet & kategori).');
    setState(() => _isLoading = true);

    try {
      final dompetList = await _dompetOperasi.getDompet();
      Log.info('Berhasil memuat ${dompetList.length} dompet.');
      final kategoriList = await _kategoriOperasi.getKategori();
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
        _tipe = trx.tipe;
        _keteranganController.text = trx.keterangan;
        _jumlahController.text = trx.jumlah.abs().toString();
        _tanggal = trx.tanggal;

        _selectedDompet = _dompetList.firstWhere(
          (final d) => d.id == trx.idDompet,
          orElse: () {
            Log.warning(
              'Dompet asal dengan ID ${trx.idDompet} tidak ditemukan. Menggunakan dompet pertama dari daftar.',
            );
            return _dompetList.first;
          },
        );

        if (trx.tipe == TipeTransaksiEnum.transfer && trx.idDompetTujuan != null) {
          _selectedDompetTujuan = _dompetList.firstWhere(
            (final d) => d.id == trx.idDompetTujuan,
            orElse: () {
              Log.warning(
                'Dompet tujuan dengan ID ${trx.idDompetTujuan} tidak ditemukan. Menggunakan dompet pertama dari daftar.',
              );
              return _dompetList.first;
            },
          );
        }

        _filterKategoriInternal();

        if (trx.idKategori.isNotEmpty) {
          _selectedKategori =
              _kategoriFiltered.cast<KategoriModel?>().firstWhere(
            (final k) => k?.id == trx.idKategori,
            orElse: () {
              Log.warning(
                'Kategori dengan ID ${trx.idKategori} tidak ditemukan setelah filter.',
              );
              return null;
            },
          );

          if (trx.idSubKategori != null && _selectedKategori != null) {
            _selectedSubKategori = _selectedKategori!.subKategori
                .cast<SubKategoriModel?>()
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
        _filterKategoriInternal();
      }
    } on Exception catch (e, s) {
      Log.error('Gagal total saat memuat data awal.', e: e, st: s);
      if (!mounted) return;
      SnackBarUtil.error(context, 'Gagal memuat data penting: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Log.info('Pemuatan data awal selesai. isLoading diatur ke false.');
      }
    }
  }

  void _filterKategoriInternal() {
    final tipeSebelum = _kategoriFiltered.length;
    final tipeKategoriTarget = _tipe == TipeTransaksiEnum.pemasukan
        ? TipeKategori.pemasukan
        : TipeKategori.pengeluaran;

    _kategoriFiltered =
        _kategoriList.where((final k) => k.tipe == tipeKategoriTarget).toList();
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

  Future<void> _pilihTanggal(final BuildContext context) async {
    Log.info('Membuka dialog pemilih tanggal.');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggal) {
      setState(() {
        _tanggal = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _tanggal.hour,
          _tanggal.minute,
        );
      });
      Log.info('Pengguna memilih tanggal baru: ${_tanggal.toLocal()}');
    } else {
      Log.info('Pengguna membatalkan pemilihan tanggal.');
    }
  }

  Future<void> _pilihWaktu(final BuildContext context) async {
    Log.info('Membuka dialog pemilih waktu.');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_tanggal),
    );

    if (!mounted || picked == null) {
      Log.info('Pengguna membatalkan pemilihan waktu.');
      return;
    }

    setState(() {
      _tanggal = DateTime(
        _tanggal.year,
        _tanggal.month,
        _tanggal.day,
        picked.hour,
        picked.minute,
      );
    });
    Log.info('Pengguna memilih waktu baru: ${_tanggal.toLocal()}');
  }

  Future<void> _simpanForm() async {
    Log.info('Tombol "Simpan" ditekan.');
    if (_formKey.currentState!.validate()) {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _isSaving = true);

      final double jumlah = double.parse(_jumlahController.text).abs();

      final transaksi = TransaksiModel(
        id: _isEditMode ? widget.transaksi!.id : const Uuid().v4(),
        keterangan: _keteranganController.text,
        jumlah: jumlah,
        tanggal: _tanggal,
        tipe: _tipe,
        idDompet: _selectedDompet!.id,
        idDompetTujuan:
            _tipe == TipeTransaksiEnum.transfer ? _selectedDompetTujuan?.id : null,
        idKategori: _selectedKategori?.id ?? '',
        idSubKategori: _selectedSubKategori?.id,
      );

      Log.info('Model Transaksi yang akan disimpan: ${transaksi.toSqlite()}');

      try {
        if (_isEditMode) {
          Log.info(
            'Menjalankan operasi UPDATE untuk transaksi ID: ${transaksi.id}',
          );
          await _transaksiOperasi.updateTransaksi(
            widget.transaksi!.id,
            transaksi,
          );
        } else {
          Log.info('Menjalankan operasi CREATE untuk transaksi baru.');
          await _transaksiOperasi.tambahTransaksi(transaksi);
        }

        if (!mounted) return;
        Log.info(
          'Penyimpanan berhasil. Menutup form dan kembali dengan hasil true.',
        );
        Navigator.pop(context, true);
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menyimpan transaksi ke database.',
          e: e,
          st: s,
        );
        if (!mounted) return;
        SnackBarUtil.error(context, 'Gagal menyimpan transaksi: $e');
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
  Widget build(final BuildContext context) {
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
                      child: SegmentedButton<TipeTransaksiEnum>(
                        segments: TipeTransaksiEnum.values.map((
                          final TipeTransaksiEnum tipe,
                        ) {
                          return ButtonSegment<TipeTransaksiEnum>(
                            value: tipe,
                            label: Text(tipe.name.toUpperCase()),
                          );
                        }).toList(),
                        selected: <TipeTransaksiEnum>{_tipe},
                        onSelectionChanged: (final Set<TipeTransaksiEnum> newSelection) {
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
                      validator: (final value) => value == null || value.isEmpty
                          ? 'Keterangan tidak boleh kosong'
                          : null,
                    ),
                    TextFormField(
                      controller: _jumlahController,
                      decoration: const InputDecoration(labelText: 'Jumlah'),
                      keyboardType: TextInputType.number,
                      validator: (final value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Format jumlah tidak valid';
                        }
                        return null;
                      },
                    ),
                    ListTile(
                      title: Text(
                        'Tanggal & Jam: ${_tanggal.toLocal().toString().split('.')[0]}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _pilihTanggal(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _pilihWaktu(context),
                          ),
                        ],
                      ),
                    ),
                    // Dropdown Dompet
                    DropdownButtonFormField<DompetModel>(
                      key: ValueKey<DompetModel?>(_selectedDompet),
                      initialValue: _selectedDompet,
                      decoration: const InputDecoration(labelText: 'Dompet'),
                      items: _dompetList.map((final dompet) {
                        return DropdownMenuItem(
                          value: dompet,
                          child: Text(dompet.namaDompet),
                        );
                      }).toList(),
                      onChanged: (final val) {
                        Log.info(
                          'Pengguna memilih dompet: ${val?.namaDompet ?? "null"}',
                        );
                        setState(() => _selectedDompet = val);
                      },
                      validator: (final val) =>
                          val == null ? 'Dompet harus dipilih' : null,
                    ),
                    if (_tipe == TipeTransaksiEnum.transfer)
                      DropdownButtonFormField<DompetModel>(
                        key: ValueKey<DompetModel?>(_selectedDompetTujuan),
                        initialValue: _selectedDompetTujuan,
                        decoration: const InputDecoration(
                          labelText: 'Dompet Tujuan',
                        ),
                        items: _dompetList.map((final dompet) {
                          return DropdownMenuItem(
                            value: dompet,
                            child: Text(dompet.namaDompet),
                          );
                        }).toList(),
                        onChanged: (final val) {
                          Log.info(
                            'Pengguna memilih dompet tujuan: ${val?.namaDompet ?? "null"}',
                          );
                          setState(() => _selectedDompetTujuan = val);
                        },
                        validator: (final val) {
                          if (val == null) return 'Dompet tujuan harus dipilih';
                          if (val == _selectedDompet) {
                            return 'Dompet tidak boleh sama';
                          }
                          return null;
                        },
                      ),
                    if (_kategoriFiltered.isNotEmpty)
                      DropdownButtonFormField<KategoriModel>(
                        key: ValueKey<KategoriModel?>(_selectedKategori),
                        initialValue: _selectedKategori,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: _kategoriFiltered.map((final kategori) {
                          return DropdownMenuItem(
                            value: kategori,
                            child: Text(kategori.nama),
                          );
                        }).toList(),
                        onChanged: (final val) {
                          Log.info(
                            'Pengguna memilih kategori: ${val?.nama ?? "null"}',
                          );
                          setState(() {
                            _selectedKategori = val;
                            _selectedSubKategori = null;
                          });
                        },
                        validator: (final val) =>
                            val == null ? 'Kategori harus dipilih' : null,
                      ),
                    if (_selectedKategori != null &&
                        _selectedKategori!.subKategori.isNotEmpty)
                      DropdownButtonFormField<SubKategoriModel>(
                        key: ValueKey<SubKategoriModel?>(_selectedSubKategori),
                        initialValue: _selectedSubKategori,
                        decoration: const InputDecoration(
                          labelText: 'Sub Kategori',
                        ),
                        items: _selectedKategori!.subKategori.map((final sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub.nama),
                          );
                        }).toList(),
                        onChanged: (final val) {
                          Log.info(
                            'Pengguna memilih sub-kategori: ${val?.nama ?? "null"}',
                          );
                          setState(() => _selectedSubKategori = val);
                        },
                        validator: (final val) =>
                            val == null ? 'Sub Kategori harus dipilih' : null,
                      ),
                    const SizedBox(height: 20),
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
    super.dispose();
  }
}
