// path: lib/fitur/investasi/page/form_saham.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
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
    final investasiAsync = ref.watch(investasiProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Investasi' : 'Tambah Investasi'),
      ),
      body: investasiAsync.when(
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  InputTeks(
                    controller: _idTransaksiController,
                    focusNode: _idTransaksiFocusNode,
                    nextFocusNode: _jumlahModalFocusNode,
                    label: 'ID Transaksi',
                    prefixIcon: TIcons.receiptLong,
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chevron_left),
                      ),
                      InputAngka(
                        controller: _jumlahLembarController,
                        focusNode: _jumlahLembarFocusNode,
                        label: 'Jumlah Lembar',
                        prefixIcon: TIcons.points,
                        textInputAction: TextInputAction.done,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(TIcons.chevronRight),
                      ),
                    ],
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
          );
        },
        error: (error, stackTrace) {},
        loading: () {},
      ),
    );
  }
}
