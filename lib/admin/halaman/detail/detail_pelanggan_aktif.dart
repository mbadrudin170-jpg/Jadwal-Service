// path: lib/admin/halaman/detail/detail_pelanggan_aktif.dart
// diubah: Mengubah Future.value() menjadi Future<PaketModel?>.value(null) untuk memberikan tipe eksplisit.
// diubah: Mengganti `jumlahPoin` yang sudah dihapus menjadi `poinHadiah` dan memperbaiki unawaited future.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_aktif_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/whatsapp/info_paket.dart';

/// Halaman untuk menampilkan detail pelanggan aktif.
class DetailPelangganAktif extends StatefulWidget {
  /// Model pelanggan aktif yang akan ditampilkan.
  final PelangganAktifModel pelanggan;

  /// Konstruktor untuk DetailPelangganAktif.
  const DetailPelangganAktif({super.key, required this.pelanggan});

  @override
  // ditambah: Komentar untuk menjelaskan kenapa lint rule diabaikan.
  // ignore: no_logic_in_create_state, Aturan ini diabaikan karena logika di dalamnya hanya untuk logging saat pembuatan state, yang berguna untuk debugging.
  State<DetailPelangganAktif> createState() {
    Log.info(
      'Membuat state untuk DetailPelangganAktif. '
      'ID Pelanggan Aktif: ${pelanggan.id}, '
      'ID Pelanggan: ${pelanggan.idPelanggan}, '
      'ID Paket: ${pelanggan.idPaket}, '
      'Status: ${pelanggan.status.displayName}',
    );
    return _DetailPelangganAktifState();
  }
}

class _DetailPelangganAktifState extends State<DetailPelangganAktif> {
  late PelangganAktifModel _pelangganAktif;
  PelangganModel? _pelanggan;
  PaketModel? _paket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman DetailPelangganAktif');
    Log.info('Inisialisasi awal dengan data dari widget:');
    Log.info('  - ID Pelanggan Aktif: ${widget.pelanggan.id}');
    Log.info('  - ID Pelanggan: ${widget.pelanggan.idPelanggan}');
    Log.info('  - ID Paket: ${widget.pelanggan.idPaket}');
    Log.info('  - Status: ${widget.pelanggan.status.displayName}');
    Log.info('  - Tanggal Mulai: ${widget.pelanggan.tanggalMulai}');
    Log.info('  - Tanggal Berakhir: ${widget.pelanggan.tanggalBerakhir}');
    Log.info('========================================');

    _pelangganAktif = widget.pelanggan;
    Log.info(
      'Variabel lokal _pelangganAktif telah diinisialisasi dengan data dari widget.',
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

    Log.info(
      'Membuat instance PelangganOperasi untuk mengambil data pelanggan dari database.',
    );
    final pelangganOperasi = PelangganOperasi();
    Log.info('PelangganOperasi instance dibuat: ${pelangganOperasi.hashCode}');

    Log.info(
      'Membuat instance PaketOperasi untuk mengambil data paket dari database.',
    );
    final paketOperasi = PaketOperasi();
    Log.info('PaketOperasi instance dibuat: ${paketOperasi.hashCode}');

    Log.info(
      'Menyiapkan query paralel untuk mengambil data pelanggan dan paket secara bersamaan.',
    );
    Log.info('  - Query 1: getPelangganById(${_pelangganAktif.idPelanggan})');

    final idPaket = _pelangganAktif.idPaket;
    Log.info('  - ID Paket: ${idPaket.isNotEmpty ? idPaket : "KOSONG"}');
    Log.info(
      '  - Query 2: ${idPaket.isNotEmpty ? "getPaketById($idPaket)" : "Future.value(null) karena ID Paket kosong"}',
    );

    try {
      Log.info(
        'Menjalankan Future.wait untuk mengeksekusi kedua query secara paralel.',
      );
      final results = await Future.wait([
        pelangganOperasi.getPelangganById(_pelangganAktif.idPelanggan),
        if (idPaket.isNotEmpty)
          paketOperasi.getPaketById(idPaket)
        else
          Future<PaketModel?>.value(),
      ]);

      Log.info('Kedua query selesai dijalankan. Memproses hasil...');
      Log.info(
        'Hasil query 1 (Pelanggan): ${results[0] != null ? "Ditemukan (Nama: ${(results[0] as PelangganModel).nama})" : "NULL - Pelanggan tidak ditemukan"}',
      );
      Log.info(
        'Hasil query 2 (Paket): ${results.length > 1 && results[1] != null ? "Ditemukan (Nama: ${(results[1] as PaketModel).nama})" : "NULL atau tidak dicari"}',
      );

      if (mounted) {
        Log.info(
          'Widget masih mounted. Memperbarui state dengan data yang telah diambil.',
        );
        setState(() {
          _pelanggan = results[0] as PelangganModel?;
          _paket = results.length > 1 ? results[1] as PaketModel? : null;
          _isLoading = false;
        });

        Log.info('State berhasil diperbarui:');
        Log.info(
          '  - _pelanggan: ${_pelanggan != null ? _pelanggan!.nama : "NULL"}',
        );
        Log.info(
          '  - _paket: ${_paket != null ? "${_paket!.nama} (Poin Hadiah: ${_paket!.poinHadiah})" : "NULL"}',
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
    Log.info('  - ID Pelanggan Aktif: ${_pelangganAktif.id}');
    Log.info('  - ID Pelanggan: ${_pelangganAktif.idPelanggan}');
    Log.info('  - ID Paket: ${_pelangganAktif.idPaket}');
    Log.info('  - Status Saat Ini: ${_pelangganAktif.status.displayName}');
    Log.info('========================================');

    Log.info(
      'Membuka halaman FormPelangganAktif dengan Navigator.push. Mengirim data _pelangganAktif terbaru ke form.',
    );

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) =>
            FormPelangganAktif(pelangganAktif: _pelangganAktif),
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

      Log.info(
        'Membuat instance PelangganAktifOperasi untuk query data terbaru.',
      );
      final operasi = PelangganAktifOperasi();

      Log.info(
        'Mengambil data pelanggan aktif terbaru dengan ID: ${_pelangganAktif.id}',
      );
      final updatedPelangganAktif = await operasi.ambilSatuPelangganAktif(
        _pelangganAktif.id,
      );

      Log.info(
        'Hasil query data terbaru: ${updatedPelangganAktif != null ? "Ditemukan (Status: ${updatedPelangganAktif.status.displayName})" : "NULL - Data tidak ditemukan"}',
      );

      if (mounted && updatedPelangganAktif != null) {
        Log.info(
          'Widget masih mounted dan data terbaru ditemukan. Memperbarui state.',
        );
        setState(() {
          _pelangganAktif = updatedPelangganAktif;
        });
        Log.info(
          '_pelangganAktif berhasil diperbarui. Status baru: ${updatedPelangganAktif.status.displayName}, Tanggal Berakhir: ${updatedPelangganAktif.tanggalBerakhir}',
        );

        Log.info(
          'Memanggil _loadDetails() untuk memperbarui data pelanggan dan paket terkait.',
        );
        await _loadDetails();
      } else if (!mounted) {
        Log.warning(
          'Widget sudah tidak mounted. Tidak dapat memperbarui state.',
        );
      } else if (updatedPelangganAktif == null) {
        Log.warning(
          'Data pelanggan aktif terbaru tidak ditemukan. Kemungkinan data telah dihapus dari database.',
        );
      }
    } else if (result == false) {
      Log.info(
        'Result bernilai FALSE. User tidak melakukan perubahan data. Tidak perlu refresh.',
      );
    } else if (result == null) {
      Log.info(
        'Result bernilai NULL. User menekan tombol back tanpa menyimpan. Tidak perlu refresh.',
      );
    } else {
      Log.info(
        'Result bernilai: $result. Tidak ada tindakan refresh yang diperlukan.',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI DetailPelangganAktif');
    Log.info('Status loading: $_isLoading');
    Log.info('Nama Pelanggan: ${_pelanggan?.nama ?? "Belum dimuat"}');
    Log.info('Nama Paket: ${_paket?.nama ?? "Belum dimuat / Tidak ada"}');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(_pelanggan?.nama ?? 'Detail Pelanggan'),
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
                                  if (_pelanggan != null) {
                                    Log.info(
                                      'NAVIGASI: TextButton nama pelanggan ditekan.',
                                    );
                                    Log.info(
                                      'Menuju halaman DetailPelangganPage dengan ID: ${_pelanggan!.id}',
                                    );
                                    await Navigator.push<void>(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (final context) =>
                                            DetailPelangganPage(
                                          idPelanggan: _pelanggan!.id,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Log.warning(
                                      'Tidak dapat navigasi ke detail pelanggan karena data _pelanggan masih null.',
                                    );
                                  }
                                },
                                child: Text(
                                  _pelanggan?.nama ??
                                      _pelangganAktif.idPelanggan,
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
                              _pelanggan?.telepon ?? 'Tidak ditemukan',
                            ),
                            InkWell(
                              onTap: () async {
                                if (_paket != null) {
                                  Log.info('NAVIGASI: Row paket ditekan.');
                                  Log.info(
                                    'Menuju halaman DetailPaketPage dengan data paket: ${_paket!.nama}',
                                  );
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (final context) =>
                                          DetailPaketPage(paket: _paket!),
                                    ),
                                  );
                                } else {
                                  Log.warning(
                                    'Tidak dapat navigasi ke detail paket karena data _paket masih null.',
                                  );
                                }
                              },
                              child: _buildInfoRow(
                                'Paket',
                                _paket?.nama ??
                                    ' (ID: ${_pelangganAktif.idPaket})',
                                isLink: true,
                              ),
                            ),
                            _buildInfoRow(
                              'Status',
                              _pelangganAktif.status.displayName,
                            ),
                            if (_paket != null)
                              _buildInfoRow(
                                'Poin Diperoleh',
                                '${_paket!.poinHadiah} Poin',
                              ),
                            _buildInfoRow(
                              'Mulai',
                              '${FormatTanggal.formatTanggalRingkas(_pelangganAktif.tanggalMulai)} - ${FormatJam.formatJamMenit(_pelangganAktif.tanggalMulai)}',
                            ),
                            _buildInfoRow(
                              'Berakhir',
                              '${FormatTanggal.formatTanggalRingkas(_pelangganAktif.tanggalBerakhir)} - ${FormatJam.formatJamMenit(_pelangganAktif.tanggalBerakhir)}',
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              PerhitunganUtil.getTeksSisaMasaAktif(
                                _pelangganAktif.tanggalBerakhir,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color:
                                        PerhitunganUtil.getWarnaSisaMasaAktif(
                                      _pelangganAktif.tanggalBerakhir,
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
                                  'Mengirim rincian paket ke pelanggan: ${_pelanggan?.nama ?? _pelangganAktif.idPelanggan}',
                                );
                                Log.info('Data yang akan dikirim:');
                                Log.info(
                                  '  - ID Pelanggan Aktif: ${_pelangganAktif.id}',
                                );
                                Log.info(
                                  '  - Nama Paket: ${_paket?.nama ?? "Tidak ada"}',
                                );
                                Log.info(
                                  '  - Status: ${_pelangganAktif.status.displayName}',
                                );
                                Log.info(
                                  '  - Masa Aktif: ${PerhitunganUtil.getTeksSisaMasaAktif(_pelangganAktif.tanggalBerakhir)}',
                                );
                                Log.info(
                                  '========================================',
                                );
                                await PesanInfoPaket.kirimRincianPaket(
                                  _pelangganAktif,
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
