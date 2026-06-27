// path: lib/fitur/transaksi/page/form_transaksi.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/event/page/event_page_a.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_rupiah.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';
import 'package:wifi/shared/widget/pemilih_tanggal_waktu_widget.dart';

class FormTransaksi extends ConsumerStatefulWidget {
  final TransaksiModel? transaksi;

  const FormTransaksi({super.key, this.transaksi});

  @override
  ConsumerState<FormTransaksi> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends ConsumerState<FormTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _jumlahFocusNode = FocusNode();
  final _keteranganFocusNode = FocusNode();
  DateTime? _tanggalDipilih;
  TimeOfDay? _jamDipilih;

  KategoriModel? _kategoriDipilih;
  SubKategoriModel? _subKategoriDipilih;
  TipeTransaksi _tipe = TipeTransaksi.income;
  DompetModel? _dompetDipilih;
  DompetModel? _dompetTujuanDipilih;

  late final DompetOpSqlite _dompetOpSlite;
  late final KategoriOpSqlite _kategoriOpSqlite;
  List<KategoriModel> _daftarKategori = [];
  List<DompetModel> _daftarDompet = [];
  List<KategoriModel> _kategoriDifilter = [];

  bool get _modeEdit => widget.transaksi != null;
  bool _loading = true;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Menginisialisasi FormTransaksiPage dalam mode: ${_modeEdit ? "Edit" : "Tambah"}.',
    );
    _dompetOpSlite = ref.read(dompetOpSqliteProvider);
    _kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    Log.info('Memulai pemuatan data awal (dompet & kategori).');
    setState(() => _loading = true);

    try {
      final daftarDompet = await _dompetOpSlite.ambilSemua();
      Log.info('Berhasil memuat ${daftarDompet.length} dompet.');
      final daftarKategori = await _kategoriOpSqlite.ambilSemua();
      Log.info('Berhasil memuat ${daftarKategori.length} kategori.');

      if (!mounted) return;

      setState(() {
        _daftarDompet = daftarDompet;
        _daftarKategori = daftarKategori;
      });

      if (_modeEdit) {
        Log.info(
          'Mode Edit: Mempopulasikan form dengan data transaksi ID: ${widget.transaksi!.id}',
        );
        final trx = widget.transaksi!;
        _tipe = trx.tipe;
        _keteranganController.text = trx.deskripsi;
        _jumlahController.text = trx.jumlah.abs().toString();
        _tanggalDipilih = trx.tanggal;
        _jamDipilih = TimeOfDay.fromDateTime(trx.tanggal);
        _dompetDipilih =
            _daftarDompet.firstWhereOrNull((d) => d.id == trx.idDompet) ??
            _daftarDompet.firstOrNull;

        if (trx.tipe == TipeTransaksi.transfer && trx.idDompetTujuan != null) {
          _dompetTujuanDipilih =
              _daftarDompet.firstWhereOrNull(
                (d) => d.id == trx.idDompetTujuan,
              ) ??
              _daftarDompet.firstOrNull;
        }

        _filterKategoriInternal();

        if (trx.idKategori.isNotEmpty) {
          _kategoriDipilih = _kategoriDifilter.cast<KategoriModel?>().firstWhere(
            (k) => k?.id == trx.idKategori,
            orElse: () {
              Log.warning(
                'Kategori dengan ID ${trx.idKategori} tidak ditemukan setelah filter.',
              );
              return null;
            },
          );

          if (trx.idSubKategori != null && _kategoriDipilih != null) {
            _subKategoriDipilih = _kategoriDipilih!.idSubKategori
                .cast<SubKategoriModel?>()
                .firstWhere(
                  (sk) => sk?.id == trx.idSubKategori,
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
        _tanggalDipilih = DateTime.now();
        _jamDipilih = TimeOfDay.fromDateTime(DateTime.now());
        _filterKategoriInternal();
      }
    } on Exception catch (e, s) {
      Log.error('Gagal total saat memuat data awal.', e: e, s: s);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memuat data penting: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        Log.info('Pemuatan data awal selesai. isLoading diatur ke false.');
      }
    }
  }

  void _filterKategoriInternal() {
    final tipeSebelum = _kategoriDifilter.length;

    if (_tipe == TipeTransaksi.transfer) {
      _kategoriDifilter = [];
      Log.info('Tipe transaksi adalah Transfer, kategori dikosongkan.');
      return;
    }

    final tipeKategoriTarget = _tipe == TipeTransaksi.income
        ? TipeKategori.income
        : TipeKategori.expense;

    _kategoriDifilter = _daftarKategori
        .where((final k) => k.tipe == tipeKategoriTarget)
        .toList();
    Log.info(
      'Kategori difilter untuk tipe: ${_tipe.name}. Jumlah: $tipeSebelum -> ${_kategoriDifilter.length}.',
    );
  }

  void _filterKategori() {
    setState(() {
      Log.info(
        'Tipe transaksi diubah, memfilter ulang kategori dan mereset pilihan kategori.',
      );
      _filterKategoriInternal();
      _kategoriDipilih = null;
      _subKategoriDipilih = null;
    });
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    Log.info('Memilih tanggal, saat ini: $_tanggalDipilih');
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggalDipilih) {
      setState(() => _tanggalDipilih = picked);
      Log.info('Tanggal dipilih: ${FormatTanggal.formatDasar(picked)}');
    }
  }

  Future<void> _pilihJam(BuildContext context) async {
    Log.info('Memilih waktu, saat ini: $_jamDipilih');
    final initial = _jamDipilih ?? TimeOfDay.fromDateTime(DateTime.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && picked != _jamDipilih) {
      setState(() => _jamDipilih = picked);
      Log.info('Waktu dipilih: ${picked.hour}:${picked.minute}');
    }
  }

  Future<void> _simpanForm() async {
    Log.info('Tombol "Simpan" ditekan.');
    if (_formKey.currentState!.validate()) {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _menyimpan = true);
      final DateTime combinedDateTime = DateTime(
        _tanggalDipilih!.year,
        _tanggalDipilih!.month,
        _tanggalDipilih!.day,
        _jamDipilih!.hour,
        _jamDipilih!.minute,
      );
      final double jumlah = double.parse(_jumlahController.text).abs();
      final transaksi = TransaksiModel(
        id: _modeEdit ? widget.transaksi!.id : const Uuid().v4(),
        deskripsi: _keteranganController.text,
        jumlah: jumlah,
        tanggal: combinedDateTime,
        tipe: _tipe,
        idDompet: _dompetDipilih?.id ?? '',
        idDompetTujuan: _tipe == TipeTransaksi.transfer
            ? _dompetTujuanDipilih?.id
            : null,
        idKategori: _kategoriDipilih?.id ?? '',
        tanggalMulai: null,
        tanggalBerakhir: null,
        idPelanggan: null,
        idPaket: null,
        idSubKategori: _subKategoriDipilih?.id,
      );

      Log.info('Model Transaksi yang akan disimpan: ${transaksi.toSqlite()}');
      final transaksiNotifier = ref.read(transaksiProvider.notifier);
      try {
        if (_modeEdit) {
          Log.info(
            'Menjalankan operasi UPDATE untuk transaksi ID: ${transaksi.id}',
          );
          await transaksiNotifier.updateTransaksi(transaksi);
        } else {
          Log.info('Menjalankan operasi CREATE untuk transaksi baru.');
          await transaksiNotifier.tambahTransaksi(transaksi);
        }
        if (!mounted) return;
        Log.info(
          'Penyimpanan berhasil. Menutup form dan kembali dengan hasil true.',
        );
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (mounted) {
          ToastUtil.success(
            context,
            'Transaksi berhasil disimpan dan disinkronkan.',
          );
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } on Exception catch (e, s) {
        Log.error('Gagal menyimpan transaksi ke database.', e: e, s: s);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal menyimpan transaksi: $e');
      } finally {
        if (mounted) {
          setState(() => _menyimpan = false);
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
      'Membangun UI FormTransaksiPage. isLoading: $_loading, isSaving: $_menyimpan',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: SegmentedButton<TipeTransaksi>(
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  switch (_tipe) {
                                    case TipeTransaksi.income:
                                      return Colors.green.withAlpha(51);
                                    case TipeTransaksi.expense:
                                      return Colors.red.withAlpha(51);
                                    case TipeTransaksi.transfer:
                                      return Colors.blue.withAlpha(51);
                                  }
                                }
                                return Colors.transparent;
                              }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  switch (_tipe) {
                                    case TipeTransaksi.income:
                                      return Colors.green;
                                    case TipeTransaksi.expense:
                                      return Colors.red;
                                    case TipeTransaksi.transfer:
                                      return Colors.blue;
                                  }
                                }
                                return Colors.grey;
                              }),
                          side: WidgetStateProperty.resolveWith<BorderSide>((
                            Set<WidgetState> states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              switch (_tipe) {
                                case TipeTransaksi.income:
                                  return const BorderSide(color: Colors.green);
                                case TipeTransaksi.expense:
                                  return const BorderSide(color: Colors.red);
                                case TipeTransaksi.transfer:
                                  return const BorderSide(color: Colors.blue);
                              }
                            }
                            return const BorderSide(color: Colors.grey);
                          }),
                        ),
                        segments: TipeTransaksi.values.map((
                          TipeTransaksi tipe,
                        ) {
                          return ButtonSegment<TipeTransaksi>(
                            value: tipe,
                            label: Text(tipe.displayName.toUpperCase()),
                          );
                        }).toList(),
                        selected: <TipeTransaksi>{_tipe},
                        onSelectionChanged: (Set<TipeTransaksi> newSelection) {
                          setState(() {
                            Log.info(
                              'Tipe transaksi diubah menjadi: ${newSelection.first.name}',
                            );
                            _tipe = newSelection.first;
                            _filterKategori();
                            _dompetTujuanDipilih = null;
                          });
                        },
                      ),
                    ),
                    InputTeks(
                      controller: _keteranganController,
                      label: 'Keterangan',
                      focusNode: _keteranganFocusNode,
                      nextFocusNode: _jumlahFocusNode,
                    ),
                    gapH8,
                    InputRupiah(
                      controller: _jumlahController,
                      focusNode: _jumlahFocusNode,
                      textInputAction: TextInputAction.done,
                    ),
                    gapH24,
                    PemilihTanggalWaktuWidget(
                      tanggalTerpilih: _tanggalDipilih,
                      waktuTerpilih: _jamDipilih,
                      onPilihTanggal: () => _pilihTanggal(context),
                      onPilihWaktu: () => _pilihJam(context),
                    ),
                    DropdownButtonFormField<DompetModel>(
                      key: ValueKey<DompetModel?>(_dompetDipilih),
                      initialValue: _dompetDipilih,
                      decoration: const InputDecoration(labelText: 'Dompet'),
                      items: _daftarDompet.map((dompet) {
                        return DropdownMenuItem(
                          value: dompet,
                          child: Text(dompet.nama),
                        );
                      }).toList(),
                      onChanged: (v) {
                        Log.info(
                          'Pengguna memilih dompet: ${v?.nama ?? "null"}',
                        );
                        setState(() => _dompetDipilih = v);
                      },
                      validator: (v) =>
                          v == null ? 'Dompet harus dipilih' : null,
                    ),
                    if (_tipe == TipeTransaksi.transfer)
                      DropdownButtonFormField<DompetModel>(
                        key: ValueKey<DompetModel?>(_dompetTujuanDipilih),
                        initialValue: _dompetTujuanDipilih,
                        decoration: const InputDecoration(
                          labelText: 'Dompet Tujuan',
                        ),
                        items: _daftarDompet.map((dompet) {
                          return DropdownMenuItem(
                            value: dompet,
                            child: Text(dompet.nama),
                          );
                        }).toList(),
                        onChanged: (val) {
                          Log.info(
                            'Pengguna memilih dompet tujuan: ${val?.nama ?? "null"}',
                          );
                          setState(() => _dompetTujuanDipilih = val);
                        },
                        validator: (val) {
                          if (val == null) return 'Dompet tujuan harus dipilih';
                          if (val == _dompetDipilih) {
                            return 'Dompet tidak boleh sama';
                          }
                          return null;
                        },
                      ),
                    if (_tipe != TipeTransaksi.transfer &&
                        _kategoriDifilter.isNotEmpty)
                      DropdownButtonFormField<KategoriModel>(
                        key: ValueKey<KategoriModel?>(_kategoriDipilih),
                        initialValue: _kategoriDipilih,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: _kategoriDifilter.map((kategori) {
                          return DropdownMenuItem(
                            value: kategori,
                            child: Text(kategori.nama),
                          );
                        }).toList(),
                        onChanged: (val) {
                          Log.info(
                            'Pengguna memilih kategori: ${val?.nama ?? "null"}',
                          );
                          setState(() {
                            _kategoriDipilih = val;
                            _subKategoriDipilih = null;
                          });
                        },
                        validator: (val) =>
                            val == null ? 'Kategori harus dipilih' : null,
                      ),
                    if (_kategoriDipilih != null &&
                        _kategoriDipilih!.idSubKategori.isNotEmpty)
                      DropdownButtonFormField<SubKategoriModel>(
                        key: ValueKey<SubKategoriModel?>(_subKategoriDipilih),
                        initialValue: _subKategoriDipilih,
                        decoration: const InputDecoration(
                          labelText: 'Sub Kategori',
                        ),
                        items: _kategoriDipilih!.idSubKategori.map((sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub.nama),
                          );
                        }).toList(),
                        onChanged: (val) {
                          Log.info(
                            'Pengguna memilih sub-kategori: ${val?.nama ?? "null"}',
                          );
                          setState(() => _subKategoriDipilih = val);
                        },
                        validator: (val) =>
                            val == null ? 'Sub Kategori harus dipilih' : null,
                      ),
                    gapH20,
                    ElevatedButton(
                      onPressed: _menyimpan ? null : _simpanForm,
                      child: _menyimpan
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
    _keteranganFocusNode.dispose();
    super.dispose();
  }
}
