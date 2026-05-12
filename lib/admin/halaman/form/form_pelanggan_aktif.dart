// path: lib/admin/halaman/form/form_pelanggan_aktif.dart

import 'package:wifi/shared/operasi/kategori_operasi.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_aktif_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/hasil_simpan_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/whatsapp/info_paket.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/enum/enum.dart';

DateTime hitungTanggalBerakhir(DateTime startDate, PaketModel paket) {
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
      hasil = Jiffy.parseFromDateTime(
        startDate,
      ).add(months: paket.durasi).dateTime;
      break;
    case TipeDurasi.menit:
      hasil = startDate.add(Duration(minutes: paket.durasi));
      break;
  }

  Log.info('  - Hasil Tanggal Berakhir: ${hasil.toIso8601String()}');
  return hasil;
}

class FormPelangganAktif extends StatefulWidget {
  final PelangganAktifModel? pelangganAktif;
  final PelangganOperasi pelangganOperasi;
  final PaketOperasi paketOperasi;
  final PelangganAktifOperasi pelangganAktifOperasi;
  final TransaksiOperasi transaksiOperasi;
  final DompetOperasi dompetOperasi;
  final KategoriOperasi kategoriOperasi;

  FormPelangganAktif({
    super.key,
    this.pelangganAktif,
    PelangganOperasi? pelangganOperasi,
    PaketOperasi? paketOperasi,
    PelangganAktifOperasi? pelangganAktifOperasi,
    TransaksiOperasi? transaksiOperasi,
    DompetOperasi? dompetOperasi,
    KategoriOperasi? kategoriOperasi,
  }) : pelangganOperasi = pelangganOperasi ?? PelangganOperasi(),
       paketOperasi = paketOperasi ?? PaketOperasi(),
       pelangganAktifOperasi = pelangganAktifOperasi ?? PelangganAktifOperasi(),
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
    if (_selectedPaket == null) return 0;
    if (_gunakanPoin) {
      return _selectedPaket!.poinPenukaran;
    }
    return 0;
  }

  int hitungSisaPoin() {
    final pakai = hitungPoinEfektif();
    return (_saldoPoinPelanggan - pakai).clamp(0, 999999999);
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        widget.pelangganOperasi.getPelanggan(),
        widget.paketOperasi.getPaket(),
        widget.dompetOperasi.getDompet(),
        widget.kategoriOperasi.getKategori(),
      ]);

      if (!mounted) return;

      setState(() {
        _pelangganList = (results[0] as List<PelangganModel>)
          ..sort(
            (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
          );
        _paketList = results[1] as List<PaketModel>;
        final semuaDompet = results[2] as List<DompetModel>;
        _daftarDompet = semuaDompet.where((d) => !d.isDeleted).toList();
        final semuaKategori = results[3] as List<KategoriModel>;
        _kategoriPemasukanList = semuaKategori
            .where((k) => k.tipe == TipeKategori.pemasukan && !k.isDeleted)
            .toList();
        _kategoriPengeluaranList = semuaKategori
            .where((k) => k.tipe == TipeKategori.pengeluaran && !k.isDeleted)
            .toList();

        if (_isEditMode) {
          _mapEditData();
        } else {
          _mapNewData();
        }

        _isLoading = false;
      });
    } catch (e, s) {
      Log.error('Gagal memuat data referensi', error: e, stackTrace: s);
      if (mounted) {
        SnackBarUtil.showError(context, 'Gagal memuat data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mapEditData() {
    final pa = widget.pelangganAktif!;
    try {
      _selectedPelanggan = _pelangganList.firstWhere(
        (p) => p.id == pa.idPelanggan,
      );
    } catch (e) {
      _selectedPelanggan = null;
    }
    try {
      _selectedPaket = _paketList.firstWhere((p) => p.id == pa.idPaket);
    } catch (e) {
      _selectedPaket = null;
      if (mounted) {
        SnackBarUtil.showWarning(
          context,
          'Peringatan: Paket asli (ID: ${pa.idPaket}) tidak ditemukan. Harap pilih paket baru.',
        );
      }
    }

    final tglMulai = pa.tanggalMulai;
    _selectedDate = tglMulai;
    _selectedTime = TimeOfDay.fromDateTime(tglMulai);
    _statusPembayaran = pa.status;
  }

  void _mapNewData() {
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    if (_daftarDompet.isNotEmpty) {
      _selectedDompet = _daftarDompet.first;
    }
    if (_kategoriPemasukanList.isNotEmpty) {
      try {
        _selectedKategori = _kategoriPemasukanList.firstWhere(
          (k) => k.nama.toLowerCase() == 'aktivasi paket',
        );
      } catch (e) {
        _selectedKategori = _kategoriPemasukanList.first;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<HasilSimpanModel<PelangganAktifModel>> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return HasilSimpanModel(sukses: false, pesan: 'Data belum lengkap');
    }

    final selectedPaket = _selectedPaket;
    if (_selectedPelanggan == null ||
        selectedPaket == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedDompet == null ||
        _selectedKategori == null) {
      return HasilSimpanModel(
        sukses: false,
        pesan: 'Harap lengkapi semua data',
      );
    }

    if (_gunakanPoin) {
      if (selectedPaket.poinPenukaran <= 0) {
        return HasilSimpanModel(
          sukses: false,
          pesan: 'Paket ini tidak mendukung penukaran poin',
        );
      }
      if (_saldoPoinPelanggan < selectedPaket.poinPenukaran) {
        return HasilSimpanModel(sukses: false, pesan: 'Poin tidak cukup');
      }
    }

    try {
      final tanggalMulai = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final tanggalBerakhir = hitungTanggalBerakhir(
        tanggalMulai,
        selectedPaket,
      );

      final transaksiId =
          _isEditMode && widget.pelangganAktif?.idTransaksi != null
          ? widget.pelangganAktif!.idTransaksi!
          : const Uuid().v4();

      final pelangganAktifData = PelangganAktifModel(
        id: _isEditMode ? widget.pelangganAktif!.id : '',
        idPelanggan: _selectedPelanggan!.id,
        idPaket: selectedPaket.id,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: _statusPembayaran,
        diperbarui: DateTime.now(),
        idTransaksi: transaksiId,
      );

      final transaksiData = TransaksiModel(
        id: transaksiId,
        tanggal: tanggalMulai,
        keterangan: 'Aktivasi Paket: ${selectedPaket.nama}',
        jumlah: _gunakanPoin ? 0 : selectedPaket.harga.toDouble(),
        tipe: _gunakanPoin
            ? TipeTransaksi.pengeluaran
            : TipeTransaksi.pemasukan,
        idDompet: _selectedDompet!.id,
        idKategori: _selectedKategori!.id,
        idPelanggan: _selectedPelanggan!.id,
        idPaket: selectedPaket.id,
        statusPembayaran: _statusPembayaran,
        poinYangDihasilkan: _gunakanPoin ? 0 : selectedPaket.poinHadiah,
        poinYangDigunakan: _gunakanPoin ? selectedPaket.poinPenukaran : 0,
        diperbarui: DateTime.now(),
        durasiPaket: selectedPaket.durasi,
        tipeDurasiPaket: selectedPaket.tipe,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        aktivasiPaket: true,
      );

      PelangganAktifModel pelangganAktifHasil;
      if (_isEditMode) {
        pelangganAktifHasil = await widget.pelangganAktifOperasi
            .updatePelangganAktif(pelangganAktifData);
        await widget.transaksiOperasi.updateTransaksi(
          transaksiId,
          transaksiData,
        );
      } else {
        pelangganAktifHasil = await widget.pelangganAktifOperasi
            .createPelangganAktif(pelangganAktifData);
        await widget.transaksiOperasi.tambahTransaksi(transaksiData);
      }

      return HasilSimpanModel(
        sukses: true,
        pesan: 'Berhasil disimpan',
        data: pelangganAktifHasil,
      );
    } catch (e, s) {
      Log.error(
        'Gagal menyimpan data pelanggan aktif.',
        error: e,
        stackTrace: s,
      );
      return HasilSimpanModel(sukses: false, pesan: 'Gagal menyimpan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Pelanggan Aktif' : 'Form Pelanggan Aktif',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gunakan Poin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (_gunakanPoin)
                Text(
                  'Poin dipakai: ${hitungPoinEfektif()}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              Text(
                'Sisa poin: ${hitungSisaPoin()}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Switch(
            value: _gunakanPoin,
            onChanged: (bool value) {
              setState(() {
                _gunakanPoin = value;
                if (!_kategoriList.contains(_selectedKategori)) {
                  _selectedKategori = _kategoriList.isNotEmpty
                      ? _kategoriList.first
                      : null;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPelangganDropdown() {
    return DropdownButtonFormField<PelangganModel>(
      key: const Key('pelanggan_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Pelanggan',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedPelanggan,
      items: _pelangganList
          .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: (PelangganModel? newValue) async {
        if (newValue == null) return;
        final saldoPoin = await widget.transaksiOperasi.getTotalPoin(
          newValue.id,
        );
        if (mounted) {
          setState(() {
            _selectedPelanggan = newValue;
            _saldoPoinPelanggan = saldoPoin;
          });
        }
      },
      validator: (v) => v == null ? 'Pelanggan tidak boleh kosong' : null,
    );
  }

  Widget _buildPaketDropdown() {
    return DropdownButtonFormField<PaketModel>(
      key: const Key('paket_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Paket',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedPaket,
      items: _paketList
          .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: (PaketModel? newValue) =>
          setState(() => _selectedPaket = newValue),
      validator: (v) => v == null ? 'Paket tidak boleh kosong' : null,
    );
  }

  Widget _buildDompetDropdown() {
    return DropdownButtonFormField<DompetModel>(
      key: const Key('dompet_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Dompet',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedDompet,
      items: _daftarDompet
          .map((d) => DropdownMenuItem(value: d, child: Text(d.namaDompet)))
          .toList(),
      onChanged: (DompetModel? newValue) =>
          setState(() => _selectedDompet = newValue),
      validator: (v) => v == null ? 'Dompet tidak boleh kosong' : null,
    );
  }

  Widget _buildKategoriDropdown() {
    return DropdownButtonFormField<KategoriModel>(
      key: const Key('kategori_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Kategori Transaksi',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedKategori,
      items: _kategoriList
          .map((k) => DropdownMenuItem(value: k, child: Text(k.nama)))
          .toList(),
      onChanged: (KategoriModel? newValue) =>
          setState(() => _selectedKategori = newValue),
      validator: (v) => v == null ? 'Kategori tidak boleh kosong' : null,
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      children: [
        const Text(
          'Pilih Tanggal & Waktu Aktif:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Pilih Tanggal'
                    : FormatTanggal.formatTanggalBasic(_selectedDate!),
              ),
            ),
            TextButton.icon(
              onPressed: () => _selectTime(context),
              icon: const Icon(Icons.access_time),
              label: Text(
                _selectedTime == null
                    ? 'Pilih Jam'
                    : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPembayaranButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _statusPembayaran == StatusPembayaranEnum.lunas
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
              foregroundColor: _statusPembayaran == StatusPembayaranEnum.lunas
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () =>
                setState(() => _statusPembayaran = StatusPembayaranEnum.lunas),
            child: const Text('Lunas'),
          ),
        ),
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
                  : Colors.black,
            ),
            onPressed: () => setState(
              () => _statusPembayaran = StatusPembayaranEnum.belumLunas,
            ),
            child: const Text('Belum Lunas'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTanggal() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tanggal Mulai:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              (_selectedDate == null || _selectedTime == null)
                  ? 'Pilih Tanggal & Jam'
                  : FormatTanggal.formatTanggalDanJam(
                      DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tanggal Berakhir:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text((() {
              if (_selectedDate != null && _selectedPaket != null) {
                DateTime startDate = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  _selectedTime?.hour ?? 0,
                  _selectedTime?.minute ?? 0,
                );
                final DateTime endDate = hitungTanggalBerakhir(
                  startDate,
                  _selectedPaket!,
                );
                return FormatTanggal.formatTanggalDanJam(endDate);
              } else {
                return 'Pilih paket & tanggal mulai';
              }
            }())),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          final navigator = Navigator.of(context);

          final hasil = await _saveForm();

          if (!mounted) return;

          if (hasil.sukses) {
            SnackBarUtil.showSuccess(context, hasil.pesan);
            if (hasil.data != null) {
              try {
                await PesanInfoPaket.kirimRincianPaket(hasil.data!);
              } catch (e) {
                Log.warning('Gagal mengirim pesan WhatsApp: $e');
                if (mounted) {
                  SnackBarUtil.showWarning(
                    context,
                    'Gagal mengirim pesan WhatsApp. Aplikasi tidak terpasang?',
                  );
                }
              }
            }
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              navigator.pop(true);
            }
          } else {
            SnackBarUtil.showError(context, hasil.pesan);
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Simpan'),
      ),
    );
  }
}
