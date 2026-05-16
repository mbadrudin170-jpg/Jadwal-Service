// path: lib/admin/halaman/form/form_pelanggan_aktif.dart
// diubah: Menambahkan dokumentasi publik dan memperbaiki kurung kurawal.
// diubah: Mengambil data transaksi di mode edit untuk mengisi dompet & kategori.
// diubah: Mengganti `initialValue` ke `value` di Dropdown agar update state terlihat.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/hasil_simpan_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/kategori_operasi.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_aktif_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/services/pembaruan_data_service.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/whatsapp/info_paket.dart';

/// Fungsi untuk menghitung tanggal berakhir berdasarkan tanggal mulai dan durasi paket.
DateTime hitungTanggalBerakhir(
  final DateTime startDate,
  final PaketModel paket,
) {
  Log.info('FUNGSI GLOBAL: hitungTanggalBerakhir() dipanggil.');
  Log.info('  - Tanggal Mulai: ${startDate.toIso8601String()}');
  Log.info('  - Nama Paket: ${paket.nama}');
  Log.info('  - Tipe Durasi: ${paket.tipe.displayName}');
  Log.info('  - Durasi: ${paket.durasi}');

  DateTime hasil;
  switch (paket.tipe) {
    case TipeDurasi.jam:
      hasil = startDate.add(Duration(hours: paket.durasi));
      break;
    case TipeDurasi.hari:
      hasil = startDate.add(Duration(days: paket.durasi));
      break;
    case TipeDurasi.bulan:
      hasil =
          Jiffy.parseFromDateTime(startDate).add(months: paket.durasi).dateTime;
      break;
    case TipeDurasi.menit:
      hasil = startDate.add(Duration(minutes: paket.durasi));
      break;
  }

  Log.info('  - Hasil Tanggal Berakhir: ${hasil.toIso8601String()}');
  return hasil;
}

/// Form untuk menambah atau mengubah data pelanggan yang sedang aktif.
class FormPelangganAktif extends StatefulWidget {
  /// Data pelanggan aktif yang akan diedit.
  final PelangganAktifModel? pelangganAktif;

  /// Operasi untuk data pelanggan
  final PelangganOperasi pelangganOperasi;

  /// Operasi untuk data paket
  final PaketOperasi paketOperasi;

  /// Operasi untuk data pelanggan aktif
  final PelangganAktifOperasi pelangganAktifOperasi;

  /// Operasi untuk data transaksi
  final TransaksiOperasi transaksiOperasi;

  /// Operasi untuk data dompet
  final DompetOperasi dompetOperasi;

  /// Operasi untuk data kategori
  final KategoriOperasi kategoriOperasi;

  /// Konstruktor untuk FormPelangganAktif
  FormPelangganAktif({
    super.key,
    this.pelangganAktif,
    final PelangganOperasi? pelangganOperasi,
    final PaketOperasi? paketOperasi,
    final PelangganAktifOperasi? pelangganAktifOperasi,
    final TransaksiOperasi? transaksiOperasi,
    final DompetOperasi? dompetOperasi,
    final KategoriOperasi? kategoriOperasi,
  })  : pelangganOperasi = pelangganOperasi ?? PelangganOperasi(),
        paketOperasi = paketOperasi ?? PaketOperasi(),
        pelangganAktifOperasi =
            pelangganAktifOperasi ?? PelangganAktifOperasi(),
        transaksiOperasi = transaksiOperasi ?? TransaksiOperasi(),
        dompetOperasi = dompetOperasi ?? DompetOperasi(),
        kategoriOperasi = kategoriOperasi ?? KategoriOperasi();

  @override
  State<FormPelangganAktif> createState() => _FormPelangganAktifState();
}

class _FormPelangganAktifState extends State<FormPelangganAktif> {
  final _formKey = GlobalKey<FormState>();

  List<PelangganModel> _pelangganList = [];
  List<PaketModel> _paketList = [];
  List<DompetModel> _daftarDompet = [];
  List<KategoriModel> _kategoriPemasukanList = [];
  List<KategoriModel> _kategoriPengeluaranList = [];

  List<KategoriModel> get _kategoriList =>
      _gunakanPoin ? _kategoriPengeluaranList : _kategoriPemasukanList;

  PelangganModel? _selectedPelanggan;
  PaketModel? _selectedPaket;
  DompetModel? _selectedDompet;
  KategoriModel? _selectedKategori;

  bool _isLoading = true;
  bool _gunakanPoin = false;
  int _saldoPoinPelanggan = 0;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  StatusPembayaranEnum _statusPembayaran = StatusPembayaranEnum.lunas;

  bool get _isEditMode => widget.pelangganAktif != null;

  int hitungPoinEfektif() {
    if (_selectedPaket == null) {
      return 0;
    }
    return _gunakanPoin ? _selectedPaket!.poinPenukaran : 0;
  }

  int hitungSisaPoin() {
    final pakai = hitungPoinEfektif();
    return (_saldoPoinPelanggan - pakai).clamp(0, 999999999);
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadAllData());
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    Log.info('Memulai memuat semua data untuk FormPelangganAktif');

    try {
      final pa = widget.pelangganAktif;
      final transaksiTerkaitFuture = pa?.idTransaksi != null
          ? widget.transaksiOperasi.getTransaksiById(pa!.idTransaksi!)
          : Future<TransaksiModel?>.value();

      final results = await Future.wait([
        widget.pelangganOperasi.getPelanggan(),
        widget.paketOperasi.getPaket(),
        widget.dompetOperasi.getDompet(),
        widget.kategoriOperasi.getKategori(),
        transaksiTerkaitFuture,
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _pelangganList = (results[0] as List<PelangganModel>)
          ..sort((final a, final b) =>
              a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
        _paketList = results[1] as List<PaketModel>;
        _daftarDompet = (results[2] as List<DompetModel>)
            .where((final d) => !d.isDeleted)
            .toList();
        final semuaKategori = results[3] as List<KategoriModel>;
        _kategoriPemasukanList = semuaKategori
            .where(
                (final k) => k.tipe == TipeKategori.pemasukan && !k.isDeleted)
            .toList();
        _kategoriPengeluaranList = semuaKategori
            .where(
                (final k) => k.tipe == TipeKategori.pengeluaran && !k.isDeleted)
            .toList();

        final transaksiTerkait =
            results.length > 4 && results[4] is TransaksiModel
                ? results[4] as TransaksiModel?
                : null;

        if (_isEditMode) {
          _mapEditData(transaksiTerkait);
        } else {
          _mapNewData();
        }

        _isLoading = false;
        Log.info('Semua data berhasil dimuat.');
      });
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data referensi', e: e, st: s);
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal memuat data: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _mapEditData(final TransaksiModel? transaksi) {
    final pa = widget.pelangganAktif!;
    Log.info('Memetakan data edit untuk PelangganAktif ID: ${pa.id}');

    _selectedPelanggan =
        _pelangganList.firstWhereOrNull((final p) => p.id == pa.idPelanggan);
    _selectedPaket =
        _paketList.firstWhereOrNull((final p) => p.id == pa.idPaket);

    if (transaksi != null) {
      Log.info(
          'Transaksi terkait (ID: ${transaksi.id}) ditemukan. Memetakan dompet dan kategori.');
      _selectedDompet = _daftarDompet
          .firstWhereOrNull((final d) => d.id == transaksi.idDompet);
      final kategoriSumber = transaksi.tipe == TipeTransaksiEnum.pemasukan
          ? _kategoriPemasukanList
          : _kategoriPengeluaranList;
      _selectedKategori = kategoriSumber
          .firstWhereOrNull((final k) => k.id == transaksi.idKategori);
    } else {
      Log.warning(
          'Transaksi terkait untuk PelangganAktif ID: ${pa.id} tidak ditemukan.');
      if (mounted) {
        SnackBarUtil.info(context,
            'Info: Transaksi asli tidak ditemukan, pilih ulang dompet/kategori.');
      }
    }

    _selectedDate = pa.tanggalMulai;
    _selectedTime = TimeOfDay.fromDateTime(pa.tanggalMulai);
    _statusPembayaran = pa.status;

    if (_selectedPelanggan != null) {
      unawaited(widget.transaksiOperasi
          .getTotalPoin(_selectedPelanggan!.id)
          .then((final poin) {
        if (mounted) {
          setState(() => _saldoPoinPelanggan = poin);
        }
      }));
    }

    Log.info('Pemetaan data edit selesai.');
  }

  void _mapNewData() {
    Log.info('Menginisialisasi form untuk entri baru.');
    final now = DateTime.now().toUtc();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
    if (_daftarDompet.isNotEmpty) {
      _selectedDompet = _daftarDompet.first;
    }
    if (_kategoriPemasukanList.isNotEmpty) {
      _selectedKategori = _kategoriPemasukanList.firstWhereOrNull(
              (final k) => k.nama.toLowerCase() == 'aktivasi paket') ??
          _kategoriPemasukanList.first;
    }
  }

  Future<void> _selectDate(final BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().toUtc(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(final BuildContext context) async {
    final initial =
        _selectedTime ?? TimeOfDay.fromDateTime(DateTime.now().toUtc());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (final context, final child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<HasilSimpanModel<PelangganAktifModel>> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return HasilSimpanModel(sukses: false, pesan: 'Data belum lengkap');
    }

    if (_selectedPelanggan == null ||
        _selectedPaket == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedDompet == null ||
        _selectedKategori == null) {
      return HasilSimpanModel(
          sukses: false, pesan: 'Harap lengkapi semua data');
    }

    try {
      final tanggalMulai = DateTime.utc(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute);
      final tanggalBerakhir =
          hitungTanggalBerakhir(tanggalMulai, _selectedPaket!);
      final transaksiId =
          (_isEditMode && widget.pelangganAktif?.idTransaksi != null)
              ? widget.pelangganAktif!.idTransaksi!
              : const Uuid().v4();

      final pelangganAktifData = PelangganAktifModel(
          id: _isEditMode ? widget.pelangganAktif!.id : '',
          idPelanggan: _selectedPelanggan!.id,
          idPaket: _selectedPaket!.id,
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          status: _statusPembayaran,
          idTransaksi: transaksiId);

      final transaksiData = TransaksiModel(
          id: transaksiId,
          tanggal: tanggalMulai,
          keterangan: 'Aktivasi Paket: ${_selectedPaket!.nama}',
          jumlah: _gunakanPoin ? 0 : _selectedPaket!.harga.toDouble(),
          tipe: _gunakanPoin
              ? TipeTransaksiEnum.pengeluaran
              : TipeTransaksiEnum.pemasukan,
          idDompet: _selectedDompet!.id,
          idKategori: _selectedKategori!.id,
          idPelanggan: _selectedPelanggan!.id,
          idPaket: _selectedPaket!.id,
          statusPembayaran: _statusPembayaran,
          poinYangDihasilkan: _gunakanPoin ? 0 : _selectedPaket!.poinHadiah,
          poinYangDigunakan: _gunakanPoin ? _selectedPaket!.poinPenukaran : 0,
          durasiPaket: _selectedPaket!.durasi,
          tipeDurasiPaket: _selectedPaket!.tipe,
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          aktivasiPaket: true);

      PelangganAktifModel pelangganAktifHasil;
      if (_isEditMode) {
        pelangganAktifHasil = await widget.pelangganAktifOperasi
            .updatePelangganAktif(pelangganAktifData);
        await widget.transaksiOperasi
            .updateTransaksi(transaksiId, transaksiData);
      } else {
        pelangganAktifHasil = await widget.pelangganAktifOperasi
            .createPelangganAktif(pelangganAktifData);
        await widget.transaksiOperasi.tambahTransaksi(transaksiData);
      }

      PembaruanDataService.instance.picuPembaruan();
      return HasilSimpanModel(
          sukses: true, pesan: 'Berhasil disimpan', data: pelangganAktifHasil);
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan data pelanggan aktif.', e: e, st: s);
      return HasilSimpanModel(sukses: false, pesan: 'Gagal menyimpan: $e');
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _isEditMode ? 'Edit Pelanggan Aktif' : 'Form Pelanggan Aktif')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPoinSwitch(),
                      const SizedBox(height: 16),
                      _buildPelangganDropdown(),
                      const SizedBox(height: 16),
                      _buildPaketDropdown(),
                      const SizedBox(height: 16),
                      _buildDompetDropdown(),
                      const SizedBox(height: 16),
                      _buildKategoriDropdown(),
                      const SizedBox(height: 24),
                      _buildDateTimePicker(),
                      const SizedBox(height: 8),
                      _buildStatusPembayaranButtons(),
                      const SizedBox(height: 16),
                      _buildInfoTanggal(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildPoinSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Gunakan Poin',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (_gunakanPoin)
            Text('Poin dipakai: ${hitungPoinEfektif()}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Text('Sisa poin: ${hitungSisaPoin()}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ]),
        Switch(
            value: _gunakanPoin,
            onChanged: (final value) {
              setState(() {
                _gunakanPoin = value;
                if (!_kategoriList.contains(_selectedKategori)) {
                  _selectedKategori =
                      _kategoriList.isNotEmpty ? _kategoriList.first : null;
                }
              });
            }),
      ]),
    );
  }

  Widget _buildPelangganDropdown() {
    return DropdownButtonFormField<PelangganModel>(
      key: const Key('pelanggan_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Pelanggan', border: OutlineInputBorder()),
      initialValue: _selectedPelanggan,
      items: _pelangganList
          .map((final p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: (final newValue) async {
        if (newValue == null) {
          return;
        }
        final saldoPoin =
            await widget.transaksiOperasi.getTotalPoin(newValue.id);
        if (mounted) {
          setState(() {
            _selectedPelanggan = newValue;
            _saldoPoinPelanggan = saldoPoin;
          });
        }
      },
      validator: (final v) => v == null ? 'Pelanggan tidak boleh kosong' : null,
    );
  }

  Widget _buildPaketDropdown() {
    return DropdownButtonFormField<PaketModel>(
      key: const Key('paket_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Paket', border: OutlineInputBorder()),
      initialValue: _selectedPaket,
      items: _paketList
          .map((final p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: (final newValue) => setState(() => _selectedPaket = newValue),
      validator: (final v) => v == null ? 'Paket tidak boleh kosong' : null,
    );
  }

  Widget _buildDompetDropdown() {
    return DropdownButtonFormField<DompetModel>(
      key: const Key('dompet_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Dompet', border: OutlineInputBorder()),
      initialValue: _selectedDompet,
      items: _daftarDompet
          .map((final d) =>
              DropdownMenuItem(value: d, child: Text(d.namaDompet)))
          .toList(),
      onChanged: (final newValue) => setState(() => _selectedDompet = newValue),
      validator: (final v) => v == null ? 'Dompet tidak boleh kosong' : null,
    );
  }

  Widget _buildKategoriDropdown() {
    return DropdownButtonFormField<KategoriModel>(
      key: const Key('kategori_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Kategori Transaksi', border: OutlineInputBorder()),
      initialValue: _selectedKategori,
      items: _kategoriList
          .map((final k) => DropdownMenuItem(value: k, child: Text(k.nama)))
          .toList(),
      onChanged: (final newValue) =>
          setState(() => _selectedKategori = newValue),
      validator: (final v) => v == null ? 'Kategori tidak boleh kosong' : null,
    );
  }

  Widget _buildDateTimePicker() {
    return Column(children: [
      const Text('Pilih Tanggal & Waktu Aktif:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        TextButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(_selectedDate == null
                ? 'Pilih Tanggal'
                : FormatTanggal.formatTanggalBasic(_selectedDate!))),
        TextButton.icon(
            onPressed: () => _selectTime(context),
            icon: const Icon(Icons.access_time),
            label: Text(_selectedTime == null
                ? 'Pilih Jam'
                : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}')),
      ]),
    ]);
  }

  Widget _buildStatusPembayaranButtons() {
    return Row(children: [
      Expanded(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _statusPembayaran == StatusPembayaranEnum.lunas
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                  foregroundColor:
                      _statusPembayaran == StatusPembayaranEnum.lunas
                          ? Colors.white
                          : Colors.black),
              onPressed: () => setState(
                  () => _statusPembayaran = StatusPembayaranEnum.lunas),
              child: const Text('Lunas'))),
      const SizedBox(width: 8),
      Expanded(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _statusPembayaran == StatusPembayaranEnum.belumLunas
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                  foregroundColor:
                      _statusPembayaran == StatusPembayaranEnum.belumLunas
                          ? Colors.white
                          : Colors.black),
              onPressed: () => setState(
                  () => _statusPembayaran = StatusPembayaranEnum.belumLunas),
              child: const Text('Belum Lunas'))),
    ]);
  }

  Widget _buildInfoTanggal() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Tanggal Mulai:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text((_selectedDate == null || _selectedTime == null)
            ? 'Pilih Tanggal & Jam'
            : FormatTanggal.formatTanggalDanJam(DateTime.utc(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute)))
      ]),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Tanggal Berakhir:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text((() {
          if (_selectedDate != null &&
              _selectedTime != null &&
              _selectedPaket != null) {
            final startDate = DateTime.utc(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute);
            return FormatTanggal.formatTanggalDanJam(
                hitungTanggalBerakhir(startDate, _selectedPaket!));
          } else {
            return 'Pilih paket & tanggal mulai';
          }
        }())),
      ]),
    ]);
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final hasil = await _saveForm();
          if (!mounted) {
            return;
          }
          if (hasil.sukses) {
            SnackBarUtil.success(context, hasil.pesan);
            if (hasil.data != null) {
              try {
                await PesanInfoPaket.kirimRincianPaket(hasil.data!);
              } on Exception catch (e) {
                Log.warning('Gagal mengirim pesan WhatsApp: $e');
                if (mounted) {
                  SnackBarUtil.warning(context,
                      'Gagal mengirim pesan WhatsApp. Aplikasi tidak terpasang?');
                }
              }
            }
            await Future<void>.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              navigator.pop(true);
            }
          } else {
            SnackBarUtil.error(context, hasil.pesan);
          }
        },
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50)),
        child: const Text('Simpan'),
      ),
    );
  }
}
