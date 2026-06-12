// path: lib/admin/halaman/form/subscription_history_form.dart
// REFAKTOR: Mengubah StatefulWidget menjadi ConsumerStatefulWidget dan menggunakan
// Riverpod untuk dependency injection (TransactionOperation, NotifikasiServis).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
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

  late DateTime _startDate;
  late DateTime _endDate;
  late PaymentStatus _paymentStatus;

  @override
  void initState() {
    super.initState();
    _startDate = widget.transaksi.startDate ?? DateTime.now();
    _endDate = widget.transaksi.endDate ?? DateTime.now();
    _paymentStatus = widget.transaksi.paymentStatus;
    Log.info(
        'Form edit riwayat langganan diinisialisasi untuk transaksi ID: ${widget.transaksi.id}');
  }

  Future<void> _selectDateTime(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;

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
          _startDate = newDateTime;
          Log.info('Tanggal & waktu mulai diubah menjadi: $_startDate');
        } else {
          _endDate = newDateTime;
          Log.info('Tanggal & waktu berakhir diubah menjadi: $_endDate');
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.warning('Form tidak valid, penyimpanan dibatalkan.');
      return;
    }
    if (!mounted) return;

    Log.info('Menyimpan perubahan untuk transaksi ID: ${widget.transaksi.id}');

    // Mengakses dependency melalui Riverpod's ref
    final transactionOperation = ref.read(transactionOperationProvider);
    final notifikasiServis = ref.read(notifikasiServisProvider);

    try {
      final updatedTransaction = widget.transaksi.copyWith(
        startDate: _startDate,
        endDate: _endDate,
        paymentStatus: _paymentStatus,
        updatedAt: DateTime.now(),
      );

      await transactionOperation.updateTransaction(
        widget.transaksi.id,
        updatedTransaction,
      );
      Log.info('Transaksi berhasil diperbarui di database.');
      ref.invalidate(transactionOperationProvider);
      await _handleExpiryNotification(
        notifikasiServis: notifikasiServis,
        statusSebelumnya: widget.transaksi.paymentStatus,
        statusSekarang: _paymentStatus,
        endDate: _endDate,
      );

      if (!mounted) return;

      final isOnline =
          await ref.read(koneksiInternetServiceProvider).cekKoneksiLokal();
      if (isOnline) {
        final syncCheckService = ref.read(syncCheckServiceProvider);
        syncCheckService.runSyncCheck();
        if (mounted) {
          ToastUtil.success(context,
              'Riwayat langganan berhasil diperbarui dan disinkronkan.');
        }
      } else {
        if (mounted) {
          ToastUtil.info(context,
              'Koneksi offline. Data disimpan lokal dan akan disinkronkan saat online.');
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
    required NotifikasiServis notifikasiServis,
    required PaymentStatus statusSebelumnya,
    required PaymentStatus statusSekarang,
    required DateTime endDate,
  }) async {
    final idNotifikasi = widget.transaksi.id.hashCode;
    final wasPaid = statusSebelumnya == PaymentStatus.paid;
    final isNowPaid = statusSekarang == PaymentStatus.paid;

    if ((!wasPaid && isNowPaid) || (wasPaid && isNowPaid)) {
      final jadwal = endDate;
      if (jadwal.isAfter(DateTime.now())) {
        Log.info(
            'Menjadwalkan notifikasi berakhirnya paket untuk ID: $idNotifikasi pada $jadwal');
        await notifikasiServis.perbaruiJadwalNotifikasi(
          id: idNotifikasi,
          title: 'Langganan Telah Berakhir',
          body:
              'Masa aktif paket Anda telah berakhir. Perpanjang sekarang untuk terhubung lagi.',
          jadwal: jadwal,
        );
      }
    } else if (wasPaid && !isNowPaid) {
      Log.info(
          'Membatalkan notifikasi berakhirnya paket untuk ID: $idNotifikasi karena status tidak lagi LUNAS.');
      await notifikasiServis.batalNotifikasi(idNotifikasi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Riwayat Langganan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildDateTimePickerTile(
                label: 'Tanggal & Waktu Mulai',
                date: _startDate,
                onPressed: () => _selectDateTime(true),
              ),
              gapH16,
              _buildDateTimePickerTile(
                label: 'Tanggal & Waktu Berakhir',
                date: _endDate,
                onPressed: () => _selectDateTime(false),
              ),
              gapH24,
              DropdownButtonFormField<PaymentStatus>(
                initialValue: _paymentStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Pembayaran',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                items: PaymentStatus.values.map((status) {
                  return DropdownMenuItem<PaymentStatus>(
                    value: status,
                    child: Text(status.displayName.toUpperCase()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _paymentStatus = newValue;
                      Log.info(
                          'Status pembayaran diubah menjadi: $_paymentStatus');
                    });
                  }
                },
              ),
              gapH32,
              ElevatedButton.icon(
                label: const Text('Simpan Perubahan'),
                onPressed: _saveChanges,
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
      subtitle: Text(FormatDateTime.formatDateAndTimeCompact(date)),
      trailing: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(Icons.calendar_month_outlined),
      ),
      onTap: onPressed,
    );
  }
}
