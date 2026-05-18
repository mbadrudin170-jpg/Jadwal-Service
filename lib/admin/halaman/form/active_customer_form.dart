// path: lib/admin/halaman/form/active_customer_form.dart
// diubah: Menambahkan dokumentasi publik dan memperbaiki kurung kurawal.
// diubah: Mengambil data transaksi di mode edit untuk mengisi dompet & kategori.
// diubah: Mengganti `initialValue` ke `value` di Dropdown agar update state terlihat.
// diubah: Memperbaiki error tipe data nullable pada pemanggilan PesanInfoPaket.kirimRincianPaket.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/save_result_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/category_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/tab/active_customer_tab.dart (ActiveCustomerPage)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/active_customer_model.dart (ActiveCustomerModel)
//   - lib/shared/model/category_model.dart (CategoryModel)
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/model/save_result_model.dart (SaveResultModel)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/model/wallet_model.dart (WalletModel)
//   - lib/shared/operasi/active_customer_operation.dart (ActiveCustomerOperation)
//   - lib/shared/operasi/category_operation.dart (CategoryOperation)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/operasi/wallet_operation.dart (WalletOperation)
//   - lib/shared/services/pembaruan_data_service.dart (PembaruanDataService)
//   - lib/shared/utils/format_util.dart (FormatUtil)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)

/// Fungsi untuk menghitung tanggal berakhir berdasarkan tanggal mulai dan durasi paket.
DateTime hitungTanggalBerakhir(
  final DateTime startDate,
  final PackageModel paket,
) {
  Log.info('FUNGSI GLOBAL: hitungTanggalBerakhir() dipanggil.');
  Log.info('  - Tanggal Mulai: ${startDate.toIso8601String()}');
  Log.info('  - Nama Paket: ${paket.name}');
  Log.info('  - Tipe Durasi: ${paket.type.name}');
  Log.info('  - Durasi: ${paket.duration}');

  DateTime hasil;
  switch (paket.type) {
    case DurationType.hours:
      hasil = startDate.add(Duration(hours: paket.duration));
      break;
    case DurationType.days:
      hasil = startDate.add(Duration(days: paket.duration));
      break;
    case DurationType.months:
      hasil = Jiffy.parseFromDateTime(startDate)
          .add(months: paket.duration)
          .dateTime;
      break;
    case DurationType.minutes:
      hasil = startDate.add(Duration(minutes: paket.duration));
      break;
  }

  Log.info('  - Hasil Tanggal Berakhir: ${hasil.toIso8601String()}');
  return hasil;
}

/// Form untuk menambah atau mengubah data pelanggan yang sedang aktif.
class FormPelangganAktif extends StatefulWidget {
  /// Data pelanggan aktif yang akan diedit.
  final ActiveCustomerModel? pelangganAktif;

  /// Operasi untuk data pelanggan
  final CustomerOperation pelangganOperasi;

  /// Operasi untuk data paket
  final PackageOperation paketOperasi;

  /// Operasi untuk data pelanggan aktif
  final ActiveCustomerOperation pelangganAktifOperasi;

  /// Operasi untuk data transaksi
  final TransactionOperation transaksiOperasi;

  /// Operasi untuk data dompet
  final WalletOperation dompetOperasi;

  /// Operasi untuk data kategori
  final CategoryOperation kategoriOperasi;

  /// Konstruktor untuk FormPelangganAktif
  FormPelangganAktif({
    super.key,
    this.pelangganAktif,
    final CustomerOperation? pelangganOperasi,
    final PackageOperation? paketOperasi,
    final ActiveCustomerOperation? pelangganAktifOperasi,
    final TransactionOperation? transaksiOperasi,
    final WalletOperation? dompetOperasi,
    final CategoryOperation? kategoriOperasi,
  })  : pelangganOperasi = pelangganOperasi ?? CustomerOperation(),
        paketOperasi = paketOperasi ?? PackageOperation(),
        pelangganAktifOperasi =
            pelangganAktifOperasi ?? ActiveCustomerOperation(),
        transaksiOperasi = transaksiOperasi ?? TransactionOperation(),
        dompetOperasi = dompetOperasi ?? WalletOperation(),
        kategoriOperasi = kategoriOperasi ?? CategoryOperation();

  @override
  State<FormPelangganAktif> createState() => _FormPelangganAktifState();
}

class _FormPelangganAktifState extends State<FormPelangganAktif> {
  final _formKey = GlobalKey<FormState>();

  List<CustomerModel> _pelangganList = [];
  List<PackageModel> _paketList = [];
  List<WalletModel> _daftarDompet = [];
  List<CategoryModel> _kategoriPemasukanList = [];
  List<CategoryModel> _kategoriPengeluaranList = [];

  List<CategoryModel> get _kategoriList =>
      _gunakanPoin ? _kategoriPengeluaranList : _kategoriPemasukanList;

  CustomerModel? _selectedPelanggan;
  PackageModel? _selectedPaket;
  WalletModel? _selectedDompet;
  CategoryModel? _selectedKategori;

  bool _isLoading = true;
  bool _gunakanPoin = false;
  int _saldoPoinPelanggan = 0;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  PaymentStatus _statusPembayaran = PaymentStatus.paid;

  bool get _isEditMode => widget.pelangganAktif != null;

  int hitungPoinEfektif() {
    if (_selectedPaket == null) {
      return 0;
    }
    return _gunakanPoin ? _selectedPaket!.redemptionPoints : 0;
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
      final transaksiTerkaitFuture = pa?.transactionId != null
          ? widget.transaksiOperasi.getTransactionById(pa!.transactionId!)
          : Future<TransactionModel?>.value();

      final results = await Future.wait([
        widget.pelangganOperasi.getCustomers(),
        widget.paketOperasi.getPackages(),
        widget.dompetOperasi.getWallets(),
        widget.kategoriOperasi.getCategories(),
        transaksiTerkaitFuture,
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _pelangganList = (results[0] as List<CustomerModel>)
          ..sort((final a, final b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _paketList = results[1] as List<PackageModel>;
        _daftarDompet = (results[2] as List<WalletModel>)
            .where((final d) => !d.isDeleted)
            .toList();
        final semuaKategori = results[3] as List<CategoryModel>;
        _kategoriPemasukanList = semuaKategori
            .where((final k) => k.type == CategoryType.income && !k.isDeleted)
            .toList();
        _kategoriPengeluaranList = semuaKategori
            .where((final k) => k.type == CategoryType.expense && !k.isDeleted)
            .toList();

        final transaksiTerkait =
            results.length > 4 && results[4] is TransactionModel
                ? results[4] as TransactionModel?
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

  void _mapEditData(final TransactionModel? transaksi) {
    final pa = widget.pelangganAktif!;
    Log.info('Memetakan data edit untuk PelangganAktif ID: ${pa.id}');

    _selectedPelanggan =
        _pelangganList.firstWhereOrNull((final p) => p.id == pa.customerId);
    _selectedPaket =
        _paketList.firstWhereOrNull((final p) => p.id == pa.packageId);

    if (transaksi != null) {
      Log.info(
          'Transaksi terkait (ID: ${transaksi.id}) ditemukan. Memetakan dompet dan kategori.');
      _selectedDompet = _daftarDompet
          .firstWhereOrNull((final d) => d.id == transaksi.walletId);
      final kategoriSumber = transaksi.type == TransactionType.income
          ? _kategoriPemasukanList
          : _kategoriPengeluaranList;
      _selectedKategori = kategoriSumber
          .firstWhereOrNull((final k) => k.id == transaksi.categoryId);
    } else {
      Log.warning(
          'Transaksi terkait untuk PelangganAktif ID: ${pa.id} tidak ditemukan.');
      if (mounted) {
        SnackBarUtil.info(context,
            'Info: Transaksi asli tidak ditemukan, pilih ulang dompet/kategori.');
      }
    }

    _selectedDate = pa.startDate;
    _selectedTime = TimeOfDay.fromDateTime(pa.startDate);
    _statusPembayaran = pa.status;

    if (_selectedPelanggan != null) {
      unawaited(widget.transaksiOperasi
          .getTotalPoints(_selectedPelanggan!.id)
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
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
    if (_daftarDompet.isNotEmpty) {
      _selectedDompet = _daftarDompet.first;
    }
    if (_kategoriPemasukanList.isNotEmpty) {
      _selectedKategori = _kategoriPemasukanList.firstWhereOrNull(
              (final k) => k.name.toLowerCase() == 'aktivasi paket') ??
          _kategoriPemasukanList.first;
    }
  }

  Future<void> _selectDate(final BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(final BuildContext context) async {
    final initial = _selectedTime ?? TimeOfDay.fromDateTime(DateTime.now());
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

  Future<SaveResultModel<ActiveCustomerModel>> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return SaveResultModel(success: false, message: 'Data belum lengkap');
    }

    if (_selectedPelanggan == null ||
        _selectedPaket == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedDompet == null ||
        _selectedKategori == null) {
      return SaveResultModel(
          success: false, message: 'Harap lengkapi semua data');
    }

    try {
      final tanggalMulai = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      final tanggalBerakhir =
          hitungTanggalBerakhir(tanggalMulai, _selectedPaket!);
      final transaksiId =
          (_isEditMode && widget.pelangganAktif?.transactionId != null)
              ? widget.pelangganAktif!.transactionId!
              : const Uuid().v4();

      final pelangganAktifData = ActiveCustomerModel(
          id: _isEditMode ? widget.pelangganAktif!.id : '',
          customerId: _selectedPelanggan!.id,
          packageId: _selectedPaket!.id,
          startDate: tanggalMulai,
          endDate: tanggalBerakhir,
          status: _statusPembayaran,
          transactionId: transaksiId);

      final transaksiData = TransactionModel(
          id: transaksiId,
          date: tanggalMulai,
          description: 'Aktivasi Paket: ${_selectedPaket!.name}',
          amount: _gunakanPoin ? 0 : _selectedPaket!.price.toDouble(),
          type: _gunakanPoin ? TransactionType.expense : TransactionType.income,
          walletId: _selectedDompet!.id,
          categoryId: _selectedKategori!.id,
          customerId: _selectedPelanggan!.id,
          packageId: _selectedPaket!.id,
          paymentStatus: _statusPembayaran,
          earnedPoints: _gunakanPoin ? 0 : _selectedPaket!.rewardPoints,
          usedPoints: _gunakanPoin ? _selectedPaket!.redemptionPoints : 0,
          packageDuration: _selectedPaket!.duration,
          durationType: _selectedPaket!.type,
          startDate: tanggalMulai,
          endDate: tanggalBerakhir,
          isActivated: true);

      ActiveCustomerModel pelangganAktifHasil;
      if (_isEditMode) {
        pelangganAktifHasil = await widget.pelangganAktifOperasi
            .updateActiveCustomer(pelangganAktifData);
        await widget.transaksiOperasi
            .updateTransaction(transaksiId, transaksiData);
      } else {
        pelangganAktifHasil = await widget.pelangganAktifOperasi
            .createActiveCustomer(pelangganAktifData);
        await widget.transaksiOperasi.addTransaction(transaksiData);
      }

      return SaveResultModel(
          success: true,
          message: 'Berhasil disimpan',
          data: pelangganAktifHasil);
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan data pelanggan aktif.', e: e, st: s);
      return SaveResultModel(success: false, message: 'Gagal menyimpan: $e');
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
    return DropdownButtonFormField<CustomerModel>(
      key: const Key('pelanggan_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Pelanggan', border: OutlineInputBorder()),
      initialValue: _selectedPelanggan,
      items: _pelangganList
          .map((final p) => DropdownMenuItem(value: p, child: Text(p.name)))
          .toList(),
      onChanged: (final newValue) async {
        if (newValue == null) {
          return;
        }
        final saldoPoin =
            await widget.transaksiOperasi.getTotalPoints(newValue.id);
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
    return DropdownButtonFormField<PackageModel>(
      key: const Key('paket_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Paket', border: OutlineInputBorder()),
      initialValue: _selectedPaket,
      items: _paketList
          .map((final p) => DropdownMenuItem(value: p, child: Text(p.name)))
          .toList(),
      onChanged: (final newValue) => setState(() => _selectedPaket = newValue),
      validator: (final v) => v == null ? 'Paket tidak boleh kosong' : null,
    );
  }

  Widget _buildDompetDropdown() {
    return DropdownButtonFormField<WalletModel>(
      key: const Key('dompet_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Dompet', border: OutlineInputBorder()),
      initialValue: _selectedDompet,
      items: _daftarDompet
          .map((final d) => DropdownMenuItem(value: d, child: Text(d.name)))
          .toList(),
      onChanged: (final newValue) => setState(() => _selectedDompet = newValue),
      validator: (final v) => v == null ? 'Dompet tidak boleh kosong' : null,
    );
  }

  Widget _buildKategoriDropdown() {
    return DropdownButtonFormField<CategoryModel>(
      key: const Key('kategori_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Kategori Transaksi', border: OutlineInputBorder()),
      initialValue: _selectedKategori,
      items: _kategoriList
          .map((final k) => DropdownMenuItem(value: k, child: Text(k.name)))
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
            icon: const Icon(AppIcons.calendar),
            label: Text(_selectedDate == null
                ? 'Pilih Tanggal'
                : FormatDate.formatDateBasic(_selectedDate!))),
        TextButton.icon(
            onPressed: () => _selectTime(context),
            icon: const Icon(AppIcons.clock),
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
                  backgroundColor: _statusPembayaran == PaymentStatus.paid
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200],
                  foregroundColor: _statusPembayaran == PaymentStatus.paid
                      ? Colors.white
                      : Colors.black),
              onPressed: () =>
                  setState(() => _statusPembayaran = PaymentStatus.paid),
              child: const Text('Lunas'))),
      const SizedBox(width: 8),
      Expanded(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _statusPembayaran == PaymentStatus.unpaid
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200],
                  foregroundColor: _statusPembayaran == PaymentStatus.unpaid
                      ? Colors.white
                      : Colors.black),
              onPressed: () =>
                  setState(() => _statusPembayaran = PaymentStatus.unpaid),
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
            : FormatDateTime.formatDateAndTimeCompact(DateTime(
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
            final startDate = DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute);
            return FormatDateTime.formatDateAndTimeCompact(
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
          if (hasil.success) {
            SnackBarUtil.success(context, hasil.message);
            await Future<void>.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              navigator.pop(true);
            }
          } else {
            SnackBarUtil.error(context, hasil.message);
          }
        },
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50)),
        child: const Text('Simpan'),
      ),
    );
  }
}
