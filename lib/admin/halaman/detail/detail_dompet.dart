// path: lib/admin/halaman/detail/detail_dompet.dart

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/form_dompet.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/widget/info_ringkasan_widget.dart';
import 'package:wifi/shared/widget/transaksi_list_widgets.dart';

class DetailDompetData {
  final DompetModel dompet;
  final List<TransaksiModel> transaksi;
  final double totalPemasukan;
  final double totalPengeluaran;

  DetailDompetData({
    required this.dompet,
    required this.transaksi,
    required this.totalPemasukan,
    required this.totalPengeluaran,
  });
}

class DetailDompet extends StatefulWidget {
  final DompetModel dompet;
  final DompetOperasi? dompetOperasi;
  final TransaksiOperasi? transaksiOperasi;

  const DetailDompet({
    super.key,
    required this.dompet,
    this.dompetOperasi,
    this.transaksiOperasi,
  });

  @override
  State<DetailDompet> createState() => _DetailDompetState();
}

class _DetailDompetState extends State<DetailDompet> {
  late Future<DetailDompetData> _futureDetailData;
  late final DompetOperasi _dompetOperasi;
  late final TransaksiOperasi _transaksiOperasi;

  String? _namaDompetTerbaru;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Membuat state untuk DetailDompet. ID Dompet: ${widget.dompet.id}, Nama Dompet: ${widget.dompet.namaDompet}',
    );

    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman DetailDompet');
    Log.info('ID Dompet yang akan ditampilkan: ${widget.dompet.id}');
    Log.info('Nama Dompet awal: ${widget.dompet.namaDompet}');
    Log.info('========================================');

    Log.info(
      'Menginisialisasi DompetOperasi. Menggunakan instance dari widget jika tersedia, jika tidak membuat instance baru.',
    );
    _dompetOperasi = widget.dompetOperasi ?? DompetOperasi();
    Log.info(
      'DompetOperasi berhasil diinisialisasi. Instance: ${_dompetOperasi.hashCode}',
    );

    Log.info(
      'Menginisialisasi TransaksiOperasi. Menggunakan instance dari widget jika tersedia, jika tidak membuat instance baru.',
    );
    _transaksiOperasi = widget.transaksiOperasi ?? TransaksiOperasi();
    Log.info(
      'TransaksiOperasi berhasil diinisialisasi. Instance: ${_transaksiOperasi.hashCode}',
    );

    Log.info(
      'Memulai pemuatan data awal dengan memanggil _loadData() untuk pertama kali.',
    );
    _futureDetailData = _loadData();
    Log.info(
      'Future _futureDetailData telah diset. UI akan menunggu future ini selesai melalui FutureBuilder.',
    );
  }

  Future<DetailDompetData> _loadData() async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES PEMUATAN DATA DETAIL DOMPET');
    Log.info('ID Dompet: ${widget.dompet.id}');
    Log.info('Nama Dompet (widget): ${widget.dompet.namaDompet}');
    Log.info('========================================');

    try {
      Log.info('Menjalankan 2 query secara paralel menggunakan Future.wait:');
      Log.info(
        '  1. getDompetById(${widget.dompet.id}) - Mengambil data dompet terbaru dari database.',
      );
      Log.info(
        '  2. ambilTransaksiByDompetId(${widget.dompet.id}) - Mengambil semua transaksi untuk dompet ini.',
      );

      final results = await Future.wait([
        _dompetOperasi.getDompetById(widget.dompet.id),
        _transaksiOperasi.ambilTransaksiByDompetId(widget.dompet.id),
      ]);

      Log.info('Kedua query selesai dijalankan. Memproses hasil...');

      final dompetTerbaru = results[0] as DompetModel?;
      final daftarTransaksi = results[1] as List<TransaksiModel>;

      Log.info(
        'Hasil query 1 (Dompet): ${dompetTerbaru != null ? "Ditemukan (Nama: ${dompetTerbaru.namaDompet}, Saldo: ${dompetTerbaru.saldo})" : "NULL - Dompet tidak ditemukan"}',
      );
      Log.info(
        'Hasil query 2 (Transaksi): ${daftarTransaksi.length} transaksi ditemukan',
      );

      if (dompetTerbaru == null) {
        Log.warning(
          'Dompet dengan ID ${widget.dompet.id} tidak ditemukan di database. '
          'Kemungkinan data telah dihapus oleh proses lain. '
          'Akan melempar Exception untuk ditangani oleh FutureBuilder.',
        );
        throw Exception('Dompet tidak ditemukan.');
      }

      Log.info(
        'Dompet ditemukan. Memperbarui variabel lokal _namaDompetTerbaru agar AppBar menampilkan nama terkini.',
      );
      if (mounted) {
        Log.info(
          'Widget masih mounted. Melakukan setState untuk memperbarui _namaDompetTerbaru dari "${_namaDompetTerbaru ?? "null"}" menjadi "${dompetTerbaru.namaDompet}".',
        );
        setState(() {
          _namaDompetTerbaru = dompetTerbaru.namaDompet;
        });
        Log.info(
          'setState berhasil dijalankan. _namaDompetTerbaru sekarang: $_namaDompetTerbaru',
        );
      } else {
        Log.warning(
          'Widget sudah tidak mounted saat ingin memperbarui _namaDompetTerbaru. '
          'Ini bisa terjadi jika user sudah navigasi keluar dari halaman sebelum data selesai dimuat.',
        );
      }

      Log.info(
        'Menghitung total pemasukan dan pengeluaran dari ${daftarTransaksi.length} transaksi.',
      );
      double pemasukan = 0;
      double pengeluaran = 0;

      for (int i = 0; i < daftarTransaksi.length; i++) {
        var trx = daftarTransaksi[i];
        if (trx.tipe == TipeTransaksi.pemasukan) {
          pemasukan += trx.jumlah;
          Log.info(
            '  Transaksi ke-${i + 1}: PEMASUKAN +${trx.jumlah} (Total pemasukan sementara: $pemasukan)',
          );
        } else if (trx.tipe == TipeTransaksi.pengeluaran) {
          pengeluaran += trx.jumlah;
          Log.info(
            '  Transaksi ke-${i + 1}: PENGELUARAN -${trx.jumlah} (Total pengeluaran sementara: $pengeluaran)',
          );
        }
      }

      Log.info('Perhitungan selesai. Ringkasan keuangan dompet:');
      Log.info('  - Nama Dompet: ${dompetTerbaru.namaDompet}');
      Log.info('  - Saldo Saat Ini: ${dompetTerbaru.saldo}');
      Log.info('  - Total Pemasukan: $pemasukan');
      Log.info('  - Total Pengeluaran: $pengeluaran');
      Log.info(
        '  - Selisih (Pemasukan - Pengeluaran): ${pemasukan - pengeluaran}',
      );
      Log.info('  - Jumlah Transaksi: ${daftarTransaksi.length}');

      Log.info('========================================');
      Log.info('PEMUATAN DATA DETAIL DOMPET BERHASIL');
      Log.info(
        'Mengembalikan DetailDompetData dengan semua informasi yang telah dihitung.',
      );
      Log.info('========================================');

      return DetailDompetData(
        dompet: dompetTerbaru,
        transaksi: daftarTransaksi,
        totalPemasukan: pemasukan,
        totalPengeluaran: pengeluaran,
      );
    } catch (e, s) {
      Log.error(
        'Gagal memuat data detail dompet untuk ID: ${widget.dompet.id}. '
        'Proses _loadData() mengalami kegagalan. '
        'Kemungkinan penyebab: koneksi database gagal, data dompet tidak ditemukan, '
        'query transaksi gagal, atau terjadi error saat perhitungan total. '
        'Error ini akan dilempar ulang dan ditangkap oleh FutureBuilder untuk ditampilkan ke UI.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  void _muatUlangData() {
    Log.info('========================================');
    Log.info('MEMICU RELOAD DATA (REFRESH)');
    Log.info('========================================');
    Log.info(
      'Pengguna atau sistem memicu pemuatan ulang data. '
      'Ini biasanya terjadi setelah:',
    );
    Log.info('  1. Kembali dari halaman FormDompet (edit data).');
    Log.info('  2. Ada perubahan pada transaksi (tambah/edit/hapus).');
    Log.info('  3. Refresh manual dari UI.');
    Log.info('');
    Log.info(
      'Menjalankan setState untuk mengganti _futureDetailData dengan future baru dari _loadData().',
    );
    Log.info(
      'UI akan otomatis memperbarui tampilan karena FutureBuilder akan mendeteksi future baru.',
    );

    setState(() {
      _futureDetailData = _loadData();
    });

    Log.info(
      'setState selesai dijalankan. _futureDetailData telah diganti dengan instance Future baru. '
      'FutureBuilder akan memulai proses pembangunan ulang UI dengan data terbaru.',
    );
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman DetailDompet');
    Log.info('ID Dompet: ${widget.dompet.id}');
    Log.info('Membersihkan resource dan state halaman DetailDompet.');
    Log.info('========================================');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI DetailDompet');
    Log.info(
      'Nama Dompet di AppBar: ${_namaDompetTerbaru ?? widget.dompet.namaDompet}',
    );
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(_namaDompetTerbaru ?? widget.dompet.namaDompet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info('========================================');
            Log.info('NAVIGASI: Tombol Kembali Ditekan');
            Log.info(
              'User menekan tombol back di AppBar halaman DetailDompet.',
            );
            Log.info('ID Dompet saat ini: ${widget.dompet.id}');
            Log.info(
              'Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.',
            );
            Log.info(
              'Nilai result true dikirim agar halaman sebelumnya tahu bahwa mungkin ada perubahan data.',
            );
            Log.info('========================================');
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Log.info('========================================');
              Log.info('NAVIGASI: Tombol Edit Ditekan');
              Log.info(
                'User ingin mengedit data dompet dengan ID: ${widget.dompet.id}',
              );
              Log.info('========================================');

              Log.info(
                'Menyiapkan data dompet yang akan dikirim ke FormDompet.',
              );
              Log.info(
                '_namaDompetTerbaru saat ini: ${_namaDompetTerbaru ?? "null"}',
              );
              Log.info('Nama dompet dari widget: ${widget.dompet.namaDompet}');

              final dompetUntukEdit = _namaDompetTerbaru != null
                  ? widget.dompet.copyWith(namaDompet: _namaDompetTerbaru)
                  : widget.dompet;

              Log.info('Data dompet yang akan dikirim ke FormDompet:');
              Log.info('  - ID: ${dompetUntukEdit.id}');
              Log.info('  - Nama: ${dompetUntukEdit.namaDompet}');
              Log.info('  - Saldo: ${dompetUntukEdit.saldo}');

              Log.info(
                'Membuka halaman FormDompet dengan Navigator.push. '
                'Menunggu hasil kembalian dari FormDompet setelah user selesai mengedit.',
              );

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormDompet(dompet: dompetUntukEdit),
                ),
              );

              Log.info('========================================');
              Log.info('KEMBALI DARI FORM DOMPET');
              Log.info('Nilai result yang diterima: $result');
              Log.info('========================================');

              if (result == true) {
                Log.info(
                  'Result bernilai TRUE. Ini berarti user melakukan perubahan data di FormDompet.',
                );
                Log.info(
                  'Memanggil _muatUlangData() untuk me-refresh data dompet dan transaksi.',
                );
                Log.info(
                  'UI akan diperbarui dengan data terbaru dari database.',
                );
                _muatUlangData();
              } else if (result == false) {
                Log.info(
                  'Result bernilai FALSE. User tidak melakukan perubahan data di FormDompet. '
                  'Tidak perlu me-refresh data.',
                );
              } else if (result == null) {
                Log.info(
                  'Result bernilai NULL. User menekan tombol back di FormDompet tanpa menyimpan perubahan. '
                  'Tidak perlu me-refresh data.',
                );
              } else {
                Log.info(
                  'Result bernilai: $result. Tidak ada tindakan refresh yang diperlukan.',
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DetailDompetData>(
        future: _futureDetailData,
        builder: (context, snapshot) {
          Log.info(
            'FutureBuilder builder dipanggil. ConnectionState: ${snapshot.connectionState}',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'FutureBuilder: Status WAITING. Data masih dalam proses pemuatan dari database.',
            );
            Log.info(
              'Menampilkan CircularProgressIndicator sebagai indikator loading.',
            );
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            Log.error(
              'FutureBuilder: Status ERROR. Terjadi kesalahan saat memuat data detail dompet.',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            Log.info('Menampilkan pesan error ke UI: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            Log.warning(
              'FutureBuilder: Status NO DATA. Snapshot berhasil tetapi tidak mengandung data. '
              'Ini mungkin terjadi jika data dompet bernilai null atau query mengembalikan hasil kosong.',
            );
            Log.info('Menampilkan pesan \"Data Kosong\" ke UI.');
            return const Center(child: Text('Data Kosong'));
          }

          final data = snapshot.data!;
          Log.info('========================================');
          Log.info('MEMBANGUN UI DENGAN DATA TERBARU');
          Log.info('FutureBuilder: Status SUCCESS. Data berhasil dimuat.');
          Log.info('Detail data yang akan ditampilkan:');
          Log.info('  - Nama Dompet: ${data.dompet.namaDompet}');
          Log.info('  - Saldo: ${data.dompet.saldo}');
          Log.info('  - Total Pemasukan: ${data.totalPemasukan}');
          Log.info('  - Total Pengeluaran: ${data.totalPengeluaran}');
          Log.info('  - Jumlah Transaksi: ${data.transaksi.length}');
          Log.info('========================================');

          return Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor.withAlpha(13),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Pemasukan',
                      jumlah: data.totalPemasukan,
                      warna: Colors.green,
                    ),
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Pengeluaran',
                      jumlah: data.totalPengeluaran,
                      warna: Colors.red,
                    ),
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Saldo',
                      jumlah: data.dompet.saldo,
                      warna: data.dompet.saldo >= 0 ? Colors.blue : Colors.red,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: data.transaksi.isEmpty
                    ? const Center(child: Text('Belum ada transaksi.'))
                    : _buildTransaksiList(data.transaksi),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransaksiList(List<TransaksiModel> transaksiData) {
    Log.info(
      'Membangun daftar transaksi yang dikelompokkan berdasarkan tanggal.',
    );
    Log.info(
      'Jumlah total transaksi yang akan ditampilkan: ${transaksiData.length}',
    );

    Log.info(
      'Mengelompokkan transaksi berdasarkan tanggal menggunakan fungsi groupTransaksiByDate.',
    );
    final groupedTransaksi = groupTransaksiByDate(transaksiData);

    Log.info('Hasil pengelompokan: ${groupedTransaksi.length} grup tanggal.');
    groupedTransaksi.forEach((tanggal, transaksiList) {
      Log.info('  - Tanggal $tanggal: ${transaksiList.length} transaksi');
    });

    return ListView.builder(
      itemCount: groupedTransaksi.length,
      itemBuilder: (context, index) {
        final tanggal = groupedTransaksi.keys.elementAt(index);
        final transaksiPadaTanggal = groupedTransaksi[tanggal]!;

        Log.info(
          'Membangun UI untuk grup tanggal: $tanggal (${transaksiPadaTanggal.length} transaksi)',
        );

        final totalHarian = transaksiPadaTanggal.fold(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.pemasukan
                  ? item.jumlah
                  : -item.jumlah),
        );

        Log.info('  Total harian untuk $tanggal: $totalHarian');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bangunHeaderSeksi(tanggal, totalHarian),
            ...transaksiPadaTanggal.map(
              (transaksi) => bangunItemTransaksi(context, transaksi, () {
                Log.info('========================================');
                Log.info('TRANSAKSI: Refresh dipicu dari ItemTransaksi');
                Log.info('ID Transaksi: ${transaksi.id}');
                Log.info(
                  'User melakukan aksi pada transaksi (edit/hapus) yang memerlukan refresh data.',
                );
                Log.info(
                  'Memanggil _muatUlangData() untuk memperbarui seluruh data halaman.',
                );
                Log.info('========================================');
                _muatUlangData();
              }, _transaksiOperasi),
            ),
          ],
        );
      },
    );
  }
}
