// path: lib/admin/halaman/form/subscription_history_form.dart
// diubah: Menyesuaikan jadwal notifikasi agar muncul TEPAT saat masa aktif berakhir.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/detail/subscription_history_detail.dart (SubscriptionHistoryDetailPage)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/enum/payment_status_enum.dart (PaymentStatus)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/utils/format_util.dart (FormatUtil)
//   - lib/shared/utils/toast_util.dart (ToastUtil)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/services/notifikasi/notifikasi_servis.dart (NotifikasiServis)

/// Halaman form untuk mengedit riwayat langganan (transaksi).
class SubscriptionHistoryForm extends StatefulWidget {
  /// Transaksi yang akan diedit.
  final TransactionModel transaction;

  /// Konstruktor untuk SubscriptionHistoryForm.
  const SubscriptionHistoryForm({super.key, required this.transaction});

  @override
  State<SubscriptionHistoryForm> createState() =>
      _SubscriptionHistoryFormState();
}

class _SubscriptionHistoryFormState extends State<SubscriptionHistoryForm> {
  final _formKey = GlobalKey<FormState>();
  final TransactionOperation _transactionOperation = TransactionOperation();

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

  /// Menampilkan dialog pemilih tanggal dan waktu.
  Future<void> _selectDateTime(final bool isStartDate) async {
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
      builder: (final context, final child) {
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

  /// Menyimpan perubahan ke database.
  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.warning('Form tidak valid, penyimpanan dibatalkan.');
      return;
    }

    Log.info(
        'Menyimpan perubahan untuk transaksi ID: ${widget.transaction.id}');

    final statusSebelumnya = widget.transaction.paymentStatus;
    final notifikasiServis =
        Provider.of<NotifikasiServis>(context, listen: false);

    try {
      final updatedTransaction = widget.transaction.copyWith(
        startDate: _startDate,
        endDate: _endDate,
        paymentStatus: _paymentStatus,
        updatedAt: DateTime.now(),
      );

      await _transactionOperation.updateTransaction(
        widget.transaction.id,
        updatedTransaction,
      );
      Log.info('Transaksi berhasil diperbarui di database.');

      await _handleExpiryNotification(
        notifikasiServis: notifikasiServis,
        statusSebelumnya: statusSebelumnya,
        statusSekarang: _paymentStatus,
        endDate: _endDate,
      );

      if (!mounted) return;
      ToastUtil.success(context, 'Riwayat langganan berhasil diperbarui.');
      Navigator.of(context).pop(true); // Return true to indicate success
    } on Exception catch (e) {
      Log.error('Gagal memperbarui riwayat langganan', e: e);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memperbarui riwayat: ${e.toString()}');
    }
  }

  // diubah: Logika disesuaikan untuk notifikasi saat masa aktif berakhir.
  Future<void> _handleExpiryNotification({
    required final NotifikasiServis notifikasiServis,
    required final PaymentStatus statusSebelumnya,
    required final PaymentStatus statusSekarang,
    required final DateTime endDate,
  }) async {
    final idNotifikasi = widget.transaction.id.hashCode;
    final wasPaid = statusSebelumnya == PaymentStatus.paid;
    final isNowPaid = statusSekarang == PaymentStatus.paid;

    // Kondisi: Status berubah menjadi LUNAS atau tanggalnya diperbarui saat masih LUNAS
    if ((!wasPaid && isNowPaid) || (wasPaid && isNowPaid)) {
      // Selalu perbarui atau set jadwal baru
      final jadwal =
          endDate; // Notifikasi dijadwalkan TEPAT pada tanggal berakhir
      if (jadwal.isAfter(DateTime.now())) {
        Log.info(
            'Menjadwalkan notifikasi berakhirnya paket untuk ID: $idNotifikasi pada $jadwal');
        // Kita gunakan perbaruiJadwalNotifikasi agar jika sudah ada, jadwalnya diperbarui.
        // Jika belum ada, ia akan membuat yang baru.
        await notifikasiServis.perbaruiJadwalNotifikasi(
          id: idNotifikasi,
          title: 'Langganan Telah Berakhir', // diubah
          body:
              'Masa aktif paket Anda telah berakhir. Perpanjang sekarang untuk terhubung lagi.', // diubah
          jadwal: jadwal,
        );
      }
      // Kondisi: Status berubah dari LUNAS menjadi status lain (misal: dibatalkan)
    } else if (wasPaid && !isNowPaid) {
      Log.info(
          'Membatalkan notifikasi berakhirnya paket untuk ID: $idNotifikasi karena status tidak lagi LUNAS.');
      await notifikasiServis.batalNotifikasi(idNotifikasi);
    }
  }

  @override
  Widget build(final BuildContext context) {
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
                items: PaymentStatus.values.map((final status) {
                  return DropdownMenuItem<PaymentStatus>(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (final newValue) {
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

  /// Widget custom untuk tile pemilih tanggal dan waktu.
  Widget _buildDateTimePickerTile(
      {required final String label,
      required final DateTime date,
      required final VoidCallback onPressed}) {
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
