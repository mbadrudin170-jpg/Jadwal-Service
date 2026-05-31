// path: lib/admin/halaman/form/subscription_history_form.dart
// REFAKTOR: Mengubah StatefulWidget menjadi ConsumerStatefulWidget dan menggunakan
// Riverpod untuk dependency injection (TransactionOperation, NotifikasiServis).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class SubscriptionHistoryForm extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const SubscriptionHistoryForm({super.key, required this.transaction});

  @override
  ConsumerState<SubscriptionHistoryForm> createState() =>
      _SubscriptionHistoryFormState();
}

class _SubscriptionHistoryFormState
    extends ConsumerState<SubscriptionHistoryForm> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _startDate;
  late DateTime _endDate;
  late PaymentStatus _paymentStatus;

  @override
  void initState() {
    super.initState();
    _startDate = widget.transaction.startDate ?? DateTime.now();
    _endDate = widget.transaction.endDate ?? DateTime.now();
    _paymentStatus = widget.transaction.paymentStatus;
    Log.info(
        'Form edit riwayat langganan diinisialisasi untuk transaksi ID: ${widget.transaction.id}');
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

    Log.info(
        'Menyimpan perubahan untuk transaksi ID: ${widget.transaction.id}');

    // Mengakses dependency melalui Riverpod's ref
    final transactionOperation = ref.read(transactionOperationProvider);
    final notifikasiServis = ref.read(notifikasiServisProvider);

    try {
      final updatedTransaction = widget.transaction.copyWith(
        startDate: _startDate,
        endDate: _endDate,
        paymentStatus: _paymentStatus,
        updatedAt: DateTime.now(),
      );

      await transactionOperation.updateTransaction(
        widget.transaction.id,
        updatedTransaction,
      );
      Log.info('Transaksi berhasil diperbarui di database.');

      await _handleExpiryNotification(
        notifikasiServis: notifikasiServis,
        statusSebelumnya: widget.transaction.paymentStatus,
        statusSekarang: _paymentStatus,
        endDate: _endDate,
      );

      if (!mounted) return;

      final hasConnection = await InternetConnectionService().checkConnection();
      if (hasConnection) {
        await SyncCheckService().runSyncCheck();
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
    final idNotifikasi = widget.transaction.id.hashCode;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildDateTimePickerTile(
                label: 'Tanggal & Waktu Mulai',
                date: _startDate,
                onPressed: () => _selectDateTime(true),
              ),
              const SizedBox(height: 16),
              _buildDateTimePickerTile(
                label: 'Tanggal & Waktu Berakhir',
                date: _endDate,
                onPressed: () => _selectDateTime(false),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
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
