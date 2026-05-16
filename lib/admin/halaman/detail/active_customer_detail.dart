// path: lib/admin/halaman/detail/active_customer_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/active_customer_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operasi.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/whatsapp/info_paket.dart';

/// Halaman untuk menampilkan detail pelanggan aktif.
class ActiveCustomerDetailPage extends StatefulWidget {
  /// Model pelanggan aktif yang akan ditampilkan.
  final ActiveCustomerModel activeCustomer;

  /// Konstruktor untuk ActiveCustomerDetailPage.
  const ActiveCustomerDetailPage({super.key, required this.activeCustomer});

  @override
  // ditambah: Komentar untuk menjelaskan kenapa lint rule diabaikan.
  // ignore: no_logic_in_create_state, Aturan ini diabaikan karena logika di dalamnya hanya untuk logging saat pembuatan state, yang berguna untuk debugging.
  State<ActiveCustomerDetailPage> createState() {
    Log.info(
      'Membuat state untuk ActiveCustomerDetailPage. '
      'ID Pelanggan Aktif: ${activeCustomer.id}, '
      'ID Pelanggan: ${activeCustomer.customerId}, '
      'ID Paket: ${activeCustomer.packageId}, '
      'Status: ${activeCustomer.status.displayName}',
    );
    return _ActiveCustomerDetailPageState();
  }
}

class _ActiveCustomerDetailPageState extends State<ActiveCustomerDetailPage> {
  late ActiveCustomerModel _activeCustomer;
  CustomerModel? _customer;
  PackageModel? _package;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman DetailPelangganAktif');
    Log.info('Inisialisasi awal dengan data dari widget:');
    Log.info('  - ID Pelanggan Aktif: ${widget.activeCustomer.id}');
    Log.info('  - ID Pelanggan: ${widget.activeCustomer.customerId}');
    Log.info('  - ID Paket: ${widget.activeCustomer.packageId}');
    Log.info('  - Status: ${widget.activeCustomer.status.displayName}');
    Log.info('  - Tanggal Mulai: ${widget.activeCustomer.startDate}');
    Log.info('  - Tanggal Berakhir: ${widget.activeCustomer.endDate}');
    Log.info('========================================');

    _activeCustomer = widget.activeCustomer;
    Log.info(
      'Variabel lokal _activeCustomer telah diinisialisasi dengan data dari widget.',
    );
    Log.info(
      'Memanggil _loadDetails() untuk mengambil data pelengkap (data Pelanggan dan Paket) dari database.',
    );
    unawaited(_loadDetails());
  }

  Future<void> _launchWhatsApp(final String phoneNumber) async {
    Log.info('========================================');
    Log.info('WHATSAPP: Mencoba membuka aplikasi WhatsApp');
    Log.info('Nomor telepon mentah yang diterima: $phoneNumber');
    Log.info('========================================');

    Log.info(
      'Membersihkan format nomor telepon. Menghapus semua karakter non-digit.',
    );
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    Log.info('Nomor setelah dibersihkan: $formattedNumber');

    if (formattedNumber.startsWith('0')) {
      Log.info(
        'Nomor diawali dengan "0". Mengkonversi ke format internasional (62).',
      );
      formattedNumber = '62${formattedNumber.substring(1)}';
      Log.info('Nomor setelah konversi dari awalan 0: $formattedNumber');
    } else if (!formattedNumber.startsWith('62')) {
      Log.info(
        'Nomor tidak diawali dengan "62". Menambahkan kode negara Indonesia (62).',
      );
      formattedNumber = '62$formattedNumber';
      Log.info('Nomor setelah penambahan kode negara: $formattedNumber');
    } else {
      Log.info(
        'Nomor sudah dalam format internasional (62). Tidak perlu modifikasi.',
      );
    }

    Log.info('Membuat URI WhatsApp: https://wa.me/$formattedNumber');
    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedNumber');

    try {
      Log.info('Memeriksa apakah perangkat dapat membuka URI WhatsApp.');
      if (await canLaunchUrl(whatsappUri)) {
        Log.info(
          'URI WhatsApp dapat dibuka. Meluncurkan WhatsApp dengan mode external application.',
        );
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        Log.info(
          'WhatsApp berhasil dibuka. Nomor yang dituju: $formattedNumber',
        );
      } else {
        Log.warning(
          'URI WhatsApp tidak dapat dibuka. Kemungkinan WhatsApp tidak terinstal di perangkat.',
        );
        // diubah: Membungkus string dalam Exception untuk mematuhi aturan lint.
        throw Exception('Could not launch $whatsappUri');
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal membuka aplikasi WhatsApp untuk nomor: $formattedNumber. Kemungkinan penyebab: WhatsApp tidak terinstal, URI tidak valid, atau izin aplikasi tidak cukup.',
        e: e,
        st: s,
      );
      if (mounted) {
        Log.info(
          'Widget masih mounted. Menampilkan SnackBar error ke pengguna.',
        );
        SnackBarUtil.error(
          context,
          'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
        );
        Log.info('SnackBar error WhatsApp telah ditampilkan.');
      } else {
        Log.warning(
          'Widget sudah tidak mounted. Tidak dapat menampilkan SnackBar error WhatsApp.',
        );
      }
    }
  }

  Future<void> _loadDetails() async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES PEMUATAN DATA DETAIL PELANGGAN AKTIF');
    Log.info('========================================');

    if (!mounted) {
      Log.warning(
        'Widget sudah tidak mounted saat _loadDetails() dipanggil. Membatalkan proses pemuatan data untuk mencegah memory leak.',
      );
      return;
    }

    Log.info('Widget masih mounted. Melanjutkan proses pemuatan data.');
    Log.info(
      'Mengatur state _isLoading menjadi true untuk menampilkan indikator loading.',
    );
    setState(() => _isLoading = true);

    final customerOperation = CustomerOperation();
    final packageOperation = PackageOperation();

    Log.info(
      'Menyiapkan query paralel untuk mengambil data pelanggan dan paket secara bersamaan.',
    );
    Log.info('  - Query 1: getCustomerById(${_activeCustomer.customerId})');

    final packageId = _activeCustomer.packageId;
    Log.info('  - ID Paket: ${packageId.isNotEmpty ? packageId : "KOSONG"}');
    Log.info(
      '  - Query 2: ${packageId.isNotEmpty ? "getPackageById($packageId)" : "Future.value(null) karena ID Paket kosong"}',
    );

    try {
      Log.info(
        'Menjalankan Future.wait untuk mengeksekusi kedua query secara paralel.',
      );
      final results = await Future.wait<dynamic>([
        customerOperation.getCustomerById(_activeCustomer.customerId),
        if (packageId.isNotEmpty)
          packageOperation.getPackageById(packageId)
        else
          Future<PackageModel?>.value(null),
      ]);

      Log.info('Kedua query selesai dijalankan. Memproses hasil...');
      Log.info(
        'Hasil query 1 (Pelanggan): ${results[0] != null ? "Ditemukan (Nama: ${(results[0] as CustomerModel).name})" : "NULL - Pelanggan tidak ditemukan"}',
      );
      Log.info(
        'Hasil query 2 (Paket): ${results.length > 1 && results[1] != null ? "Ditemukan (Nama: ${(results[1] as PackageModel).name})" : "NULL atau tidak dicari"}',
      );

      if (mounted) {
        Log.info(
          'Widget masih mounted. Memperbarui state dengan data yang telah diambil.',
        );
        setState(() {
          _customer = results[0] as CustomerModel?;
          _package = results.length > 1 ? results[1] as PackageModel? : null;
          _isLoading = false;
        });

        Log.info('State berhasil diperbarui:');
        Log.info(
          '  - _customer: ${_customer != null ? _customer!.name : "NULL"}',
        );
        Log.info(
          '  - _package: ${_package != null ? "${_package!.name} (Poin Hadiah: ${_package!.rewardPoints})" : "NULL"}',
        );
        Log.info('  - _isLoading: $_isLoading');

        Log.info('========================================');
        Log.info('PEMUATAN DATA DETAIL PELANGGAN AKTIF BERHASIL');
        Log.info('========================================');
      } else {
        Log.warning(
          'Widget sudah tidak mounted setelah data berhasil diambil. Data tidak akan diupdate ke state untuk mencegah error.',
        );
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal memuat detail pelanggan aktif. Proses _loadDetails() mengalami kegagalan. Kemungkinan penyebab: koneksi database gagal, data pelanggan tidak ditemukan, data paket tidak ditemukan, atau terjadi error saat menggabungkan hasil query.',
        e: e,
        st: s,
      );
      if (mounted) {
        Log.info(
          'Widget masih mounted. Mengatur _isLoading menjadi false agar UI menampilkan data yang tersedia.',
        );
        setState(() => _isLoading = false);
      } else {
        Log.warning(
          'Widget sudah tidak mounted. Tidak dapat memperbarui state _isLoading.',
        );
      }
    }
  }

  Future<void> _navigateToEdit() async {
    Log.info('========================================');
    Log.info('NAVIGASI: Menuju halaman edit pelanggan aktif');
    Log.info('Data yang akan diedit:');
    Log.info('  - ID Pelanggan Aktif: ${_activeCustomer.id}');
    Log.info('  - ID Pelanggan: ${_activeCustomer.customerId}');
    Log.info('  - ID Paket: ${_activeCustomer.packageId}');
    Log.info('  - Status Saat Ini: ${_activeCustomer.status.displayName}');
    Log.info('========================================');

    Log.info(
      'Membuka halaman ActiveCustomerForm dengan Navigator.push. Mengirim data _activeCustomer terbaru ke form.',
    );

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) =>
            ActiveCustomerForm(activeCustomer: _activeCustomer),
      ),
    );

    Log.info('========================================');
    Log.info('KEMBALI DARI FORM PELANGGAN AKTIF');
    Log.info('Nilai result yang diterima: $result');
    Log.info('========================================');

    if (result ?? false) {
      Log.info(
        'Result bernilai TRUE. User telah melakukan perubahan data di form.',
      );
      Log.info(
        'Akan mengambil data terbaru dari database untuk memperbarui tampilan.',
      );

      final operation = ActiveCustomerOperation();

      final updatedActiveCustomer = await operation.getActiveCustomerById(
        _activeCustomer.id,
      );

      if (mounted && updatedActiveCustomer != null) {
        Log.info(
          'Widget masih mounted dan data terbaru ditemukan. Memperbarui state.',
        );
        setState(() {
          _activeCustomer = updatedActiveCustomer;
        });
        Log.info(
          '_activeCustomer berhasil diperbarui. Status baru: ${updatedActiveCustomer.status.displayName}, Tanggal Berakhir: ${updatedActiveCustomer.endDate}',
        );

        Log.info(
          'Memanggil _loadDetails() untuk memperbarui data pelanggan dan paket terkait.',
        );
        await _loadDetails();
      } else if (!mounted) {
        Log.warning(
          'Widget sudah tidak mounted. Tidak dapat memperbarui state.',
        );
      } else if (updatedActiveCustomer == null) {
        Log.warning(
          'Data pelanggan aktif terbaru tidak ditemukan. Kemungkinan data telah dihapus dari database.',
        );
      }
    } else {
      Log.info(
        'Result bernilai false atau null. Tidak ada tindakan refresh yang diperlukan.',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI DetailPelangganAktif');
    Log.info('Status loading: $_isLoading');
    Log.info('Nama Pelanggan: ${_customer?.name ?? "Belum dimuat"}');
    Log.info('Nama Paket: ${_package?.name ?? "Belum dimuat / Tidak ada"}');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(_customer?.name ?? 'Detail Pelanggan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'NAVIGASI: Tombol Kembali ditekan. Kembali ke halaman sebelumnya dengan result true.',
            );
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Log.info('AKSI: Tombol Edit pada AppBar ditekan.');
              Log.info('Memanggil _navigateToEdit() untuk membuka form edit.');
              await _navigateToEdit();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: TextButton(
                                onPressed: () async {
                                  if (_customer != null) {
                                    Log.info(
                                      'NAVIGASI: TextButton nama pelanggan ditekan.',
                                    );
                                    Log.info(
                                      'Menuju halaman CustomerDetailPage dengan ID: ${_customer!.id}',
                                    );
                                    await Navigator.push<void>(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (final context) =>
                                            CustomerDetailPage(
                                          customerId: _customer!.id,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Log.warning(
                                      'Tidak dapat navigasi ke detail pelanggan karena data _customer masih null.',
                                    );
                                  }
                                },
                                child: Text(
                                  _customer?.name ??
                                      _activeCustomer.customerId,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: Colors.blue),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            _buildWhatsAppInfoRow(
                              'No HP',
                              _customer?.phone ?? 'Tidak ditemukan',
                            ),
                            InkWell(
                              onTap: () async {
                                if (_package != null) {
                                  Log.info('NAVIGASI: Row paket ditekan.');
                                  Log.info(
                                    'Menuju halaman PackageDetailPage dengan data paket: ${_package!.name}',
                                  );
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (final context) =>
                                          PackageDetailPage(package: _package),
                                    ),
                                  );
                                } else {
                                  Log.warning(
                                    'Tidak dapat navigasi ke detail paket karena data _package masih null.',
                                  );
                                }
                              },
                              child: _buildInfoRow(
                                'Paket',
                                _package?.name ??
                                    ' (ID: ${_activeCustomer.packageId})',
                                isLink: true,
                              ),
                            ),
                            _buildInfoRow(
                              'Status',
                              _activeCustomer.status.displayName,
                            ),
                            if (_package != null)
                              _buildInfoRow(
                                'Poin Diperoleh',
                                '${_package!.rewardPoints} Poin',
                              ),
                            _buildInfoRow(
                              'Mulai',
                              '${FormatUtil.formatDateSimple(_activeCustomer.startDate)} - ${FormatUtil.formatTime(_activeCustomer.startDate)}',
                            ),
                            _buildInfoRow(
                              'Berakhir',
                              '${FormatUtil.formatDateSimple(_activeCustomer.endDate)} - ${FormatUtil.formatTime(_activeCustomer.endDate)}',
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              CalculationUtil.getRemainingActivePeriodText(
                                _activeCustomer.endDate,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color:
                                        CalculationUtil.getRemainingActivePeriodColor(
                                      _activeCustomer.endDate,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.send_to_mobile),
                              label: const Text('Kirim Info via WhatsApp'),
                              onPressed: () async {
                                Log.info(
                                  '========================================',
                                );
                                Log.info(
                                  'AKSI: Tombol Kirim Info via WhatsApp ditekan',
                                );
                                Log.info(
                                  'Mengirim rincian paket ke pelanggan: ${_customer?.name ?? _activeCustomer.customerId}',
                                );
                                Log.info('Data yang akan dikirim:');
                                Log.info(
                                  '  - ID Pelanggan Aktif: ${_activeCustomer.id}',
                                );
                                Log.info(
                                  '  - Nama Paket: ${_package?.name ?? "Tidak ada"}',
                                );
                                Log.info(
                                  '  - Status: ${_activeCustomer.status.displayName}',
                                );
                                Log.info(
                                  '  - Masa Aktif: ${CalculationUtil.getRemainingActivePeriodText(_activeCustomer.endDate)}',
                                );
                                Log.info(
                                  '========================================',
                                );
                                await WhatsappPackageInfo.sendPackageDetails(
                                  _activeCustomer,
                                );
                                Log.info(
                                  'Fungsi kirimRincianPaket telah dipanggil.',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(final String label, final String value, {final bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLink ? Colors.blue : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppInfoRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          InkWell(
            onTap: () async {
              Log.info(
                'WHATSAPP: Row nomor HP ditekan. Memanggil _launchWhatsApp dengan nomor: $value',
              );
              await _launchWhatsApp(value);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                  const SizedBox(width: 8),
                  FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
