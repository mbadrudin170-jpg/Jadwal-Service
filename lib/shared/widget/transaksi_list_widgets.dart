// path: lib/shared/widget/transaksi_list_widgets.dart
// diubah: Menghapus operator null-aware yang tidak perlu dan memperbaiki penanganan error.

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/detail_transaksi.dart';
import 'package:wifi/admin/halaman/form/form_transaksi.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/category_repository.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Mengelompokkan daftar transaksi berdasarkan tanggal (tanpa jam).
///
/// Mengembalikan [Map] dengan kunci [DateTime] (hanya tahun, bulan, hari)
/// dan nilai berupa [List] dari [TransactionModel] pada tanggal tersebut.
Map<DateTime, List<TransactionModel>> groupTransaksiByDate(
  final List<TransactionModel> transaksi,
) {
  final Map<DateTime, List<TransactionModel>> grouped = {};
  for (final t in transaksi) {
    final date = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
    if (grouped[date] == null) {
      grouped[date] = [];
    }
    grouped[date]!.add(t);
  }
  return grouped;
}

/// Membangun widget header untuk sebuah seksi transaksi berdasarkan tanggal.
///
/// Menampilkan [tanggal] yang diformat dan [total] nominal transaksi
/// pada tanggal tersebut.
Widget bangunHeaderSeksi(final DateTime tanggal, final double total) {
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

/// Widget tile untuk menampilkan satu transaksi dalam daftar.
///
/// Menampilkan ikon, keterangan, kategori, dompet, jumlah, dan waktu.
/// Mendukung tap untuk melihat detail, long-press untuk edit/hapus.
class TransaksiTile extends StatefulWidget {
  /// Data transaksi yang ditampilkan.
  final TransactionModel transaksi;

  /// Callback saat data berubah (setelah edit/hapus).
  final VoidCallback onDataChanged;

  /// Operasi transaksi untuk aksi arsipkan.
  final TransaksiOperasi transaksiOperasi;

  /// Membuat tile transaksi.
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
    } on Exception {
      return 'Tidak ada kategori';
    }
  }

  Future<String> _getNamaDompet() async {
    try {
      final dompet = await _dompetOperasi.getDompetById(
        widget.transaksi.idDompet,
      );
      return dompet!.namaDompet;
    } on Exception {
      return 'Tidak ada dompet';
    }
  }

  Future<void> _arsipkanTransaksi() async {
    await widget.transaksiOperasi.arsipkanTransaksi(widget.transaksi.id);
    widget.onDataChanged();
  }

  @override
  Widget build(final BuildContext context) {
    IconData iconData;
    Color iconColor;
    if (widget.transaksi.tipe == TipeTransaksiEnum.pemasukan) {
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
          final result = await Navigator.push<bool>(
            // ✅ Explicit type
            context,
            MaterialPageRoute<bool>(
              // ✅ Explicit type
              builder: (final context) =>
                  DetailTransaksiPage(transaksi: widget.transaksi),
            ),
          );
          if (result ?? false) {
            widget.onDataChanged();
          }
        },
        onLongPress: () async {
          await showDialog<void>(
            // ✅ Explicit type
            context: context,
            builder: (final context) => AlertDialog(
              title: const Text('Opsi'),
              content: const Text(
                'Apa yang ingin Anda lakukan dengan transaksi ini?',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push<bool>(
                      // ✅ Explicit type
                      context,
                      MaterialPageRoute<bool>(
                        // ✅ Explicit type
                        builder: (final context) =>
                            FormTransaksiPage(transaksi: widget.transaksi),
                      ),
                    );
                    if (result ?? false) {
                      widget.onDataChanged();
                    }
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _arsipkanTransaksi();
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
          builder: (final context, final snapshot) {
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

/// Membangun widget [TransaksiTile] dengan parameter yang diberikan.
///
/// Fungsi convenience untuk membuat tile transaksi.
Widget bangunItemTransaksi(
  final BuildContext context,
  final TransactionModel transaksi,
  final VoidCallback onDataChanged,
  final TransaksiOperasi transaksiOperasi,
) {
  return TransaksiTile(
    transaksi: transaksi,
    onDataChanged: onDataChanged,
    transaksiOperasi: transaksiOperasi,
  );
}
