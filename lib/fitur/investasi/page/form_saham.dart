// path: lib/fitur/investasi/page/form_saham.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_angka.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';
import 'package:wifi/shared/widget/pemilih_tanggal_waktu_widget.dart';

class FormSaham extends ConsumerStatefulWidget {
  final String? idInvestasi;
  final String? idInvestor;
  const FormSaham({super.key, this.idInvestasi, this.idInvestor});

  @override
  ConsumerState<FormSaham> createState() => _FormSahamState();
}

class _FormSahamState extends ConsumerState<FormSaham> {
  final _formKey = GlobalKey<FormState>();
  final _idTransaksiController = TextEditingController();
  final _jumlahModalController = TextEditingController();
  final _jumlahLembarController = TextEditingController();
  final _idTransaksiFocusNode = FocusNode();
  final _jumlahModalFocusNode = FocusNode();
  final _jumlahLembarFocusNode = FocusNode();

  DateTime? _tanggalInvestasi;
  TimeOfDay? _waktuInvestasi;
  bool _menyimpan = false;
  bool get _modeEdit => widget.idInvestasi != null;

  @override
  void initState() {
    super.initState();
    _tanggalInvestasi = DateTime.now();
    _waktuInvestasi = TimeOfDay.fromDateTime(DateTime.now());

    if (_modeEdit) {
      final investasi = ref
          .read(investasiProvider)
          .value
          ?.ambilInvestasiById(widget.idInvestasi!);
      if (investasi != null) {
        _idTransaksiController.text = investasi.idTransaksi;
        _jumlahModalController.text = investasi.jumlahModal.toString();
        _jumlahLembarController.text = investasi.jumlahLembar.toString();
        _tanggalInvestasi = investasi.tanggalInvestasi ?? DateTime.now();
        _waktuInvestasi = investasi.tanggalInvestasi != null
            ? TimeOfDay.fromDateTime(investasi.tanggalInvestasi!)
            : TimeOfDay.fromDateTime(DateTime.now());
      }
    }
  }

  @override
  void dispose() {
    _idTransaksiController.dispose();
    _jumlahModalController.dispose();
    _jumlahLembarController.dispose();
    _idTransaksiFocusNode.dispose();
    _jumlahModalFocusNode.dispose();
    _jumlahLembarFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalInvestasi ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _tanggalInvestasi = picked);
    }
  }

  Future<void> _pilihWaktu() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _waktuInvestasi ?? TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _waktuInvestasi = picked);
    }
  }

  Future<void> _pilihTransaksi() async {
    final transaksiState = ref.read(transaksiOpProvider);
    if (!transaksiState.hasValue) {
      ToastUtil.warning(context, 'Data transaksi belum tersedia');
      return;
    }

    final daftarTransaksi = transaksiState.value!.transaksi;
    if (daftarTransaksi.isEmpty) {
      ToastUtil.warning(context, 'Belum ada transaksi');
      return;
    }

    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Transaksi'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: daftarTransaksi.length > 20
                  ? 20
                  : daftarTransaksi.length,
              itemBuilder: (context, index) {
                final transaksi = daftarTransaksi[index];
                return ListTile(
                  title: Text(
                    transaksi.deskripsi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'ID: ${transaksi.id}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    FormatUang.formatMataUang(transaksi.jumlah),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _idTransaksiController.text = transaksi.id;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simpan() async {
    if (_menyimpan) return;
    if (!_formKey.currentState!.validate()) return;

    final idInvestor = widget.idInvestor;
    if (idInvestor == null || idInvestor.isEmpty) {
      ToastUtil.error(context, 'ID Investor tidak ditemukan');
      return;
    }

    setState(() => _menyimpan = true);

    try {
      final tanggal = DateTime(
        _tanggalInvestasi!.year,
        _tanggalInvestasi!.month,
        _tanggalInvestasi!.day,
        _waktuInvestasi!.hour,
        _waktuInvestasi!.minute,
      );

      final investasi = InvestasiModel(
        id: _modeEdit ? widget.idInvestasi! : const Uuid().v4(),
        idInvestor: idInvestor,
        idTransaksi: _idTransaksiController.text.trim(),
        jumlahModal: double.parse(_jumlahModalController.text),
        jumlahLembar: int.parse(_jumlahLembarController.text),
        tanggalInvestasi: tanggal,
      );

      final notifier = ref.read(investasiProvider.notifier);
      if (_modeEdit) {
        await notifier.perbaruiInvestasi(investasi);
        if (mounted) {
          ToastUtil.success(context, 'Investasi berhasil diperbarui');
        }
      } else {
        await notifier.tambahInvestasi(investasi);
        if (mounted) {
          ToastUtil.success(context, 'Investasi berhasil ditambahkan');
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e, s) {
      Log.error('Gagal menyimpan investasi', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Investasi' : 'Tambah Investasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InputTeks(
                      controller: _idTransaksiController,
                      focusNode: _idTransaksiFocusNode,
                      nextFocusNode: _jumlahModalFocusNode,
                      label: 'ID Transaksi',
                      prefixIcon: TIcons.receiptLong,
                    ),
                  ),
                  IconButton(
                    onPressed: _pilihTransaksi,
                    icon: const Icon(TIcons.search),
                    tooltip: 'Pilih Transaksi',
                  ),
                ],
              ),
              gapH16,
              InputAngka(
                controller: _jumlahModalController,
                focusNode: _jumlahModalFocusNode,
                nextFocusNode: _jumlahLembarFocusNode,
                label: 'Jumlah Modal',
                prefixIcon: TIcons.money,
              ),
              gapH16,
              InputAngka(
                controller: _jumlahLembarController,
                focusNode: _jumlahLembarFocusNode,
                label: 'Jumlah Lembar',
                prefixIcon: TIcons.points,
                textInputAction: TextInputAction.done,
              ),
              gapH16,
              PemilihTanggalWaktuWidget(
                tanggalTerpilih: _tanggalInvestasi,
                waktuTerpilih: _waktuInvestasi,
                onPilihTanggal: _pilihTanggal,
                onPilihWaktu: _pilihWaktu,
                teksLabel: 'Tanggal Investasi',
              ),
              gapH24,
              ElevatedButton(
                onPressed: _menyimpan ? null : _simpan,
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
            ],
          ),
        ),
      ),
    );
  }
}
