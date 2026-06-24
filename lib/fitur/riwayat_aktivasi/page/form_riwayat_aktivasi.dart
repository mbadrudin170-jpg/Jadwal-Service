// path: lib/fitur/riwayat_aktivasi/page/form_riwayat_aktivasi.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FromRiwayatAktivasi extends ConsumerStatefulWidget {
  final TransaksiModel transaksi;

  const FromRiwayatAktivasi({super.key, required this.transaksi});

  @override
  ConsumerState<FromRiwayatAktivasi> createState() =>
      _SubscriptionHistoryFormState();
}

class _SubscriptionHistoryFormState extends ConsumerState<FromRiwayatAktivasi> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _tanggalMulai;
  late DateTime _tanggalBerakhir;
  late StatusPembayaran _statusPembayaran;

  @override
  void initState() {
    super.initState();
    _tanggalMulai = widget.transaksi.tanggalMulai ?? DateTime.now();
    _tanggalBerakhir = widget.transaksi.tanggalBerakhir ?? DateTime.now();
    _statusPembayaran = widget.transaksi.statusPembayaran;
    Log.info(
      'Form edit riwayat langganan diinisialisasi untuk transaksi ID: ${widget.transaksi.id}',
    );
  }

  Future<void> _selectDateTime(bool isStartDate) async {
    final initialDate = isStartDate ? _tanggalMulai : _tanggalBerakhir;

    if (!mounted) return;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (isStartDate) {
          _tanggalMulai = newDateTime;
          Log.info('Tanggal & waktu mulai diubah menjadi: $_tanggalMulai');
        } else {
          _tanggalBerakhir = newDateTime;
          Log.info(
            'Tanggal & waktu berakhir diubah menjadi: $_tanggalBerakhir',
          );
        }
      });
    }
  }

  Future<void> _simpanPerubahan() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.warning('Form tidak valid, penyimpanan dibatalkan.');
      return;
    }
    if (!mounted) return;

    Log.info('Menyimpan perubahan untuk transaksi ID: ${widget.transaksi.id}');

    // Mengakses dependency melalui Riverpod's ref
    final transaksiOpSqlite = ref.read(transaksiOpSqliteProvider);
    final layananNotifikasi = ref.read(layananNotifikasiProvider);

    try {
      final updateTransaksi = widget.transaksi.copyWith(
        tanggalMulai: _tanggalMulai,
        tanggalBerakhir: _tanggalBerakhir,
        statusPembayaran: _statusPembayaran,
        diperbaruiPada: DateTime.now(),
      );

      await transaksiOpSqlite.perbaruiTransaksi(
        widget.transaksi.id,
        updateTransaksi,
      );
      Log.info('Transaksi berhasil diperbarui di database.');
      ref.invalidate(transaksiOpSqliteProvider);
      await _handleExpiryNotification(
        layananNotifikasi: layananNotifikasi,
        statusSebelumnya: widget.transaksi.statusPembayaran,
        statusSekarang: _statusPembayaran,
        tanggalBerakhir: _tanggalBerakhir,
      );

      if (!mounted) return;

      final isOnline = await ref
          .read(koneksiInternetServiceProvider)
          .cekKoneksiLokal();
      if (isOnline) {
        final syncCheckService = ref.read(layananCekSinkronisasiProvider);
        unawaited(syncCheckService.jalankanCekSinkronisasi());
        if (mounted) {
          ToastUtil.success(
            context,
            'Riwayat langganan berhasil diperbarui dan disinkronkan.',
          );
        }
      } else {
        if (mounted) {
          ToastUtil.info(
            context,
            'Koneksi offline. Data disimpan lokal dan akan disinkronkan saat online.',
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } on Exception catch (e) {
      Log.error('Gagal memperbarui riwayat langganan', e: e);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memperbarui riwayat: ${e.toString()}');
    }
  }

  Future<void> _handleExpiryNotification({
    required LayananNotifikasi layananNotifikasi,
    required StatusPembayaran statusSebelumnya,
    required StatusPembayaran statusSekarang,
    required DateTime tanggalBerakhir,
  }) async {
    final idNotifikasi = widget.transaksi.id.hashCode;
    final wasPaid = statusSebelumnya == StatusPembayaran.paid;
    final isNowPaid = statusSekarang == StatusPembayaran.paid;

    if ((!wasPaid && isNowPaid) || (wasPaid && isNowPaid)) {
      final jadwal = tanggalBerakhir;
      if (jadwal.isAfter(DateTime.now())) {
        Log.info(
          'Menjadwalkan notifikasi berakhirnya paket untuk ID: $idNotifikasi pada $jadwal',
        );
        await layananNotifikasi.perbaruiJadwalNotifikasi(
          id: idNotifikasi,
          title: 'Langganan Telah Berakhir',
          body:
              'Masa aktif paket Anda telah berakhir. Perpanjang sekarang untuk terhubung lagi.',
          jadwal: jadwal,
        );
      }
    } else if (wasPaid && !isNowPaid) {
      Log.info(
        'Membatalkan notifikasi berakhirnya paket untuk ID: $idNotifikasi karena status tidak lagi LUNAS.',
      );
      await layananNotifikasi.batalNotifikasi(idNotifikasi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Riwayat Langganan')),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildDateTimePickerTile(
                label: 'Tanggal & Waktu Mulai',
                date: _tanggalMulai,
                onPressed: () => _selectDateTime(true),
              ),
              gapH16,
              _buildDateTimePickerTile(
                label: 'Tanggal & Waktu Berakhir',
                date: _tanggalBerakhir,
                onPressed: () => _selectDateTime(false),
              ),
              gapH24,
              DropdownButtonFormField<StatusPembayaran>(
                initialValue: _statusPembayaran,
                decoration: const InputDecoration(
                  labelText: 'Status Pembayaran',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                items: StatusPembayaran.values.map((status) {
                  return DropdownMenuItem<StatusPembayaran>(
                    value: status,
                    child: Text(status.displayName.toUpperCase()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _statusPembayaran = newValue;
                      Log.info(
                        'Status pembayaran diubah menjadi: $_statusPembayaran',
                      );
                    });
                  }
                },
              ),
              gapH32,
              ElevatedButton.icon(
                label: const Text('Simpan Perubahan'),
                onPressed: _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePickerTile({
    required String label,
    required DateTime date,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      title: Text(label),
      subtitle: Text(FormatWaktuLengkap.formatSingkat(date)),
      trailing: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(Icons.calendar_month_outlined),
      ),
      onTap: onPressed,
    );
  }
}
