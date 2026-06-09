// path: lib/admin/halaman/form/active_customer_form.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/admin/providers/active_customer_provider.dart';
import 'package:wifi/admin/providers/statistik_provider.dart';
import 'package:wifi/admin/providers/transaction_provider.dart';
import 'package:wifi/shared/common/text.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/date_time_picker_widget.dart';
import 'package:wifi/shared/widget/input/input_angka.dart';

class FormPelangganAktif extends ConsumerStatefulWidget {
  final ActiveCustomerModel? pelangganAktif;

  const FormPelangganAktif({super.key, this.pelangganAktif});

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
  late TextEditingController _bonusDurationController;
  DurationType _bonusDurationType = DurationType.minutes;
  bool _isBonus = false;
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
    _bonusDurationController = TextEditingController();
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
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final paketList = (results[1] as List<PackageModel>)
        ..sort((a, b) =>
            _getDurationInMinutes(a).compareTo(_getDurationInMinutes(b)));

      final daftarDompet =
          (results[2] as List<WalletModel>).where((d) => !d.isDeleted).toList();

      final semuaKategori = results[3] as List<CategoryModel>;
      final kategoriPemasukanList = semuaKategori
          .where((k) => k.type == CategoryType.income && !k.isDeleted)
          .toList();
      final kategoriPengeluaranList = semuaKategori
          .where((k) => k.type == CategoryType.expense && !k.isDeleted)
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

  void _mapEditData(TransactionModel? transaksi) {
    final transaksiOperasi = ref.read(transactionOperationProvider);
    final pa = widget.pelangganAktif!;
    Log.info('Memetakan data edit untuk PelangganAktif ID: ${pa.id}');

    _selectedPelanggan =
        _pelangganList.firstWhereOrNull((p) => p.id == pa.customerId);
    _selectedPaket = _paketList.firstWhereOrNull((p) => p.id == pa.packageId);

    if (transaksi != null) {
      Log.info(
          'Transaksi terkait (ID: ${transaksi.id}) ditemukan. Memetakan dompet dan kategori.');
      _selectedDompet =
          _daftarDompet.firstWhereOrNull((d) => d.id == transaksi.walletId);
      final kategoriSumber = transaksi.type == TransactionType.income
          ? _kategoriPemasukanList
          : _kategoriPengeluaranList;
      _selectedKategori =
          kategoriSumber.firstWhereOrNull((k) => k.id == transaksi.categoryId);

      if (transaksi.durasiBonus != null && transaksi.durasiBonus! > 0) {
        _isBonus = true;
        _bonusDurationController.text = transaksi.durasiBonus.toString();
        _bonusDurationType = transaksi.durasiBonusType ?? DurationType.hours;
      }
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
      transaksiOperasi.getTotalPoints(_selectedPelanggan!.id).then((poin) {
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
              (k) => k.name.toLowerCase() == 'aktivasi paket') ??
          _kategoriPemasukanList.first;
    }
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

  Future<SaveResultModel<ActiveCustomerModel>> _simpanData() async {
    Log.info('Mulai menyimpan form, isEditMode=$_isEditMode');
    final notifikasiOpFirebase = ref.read(notifikasiOpFirebaseProvider);
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
      final int nilaiBonus =
          _isBonus ? (int.tryParse(_bonusDurationController.text) ?? 0) : 0;
      final DateTime tanggalBerakhir = CalculationUtil.hitungTanggalBerakhir(
        tanggalMulai,
        _selectedPaket!,
        durasiBonus: nilaiBonus,
        durasiBonusType: _isBonus ? _bonusDurationType : null,
      );

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
        durasiBonus: nilaiBonus,
        durasiBonusType: _isBonus ? _bonusDurationType : null,
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
        notifikasiOpFirebase.deleteByTransactionId(transaksiId);
        Log.info(
            'menghapus data notifikasi dalam mode edit agar data selalu terbaru');
      } else {
        pelangganAktifHasil = await pelangganAktifOperasi
            .createActiveCustomer(pelangganAktifData);
        await ref
            .read(transactionProvider.notifier)
            .addTransaction(transaksiData);
      }
      ref.invalidate(activeCustomerProvider);

      final totalDurasi = tanggalBerakhir.difference(tanggalMulai);
      final durasiSetengahJalan =
          Duration(microseconds: (totalDurasi.inMicroseconds / 2).round());
      final tanggalNotifikasiSetengahJalan =
          tanggalMulai.add(durasiSetengahJalan);

      final List<NotifikasiModel> daftarNotifikasi = [
        NotifikasiModel(
          id: const Uuid().v4(),
          startDate: tanggalMulai,
          endDate: tanggalBerakhir,
          userId: _selectedPelanggan!.id,
          tanggalTampil: tanggalNotifikasiSetengahJalan,
          title: 'Info: Setengah Perjalanan Paket',
          description:
              'Anda telah menggunakan 50% dari masa aktif paket ${_selectedPaket!.name}.',
          idTujuan: transaksiId,
          type: TipeNotifikasiEnum.transaksi,
          updatedAt: DateTime.now().toUtc(),
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          startDate: tanggalMulai,
          endDate: tanggalBerakhir,
          userId: _selectedPelanggan!.id,
          tanggalTampil: tanggalBerakhir.subtract(const Duration(days: 1)),
          title: 'Pengingat: Masa Aktif Segera Habis',
          description:
              'Masa aktif paket ${_selectedPaket!.name} Anda akan berakhir besok.',
          idTujuan: transaksiId,
          type: TipeNotifikasiEnum.transaksi,
          updatedAt: DateTime.now().toUtc(),
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          startDate: tanggalMulai,
          endDate: tanggalBerakhir,
          userId: _selectedPelanggan!.id,
          tanggalTampil: tanggalBerakhir,
          title: 'Masa Aktif Paket Habis',
          description:
              'Masa aktif untuk paket ${_selectedPaket!.name} telah berakhir hari ini.',
          idTujuan: transaksiId,
          type: TipeNotifikasiEnum.transaksi,
          updatedAt: DateTime.now().toUtc(),
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          startDate: tanggalMulai,
          endDate: tanggalBerakhir,
          userId: _selectedPelanggan!.id,
          tanggalTampil: tanggalBerakhir.add(const Duration(days: 1)),
          title: 'Masa Aktif Telah Berakhir',
          description:
              'Masa aktif untuk paket ${_selectedPaket!.name} telah berakhir kemarin. Silakan perpanjang.',
          idTujuan: transaksiId,
          type: TipeNotifikasiEnum.transaksi,
          updatedAt: DateTime.now().toUtc(),
        ),
      ];
      Log.info('data notifikasi untuk masa aktif paket telah dibuat,');

      for (final notif in daftarNotifikasi) {
        notifikasiOpFirebase.add(notif);
      }

      final internetService = ref.read(internetConnectionServiceProvider);
      final isOnline = await internetService.checkLocalConnection();
      String successMessage;
      if (isOnline) {
        Log.info('Koneksi online, memulai sinkronisasi di latar belakang.');
        final syncCheckService = ref.read(syncCheckServiceProvider);
        unawaited(syncCheckService.runSyncCheck());
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
                      _buildTombolBonus(),
                      _buildDurasiBonus(),
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
            onChanged: (value) {
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
          .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
          .toList(),
      onChanged: (newValue) async {
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
      validator: (v) => v == null ? 'Pelanggan tidak boleh kosong' : null,
    );
  }

  Widget _buildPaketDropdown() {
    return DropdownButtonFormField<PackageModel>(
      key: const Key('paket_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Paket', border: OutlineInputBorder()),
      initialValue: _selectedPaket,
      items: _paketList
          .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
          .toList(),
      onChanged: (newValue) {
        Log.info('Paket dipilih: id=${newValue?.id} nama=${newValue?.name}');
        setState(() => _selectedPaket = newValue);
      },
      validator: (v) => v == null ? 'Paket tidak boleh kosong' : null,
    );
  }

  Widget _buildDompetDropdown() {
    return DropdownButtonFormField<WalletModel>(
      key: const Key('dompet_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Dompet', border: OutlineInputBorder()),
      initialValue: _selectedDompet,
      items: _daftarDompet
          .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
          .toList(),
      onChanged: (newValue) {
        Log.info('Dompet dipilih: id=${newValue?.id} nama=${newValue?.name}');
        setState(() => _selectedDompet = newValue);
      },
      validator: (v) => v == null ? 'Dompet tidak boleh kosong' : null,
    );
  }

  Widget _buildKategoriDropdown() {
    return DropdownButtonFormField<CategoryModel>(
      key: const Key('kategori_dropdown'),
      decoration: const InputDecoration(
          labelText: 'Pilih Kategori Transaksi', border: OutlineInputBorder()),
      initialValue: _selectedKategori,
      items: _kategoriList
          .map((k) => DropdownMenuItem(value: k, child: Text(k.name)))
          .toList(),
      onChanged: (newValue) {
        Log.info('Kategori dipilih: id=${newValue?.id} nama=${newValue?.name}');
        setState(() => _selectedKategori = newValue);
      },
      validator: (v) => v == null ? 'Kategori tidak boleh kosong' : null,
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
            final int nilaiBonus = _isBonus
                ? (int.tryParse(_bonusDurationController.text) ?? 0)
                : 0;
            final DateTime endDate = CalculationUtil.hitungTanggalBerakhir(
              startDate,
              _selectedPaket!,
              durasiBonus: nilaiBonus,
              durasiBonusType: _isBonus ? _bonusDurationType : null,
            );

            return FormatDateTime.formatDateAndTimeCompact(endDate);
          } else {
            return 'Pilih paket & tanggal mulai';
          }
        }())),
      ]),
    ]);
  }

  Widget _buildTombolBonus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const TeksIsiBesar('Bonus'),
        Switch(
          value: _isBonus,
          onChanged: (value) {
            setState(() {
              _isBonus = value;
              Log.info('Status bonus diubah: $_isBonus');
            });
          },
        ),
      ],
    );
  }

  Widget _buildDurasiBonus() {
    if (!_isBonus) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gapH8,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: InputAngka(
                controller: _bonusDurationController,
                label: 'Durasi Bonus ',
                icons: TIcons.timerOutlined,
                validasi: _isBonus,
              ),
            ),
            gapW8,
            Expanded(
              child: DropdownButtonFormField<DurationType>(
                key: const Key('dropdown_bonus_duration_type'),
                initialValue: _bonusDurationType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: DurationType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _bonusDurationType = newValue;
                      Log.info('Tipe durasi bonus diubah: $_bonusDurationType');
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
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
            ref.invalidate(activeCustomerOpFirebaseProvider);
            ref.invalidate(activeCustomerOperationProvider);
            ref.invalidate(transactionOperationProvider);
            ref.invalidate(transactionOpFirebaseProvider);
            ref.invalidate(walletOperationProvider);
            ref.invalidate(statistikProvider);
            navigator.pop();
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
