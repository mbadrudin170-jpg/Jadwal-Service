// path: lib/admin/halaman/lainnya/riwayat_aktivasi_paket.dart
// diubah: Memperbaiki unawaited future.

import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/admin/halaman/detail/detail_riwayat_langganan.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/widget/nama_paket.dart';
import 'package:wifi/admin/halaman/widget/nama_pelanggan.dart';

enum OpsiUrutkan { berakhirHariIni, terbaru, terlama, lunas, belumLunas }

class RiwayatAktivasiPaketPage extends StatefulWidget {
  const RiwayatAktivasiPaketPage({super.key});

  @override
  State<RiwayatAktivasiPaketPage> createState() =>
      _RiwayatAktivasiPaketPageState();
}

class _RiwayatAktivasiPaketPageState extends State<RiwayatAktivasiPaketPage> {
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  late Future<List<TransaksiModel>> _listTransaksiFuture;
  OpsiUrutkan _urutanAktif = OpsiUrutkan.terbaru;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Riwayat Aktivasi Paket');
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    Log.info('Memuat data transaksi aktivasi paket dari database');
    setState(() {
      _listTransaksiFuture =
          _transaksiOperasi.getTransaksiByAktivasiPaket().then((list) {
        Log.info(
          'Berhasil memuat ${list.length} data transaksi aktivasi paket',
        );

        // Log ringkasan setiap transaksi
        int jumlahLunas = 0;
        int jumlahBelumLunas = 0;
        int jumlahBerakhirHariIni = 0;
        final sekarang = DateTime.now();

        for (var transaksi in list) {
          if (transaksi.statusPembayaran == StatusPembayaranEnum.lunas) {
            jumlahLunas++;
          } else {
            jumlahBelumLunas++;
          }

          if (transaksi.tanggalBerakhir != null &&
              transaksi.tanggalBerakhir!.year == sekarang.year &&
              transaksi.tanggalBerakhir!.month == sekarang.month &&
              transaksi.tanggalBerakhir!.day == sekarang.day) {
            jumlahBerakhirHariIni++;
          }

          Log.info(
            'Transaksi ID: ${transaksi.id} - Pelanggan ID: ${transaksi.idPelanggan ?? "N/A"}, Paket ID: ${transaksi.idPaket ?? "N/A"}, Status: ${transaksi.statusPembayaran.name}, Mulai: ${transaksi.tanggalMulai != null ? FormatTanggal.formatTanggalBasic(transaksi.tanggalMulai!) : "N/A"}, Berakhir: ${transaksi.tanggalBerakhir != null ? FormatTanggal.formatTanggalBasic(transaksi.tanggalBerakhir!) : "N/A"}',
          );
        }

        Log.info(
          'Ringkasan transaksi - Total: ${list.length}, Lunas: $jumlahLunas, Belum Lunas: $jumlahBelumLunas, Berakhir Hari Ini: $jumlahBerakhirHariIni',
        );

        _urutkanList(list, _urutanAktif);
        return list;
      }).catchError((Object error, StackTrace st) {
        Log.error(
          'Gagal memuat data transaksi aktivasi paket dari database',
          e: error,
          st: st,
        );
        throw error;
      });
    });
  }

  void _urutkanList(List<TransaksiModel> list, OpsiUrutkan pilihan) {
    Log.info(
      'Mengurutkan ${list.length} data transaksi berdasarkan: ${pilihan.name}',
    );
    int Function(TransaksiModel, TransaksiModel) comparator;

    switch (pilihan) {
      case OpsiUrutkan.terbaru:
        comparator = (a, b) =>
            (b.diperbarui ?? b.tanggal).compareTo(a.diperbarui ?? a.tanggal);
        Log.info('Pengurutan: Terbaru (berdasarkan waktu update/tanggal)');
        break;
      case OpsiUrutkan.terlama:
        comparator = (a, b) =>
            (a.diperbarui ?? a.tanggal).compareTo(b.diperbarui ?? b.tanggal);
        Log.info('Pengurutan: Terlama (berdasarkan waktu update/tanggal)');
        break;
      case OpsiUrutkan.lunas:
        comparator = (a, b) {
          final isLunasA = a.statusPembayaran == StatusPembayaranEnum.lunas;
          final isLunasB = b.statusPembayaran == StatusPembayaranEnum.lunas;
          if (isLunasA == isLunasB) {
            Log.info(
              'Status sama (${isLunasA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isLunasA ? -1 : 1;
          Log.info(
            'Memindahkan transaksi ${isLunasA ? "lunas" : "belum lunas"} ke ${isLunasA ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info('Pengurutan: Lunas di atas, Belum Lunas di bawah');
        break;
      case OpsiUrutkan.belumLunas:
        comparator = (a, b) {
          final isLunasA = a.statusPembayaran == StatusPembayaranEnum.lunas;
          final isLunasB = b.statusPembayaran == StatusPembayaranEnum.lunas;
          if (isLunasA == isLunasB) {
            Log.info(
              'Status sama (${isLunasA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isLunasA ? 1 : -1;
          Log.info(
            'Memindahkan transaksi ${isLunasA ? "lunas" : "belum lunas"} ke ${isLunasA ? "bawah" : "atas"}',
          );
          return result;
        };
        Log.info('Pengurutan: Belum Lunas di atas, Lunas di bawah');
        break;
      case OpsiUrutkan.berakhirHariIni:
        comparator = (a, b) {
          final sekarang = DateTime.now();
          final tanggalSekarangStr = FormatTanggal.formatTanggalBasic(sekarang);

          bool isHariIni(DateTime? tanggal) {
            if (tanggal == null) return false;
            return tanggal.year == sekarang.year &&
                tanggal.month == sekarang.month &&
                tanggal.day == sekarang.day;
          }

          final aHariIni = isHariIni(a.tanggalBerakhir);
          final bHariIni = isHariIni(b.tanggalBerakhir);

          if (aHariIni == bHariIni) {
            Log.info(
              'Status berakhir hari ini sama ($aHariIni), posisi tidak berubah',
            );
            return 0;
          }

          final result = aHariIni ? -1 : 1;
          Log.info(
            'Transaksi ${aHariIni ? "berakhir $tanggalSekarangStr" : "tidak berakhir hari ini"} dipindahkan ke ${aHariIni ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info(
          'Pengurutan: Berakhir Hari Ini (${FormatTanggal.formatTanggalBasic(DateTime.now())}) di atas',
        );
        break;
    }

    list.sort(comparator);

    // Log 5 data teratas setelah pengurutan
    Log.info('5 data teratas setelah pengurutan ${pilihan.name}:');
    for (int i = 0; i < (list.length < 5 ? list.length : 5); i++) {
      final t = list[i];
      Log.info(
        '  ${i + 1}. ID: ${t.id} - Status: ${t.statusPembayaran.name} - Berakhir: ${t.tanggalBerakhir != null ? FormatTanggal.formatTanggalBasic(t.tanggalBerakhir!) : "N/A"}',
      );
    }

    Log.info('Proses pengurutan selesai, ${list.length} data telah diurutkan');
  }

  void _showUrutkanDialog() async {
    Log.info(
      'Menampilkan dialog opsi pengurutan, urutan saat ini: ${_urutanAktif.name}',
    );
    final OpsiUrutkan? pilihan = await showDialog<OpsiUrutkan>(
      context: context,
      builder: (BuildContext context) {
        Widget buildOption(String text, OpsiUrutkan value) {
          final bool isSelected = _urutanAktif == value;
          return SimpleDialogOption(
            onPressed: () {
              Log.info(
                'User memilih opsi urutkan: ${value.name} (${isSelected ? "sudah aktif" : "berubah"} dari ${_urutanAktif.name})',
              );
              Navigator.pop(context, value);
            },
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Berakhir Hari Ini', OpsiUrutkan.berakhirHariIni),
            buildOption('Terbaru', OpsiUrutkan.terbaru),
            buildOption('Terlama', OpsiUrutkan.terlama),
            buildOption('Status (Lunas di Atas)', OpsiUrutkan.lunas),
            buildOption('Status (Belum Lunas di Atas)', OpsiUrutkan.belumLunas),
          ],
        );
      },
    );

    if (pilihan != null && pilihan != _urutanAktif) {
      Log.info(
        'Menerapkan perubahan urutan dari ${_urutanAktif.name} ke ${pilihan.name}',
      );
      final list = await _listTransaksiFuture;
      setState(() {
        _urutanAktif = pilihan;
        _urutkanList(list, pilihan);
        _listTransaksiFuture = Future.value(list);
      });
      Log.info('Urutan berhasil diubah ke ${pilihan.name}');
    } else if (pilihan == _urutanAktif) {
      Log.info(
        'User memilih urutan yang sama (${_urutanAktif.name}), tidak ada perubahan',
      );
    } else {
      Log.info('Dialog urutkan ditutup tanpa memilih opsi');
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI halaman Riwayat Aktivasi Paket, urutan aktif: ${_urutanAktif.name}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'Kembali ke halaman sebelumnya dari Riwayat Aktivasi Paket',
            );
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showUrutkanDialog,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: FutureBuilder<List<TransaksiModel>>(
        future: _listTransaksiFuture,
        builder: (context, snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data transaksi masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat menampilkan data transaksi',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info(
              'Data riwayat aktivasi kosong, menampilkan pesan tidak ada data',
            );
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          } else {
            final dataLength = snapshot.data!.length;
            Log.info('Menampilkan $dataLength data transaksi dalam ListView');

            return ListView.builder(
              itemCount: dataLength,
              itemBuilder: (context, index) {
                final transaksi = snapshot.data![index];
                final statusPembayaranColor =
                    transaksi.statusPembayaran == StatusPembayaranEnum.lunas
                        ? Colors.green
                        : Colors.red;

                Log.info(
                  'Membangun item ke-${index + 1} dari $dataLength - ID: ${transaksi.id}, Pelanggan: ${transaksi.idPelanggan ?? "N/A"}, Status: ${transaksi.statusPembayaran.name}',
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: ListTile(
                    onTap: () async {
                      Log.info(
                        'Navigasi ke halaman Detail Transaksi ID: ${transaksi.id}, Pelanggan ID: ${transaksi.idPelanggan ?? "N/A"}',
                      );
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailLanggananTransaksiPage(
                            idTransaksi: transaksi.id,
                          ),
                        ),
                      );
                      if (result == true) {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaksi.id} dengan perubahan data, menyegarkan daftar',
                        );
                        await _loadRiwayat();
                      } else {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaksi.id} tanpa perubahan data',
                        );
                      }
                    },
                    title: NamaPelangganWidget(
                      idPelanggan: transaksi.idPelanggan ?? ' ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NamaPaketWidget(idPaket: transaksi.idPaket ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${transaksi.statusPembayaran.name}',
                          style: TextStyle(
                            color: statusPembayaranColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (transaksi.tanggalMulai != null &&
                            transaksi.tanggalBerakhir != null)
                          Text(
                            'Aktif: ${FormatTanggal.formatTanggalBasic(transaksi.tanggalMulai!)} - ${FormatTanggal.formatTanggalBasic(transaksi.tanggalBerakhir!)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
