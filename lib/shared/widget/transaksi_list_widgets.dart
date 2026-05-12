// path: lib/widget/transaksi_list_widgets.dart
// diubah: Menghapus operator null-aware yang tidak perlu dan memperbaiki penanganan error.

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/halaman/detail/detail_transaksi.dart';
import 'package:admin_wifi/halaman/form/form_transaksi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';

Map<DateTime, List<TransaksiModel>> groupTransaksiByDate(
  List<TransaksiModel> transaksi,
) {
  final Map<DateTime, List<TransaksiModel>> grouped = {};
  for (final t in transaksi) {
    final date = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
    if (grouped[date] == null) {
      grouped[date] = [];
    }
    grouped[date]!.add(t);
  }
  return grouped;
}

Widget bangunHeaderSeksi(DateTime tanggal, double total) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          FormatTanggal.formatTanggalBasic(tanggal),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          FormatUang.formatMataUang(total),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: total >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    ),
  );
}

class TransaksiTile extends StatefulWidget {
  final TransaksiModel transaksi;
  final VoidCallback onDataChanged;
  final TransaksiOperasi transaksiOperasi;

  const TransaksiTile({
    super.key,
    required this.transaksi,
    required this.onDataChanged,
    required this.transaksiOperasi,
  });

  @override
  State<TransaksiTile> createState() => _TransaksiTileState();
}

class _TransaksiTileState extends State<TransaksiTile> {
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final DompetOperasi _dompetOperasi = DompetOperasi();

  Future<String> _getNamaKategori() async {
    try {
      final kategori = await _kategoriOperasi.getKategoriById(
        widget.transaksi.idKategori,
      );
      return kategori.nama;
    } catch (e) {
      return 'Tidak ada kategori';
    }
  }

  Future<String> _getNamaDompet() async {
    try {
      final dompet = await _dompetOperasi.getDompetById(
        widget.transaksi.idDompet,
      );
      return dompet!.namaDompet;
    } catch (e) {
      return 'Tidak ada dompet';
    }
  }

  void _arsipkanTransaksi() async {
    await widget.transaksiOperasi.arsipkanTransaksi(widget.transaksi.id);
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    if (widget.transaksi.tipe == TipeTransaksi.pemasukan) {
      iconData = Icons.arrow_downward;
      iconColor = Colors.green;
    } else {
      iconData = Icons.arrow_upward;
      iconColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        key: ValueKey(widget.transaksi.id),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailTransaksiPage(transaksi: widget.transaksi),
            ),
          );
          if (result == true) {
            widget.onDataChanged();
          }
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Opsi'),
              content: const Text(
                'Apa yang ingin Anda lakukan dengan transaksi ini?',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FormTransaksiPage(transaksi: widget.transaksi),
                      ),
                    );
                    if (result == true) {
                      widget.onDataChanged();
                    }
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _arsipkanTransaksi();
                  },
                  child: const Text('Hapus'),
                ),
              ],
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: iconColor.withAlpha(25),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(widget.transaksi.keterangan),
        subtitle: FutureBuilder<List<String>>(
          future: Future.wait([_getNamaKategori(), _getNamaDompet()]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Memuat...');
            }
            if (snapshot.hasError) {
              return const Text('Error memuat data');
            }
            final namaKategori = snapshot.data?[0] ?? '-';
            final namaDompet = snapshot.data?[1] ?? '-';
            return Text('$namaKategori | $namaDompet');
          },
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FormatUang.formatMataUang(widget.transaksi.jumlah),
              style: TextStyle(fontWeight: FontWeight.bold, color: iconColor),
            ),
            Text(FormatJam.formatJamMenit(widget.transaksi.tanggal)),
          ],
        ),
      ),
    );
  }
}

Widget bangunItemTransaksi(
  BuildContext context,
  TransaksiModel transaksi,
  VoidCallback onDataChanged,
  TransaksiOperasi transaksiOperasi,
) {
  return TransaksiTile(
    transaksi: transaksi,
    onDataChanged: onDataChanged,
    transaksiOperasi: transaksiOperasi,
  );
}
