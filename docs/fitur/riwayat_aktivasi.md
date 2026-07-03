# Dokumentasi Fitur: riwayat_aktivasi

## Daftar file

- [lib/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart](../../lib/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart)
- [lib/fitur/riwayat_aktivasi/page/form_riwayat_aktivasi.dart](../../lib/fitur/riwayat_aktivasi/page/form_riwayat_aktivasi.dart)
- [lib/fitur/riwayat_aktivasi/page/riwayat_aktivasi_paket.dart](../../lib/fitur/riwayat_aktivasi/page/riwayat_aktivasi_paket.dart)
- [lib/fitur/riwayat_aktivasi/provider/detail_langganan_provider.dart](../../lib/fitur/riwayat_aktivasi/provider/detail_langganan_provider.dart)
- [lib/fitur/riwayat_aktivasi/provider/riwayat_aktivasi_paket_provider.dart](../../lib/fitur/riwayat_aktivasi/provider/riwayat_aktivasi_paket_provider.dart)

## Isi file

### File: `lib/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart`
```dart
// path: lib/admin/halaman/detail/subscription_history_detail.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan.dart';
import 'package:wifi/fitur/riwayat_aktivasi/page/form_riwayat_aktivasi.dart';
import 'package:wifi/fitur/riwayat_aktivasi/provider/detail_langganan_provider.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';

class DetailRiwayatAktivasiPage extends ConsumerWidget {
  final String idTransaksi;
  const DetailRiwayatAktivasiPage({super.key, required this.idTransaksi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(ambilDetailLanggananProvider(idTransaksi));

    return detailAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (data) {
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('Transaksi tidak ditemukan')),
          );
        }

        final transaksi = data.transaksi;
        final pelanggan = data.pelanggan;
        final paket = data.paket;
        final warnaStatusPembayaran =
            transaksi?.statusPembayaran == StatusPembayaran.paid
            ? Colors.green
            : Colors.red;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Langganan'),
            actions: [
              IconButton(
                icon: const Icon(TIcons.edit),
                onPressed: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FormRiwayatAktivasi(transaksi: transaksi!),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(ambilDetailLanggananProvider(idTransaksi)),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // CARD 1: INFORMASI PELANGGAN
                _buildCard(
                  title: 'Informasi Pelanggan',
                  onTap: pelanggan == null
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                DetailPelanggan(idPelanggan: pelanggan.id),
                          ),
                        ),
                  children: [
                    _buildRow(
                      'Nama Pelanggan',
                      pelanggan?.nama ?? 'Tidak Diketahui',
                    ),
                  ],
                ),
                gapH16,

                // CARD 2: INFORMASI PAKET
                _buildCard(
                  title: 'Informasi Paket',
                  onTap: paket == null
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => DetailPaketPage(paket: paket),
                          ),
                        ),
                  children: [
                    _buildRow('Nama Paket', paket?.nama ?? 'Tidak Diketahui'),
                    _buildRow(
                      'Harga',
                      FormatUang.formatMataUang((paket?.harga ?? 0).toDouble()),
                    ),
                    _buildRow(
                      'Durasi',
                      '${paket?.durasi ?? 0} ${paket?.tipe.displayName ?? ""}',
                    ),
                  ],
                ),
                gapH16,
                // CARD 3: POIN TRANSAKSI
                if (transaksi!.poinDidapat > 0 ||
                    transaksi.poinDigunakan > 0) ...[
                  _buildCard(
                    title: 'Informasi Poin',
                    children: [
                      _buildRow(
                        'Poin Dihasilkan',
                        '+${transaksi.poinDidapat} Poin',
                        color: Colors.green,
                      ),
                      _buildRow(
                        'Poin Digunakan',
                        '-${transaksi.poinDigunakan} Poin',
                        color: Colors.red,
                      ),
                    ],
                  ),
                  gapH16,
                ],

                // CARD 4: WAKTU & STATUS
                _buildCard(
                  title: 'Waktu & Status',
                  children: [
                    if (transaksi.tanggalMulai != null)
                      _buildRow(
                        'Tanggal Mulai',
                        FormatWaktuLengkap.formatSingkat(
                          transaksi.tanggalMulai!,
                        ),
                      ),
                    if (transaksi.tanggalBerakhir != null)
                      _buildRow(
                        'Tanggal Berakhir',
                        FormatWaktuLengkap.formatSingkat(
                          transaksi.tanggalBerakhir!,
                        ),
                      ),
                    _buildRow(
                      'Status Pembayaran',
                      transaksi.statusPembayaran.displayName.toUpperCase(),
                      color: warnaStatusPembayaran,
                      isBold: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget sederhana untuk memangkas boilerplate code
  Widget _buildCard({
    required String title,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/riwayat_aktivasi/page/form_riwayat_aktivasi.dart`
```dart
// path: lib/fitur/riwayat_aktivasi/page/form_riwayat_aktivasi.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/notifikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FormRiwayatAktivasi extends ConsumerStatefulWidget {
  final TransaksiModel transaksi;

  const FormRiwayatAktivasi({super.key, required this.transaksi});

  @override
  ConsumerState<FormRiwayatAktivasi> createState() =>
      _FormRiwayatAktivasiState();
}

class _FormRiwayatAktivasiState extends ConsumerState<FormRiwayatAktivasi> {
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
    if (_tanggalBerakhir.isBefore(_tanggalMulai)) {
      Log.warning('Tanggal berakhir mendahului tanggal mulai.');
      ToastUtil.error(
        context,
        'Tanggal berakhir tidak boleh sebelum tanggal mulai!',
      );
      return;
    }
    if (!mounted) return;
    Log.info('Menyimpan perubahan untuk transaksi ID: ${widget.transaksi.id}');
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    final layananNotifikasi = ref.read(layananNotifikasiProvider);

    try {
      final updateTransaksi = widget.transaksi.copyWith(
        tanggalMulai: _tanggalMulai,
        tanggalBerakhir: _tanggalBerakhir,
        statusPembayaran: _statusPembayaran,
        diperbaruiPada: DateTime.now(),
      );
      await transaksiOp.perbaruiTransaksi(updateTransaksi);
      Log.info('Transaksi berhasil diperbarui di database.');
      await _handleExpiryNotification(
        layananNotifikasi: layananNotifikasi,
        statusSebelumnya: widget.transaksi.statusPembayaran,
        statusSekarang: _statusPembayaran,
        tanggalBerakhir: _tanggalBerakhir,
      );
      if (!mounted) return;
      unawaited(
        ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
      );
      if (mounted) {
        ToastUtil.success(
          context,
          'Riwayat langganan berhasil diperbarui dan disinkronkan.',
        );
      }
      if (mounted) {
        Navigator.pop(context);
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
      await layananNotifikasi.batalkanNotifikasi(idNotifikasi);
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
```

### File: `lib/fitur/riwayat_aktivasi/page/riwayat_aktivasi_paket.dart`
```dart
// path lib/fitur/riwayat_aktivasi/page/riwayat_aktivasi_paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart';
import 'package:wifi/fitur/riwayat_aktivasi/provider/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';

class RiwayatAktivasiPaket extends ConsumerStatefulWidget {
  const RiwayatAktivasiPaket({super.key});
  @override
  ConsumerState<RiwayatAktivasiPaket> createState() =>
      _RiwayatAktivasiPaketState();
}

class _RiwayatAktivasiPaketState extends ConsumerState<RiwayatAktivasiPaket> {
  final ScrollController _pengendaliScroll = ScrollController();
  final TextEditingController _cariController = TextEditingController();
  late final FocusNode _cariFocusNode;
  int _jumlahTampil = 20;
  String _queryCari = '';
  bool _sedangMemuatLebih = false;
  bool _sedangMencari = false; // Perbaikan 1: State khusus untuk mode pencarian

  @override
  void initState() {
    super.initState();
    ref.listenManual(riwayatAktivasiPaketProvider, (prev, next) {
      if (next.hasValue && mounted) {
        setState(() => _jumlahTampil = 20);
      }
    });
    _pengendaliScroll.addListener(_deteksiScroll);
    _cariFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pengendaliScroll.removeListener(_deteksiScroll);
    _pengendaliScroll.dispose();
    _cariController.dispose();
    _cariFocusNode.dispose();
    super.dispose();
  }

  void _deteksiScroll() {
    if (_sedangMemuatLebih) return;
    if (_pengendaliScroll.position.pixels >=
        _pengendaliScroll.position.maxScrollExtent - 200) {
      final state = ref.read(riwayatAktivasiPaketProvider).value;
      if (state == null) return;

      final itemsFiltered = _filterData(state.items, _queryCari);
      if (_jumlahTampil < itemsFiltered.length) {
        setState(() {
          _sedangMemuatLebih = true;
          _jumlahTampil += 20;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _sedangMemuatLebih = false);
        });
      }
    }
  }

  List<TransaksiDenganPelanggan> _filterData(
    List<TransaksiDenganPelanggan> items,
    String katakunci,
  ) {
    if (katakunci.trim().isEmpty) return items;

    final katakunciLower = katakunci.toLowerCase().trim();
    return items.where((item) {
      return item.namaPelanggan.toLowerCase().contains(katakunciLower) ||
          item.transaksi.deskripsi.toLowerCase().contains(katakunciLower) ||
          item.transaksi.id.toLowerCase().contains(katakunciLower);
    }).toList();
  }

  Future<void> _dialogOpsi(TransaksiModel transaksi) async {
    final aksiDipilih = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Pilih Aksi'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'edit'),
              child: const Text('Edit'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'hapus'),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (aksiDipilih != null) {
      Log.info('Aksi dipilih: $aksiDipilih');

      if (aksiDipilih == 'edit') {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => FormTransaksi(transaksi: transaksi),
          ),
        );
      } else if (aksiDipilih == 'hapus') {
        await _dialogKonfirmasiSoftDelete(transaksi);
      }
    }
  }

  Future<void> _dialogKonfirmasiSoftDelete(TransaksiModel transaksi) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(transaksiOpGlobalProvider)
                  .softDelete(transaksi.id);
              unawaited(
                ref
                    .read(layananCekSinkronisasiProvider)
                    .jalankanCekSinkronisasi(),
              );
              ref.invalidate(riwayatAktivasiPaketProvider);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Iya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(riwayatAktivasiPaketProvider);

    return Scaffold(
      appBar: AppBar(
        // Perbaikan Utama pada Logika Tampilan AppBar
        title: !_sedangMencari
            ? const TeksJudulBesar('Riwayat Langganan', warna: Colors.white)
            : TextField(
                controller: _cariController,
                focusNode: _cariFocusNode,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari data...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  prefixIcon: const Icon(TIcons.search, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: const Icon(TIcons.close, color: Colors.white),
                    onPressed: () {
                      _cariController.clear();
                      setState(() {
                        _queryCari = '';
                        _jumlahTampil = 20;
                        _sedangMencari = false; // Keluar dari mode pencarian
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _queryCari = value;
                    _jumlahTampil = 20;
                  });
                },
              ),
        actions: [
          if (!_sedangMencari) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _sedangMencari = true;
                });
                Future.microtask(() => _cariFocusNode.requestFocus());
              },
              icon: const Icon(TIcons.search),
            ),
            IconButton(
              icon: const Icon(TIcons.filter),
              onPressed: () {
                if (historyAsync.hasValue) {
                  Log.info('Membuka dialog pengurutan riwayat langganan.');
                  _tampilkanDialogUrutan(
                    context,
                    ref,
                    historyAsync.value!.sortBy,
                  );
                }
              },
              tooltip: 'Urutkan',
            ),
          ],
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (state) {
          final itemsFiltered = _filterData(state.items, _queryCari);
          if (itemsFiltered.isEmpty) {
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          }
          final itemsTampil = itemsFiltered.take(_jumlahTampil).toList();
          return ListView.builder(
            controller: _pengendaliScroll,
            itemCount:
                itemsTampil.length +
                (_jumlahTampil < itemsFiltered.length ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == itemsTampil.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final item = itemsTampil[index];
              final transaksi = item.transaksi;
              final warnaStatusPembayaran =
                  transaksi.statusPembayaran == StatusPembayaran.paid
                  ? Colors.green
                  : Colors.red;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: ListTile(
                  onTap: () async {
                    Log.info('Melihat detail riwayat langganan.', {
                      'transactionId': transaksi.id,
                    });
                    await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailRiwayatAktivasiPage(
                          idTransaksi: transaksi.id,
                        ),
                      ),
                    );
                  },
                  onLongPress: () => _dialogOpsi(transaksi),
                  title: Text(
                    item.namaPelanggan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NamaPaketWidget(
                        idPaket: transaksi.idPaket ?? '',
                        style: TextStyle(color: warnaStatusPembayaran),
                      ),
                      gapH4,
                      Text(
                        'Status: ${transaksi.statusPembayaran.displayName}',
                        style: TextStyle(
                          color: warnaStatusPembayaran,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gapH4,
                      if (transaksi.tanggalMulai != null &&
                          transaksi.tanggalBerakhir != null)
                        Text(
                          'Aktif: ${FormatTanggal.formatDasar(transaksi.tanggalMulai!)} - ${FormatTanggal.formatDasar(transaksi.tanggalBerakhir!)}',
                        ),
                    ],
                  ),
                  trailing: const Icon(TIcons.chevronRight),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _tampilkanDialogUrutan(
    BuildContext context,
    WidgetRef ref,
    OpsiUrutan currentSort,
  ) async {
    final dipilih = await showDialog<OpsiUrutan>(
      context: context,
      builder: (context) {
        Widget buildOption(String text, OpsiUrutan value) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, value),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: currentSort == value
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            // Perbaikan: Pastikan enum beralhirHariIni sudah dibetulkan typo-nya jika diperlukan
            buildOption('Berakhir Hari Ini', OpsiUrutan.berakhirHariIni),
            buildOption('Tanggal Berakhir', OpsiUrutan.tanggalBerakhir),
            buildOption('Nama A-Z', OpsiUrutan.namaAZ),
            buildOption('Nama Z-A', OpsiUrutan.namaZA),
            buildOption('Lunas', OpsiUrutan.lunas),
            buildOption('Belum Lunas', OpsiUrutan.belumLunas),
            buildOption('Update Terbaru', OpsiUrutan.diperbaruiPadaAZ),
            buildOption('Update Terlama', OpsiUrutan.diperbaruiPadaZA),
          ],
        );
      },
    );

    if (dipilih != null) {
      ref.read(riwayatAktivasiPaketProvider.notifier).changeSort(dipilih);
    }
  }
}
```

### File: `lib/fitur/riwayat_aktivasi/provider/detail_langganan_provider.dart`
```dart
// path lib/fitur/riwayat_aktivasi/provider/detail_langganan_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';

part 'detail_langganan_provider.g.dart';
part 'detail_langganan_provider.freezed.dart';

@freezed
abstract class DetailLanggananState with _$DetailLanggananState {
  const factory DetailLanggananState({
    TransaksiModel? transaksi,
    PelangganModel? pelanggan,
    PaketModel? paket,
  }) = _DetailLanggananState;
}

@riverpod
Future<DetailLanggananState?> ambilDetailLangganan(
  Ref ref,
  String idTransaksi,
) async {
  final transaksiOp = ref.watch(transaksiOpGlobalProvider);
  final pelangganOpSqlite = ref.watch(pelangganOpGlobalProvider);
  final paketOpSqlite = ref.watch(paketOpSqliteProvider);

  // 1. Ambil data transaksi utama
  final transaksi = await transaksiOp.ambilBerdasarkanId(idTransaksi);
  if (transaksi == null) return null;

  // 2. Ambil data relasi secara paralel untuk menghemat waktu pemuatan
  final hasil = await Future.wait<Object?>([
    transaksi.idPelanggan != null
        ? pelangganOpSqlite.ambilBerdasarkanId(transaksi.idPelanggan!)
        : Future<PelangganModel?>.value(),
    transaksi.idPaket != null
        ? paketOpSqlite.ambilBerdasarkanId(transaksi.idPaket!)
        : Future<PaketModel?>.value(),
  ]);

  return DetailLanggananState(
    transaksi: transaksi,
    pelanggan: hasil[0] as PelangganModel?,
    paket: hasil[1] as PaketModel?,
  );
}
```

### File: `lib/fitur/riwayat_aktivasi/provider/riwayat_aktivasi_paket_provider.dart`
```dart
// path lib/fitur/riwayat_aktivasi/provider/riwayat_aktivasi_paket_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';

part 'riwayat_aktivasi_paket_provider.g.dart';

class TransaksiDenganPelanggan {
  final TransaksiModel transaksi;
  final PelangganModel? pelanggan;
  TransaksiDenganPelanggan({required this.transaksi, this.pelanggan});
  String get namaPelanggan => pelanggan?.nama ?? 'Tidak diketahui';
}

enum OpsiUrutan {
  tanggalBerakhir,
  namaAZ,
  namaZA,
  berakhirHariIni,
  diperbaruiPadaAZ,
  diperbaruiPadaZA,
  lunas,
  belumLunas,
}

class RiwayatAktivasiPaketState {
  final List<TransaksiDenganPelanggan> items;
  final OpsiUrutan sortBy;
  RiwayatAktivasiPaketState({
    this.items = const [],
    this.sortBy = OpsiUrutan.berakhirHariIni,
  });

  RiwayatAktivasiPaketState copyWith({
    List<TransaksiDenganPelanggan>? items,
    OpsiUrutan? sortBy,
  }) {
    return RiwayatAktivasiPaketState(
      items: items ?? this.items,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

@riverpod
class RiwayatAktivasiPaket extends _$RiwayatAktivasiPaket {
  @override
  FutureOr<RiwayatAktivasiPaketState> build() {
    ref.watch(transaksiOpGlobalProvider);
    ref.watch(pelangganOpGlobalProvider);
    return _loadData(OpsiUrutan.berakhirHariIni);
  }

  Future<RiwayatAktivasiPaketState> _loadData(OpsiUrutan targetSort) async {
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    final pelangganOpSqlite = ref.read(pelangganOpSqliteProvider);
    final transaksi = await transaksiOp.ambilBerdasarkanStatusAktivasi();
    final pealnggan = await pelangganOpSqlite.ambilSemua();
    final customerMap = {for (final c in pealnggan) c.id: c};
    final combinedList = transaksi.map((trans) {
      return TransaksiDenganPelanggan(
        transaksi: trans,
        pelanggan: customerMap[trans.idPelanggan],
      );
    }).toList();
    _performSort(combinedList, targetSort);
    return RiwayatAktivasiPaketState(items: combinedList, sortBy: targetSort);
  }

  void changeSort(OpsiUrutan newSort) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    if (currentState.sortBy == newSort) return;
    final sortedList = List<TransaksiDenganPelanggan>.from(currentState.items);
    _performSort(sortedList, newSort);
    state = AsyncValue.data(
      currentState.copyWith(items: sortedList, sortBy: newSort),
    );
  }

  void _performSort(List<TransaksiDenganPelanggan> list, OpsiUrutan option) {
    switch (option) {
      case OpsiUrutan.tanggalBerakhir:
        list.sort((a, b) {
          if (a.transaksi.tanggalBerakhir == null &&
              b.transaksi.tanggalBerakhir == null) {
            return 0;
          }
          if (a.transaksi.tanggalBerakhir == null) return 1;
          if (b.transaksi.tanggalBerakhir == null) return -1;
          final dateCompare = a.transaksi.tanggalBerakhir!.compareTo(
            b.transaksi.tanggalBerakhir!,
          );
          if (dateCompare != 0) return dateCompare;
          return a.transaksi.id.compareTo(b.transaksi.id);
        });
        break;
      case OpsiUrutan.diperbaruiPadaAZ:
        list.sort((a, b) {
          final updateAtA = a.transaksi.diperbaruiPada;
          final updateAtB = b.transaksi.diperbaruiPada;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return 1;
          if (updateAtB == null) return -1;
          return updateAtB.compareTo(updateAtA);
        });
        break;
      case OpsiUrutan.diperbaruiPadaZA:
        list.sort((a, b) {
          final updateAtA = a.transaksi.diperbaruiPada;
          final updateAtB = b.transaksi.diperbaruiPada;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return -1;
          if (updateAtB == null) return 1;
          return updateAtA.compareTo(updateAtB);
        });
        break;
      case OpsiUrutan.namaAZ:
        list.sort((a, b) {
          final nameCompare = a.namaPelanggan.toLowerCase().compareTo(
            b.namaPelanggan.toLowerCase(),
          );
          if (nameCompare != 0) return nameCompare;
          // Jika nama sama, urutkan berdasarkan ID transaksi (trx1 < trx3)
          return a.transaksi.id.compareTo(b.transaksi.id);
        });
        break;
      case OpsiUrutan.namaZA:
        list.sort((a, b) {
          final nameCompare = b.namaPelanggan.toLowerCase().compareTo(
            a.namaPelanggan.toLowerCase(),
          );
          if (nameCompare != 0) return nameCompare;
          return a.transaksi.id.compareTo(b.transaksi.id);
        });
        break;
      case OpsiUrutan.berakhirHariIni:
        final now = DateTime.now();
        list.sort((a, b) {
          final isTodayA =
              a.transaksi.tanggalBerakhir != null &&
              a.transaksi.tanggalBerakhir!.year == now.year &&
              a.transaksi.tanggalBerakhir!.month == now.month &&
              a.transaksi.tanggalBerakhir!.day == now.day;
          final isTodayB =
              b.transaksi.tanggalBerakhir != null &&
              b.transaksi.tanggalBerakhir!.year == now.year &&
              b.transaksi.tanggalBerakhir!.month == now.month &&
              b.transaksi.tanggalBerakhir!.day == now.day;
          if (isTodayA && !isTodayB) return -1;
          if (!isTodayA && isTodayB) return 1;
          if (a.transaksi.tanggalBerakhir == null &&
              b.transaksi.tanggalBerakhir == null) {
            return 0;
          }
          if (a.transaksi.tanggalBerakhir == null) return 1;
          if (b.transaksi.tanggalBerakhir == null) return -1;
          return a.transaksi.tanggalBerakhir!.compareTo(
            b.transaksi.tanggalBerakhir!,
          );
        });
        break;
      case OpsiUrutan.lunas:
        list.sort((a, b) {
          final isPaidA = a.transaksi.statusPembayaran == StatusPembayaran.paid;
          final isPaidB = b.transaksi.statusPembayaran == StatusPembayaran.paid;
          if (isPaidA && !isPaidB) return -1;
          if (!isPaidA && isPaidB) return 1;
          return (b.transaksi.diperbaruiPada ?? b.transaksi.tanggal).compareTo(
            a.transaksi.diperbaruiPada ?? a.transaksi.tanggal,
          );
        });
        break;
      case OpsiUrutan.belumLunas:
        list.sort((a, b) {
          final isUnpaidA =
              a.transaksi.statusPembayaran == StatusPembayaran.unpaid;
          final isUnpaidB =
              b.transaksi.statusPembayaran == StatusPembayaran.unpaid;
          if (isUnpaidA && !isUnpaidB) return -1;
          if (!isUnpaidA && isUnpaidB) return 1;
          return (b.transaksi.diperbaruiPada ?? b.transaksi.tanggal).compareTo(
            a.transaksi.diperbaruiPada ?? a.transaksi.tanggal,
          );
        });
        break;
    }
  }
}
```

