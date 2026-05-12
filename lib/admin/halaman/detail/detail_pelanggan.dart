// path: lib/admin/halaman/detail/detail_pelanggan.dart

import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan.dart';
import 'package:wifi/admin/halaman/pembantu/halaman_poin.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailPelangganPage extends StatefulWidget {
  final String idPelanggan;

  const DetailPelangganPage({super.key, required this.idPelanggan});

  @override
  State<DetailPelangganPage> createState() => _DetailPelangganPageState();
}

class _DetailPelangganPageState extends State<DetailPelangganPage> {
  final PelangganOperasi pelangganOperasi = PelangganOperasi();
  final TransaksiOperasi transaksiOperasi = TransaksiOperasi();

  PelangganModel? pelanggan;
  int totalPoin = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Log inisialisasi state
    Log.info(
      'Memulai siklus hidup initState pada DetailPelangganPage untuk ID Pelanggan: ${widget.idPelanggan}. Sistem akan segera memicu pemuatan data dari database.',
    );
    _loadData();
  }

  // Fungsi ini bertujuan untuk memuat data pelanggan dan total poin.
  Future<void> _loadData() async {
    Log.info(
      'Menjalankan fungsi _loadData(). Mencoba melakukan pengambilan data paralel untuk profil pelanggan dan akumulasi poin dari database.',
    );
    try {
      // diubah: agar lebih ringkas
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      Log.info(
        'Memulai request asinkron ke PelangganOperasi untuk mencari data dengan ID: ${widget.idPelanggan}',
      );
      final hasilPelanggan = await pelangganOperasi.getPelangganById(
        widget.idPelanggan,
      );

      Log.info(
        'Memulai request asinkron ke TransaksiOperasi untuk menghitung total poin pelanggan ID: ${widget.idPelanggan}',
      );
      final hasilPoin = await transaksiOperasi.getTotalPoin(widget.idPelanggan);

      if (!mounted) {
        Log.warning(
          'Fungsi _loadData() selesai tapi widget sudah tidak terpasang (not mounted) di pohon widget. Membatalkan pembaruan State untuk mencegah kebocoran memori.',
        );
        return;
      }

      setState(() {
        pelanggan = hasilPelanggan;
        totalPoin = hasilPoin;
        isLoading = false;
      });

      if (hasilPelanggan != null) {
        Log.info(
          'Pemuatan data berhasil secara keseluruhan. Objek pelanggan atas nama "${hasilPelanggan.nama}" telah dimuat ke dalam state dan UI siap dirender ulang.',
        );
      } else {
        Log.warning(
          'Pemuatan data selesai tetapi mengembalikan nilai null. Pelanggan dengan ID: ${widget.idPelanggan} tidak ditemukan dalam koleksi database. UI akan menampilkan pesan data tidak ditemukan.',
        );
      }
    } catch (e, st) {
      Log.error(
        'Terjadi kegagalan fatal saat proses pengambilan data di fungsi _loadData(). Hal ini bisa disebabkan oleh masalah koneksi database atau ketidakcocokan skema model.',
        error: e,
        st: st,
      );
      if (mounted) {
        setState(() => isLoading = false);
        Log.info(
          'State isLoading telah diatur ke false meskipun terjadi error agar spinner berhenti berputar.',
        );
      }
    }
  }

  // ditambahkan: fungsi untuk navigasi ke halaman edit
  void _editPelanggan() async {
    if (pelanggan == null) return;
    Log.info('Menavigasi ke FormPelanggan untuk mode edit dengan ID: ${pelanggan!.id}');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPelanggan(pelanggan: pelanggan),
      ),
    );

    if (result == true && mounted) {
      Log.info('Kembali dari FormPelanggan dengan hasil true. Memuat ulang data pelanggan.');
      _loadData(); // Muat ulang data untuk menampilkan perubahan
    } else {
      Log.info('Kembali dari FormPelanggan tanpa menyimpan perubahan.');
    }
  }

  // Fungsi ini bertujuan untuk menyalin semua info pelanggan.
  void _salinSemuaInfo(BuildContext context, PelangganModel pelanggan) {
    Log.info(
      'User memicu aksi _salinSemuaInfo(). Mempersiapkan penggabungan string untuk Nama: ${pelanggan.nama}, Telepon: ${pelanggan.telepon}, Alamat: ${pelanggan.alamat}, Password: ${pelanggan.password}, dan MAC: ${pelanggan.macAddress}.',
    );

    final info =
        '''
Nama : ${pelanggan.nama}
No HP : ${pelanggan.telepon}
Alamat : ${pelanggan.alamat}
Password : ${pelanggan.password}
MAC : ${pelanggan.macAddress}
'''
            .trim();

    Clipboard.setData(ClipboardData(text: info)).then((_) {
      Log.info(
        'Data komprehensif pelanggan berhasil didorong ke sistem Clipboard perangkat.',
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua info berhasil disalin')),
    );
  }

  // Fungsi ini bertujuan untuk menyalin data spesifik.
  void _salinData(BuildContext context, String label, String data) {
    Log.info(
      'User memicu aksi _salinData() untuk bagian spesifik: $label dengan nilai data: $data.',
    );

    Clipboard.setData(ClipboardData(text: data)).then((_) {
      Log.info('Berhasil menyalin data kategori $label ke Clipboard.');
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label berhasil disalin')));
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI (build method) DetailPelangganPage. Status Loading: $isLoading, Pelanggan Terdeteksi: ${pelanggan != null}',
    );

    // Tampilkan loading spinner saat data sedang diambil
    if (isLoading) {
      Log.info(
        'Merender tampilan CircularProgressIndicator karena status isLoading masih true.',
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat Detail...')), // diubah: judul appbar saat loading
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Cek jika data kosong setelah loading selesai
    if (pelanggan == null) {
      Log.warning(
        'Merender tampilan pesan "Pelanggan tidak ditemukan" karena objek pelanggan bernilai null setelah proses loading selesai.',
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const Center(child: Text('Pelanggan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        // ditambahkan: tombol edit di appbar
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Pelanggan',
            onPressed: _editPelanggan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Log.info(
                    'Interaksi pengguna: Mengetuk kartu Poin. Melakukan navigasi push ke HalamanPoin untuk pelanggan: ${pelanggan!.nama}',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HalamanPoin(idPelanggan: widget.idPelanggan),
                    ),
                  ).then((_) {
                    Log.info(
                      'Kembali dari HalamanPoin ke DetailPelangganPage.',
                    );
                    _loadData(); // ditambahkan: muat ulang data poin jika ada perubahan
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Total Poin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalPoin',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const Text(
                        'Klik untuk detail riwayat poin',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(context, 'Nama', pelanggan!.nama, () {
              Log.info('Trigger tombol salin pada baris Nama.');
              _salinData(context, 'Nama', pelanggan!.nama);
            }),
            const Divider(),
            _buildDetailRow(context, 'Telepon', pelanggan!.telepon, () {
              Log.info('Trigger tombol salin pada baris Telepon.');
              _salinData(context, 'No Telepon', pelanggan!.telepon);
            }),
            const Divider(),
            _buildDetailRow(context, 'Alamat', pelanggan!.alamat, () {
              Log.info('Trigger tombol salin pada baris Alamat.');
              _salinData(context, 'Alamat', pelanggan!.alamat);
            }),
            const Divider(),
            _buildDetailRow(context, 'Password', pelanggan!.password, () {
              Log.info('Trigger tombol salin pada baris Password.');
              _salinData(context, 'Password', pelanggan!.password);
            }),
            const Divider(),
            _buildDetailRow(context, 'MAC Address', pelanggan!.macAddress, () {
              Log.info('Trigger tombol salin pada baris MAC Address.');
              _salinData(context, 'MAC Address', pelanggan!.macAddress);
            }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Log.info(
                  'Menekan tombol utama "Salin Semua Info" di bagian bawah layar.',
                );
                _salinSemuaInfo(context, pelanggan!);
              },
              icon: const Icon(Icons.copy_all),
              label: const Text('Salin Semua Info'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String judul,
    String detail,
    VoidCallback salinData,
  ) {
    // Log pembentukan widget row (opsional untuk sangat terperinci)
    // Log.info('Membangun baris detail untuk kategori: $judul');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.isEmpty ? '-' : detail,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: salinData,
                icon: const Icon(Icons.content_copy, size: 20),
                color: Colors.grey,
                tooltip: 'Salin $judul',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
