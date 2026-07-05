// path: lib/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/fitur/paket/core/perhitungan_paket.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/future_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_angka.dart';
import 'package:wifi/shared/widget/pemilih_tanggal_waktu_widget.dart';

class FormPelangganAktif extends ConsumerStatefulWidget {
  final PelangganAktifModel? pelangganAktif;
  final bool modePerpanjang; // baru
  const FormPelangganAktif({
    super.key,
    this.pelangganAktif,
    this.modePerpanjang = false,
  });
  @override
  ConsumerState<FormPelangganAktif> createState() => _FormPelangganAktifState();
}

class _FormPelangganAktifState extends ConsumerState<FormPelangganAktif> {
  final _formKey = GlobalKey<FormState>();

  List<PelangganModel> _daftarPelanggan = [];
  List<PaketModel> _daftarPaket = [];
  List<DompetModel> _dompetList = [];
  List<KategoriModel> _kategoriPemasukanList = [];
  List<KategoriModel> _kategoriPengeluaranList = [];
  List<KategoriModel> get _kategoriList =>
      _gunakanPoin ? _kategoriPengeluaranList : _kategoriPemasukanList;
  PelangganModel? _pelangganDipilih;
  PaketModel? _paketDipilih;
  DompetModel? _dompetDipilih;
  KategoriModel? _kategoriDipilih;
  bool _isLoading = true;
  bool _menyimpan = false;
  bool _gunakanPoin = false;
  late TextEditingController _durasiBonusController;
  TipeDurasiPaket _tipeBonusDurasi = TipeDurasiPaket.minutes;
  bool _bonus = false;
  int _saldoPoinPelanggan = 0;
  DateTime? _pilihTanggal;
  TimeOfDay? _pilihJam;
  StatusPembayaran _statusPembayaran = StatusPembayaran.paid;
  bool get _modeEdit => widget.pelangganAktif != null && !widget.modePerpanjang;
  bool get _modePerpanjang => widget.modePerpanjang;
  int hitungPoinEfektif() {
    if (_paketDipilih == null) {
      return 0;
    }
    return _gunakanPoin ? _paketDipilih!.poinPenukaran : 0;
  }

  int hitungSisaPoin() {
    final poinDipakai = hitungPoinEfektif();
    return (_saldoPoinPelanggan - poinDipakai).clamp(0, 999999999);
  }

  int _statusPembayaranNotif = 0;

  @override
  void initState() {
    super.initState();
    _durasiBonusController = TextEditingController();
    _loadAllData().catchError((Object e, StackTrace st) {
      Log.error('Gagal memuat data di FormPelangganAktif', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data. Silakan coba lagi.');
        setState(() => _isLoading = false);
        if (widget.pelangganAktif?.status == StatusPembayaran.unpaid) {
          setState(() {
            _statusPembayaranNotif = 1;
          });
          Log.info('Bernilai $_statusPembayaranNotif');
        }
      }
    });
  }

  @override
  void dispose() {
    _durasiBonusController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    Log.info('Memulai memuat semua data untuk FormPelangganAktif');
    final pelangganOpSqlite = ref.read(pelangganOpSqliteProvider);
    final paketOpsqlite = ref.read(paketOpSqliteProvider);
    final transaksiOperasi = ref.read(transaksiOpGlobalProvider);
    final dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    final kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    try {
      final pa = widget.pelangganAktif;
      final transaksiTerkaitFuture = pa?.idTransaksi != null
          ? transaksiOperasi.ambilBerdasarkanId(pa!.idTransaksi)
          : Future<TransaksiModel?>.value();
      final hasil = await futureWait([
        pelangganOpSqlite.ambilSemua(),
        paketOpsqlite.ambilSemua(),
        dompetOpSqlite.ambilSemua(),
        kategoriOpSqlite.ambilSemua(),
        transaksiTerkaitFuture,
      ]);
      if (!mounted) return;

      final daftarPelanggan = (hasil[0] as List<PelangganModel>)
        ..sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      final daftarPaket = (hasil[1] as List<PaketModel>)
        ..sort(
          (a, b) => PerhitunganPaket()
              .hitungDurasiPaket(a)
              .compareTo(PerhitunganPaket().hitungDurasiPaket(b)),
        );
      final daftarDompet = (hasil[2] as List<DompetModel>)
          .where((d) => !d.dihapus)
          .toList();
      final semuaKategori = hasil[3] as List<KategoriModel>;
      final kategoriPemasukanList = semuaKategori
          .where((k) => k.tipe == TipeKategori.income && !k.diHapus)
          .toList();
      final daftarKategoriPengeluaran = semuaKategori
          .where((k) => k.tipe == TipeKategori.expense && !k.diHapus)
          .toList();
      final transaksiTerkait = hasil.length > 4 && hasil[4] is TransaksiModel
          ? hasil[4] as TransaksiModel?
          : null;
      setState(() {
        _daftarPelanggan = daftarPelanggan;
        _daftarPaket = daftarPaket;
        _dompetList = daftarDompet;
        _kategoriPemasukanList = kategoriPemasukanList;
        _kategoriPengeluaranList = daftarKategoriPengeluaran;
      });
      Log.info('Semua data berhasil dimuat.');
      if (_modePerpanjang) {
        await _mapPerpanjangData();
      } else if (_modeEdit) {
        await _mapEditData(transaksiTerkait);
      } else {
        _mapNewData();
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Log.info('Semua data berhasil dimuat.');
    } catch (e, s) {
      Log.error('Gagal memuat data referensi', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _mapEditData(TransaksiModel? transaksi) async {
    final transaksiOperasi = ref.read(transaksiOpGlobalProvider);
    final pa = widget.pelangganAktif!;
    Log.info('Memetakan data edit untuk PelangganAktif ID: ${pa.id}');
    _pelangganDipilih = _daftarPelanggan.firstWhereOrNull(
      (p) => p.id == pa.idPelanggan,
    );
    _paketDipilih = _daftarPaket.firstWhereOrNull((p) => p.id == pa.idPaket);
    if (transaksi != null) {
      Log.info(
        'Transaksi terkait (ID: ${transaksi.id}) ditemukan. Memetakan dompet dan kategori.',
      );
      _dompetDipilih = _dompetList.firstWhereOrNull(
        (d) => d.id == transaksi.idDompet,
      );
      final kategoriSumber = transaksi.tipe == TipeTransaksi.income
          ? _kategoriPemasukanList
          : _kategoriPengeluaranList;
      _kategoriDipilih = kategoriSumber.firstWhereOrNull(
        (k) => k.id == transaksi.idKategori,
      );
      if (transaksi.durasiBonus > 0) {
        _bonus = true;
        _durasiBonusController.text = transaksi.durasiBonus.toString();
        _tipeBonusDurasi = transaksi.tipeDurasiBonus ?? TipeDurasiPaket.hours;
      }
    } else {
      Log.warning(
        'Transaksi terkait untuk PelangganAktif ID: ${pa.id} tidak ditemukan.',
      );
      if (mounted) {
        ToastUtil.info(
          context,
          'Info: Transaksi asli tidak ditemukan, pilih ulang dompet/kategori.',
        );
      }
    }
    _pilihTanggal = pa.tanggalMulai;
    _pilihJam = TimeOfDay.fromDateTime(pa.tanggalMulai);
    _statusPembayaran = pa.status;
    if (_pelangganDipilih != null) {
      final poin = await transaksiOperasi.ambilTotalPoin(_pelangganDipilih!.id);
      if (mounted) {
        setState(() => _saldoPoinPelanggan = poin);
      }
    }
    Log.info('Pemetaan data edit selesai.');
  }

  void _mapNewData() {
    Log.info('Menginisialisasi form untuk entri baru.');
    final now = DateTime.now();
    _pilihTanggal = now;
    _pilihJam = TimeOfDay.fromDateTime(now);
    if (_dompetList.isNotEmpty) {
      _dompetDipilih = _dompetList.first;
    }
    if (_kategoriPemasukanList.isNotEmpty) {
      _kategoriDipilih =
          _kategoriPemasukanList.firstWhereOrNull(
            (k) => k.nama.toLowerCase() == 'aktivasi paket',
          ) ??
          _kategoriPemasukanList.first;
    }
  }

  Future<void> _mapPerpanjangData() async {
    final pa = widget.pelangganAktif!;
    _pelangganDipilih = _daftarPelanggan.firstWhereOrNull(
      (p) => p.id == pa.idPelanggan,
    );
    _paketDipilih = _daftarPaket.firstWhereOrNull((p) => p.id == pa.idPaket);

    // Untuk perpanjang, tanggal mulai diisi dengan tanggal berakhir saat ini
    _pilihTanggal = pa.tanggalBerakhir;
    _pilihJam = TimeOfDay.fromDateTime(pa.tanggalBerakhir);

    // Dompet dan kategori diisi default (bisa diubah user)
    _dompetDipilih = _dompetList.isNotEmpty ? _dompetList.first : null;
    _kategoriDipilih =
        _kategoriPemasukanList.firstWhereOrNull(
          (k) => k.nama.toLowerCase() == 'perpanjangan paket',
        ) ??
        _kategoriPemasukanList.first;

    _statusPembayaran = StatusPembayaran.paid; // default lunas

    // Ambil saldo poin seperti biasa
    if (_pelangganDipilih != null) {
      final transaksiOperasi = ref.read(transaksiOpGlobalProvider);
      final poin = await transaksiOperasi.ambilTotalPoin(_pelangganDipilih!.id);
      if (mounted) setState(() => _saldoPoinPelanggan = poin);
    }
  }

  Future<void> _memilihTanggal(BuildContext context) async {
    Log.info('Memilih tanggal, saat ini: $_pilihTanggal');
    final terpilih = await showDatePicker(
      context: context,
      initialDate: _pilihTanggal ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (terpilih != null && terpilih != _pilihTanggal) {
      setState(() => _pilihTanggal = terpilih);
      Log.info('Tanggal dipilih: ${FormatTanggal.formatDasar(terpilih)}');
    }
  }

  Future<void> _memilihJam(BuildContext context) async {
    Log.info('Memilih waktu, saat ini: $_pilihJam');
    final initial = _pilihJam ?? TimeOfDay.fromDateTime(DateTime.now());
    final terpilih = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (terpilih != null && terpilih != _pilihJam) {
      setState(() => _pilihJam = terpilih);
      Log.info('Waktu dipilih: ${terpilih.hour}:${terpilih.minute}');
    }
  }

  Future<bool> _simpanData() async {
    Log.info('Mulai menyimpan form, isEditMode=$_modeEdit');
    final notifikasiOpSqlite = ref.read(notifikasiOpSqliteProvider);
    final pelangganAktif = ref.read(pelangganAktifProvider.notifier);
    final transaksiOp = ref.read(transaksiOpProvider.notifier);

    final String idPelangganAktif;
    final String idTransaksi;

    if (_modePerpanjang) {
      idPelangganAktif = widget.pelangganAktif!.id;
      idTransaksi = const Uuid().v4();
    } else if (_modeEdit) {
      idPelangganAktif = widget.pelangganAktif!.id;
      idTransaksi = widget.pelangganAktif!.idTransaksi;
    } else {
      idPelangganAktif = const Uuid().v4();
      idTransaksi = const Uuid().v4();
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.warning('Validasi form gagal');
      if (mounted) {
        ToastUtil.error(context, 'Data belum lengkap');
      }
      return false;
    }
    if (_pelangganDipilih == null ||
        _paketDipilih == null ||
        _pilihTanggal == null ||
        _pilihJam == null ||
        _dompetDipilih == null ||
        _kategoriDipilih == null) {
      Log.warning('Data form belum lengkap');
      if (mounted) {
        ToastUtil.error(context, 'Harap lengkapi semua data');
      }
      return false;
    }
    try {
      final tanggalMulai = DateTime(
        _pilihTanggal!.year,
        _pilihTanggal!.month,
        _pilihTanggal!.day,
        _pilihJam!.hour,
        _pilihJam!.minute,
      );
      var durasiBonus = 0;
      if (_bonus) {
        durasiBonus =
            int.tryParse(_durasiBonusController.text.replaceAll('.', '')) ?? 0;
        if (durasiBonus <= 0) {
          ToastUtil.error(
            context,
            'Durasi bonus harus diisi dan lebih dari 0.',
          );
          return false;
        }
      }
      final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
        tanggalMulai,
        _paketDipilih!,
        durasiBonus: durasiBonus,
        tipeDurasiBonus: _bonus ? _tipeBonusDurasi : null,
      );
      final sekarang = DateTime.now();
      final pelangganAktifData = PelangganAktifModel(
        id: idPelangganAktif,
        idPelanggan: _pelangganDipilih!.id,
        idPaket: _paketDipilih!.id,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: _statusPembayaran,
        idTransaksi: idTransaksi,
        diperbaruiPada: sekarang,
      );
      final transaksiData = TransaksiModel(
        id: idTransaksi,
        tanggal: tanggalMulai,
        deskripsi: _gunakanPoin
            ? 'Tukar Poin ${_paketDipilih!.nama}'
            : 'Aktivasi Paket: ${_paketDipilih!.nama}',
        jumlah: _gunakanPoin ? 0 : _paketDipilih!.harga.toDouble(),
        tipe: _gunakanPoin ? TipeTransaksi.expense : TipeTransaksi.income,
        idDompet: _dompetDipilih!.id,
        idKategori: _kategoriDipilih!.id,
        idPelanggan: _pelangganDipilih!.id,
        idPaket: _paketDipilih?.id,
        statusPembayaran: _statusPembayaran,
        poinDidapat: _gunakanPoin ? 0 : _paketDipilih!.poinHadiah,
        poinDigunakan: _gunakanPoin ? _paketDipilih!.poinPenukaran : 0,
        durasiPaket: _paketDipilih!.durasi,
        tipeDurasiPaket: _paketDipilih!.tipe,
        durasiBonus: durasiBonus,
        tipeDurasiBonus: _bonus ? _tipeBonusDurasi : null,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        statusAktivasi: true,
      );
      Log.info(
        'Menyimpan data: customerId=${_pelangganDipilih!.id}, packageId=${_paketDipilih!.id}, transaksiId=$idTransaksi',
      );
      if (_modePerpanjang) {
        // Perpanjang: update pelangganAktif yang sudah ada, transaksi BARU
        await pelangganAktif.perbarui(pelangganAktifData);
        await transaksiOp.tambah(transaksiData);
        // Hapus notifikasi dari transaksi sebelumnya (ID transaksi lama)
        await notifikasiOpSqlite.hapusBerdasarkanIdTujuan(
          widget.pelangganAktif!.idTransaksi,
        );
      } else if (_modeEdit) {
        await futureWait([
          pelangganAktif.perbarui(pelangganAktifData),
          transaksiOp.perbarui(transaksiData),
        ]);
        unawaited(notifikasiOpSqlite.hapusBerdasarkanIdTujuan(idTransaksi));
      } else {
        await Future.wait([
          pelangganAktif.tambah(pelangganAktifData),
          transaksiOp.tambah(transaksiData),
        ]);
      }
      final totalDurasi = tanggalBerakhir.difference(tanggalMulai);
      final durasiSetengahJalan = Duration(
        microseconds: (totalDurasi.inMicroseconds / 2).round(),
      );
      final tanggalNotifikasiSetengahJalan = tanggalMulai.add(
        durasiSetengahJalan,
      );
      final daftarNotifikasi = <NotifikasiModel>[
        NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          userId: _pelangganDipilih!.id,
          tanggalTampil: tanggalNotifikasiSetengahJalan,
          judul: 'Info: Setengah Perjalanan Paket',
          deskripsi:
              'Anda telah menggunakan 50% dari masa aktif paket ${_paketDipilih!.nama}.',
          idTujuan: idTransaksi,
          targetRole: AppRole.user,
          tipe: TipeNotifikasiEnum.transaksi,
          diperbaruiPada: sekarang,
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          userId: _pelangganDipilih!.id,
          tanggalTampil: tanggalBerakhir.subtract(const Duration(days: 1)),
          judul: 'Pengingat: Masa Aktif Segera Habis',
          deskripsi:
              'Masa aktif paket ${_paketDipilih!.nama} Anda akan berakhir besok.',
          idTujuan: idTransaksi,
          targetRole: AppRole.user,
          tipe: TipeNotifikasiEnum.transaksi,
          diperbaruiPada: sekarang,
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          userId: _pelangganDipilih!.id,
          tanggalTampil: tanggalBerakhir,
          judul: 'Masa Aktif Paket Habis',
          deskripsi:
              'Masa aktif untuk paket ${_paketDipilih!.nama} telah berakhir hari ini.',
          idTujuan: idTransaksi,
          targetRole: AppRole.user,
          tipe: TipeNotifikasiEnum.transaksi,
          diperbaruiPada: sekarang,
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          userId: _pelangganDipilih!.id,
          tanggalTampil: tanggalBerakhir.add(const Duration(days: 1)),
          judul: 'Masa Aktif Telah Berakhir',
          deskripsi:
              'Masa aktif untuk paket ${_paketDipilih!.nama} telah berakhir kemarin. Silakan perpanjang.',
          idTujuan: idTransaksi,
          targetRole: AppRole.user,
          tipe: TipeNotifikasiEnum.transaksi,
          diperbaruiPada: sekarang,
        ),
      ];
      await futureWait(
        daftarNotifikasi.map(notifikasiOpSqlite.tambahNotifikasi).toList(),
      );
      unawaited(
        ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
      );
      return true;
    } catch (e, s) {
      Log.error('Gagal menyimpan data pelanggan aktif.', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyimpan: $e');
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modePerpanjang
              ? 'Perpanjang Masa Aktif'
              : _modeEdit
              ? 'Edit Pelanggan Aktif'
              : 'Form Pelanggan Aktif',
        ),
      ),
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
                      PemilihTanggalWaktuWidget(
                        tanggalTerpilih: _pilihTanggal,
                        waktuTerpilih: _pilihJam,
                        onPilihTanggal: _modePerpanjang
                            ? null
                            : () => _memilihTanggal(context),
                        onPilihWaktu: _modePerpanjang
                            ? null
                            : () => _memilihJam(context),
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
      bottomNavigationBar: _buildTombolSimpan(),
    );
  }

  Widget _buildPoinSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.p16,
        vertical: TSizes.p8,
      ),
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
              gapH4,
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
            onChanged: (value) {
              if (!mounted) return;
              setState(() {
                _gunakanPoin = value;
                Log.info(
                  'Penggunaan poin diubah: $_gunakanPoin, poin efektif=${hitungPoinEfektif()}',
                );
                _kategoriDipilih = null;
                if (_kategoriList.isNotEmpty) {
                  _kategoriDipilih = _kategoriList.first;
                  Log.info(
                    'Kategori otomatis dipilih: ${_kategoriDipilih!.nama} (${_kategoriList.length} kategori tersedia)',
                  );
                } else {
                  Log.warning(
                    'Tidak ada kategori tersedia untuk mode ${_gunakanPoin ? "pengeluaran" : "pemasukan"}',
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPelangganDropdown() {
    final transaksiOperasi = ref.read(transaksiOpGlobalProvider);
    return DropdownButtonFormField<PelangganModel>(
      key: const Key('pelanggan_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Pelanggan',
        border: OutlineInputBorder(),
      ),
      initialValue: _pelangganDipilih,
      items: _daftarPelanggan
          .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: _modePerpanjang
          ? null
          : (newValue) async {
              if (newValue == null) return;
              final saldoPoin = await transaksiOperasi.ambilTotalPoin(
                newValue.id,
              );
              if (mounted) {
                setState(() {
                  _pelangganDipilih = newValue;
                  _saldoPoinPelanggan = saldoPoin;
                  if (_kategoriList.isNotEmpty && _kategoriDipilih == null) {
                    _kategoriDipilih = _kategoriList.first;
                  }
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
      initialValue: _paketDipilih,
      items: _daftarPaket
          .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: (newValue) {
        if (!mounted) return;
        Log.info(
          'Paket dipilih: id=${(newValue)?.id} nama=${(newValue)?.nama}',
        );
        setState(() => _paketDipilih = newValue);
      },
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
      initialValue: _dompetDipilih,
      items: _dompetList
          .map((d) => DropdownMenuItem(value: d, child: Text(d.nama)))
          .toList(),
      onChanged: (newValue) {
        Log.info('Dompet dipilih: id=${newValue?.id} nama=${newValue?.nama}');
        setState(() => _dompetDipilih = newValue);
      },
      validator: (v) => v == null ? 'Dompet tidak boleh kosong' : null,
    );
  }

  Widget _buildKategoriDropdown() {
    if (_kategoriList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(TSizes.p12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            gapW8,
            Expanded(
              child: Text(
                _gunakanPoin
                    ? 'Belum ada kategori pengeluaran. Buat kategori terlebih dahulu.'
                    : 'Belum ada kategori pemasukan. Buat kategori terlebih dahulu.',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }
    return DropdownButtonFormField<KategoriModel>(
      key: const Key('kategori_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Kategori Transaksi',
        border: OutlineInputBorder(),
      ),
      initialValue: _kategoriDipilih,
      items: _kategoriList
          .map((k) => DropdownMenuItem(value: k, child: Text(k.nama)))
          .toList(),
      onChanged: (newValue) {
        Log.info('Kategori dipilih: id=${newValue?.id} nama=${newValue?.nama}');
        setState(() => _kategoriDipilih = newValue);
      },
      validator: (v) {
        if (v == null) {
          return _kategoriList.isEmpty
              ? 'Tidak ada kategori tersedia. Silakan buat kategori terlebih dahulu.'
              : 'Kategori tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildStatusPembayaranButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _statusPembayaran == StatusPembayaran.paid
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
              foregroundColor: _statusPembayaran == StatusPembayaran.paid
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              Log.info('Status pembayaran diubah: paid');
              setState(() => _statusPembayaran = StatusPembayaran.paid);
            },
            child: const Text('Lunas'),
          ),
        ),
        gapW8,
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _statusPembayaran == StatusPembayaran.unpaid
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
              foregroundColor: _statusPembayaran == StatusPembayaran.unpaid
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              Log.info('Status pembayaran diubah: unpaid');
              setState(() => _statusPembayaran = StatusPembayaran.unpaid);
            },
            child: const Text('Belum Lunas'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTanggalBerakhir() {
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
              (_pilihTanggal == null || _pilihJam == null)
                  ? 'Pilih Tanggal & Jam'
                  : FormatWaktuLengkap.formatSingkat(
                      DateTime(
                        _pilihTanggal!.year,
                        _pilihTanggal!.month,
                        _pilihTanggal!.day,
                        _pilihJam!.hour,
                        _pilihJam!.minute,
                      ),
                    ),
            ),
          ],
        ),
        gapH8,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tanggal Berakhir:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text((() {
              if (_pilihTanggal != null &&
                  _pilihJam != null &&
                  _paketDipilih != null) {
                final startDate = DateTime(
                  _pilihTanggal!.year,
                  _pilihTanggal!.month,
                  _pilihTanggal!.day,
                  _pilihJam!.hour,
                  _pilihJam!.minute,
                );
                final nilaiBonus = _bonus
                    ? (int.tryParse(_durasiBonusController.text) ?? 0)
                    : 0;
                final endDate = PerhitunganUtil.hitungTanggalBerakhir(
                  startDate,
                  _paketDipilih!,
                  durasiBonus: nilaiBonus,
                  tipeDurasiBonus: _bonus ? _tipeBonusDurasi : null,
                );

                return FormatWaktuLengkap.formatSingkat(endDate);
              } else {
                return 'Pilih paket & tanggal mulai';
              }
            }())),
          ],
        ),
      ],
    );
  }

  Widget _buildTombolBonus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const TeksIsiBesar('Bonus'),
        Switch(
          value: _bonus,
          onChanged: (value) {
            setState(() {
              _bonus = value;
              Log.info('Status bonus diubah: $_bonus');
            });
          },
        ),
      ],
    );
  }

  Widget _buildDurasiBonus() {
    if (!_bonus) return const SizedBox.shrink();
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
                controller: _durasiBonusController,
                label: 'Durasi Bonus',
                enabled: _bonus,
                prefixIcon: TIcons.timer,
              ),
            ),
            gapW8,
            Expanded(
              child: DropdownButtonFormField<TipeDurasiPaket>(
                key: const Key('dropdown_bonus_duration_type'),
                initialValue: _tipeBonusDurasi,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: TipeDurasiPaket.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _tipeBonusDurasi = newValue;
                      Log.info('Tipe durasi bonus diubah: $_tipeBonusDurasi');
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

  Widget _buildTombolSimpan() {
    return Padding(
      padding: const EdgeInsets.all(TSizes.p16),
      child: ElevatedButton(
        onPressed: _menyimpan
            ? null
            : () async {
                setState(() {
                  _menyimpan = true;
                });
                Log.info('Tombol Simpan ditekan');
                final berhasil = await _simpanData();
                if (!mounted) {
                  setState(() {
                    _menyimpan = false;
                  });
                  return;
                }
                setState(() {
                  _menyimpan = false;
                });
                if (berhasil) {
                  // Tunda toast dan pop agar tidak bentrok dengan rebuild provider
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ToastUtil.success(context, 'Data berhasil disimpan');
                      Navigator.pop(context);
                    }
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ToastUtil.error(context, 'Data tidak tersimpan');
                    }
                  });
                }
              },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _menyimpan
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Simpan'),
      ),
    );
  }
}
