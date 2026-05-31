// path: lib/admin/halaman/form/active_customer_form.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/admin/halaman/widget/date_time_picker_widget.dart';
import 'package:wifi/admin/providers/active_customer_provider.dart';
import 'package:wifi/admin/providers/statistik_provider.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/admin/providers/transaction_provider.dart';
import 'package:wifi/admin/providers/wallet_provider.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FormPelangganAktif extends ConsumerStatefulWidget {
  final ActiveCustomerModel? pelangganAktif;

  FormPelangganAktif({super.key, this.pelangganAktif});

  @override
  ConsumerState<FormPelangganAktif> createState() => _FormPelangganAktifState();
}

class _FormPelangganAktifState extends ConsumerState<FormPelangganAktif> {
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

  int _getDurationInMinutes(final PackageModel package) {
    switch (package.type) {
      case DurationType.minutes:
        return package.duration;
      case DurationType.hours:
        return package.duration * 60;
      case DurationType.days:
        return package.duration * 24 * 60;
      case DurationType.months:
        return package.duration * 30 * 24 * 60;
    }
  }

  @override
  void initState() {
    super.initState();
    Log.info('FormPelangganAktif initState, isEditMode=$_isEditMode');
    unawaited(_loadAllData());
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    Log.info('Memulai memuat semua data untuk FormPelangganAktif');
    final pelangganOperasi = ref.read(customerOperationProvider);
    final paketOperasi = ref.read(packageOperationProvider);
    final transaksiOperasi = ref.read(transactionOperationProvider);
    final dompetOperasi = ref.read(walletOperationProvider);
    final kategoriOperasi = ref.read(categoryOperationProvider);
    try {
      final pa = widget.pelangganAktif;
      final transaksiTerkaitFuture = pa?.transactionId != null
          ? transaksiOperasi.getTransactionById(pa!.transactionId!)
          : Future<TransactionModel?>.value();

      final results = await Future.wait([
        pelangganOperasi.getAll(),
        paketOperasi.getByAktif(),
        dompetOperasi.getWallets(),
        kategoriOperasi.getCategories(),
        transaksiTerkaitFuture,
      ]);

      if (!mounted) {
        return;
      }

      final pelangganList = (results[0] as List<CustomerModel>)
        ..sort((final a, final b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final paketList = (results[1] as List<PackageModel>)
        ..sort((final a, final b) =>
            _getDurationInMinutes(a).compareTo(_getDurationInMinutes(b)));

      final daftarDompet = (results[2] as List<WalletModel>)
          .where((final d) => !d.isDeleted)
          .toList();

      final semuaKategori = results[3] as List<CategoryModel>;
      final kategoriPemasukanList = semuaKategori
          .where((final k) => k.type == CategoryType.income && !k.isDeleted)
          .toList();
      final kategoriPengeluaranList = semuaKategori
          .where((final k) => k.type == CategoryType.expense && !k.isDeleted)
          .toList();

      final transaksiTerkait =
          results.length > 4 && results[4] is TransactionModel
              ? results[4] as TransactionModel?
              : null;

      setState(() {
        _pelangganList = pelangganList;
        _paketList = paketList;
        _daftarDompet = daftarDompet;
        _kategoriPemasukanList = kategoriPemasukanList;
        _kategoriPengeluaranList = kategoriPengeluaranList;

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
        ToastUtil.error(context, 'Gagal memuat data: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _mapEditData(final TransactionModel? transaksi) {
    final transaksiOperasi = ref.read(transactionOperationProvider);
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
        ToastUtil.info(context,
            'Info: Transaksi asli tidak ditemukan, pilih ulang dompet/kategori.');
      }
    }

    _selectedDate = pa.startDate;
    _selectedTime = TimeOfDay.fromDateTime(pa.startDate);
    _statusPembayaran = pa.status;

    if (_selectedPelanggan != null) {
      transaksiOperasi
          .getTotalPoints(_selectedPelanggan!.id)
          .then((final poin) {
        if (mounted) {
          setState(() => _saldoPoinPelanggan = poin);
        }
      });
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

  Future<void> _selectTime(final BuildContext context) async {
    Log.info('Memilih waktu, saat ini: $_selectedTime');
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
      Log.info('Waktu dipilih: ${picked.hour}:${picked.minute}');
    }
  }

  Future<SaveResultModel<ActiveCustomerModel>> _simpanData() async {
    Log.info('Mulai menyimpan form, isEditMode=$_isEditMode');
    final pelangganAktifOperasi = ref.read(activeCustomerOperationProvider);
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.warning('Validasi form gagal');
      if (mounted) {
        ToastUtil.error(context, 'Data belum lengkap');
      }
      return SaveResultModel(success: false, message: 'Data belum lengkap');
    }

    if (_selectedPelanggan == null ||
        _selectedPaket == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedDompet == null ||
        _selectedKategori == null) {
      Log.warning('Data form belum lengkap');
      if (mounted) {
        ToastUtil.error(context, 'Harap lengkapi semua data');
      }
      return SaveResultModel(
          success: false, message: 'Harap lengkapi semua data');
    }

    try {
      final tanggalMulai = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      final tanggalBerakhir =
          CalculationUtil.hitungTanggalBerakhir(tanggalMulai, _selectedPaket!);
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
        isActivated: true,
      );
      Log.info(
          'Menyimpan data: customerId=${_selectedPelanggan!.id}, packageId=${_selectedPaket!.id}, transaksiId=$transaksiId');

      ActiveCustomerModel pelangganAktifHasil;
      if (_isEditMode) {
        pelangganAktifHasil = await pelangganAktifOperasi
            .updateActiveCustomer(pelangganAktifData);
        await ref
            .read(transactionProvider.notifier)
            .updateTransaction(transaksiData);
      } else {
        pelangganAktifHasil = await pelangganAktifOperasi
            .createActiveCustomer(pelangganAktifData);
        await ref
            .read(transactionProvider.notifier)
            .addTransaction(transaksiData);
      }
      final internetService = InternetConnectionService();
      final isOnline = await internetService.checkConnection();
      String successMessage;
      if (isOnline) {
        Log.info('Koneksi online, memulai sinkronisasi di latar belakang.');
        unawaited(SyncCheckService().runSyncCheck());
        successMessage = 'Berhasil disimpan. Sinkronisasi dimulai...';
      } else {
        Log.warning('Koneksi offline, sinkronisasi akan dijalankan nanti.');
        successMessage = 'Berhasil disimpan (offline).';
      }
      Log.info('Berhasil menyimpan, id hasil=${pelangganAktifHasil.id}');
      return SaveResultModel(
          success: true, message: successMessage, data: pelangganAktifHasil);
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan data pelanggan aktif.', e: e, st: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyimpan: $e');
      }
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
              padding: const EdgeInsets.all(TSizes.p16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPoinSwitch(),
                      gapH16,
                      _buildPelangganDropdown(),
                      gapH16,
                      _buildPaketDropdown(),
                      gapH16,
                      _buildDompetDropdown(),
                      gapH16,
                      _buildKategoriDropdown(),
                      gapH24,
                      DateTimePickerWidget(
                        selectedDate: _selectedDate,
                        selectedTime: _selectedTime,
                        onSelectDate: () => _selectDate(context),
                        onSelectTime: () => _selectTime(context),
                      ),
                      gapH8,
                      _buildStatusPembayaranButtons(),
                      gapH24,
                      _buildInfoTanggalBerakhir(),
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
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.p16, vertical: TSizes.p8),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Gunakan Poin',
              style: TextStyle(fontWeight: FontWeight.bold)),
          gapH4,
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
                Log.info(
                    'Penggunaan poin diubah: $_gunakanPoin, poin efektif=${hitungPoinEfektif()}');
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
    final transaksiOperasi = ref.read(transactionOperationProvider);
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
        final saldoPoin = await transaksiOperasi.getTotalPoints(newValue.id);
        if (mounted) {
          setState(() {
            Log.info(
                'Pelanggan dipilih: id=${newValue.id} nama=${newValue.name}, saldoPoin=$saldoPoin');
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
      onChanged: (final newValue) {
        Log.info('Paket dipilih: id=${newValue?.id} nama=${newValue?.name}');
        setState(() => _selectedPaket = newValue);
      },
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
      onChanged: (final newValue) {
        Log.info('Dompet dipilih: id=${newValue?.id} nama=${newValue?.name}');
        setState(() => _selectedDompet = newValue);
      },
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
      onChanged: (final newValue) {
        Log.info('Kategori dipilih: id=${newValue?.id} nama=${newValue?.name}');
        setState(() => _selectedKategori = newValue);
      },
      validator: (final v) => v == null ? 'Kategori tidak boleh kosong' : null,
    );
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
              onPressed: () {
                Log.info('Status pembayaran diubah: paid');
                setState(() => _statusPembayaran = PaymentStatus.paid);
              },
              child: const Text('Lunas'))),
      gapW8,
      Expanded(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _statusPembayaran == PaymentStatus.unpaid
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200],
                  foregroundColor: _statusPembayaran == PaymentStatus.unpaid
                      ? Colors.white
                      : Colors.black),
              onPressed: () {
                Log.info('Status pembayaran diubah: unpaid');
                setState(() => _statusPembayaran = PaymentStatus.unpaid);
              },
              child: const Text('Belum Lunas'))),
    ]);
  }

  Widget _buildInfoTanggalBerakhir() {
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
      gapH8,
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
                CalculationUtil.hitungTanggalBerakhir(
                    startDate, _selectedPaket!));
          } else {
            return 'Pilih paket & tanggal mulai';
          }
        }())),
      ]),
    ]);
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(TSizes.p16),
      child: ElevatedButton(
        onPressed: () async {
          Log.info('Tombol Simpan ditekan');
          final navigator = Navigator.of(context);
          final hasil = await _simpanData();
          if (!mounted) {
            return;
          }
          if (hasil.success) {
            ToastUtil.success(context, hasil.message);
            ref.invalidate(activeCustomerProvider);
            ref.read(walletProvider.notifier).refresh();
            ref.read(statistikProvider.notifier).refresh();
            ref.invalidate(statistikProvider);
            navigator.pop(true);
            Log.info(
                'Form berhasil disimpan, memicu refresh dompet, statistik, dan menutup halaman.');
          } else {
            ToastUtil.error(context, hasil.message);
            Log.warning('Form gagal disimpan, pesan: ${hasil.message}');
          }
        },
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50)),
        child: const Text('Simpan'),
      ),
    );
  }
}
