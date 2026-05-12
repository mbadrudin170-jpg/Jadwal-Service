// path: lib/admin/halaman/lainnya/pengaturan_admin.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';
import 'package:wifi/admin/halaman/form/form_pengaturan.dart';

// Halaman untuk menampilkan konfigurasi pengaturan aplikasi.
class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();
  late Future<PengaturanModel> _futurePengaturan;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Pengaturan Aplikasi');
    _loadPengaturan();
  }

  // Fungsi untuk memuat data pengaturan dari database.
  void _loadPengaturan() {
    Log.info('Memuat data pengaturan dari database lokal');
    setState(() {
      _futurePengaturan = _pengaturanOperasi.getPengaturan().then((data) {
        Log.info('Data pengaturan berhasil dimuat dari database');
        Log.info(
          'Detail pengaturan - Interval sinkronisasi: ${data.intervalSinkronisasiOtomatis} jam, Hapus arsip: ${data.hapusOtomatisDataArsip} hari, Mode pemeliharaan: ${data.modePemeliharaan ? "Aktif" : "Nonaktif"}, Info pemeliharaan: ${data.infoPemeliharaan.isNotEmpty ? data.infoPemeliharaan : "(kosong)"}',
        );
        return data;
      }).catchError((error, st) {
        Log.error(
          'Gagal memuat data pengaturan dari database lokal',
          error: error,
          st: st,
        );
        throw error;
      });
    });
  }

  // Fungsi untuk menavigasi ke halaman form edit dan memuat ulang data jika ada perubahan.
  void _editPengaturan(PengaturanModel pengaturan) async {
    Log.info('Navigasi ke halaman Form Edit Pengaturan');
    Log.info(
      'Data pengaturan sebelum edit - Interval: ${pengaturan.intervalSinkronisasiOtomatis} jam, Hapus arsip: ${pengaturan.hapusOtomatisDataArsip} hari, Mode pemeliharaan: ${pengaturan.modePemeliharaan}, Info: ${pengaturan.infoPemeliharaan.isNotEmpty ? pengaturan.infoPemeliharaan : "(kosong)"}',
    );

    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPengaturan(pengaturan: pengaturan),
      ),
    );

    if (hasil == true && mounted) {
      Log.info(
        'Data pengaturan berhasil diperbarui dari Form Edit, menyegarkan tampilan',
      );
      _loadPengaturan();
    } else if (hasil == false) {
      Log.info('Kembali dari Form Edit Pengaturan tanpa melakukan perubahan');
    } else {
      Log.info('Kembali dari Form Edit Pengaturan (hasil: $hasil)');
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman Pengaturan Aplikasi');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info('Kembali ke halaman sebelumnya dari Pengaturan');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<PengaturanModel>(
        future: _futurePengaturan,
        builder: (context, snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data pengaturan masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat memuat data pengaturan',
              error: snapshot.error,
              st: snapshot.st,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pengaturan = snapshot.data!;
            Log.info('Data pengaturan tersedia, menampilkan detail pengaturan');
            Log.info(
              'Mode pemeliharaan: ${pengaturan.modePemeliharaan ? "Aktif" : "Nonaktif"}, Info: ${pengaturan.infoPemeliharaan.isNotEmpty ? pengaturan.infoPemeliharaan : "(kosong)"}',
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildInfoCard(
                          judul: 'Sinkronisasi Otomatis',
                          nilai:
                              '${pengaturan.intervalSinkronisasiOtomatis} Jam',
                          ikon: Icons.sync,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          judul: 'Hapus Arsip Otomatis',
                          nilai: '${pengaturan.hapusOtomatisDataArsip} Hari',
                          ikon: Icons.auto_delete_outlined,
                        ),
                        const Divider(height: 24, thickness: 1),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'Mode Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  pengaturan.modePemeliharaan
                                      ? 'Aplikasi dalam mode pemeliharaan'
                                      : 'Aplikasi berjalan normal',
                                ),
                                value: pengaturan.modePemeliharaan,
                                onChanged: null, // Read-only di halaman ini
                                secondary: Icon(
                                  pengaturan.modePemeliharaan
                                      ? Icons.construction
                                      : Icons.check_circle_outline,
                                  color: pengaturan.modePemeliharaan
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                              if (pengaturan.modePemeliharaan)
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text(
                                    'Info Pemeliharaan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    pengaturan.infoPemeliharaan.isNotEmpty
                                        ? pengaturan.infoPemeliharaan
                                        : '(Tidak ada pesan diatur)',
                                  ),
                                  isThreeLine: true,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Pengaturan'),
                    onPressed: () {
                      Log.info('Tombol Edit Pengaturan ditekan');
                      _editPengaturan(pengaturan);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          } else {
            Log.warning(
              'Data pengaturan tidak tersedia (null), menampilkan pesan kosong',
            );
            return const Center(child: Text('Pengaturan tidak ditemukan.'));
          }
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String judul,
    required String nilai,
    required IconData ikon,
  }) {
    Log.info('Membangun kartu info: $judul dengan nilai: $nilai');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        leading: Icon(ikon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          nilai,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
