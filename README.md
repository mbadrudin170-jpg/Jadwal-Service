# Dokumentasi Fitur

## Fitur: transaksi

### Daftar file

- [lib/fitur/transaksi/enum/status_pembayaran.dart](./lib/fitur/transaksi/enum/status_pembayaran.dart)
- [lib/fitur/transaksi/enum/tipe_transaksi.dart](./lib/fitur/transaksi/enum/tipe_transaksi.dart)
- [lib/fitur/transaksi/helper/pengurut_transaksi.dart](./lib/fitur/transaksi/helper/pengurut_transaksi.dart)
- [lib/fitur/transaksi/model/transaksi_model.dart](./lib/fitur/transaksi/model/transaksi_model.dart)
- [lib/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart](./lib/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart)
- [lib/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart](./lib/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart)
- [lib/fitur/transaksi/operasi/transaksi_op_firebase.dart](./lib/fitur/transaksi/operasi/transaksi_op_firebase.dart)
- [lib/fitur/transaksi/operasi/transaksi_op_global.dart](./lib/fitur/transaksi/operasi/transaksi_op_global.dart)
- [lib/fitur/transaksi/operasi/transaksi_op_sqlite.dart](./lib/fitur/transaksi/operasi/transaksi_op_sqlite.dart)
- [lib/fitur/transaksi/page/detail_transaksi_a.dart](./lib/fitur/transaksi/page/detail_transaksi_a.dart)
- [lib/fitur/transaksi/page/detail_transaksi_u.dart](./lib/fitur/transaksi/page/detail_transaksi_u.dart)
- [lib/fitur/transaksi/page/form_transaksi.dart](./lib/fitur/transaksi/page/form_transaksi.dart)
- [lib/fitur/transaksi/page/transaksi_a.dart](./lib/fitur/transaksi/page/transaksi_a.dart)
- [lib/fitur/transaksi/page/transaksi_u.dart](./lib/fitur/transaksi/page/transaksi_u.dart)
- [lib/fitur/transaksi/provider/transaksi_provider_usang.dart](./lib/fitur/transaksi/provider/transaksi_provider_usang.dart)
- [lib/fitur/transaksi/transaksi_provider_usang.dart](./lib/fitur/transaksi/transaksi_provider_usang.dart)
- [lib/fitur/transaksi/widget/daftar_transaksi_widget.dart](./lib/fitur/transaksi/widget/daftar_transaksi_widget.dart)

### Isi file

#### File: `lib/fitur/transaksi/enum/status_pembayaran.dart`
```dart
// path: lib/fitur/transaksi/enum/status_pembayaran.dart

/// Enum untuk status pembayaran transaksi atau tagihan.
enum StatusPembayaran {
  /// Status lunas, pembayaran telah diselesaikan.
  paid,

  /// Status belum lunas, pembayaran masih tertunda.
  unpaid;

  /// Mengembalikan nama tampilan (display name) untuk setiap status pembayaran.
  String get displayName {
    switch (this) {
      case StatusPembayaran.paid:
        return 'Lunas';
      case StatusPembayaran.unpaid:
        return 'Belum Lunas';
    }
  }
}
```

#### File: `lib/fitur/transaksi/enum/tipe_transaksi.dart`
```dart
// path: lib/shared/enum/transaction_type_enum.dart
// diperbaiki: Menambahkan dokumentasi untuk getter.

/// Enum untuk tipe-tipe transaksi.
enum TipeTransaksi {
  /// Untuk transaksi pemasukan.
  income,

  /// Untuk transaksi pengeluaran.
  expense,

  /// Untuk transaksi transfer.
  transfer;

  /// Mendapatkan nama tampilan (display name) dari tipe transaksi.
  String get displayName {
    switch (this) {
      case TipeTransaksi.income:
        return 'Pemasukan';
      case TipeTransaksi.expense:
        return 'Pengeluaran';
      case TipeTransaksi.transfer:
        return 'Transfer';
    }
  }
}
```

#### File: `lib/fitur/transaksi/helper/pengurut_transaksi.dart`
```dart
// path lib/fitur/transaksi/helper/pengurut_transaksi.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';

part 'pengurut_transaksi.g.dart';

enum UrutanTransaksi {
  terbaru('Terbaru'),
  terlama('Terlama'),
  jumlahTerbesar('Jumlah Terbesar'),
  jumlahTerkecil('Jumlah Terkecil');

  const UrutanTransaksi(this.teks);
  final String teks;
}

@riverpod
class UrutanTransaksiState extends _$UrutanTransaksiState {
  @override
  UrutanTransaksi build() => UrutanTransaksi.terbaru;
  void ubahUrutan(UrutanTransaksi urutanBaru) => state = urutanBaru;
}

extension PengurutTransaksiX on List<TransaksiModel> {
  List<TransaksiModel> urutkan(UrutanTransaksi opsi) {
    final sorted = List<TransaksiModel>.from(this);
    switch (opsi) {
      case UrutanTransaksi.terbaru:
        sorted.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        break;
      case UrutanTransaksi.terlama:
        sorted.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        break;
      case UrutanTransaksi.jumlahTerbesar:
        sorted.sort((a, b) => b.jumlah.compareTo(a.jumlah));
        break;
      case UrutanTransaksi.jumlahTerkecil:
        sorted.sort((a, b) => a.jumlah.compareTo(b.jumlah));
        break;
    }
    return sorted;
  }
}

@riverpod
Future<List<TransaksiModel>> sortedTransaksi(Ref ref) async {
  final transaksiState = await ref.watch(operasiProviderProvider.future);
  final urutanAktif = ref.watch(urutanTransaksiStateProvider);
  return transaksiState.transaksi.urutkan(urutanAktif);
}
```

#### File: `lib/fitur/transaksi/model/transaksi_model.dart`
```dart
// path: lib/fitur/transaksi/model/transaksi_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'transaksi_model.freezed.dart';

@freezed
abstract class TransaksiModel with _$TransaksiModel implements HasId {
  const TransaksiModel._(); // Private constructor untuk method custom

  const factory TransaksiModel({
    required String id,
    required DateTime tanggal,
    required String deskripsi,
    required double jumlah,
    required TipeTransaksi tipe,
    required String idDompet,
    required String idKategori,
    String? idDompetTujuan,
    required String? idPelanggan,
    required String? idPaket,
    String? idSubKategori,
    @Default(StatusPembayaran.paid) StatusPembayaran statusPembayaran,
    @Default(0) int poinDidapat,
    @Default(0) int poinDigunakan,
    DateTime? diperbaruiPada,
    DateTime? diarsipkanPada,
    @Default(false) bool diHapus,
    int? durasiPaket,
    TipeDurasiPaket? tipeDurasiPaket,
    @Default(0) int durasiBonus,
    TipeDurasiPaket? tipeDurasiBonus,
    required DateTime? tanggalMulai,
    required DateTime? tanggalBerakhir,
    @Default(false) bool statusAktivasi,
  }) = _TransaksiModel;

  factory TransaksiModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Membuat TransaksiModel dari SQLite: ${map[NamaKolom.id]}');
    return TransaksiModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      tanggal:
          ParserUtil.parseDateTime(map[NamaKolom.tanggal]) ?? DateTime.now(),
      deskripsi: map[NamaKolom.deskripsi] as String? ?? '',
      jumlah: (map[NamaKolom.jumlah] as num? ?? 0).toDouble(),
      tipe:
          ParserUtil.safeParseEnum(TipeTransaksi.values, map[NamaKolom.tipe]) ??
          TipeTransaksi.expense,
      idDompet: map[NamaKolom.idDompet] as String? ?? '',
      idKategori: map[NamaKolom.idKategori] as String? ?? '',
      idDompetTujuan: map[NamaKolom.idDompetTujuan] as String?,
      idPelanggan: map[NamaKolom.idPelanggan] as String?,
      idPaket: map[NamaKolom.idPaket] as String?,
      idSubKategori: map[NamaKolom.idSubKategori] as String?,
      statusPembayaran:
          ParserUtil.safeParseEnum(
            StatusPembayaran.values,
            map[NamaKolom.statusPembayaran],
          ) ??
          StatusPembayaran.unpaid,
      poinDidapat: (map[NamaKolom.poinDidapat] as num? ?? 0).toInt(),
      poinDigunakan: (map[NamaKolom.poinDigunakan] as num? ?? 0).toInt(),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      durasiPaket: (map[NamaKolom.durasiPaket] as num?)?.toInt(),
      tipeDurasiPaket: ParserUtil.safeParseEnum(
        TipeDurasiPaket.values,
        map[NamaKolom.tipeDurasiPaket],
      ),
      durasiBonus: (map[NamaKolom.durasiBonus] as num? ?? 0).toInt(),
      tipeDurasiBonus: ParserUtil.safeParseEnum(
        TipeDurasiPaket.values,
        map[NamaKolom.tipeDurasiBonus],
      ),
      tanggalMulai: ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]),
      tanggalBerakhir: ParserUtil.parseDateTime(map[NamaKolom.tanggalBerakhir]),
      statusAktivasi: ParserUtil.parseBool(map[NamaKolom.statusAktivasi]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggal: tanggal.millisecondsSinceEpoch,
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.jumlah: jumlah,
      NamaKolom.tipe: tipe.name,
      NamaKolom.idDompet: idDompet,
      NamaKolom.idKategori: idKategori,
      NamaKolom.idDompetTujuan: idDompetTujuan,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.idSubKategori: idSubKategori,
      NamaKolom.statusPembayaran: statusPembayaran.name,
      NamaKolom.poinDidapat: poinDidapat,
      NamaKolom.poinDigunakan: poinDigunakan,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.durasiPaket: durasiPaket,
      NamaKolom.tipeDurasiPaket: tipeDurasiPaket?.name,
      NamaKolom.durasiBonus: durasiBonus,
      NamaKolom.tipeDurasiBonus: tipeDurasiBonus?.name,
      NamaKolom.tanggalMulai: tanggalMulai?.millisecondsSinceEpoch,
      NamaKolom.tanggalBerakhir: tanggalBerakhir?.millisecondsSinceEpoch,
      NamaKolom.statusAktivasi: statusAktivasi ? 1 : 0,
    };
  }

  factory TransaksiModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Membuat TransaksiModel dari Firebase: $id');
    return TransaksiModel(
      id: id,
      tanggal:
          ParserUtil.parseDateTime(data[NamaKolom.tanggal]) ?? DateTime.now(),
      deskripsi: data[NamaKolom.deskripsi] as String? ?? '',
      jumlah: (data[NamaKolom.jumlah] as num? ?? 0).toDouble(),
      tipe:
          ParserUtil.safeParseEnum(
            TipeTransaksi.values,
            data[NamaKolom.tipe],
          ) ??
          TipeTransaksi.expense,
      idDompet: data[NamaKolom.idDompet] as String? ?? '',
      idKategori: data[NamaKolom.idKategori] as String? ?? '',
      idDompetTujuan: data[NamaKolom.idDompetTujuan] as String?,
      idPelanggan: data[NamaKolom.idPelanggan] as String?,
      idPaket: data[NamaKolom.idPaket] as String?,
      idSubKategori: data[NamaKolom.idSubKategori] as String?,
      statusPembayaran:
          ParserUtil.safeParseEnum(
            StatusPembayaran.values,
            data[NamaKolom.statusPembayaran],
          ) ??
          StatusPembayaran.unpaid,
      poinDidapat: (data[NamaKolom.poinDidapat] as num? ?? 0).toInt(),
      poinDigunakan: (data[NamaKolom.poinDigunakan] as num? ?? 0).toInt(),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      durasiPaket: (data[NamaKolom.durasiPaket] as num?)?.toInt(),
      tipeDurasiPaket: ParserUtil.safeParseEnum(
        TipeDurasiPaket.values,
        data[NamaKolom.tipeDurasiPaket],
      ),
      durasiBonus: (data[NamaKolom.durasiBonus] as num? ?? 0).toInt(),
      tipeDurasiBonus: ParserUtil.safeParseEnum(
        TipeDurasiPaket.values,
        data[NamaKolom.tipeDurasiBonus],
      ),
      tanggalMulai: ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]),
      tanggalBerakhir: ParserUtil.parseDateTime(
        data[NamaKolom.tanggalBerakhir],
      ),
      statusAktivasi: ParserUtil.parseBool(data[NamaKolom.statusAktivasi]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggal: Timestamp.fromDate(tanggal.toUtc()),
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.jumlah: jumlah,
      NamaKolom.tipe: tipe.name,
      NamaKolom.idDompet: idDompet,
      NamaKolom.idKategori: idKategori,
      NamaKolom.idDompetTujuan: idDompetTujuan,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.idSubKategori: idSubKategori,
      NamaKolom.statusPembayaran: statusPembayaran.name,
      NamaKolom.poinDidapat: poinDidapat,
      NamaKolom.poinDigunakan: poinDigunakan,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
      NamaKolom.dihapus: diHapus,
      NamaKolom.durasiPaket: durasiPaket,
      NamaKolom.tipeDurasiPaket: tipeDurasiPaket?.name,
      NamaKolom.durasiBonus: durasiBonus,
      NamaKolom.tipeDurasiBonus: tipeDurasiBonus?.name,
      NamaKolom.tanggalMulai: tanggalMulai != null
          ? Timestamp.fromDate(tanggalMulai!.toUtc())
          : null,
      NamaKolom.tanggalBerakhir: tanggalBerakhir != null
          ? Timestamp.fromDate(tanggalBerakhir!.toUtc())
          : null,
      NamaKolom.statusAktivasi: statusAktivasi,
    };
  }
}
```

#### File: `lib/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart`
```dart
// path: lib/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'transaksi_op_provider.freezed.dart';
part 'transaksi_op_provider.g.dart';

@freezed
abstract class TransaksiNotifierState with _$TransaksiNotifierState {
  const factory TransaksiNotifierState({
    @Default([]) List<TransaksiModel> transaksi,
  }) = _TransaksiNotifierState;
}

@riverpod
class TransaksiOp extends _$TransaksiOp {
  TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);
  @override
  FutureOr<TransaksiNotifierState> build() async {
    final transaksi = await ref.read(transaksiOpGlobalProvider).ambilSemua();
    return TransaksiNotifierState(transaksi: transaksi);
  }

  Future<void> tambah(TransaksiModel transaksi) async {
    try {
      if (!state.hasValue) return;
      await _transaksiOp.tambahTransaksi(transaksi);
      final currentData = state.requireValue;
      state = AsyncData(
        currentData.copyWith(transaksi: [...currentData.transaksi, transaksi]),
      );
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(TransaksiModel transaksi) async {
    try {
      if (!state.hasValue) return;
      await _transaksiOp.perbaruiTransaksi(transaksi);
      final currentData = state.requireValue;
      final updatedList = currentData.transaksi.map((t) {
        return t.id == transaksi.id ? transaksi : t;
      }).toList();
      state = AsyncData(currentData.copyWith(transaksi: updatedList));
    } on Exception catch (e, s) {
      Log.error('Error perbarui: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> hapus(String idTransaksi) async {
    try {
      if (!state.hasValue) return;
      await _transaksiOp.softDelete(idTransaksi);
      final currentData = state.requireValue;
      final updatedList = currentData.transaksi
          .where((t) => t.id != idTransaksi)
          .toList();
      state = AsyncData(currentData.copyWith(transaksi: updatedList));
    } on Exception catch (e, s) {
      Log.error('Error hapus: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteAll() async {
    try {
      if (!state.hasValue) return;
      await _transaksiOp.softDeleteAll();
      final currentData = state.requireValue;
      state = AsyncData(currentData.copyWith(transaksi: []));
    } on Exception catch (e, s) {
      Log.error('Error hapus semua: $e', e: e, s: s);
      rethrow;
    }
  }

  void invalidate() {
    ref.invalidateSelf();
  }
}
```

#### File: `lib/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart`
```dart
// path: lib/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/shared/debug/log.dart';

part 'transaksi_provider.g.dart';
part 'transaksi_provider.freezed.dart';

class PaketTerlarisMentah {
  final String id;
  final int totalTerjual;
  const PaketTerlarisMentah(this.id, this.totalTerjual);
}

@freezed
abstract class TransaksiState with _$TransaksiState {
  const TransaksiState._();
  const factory TransaksiState({
    @Default(0.0) double totalPemasukan,
    @Default(0.0) double totalPengeluaran,
    @Default(0.0) double total,
    @Default(0) int totalPoinSemuaPelanggan,
    @Default([]) List<PaketTerlarisMentah> paketTerlaris,
    @Default([]) List<double> pendapatanHarian,
    @Default([]) List<double> pendapatanMingguan,
    @Default([]) List<double> pendapatanBulanan,
    @Default(0.0) double pendapatanBulanIni,
  }) = _TransaksiState;
}

@riverpod
class Transaksi extends _$Transaksi {
  @override
  FutureOr<TransaksiState> build() {
    return _loadData();
  }

  Future<TransaksiState> _loadData() async {
    try {
      final state = ref.watch(transaksiOpProvider).value;
      final list = state?.transaksi ?? [];
      final totalPemasukan = list
          .where(
            (t) =>
                t.tipe == TipeTransaksi.income &&
                t.statusPembayaran == StatusPembayaran.paid,
          )
          .fold(0.0, (sum, t) => sum + t.jumlah);
      final totalPengeluaran = list
          .where((t) => t.tipe == TipeTransaksi.expense)
          .fold(0.0, (sum, t) => sum + t.jumlah);
      final total = totalPemasukan - totalPengeluaran;
      final totalPoinSemuaPelanggan = list.fold<int>(
        0,
        (sum, t) => sum + (t.poinDidapat - t.poinDigunakan),
      );
      final paketTerlaris = _hitungPaketTerlaris(list);
      final pendapatanHarian = _hitungPendapatanHarian(list);
      final pendapatanMingguan = _hitungPendapatanMingguan(list);
      final pendapatanBulanan = _hitungPendapatanBulanan(list);
      final pendapatanBulanIni = _hitungPendapatanBulanIni(list);
      return TransaksiState(
        totalPemasukan: totalPemasukan,
        totalPengeluaran: totalPengeluaran,
        total: total,
        totalPoinSemuaPelanggan: totalPoinSemuaPelanggan,
        paketTerlaris: paketTerlaris,
        pendapatanHarian: pendapatanHarian,
        pendapatanMingguan: pendapatanMingguan,
        pendapatanBulanan: pendapatanBulanan,
        pendapatanBulanIni: pendapatanBulanIni,
      );
    } on Exception catch (e, s) {
      Log.error('Error di Load_loadData(: $e', e: e, s: s);
      rethrow;
    }
  }

  // --- HELPER METODE UNTUK MEMPROSES GRAFIK & STATISTIK ---

  List<PaketTerlarisMentah> _hitungPaketTerlaris(List<TransaksiModel> list) {
    final jumlahPerPaket = <String, int>{};
    for (final t in list) {
      if (t.idPaket != null && t.statusPembayaran == StatusPembayaran.paid) {
        jumlahPerPaket[t.idPaket!] = (jumlahPerPaket[t.idPaket!] ?? 0) + 1;
      }
    }
    final sortedEntries = jumlahPerPaket.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries
        .take(5)
        .map((e) => PaketTerlarisMentah(e.key, e.value))
        .toList();
  }

  List<double> _hitungPendapatanHarian(List<TransaksiModel> list) {
    final hasil = List<double>.filled(7, 0.0);
    final sekarang = DateTime.now();
    for (var i = 0; i < 7; i++) {
      final targetTanggal = sekarang.subtract(Duration(days: i));
      final totalHariItu = list
          .where(
            (t) =>
                t.tipe == TipeTransaksi.income &&
                t.statusPembayaran == StatusPembayaran.paid &&
                t.tanggal.day == targetTanggal.day &&
                t.tanggal.month == targetTanggal.month &&
                t.tanggal.year == targetTanggal.year,
          )
          .fold(0.0, (sum, t) => sum + t.jumlah);
      hasil[6 - i] = totalHariItu;
    }
    return hasil;
  }

  List<double> _hitungPendapatanMingguan(List<TransaksiModel> list) {
    final hasil = List<double>.filled(4, 0.0);
    final sekarang = DateTime.now();

    for (var i = 0; i < 4; i++) {
      final batasBawah = sekarang.subtract(Duration(days: (i + 1) * 7));
      final batasAtas = sekarang.subtract(Duration(days: i * 7));

      final totalMingguItu = list
          .where((t) {
            if (t.tipe != TipeTransaksi.income ||
                t.statusPembayaran != StatusPembayaran.paid) {
              return false;
            }
            return t.tanggal.isAfter(batasBawah) &&
                t.tanggal.isBefore(batasAtas.add(const Duration(days: 1)));
          })
          .fold(0.0, (sum, t) => sum + t.jumlah);

      hasil[3 - i] = totalMingguItu;
    }
    return hasil;
  }

  List<double> _hitungPendapatanBulanan(List<TransaksiModel> list) {
    final hasil = List<double>.filled(5, 0.0);
    final sekarang = DateTime.now();
    for (var i = 0; i < 5; i++) {
      var targetBulan = sekarang.month - i;
      var targetTahun = sekarang.year;

      while (targetBulan <= 0) {
        targetBulan += 12;
        targetTahun -= 1;
      }
      final totalBulanItu = list
          .where(
            (t) =>
                t.tipe == TipeTransaksi.income &&
                t.statusPembayaran == StatusPembayaran.paid &&
                t.tanggal.month == targetBulan &&
                t.tanggal.year == targetTahun,
          )
          .fold(0.0, (sum, t) => sum + t.jumlah);
      hasil[4 - i] = totalBulanItu;
    }
    return hasil;
  }

  double _hitungPendapatanBulanIni(List<TransaksiModel> list) {
    final sekarang = DateTime.now();
    return list
        .where(
          (t) =>
              t.tipe == TipeTransaksi.income &&
              t.statusPembayaran == StatusPembayaran.paid &&
              t.tanggal.month == sekarang.month &&
              t.tanggal.year == sekarang.year,
        )
        .fold(0.0, (sum, t) => sum + t.jumlah);
  }

  Future<({List<TransaksiModel> transaksi, int totalPoin})>
  riwayatTransaksiPelanggan(String idPelanggan) async {
    Log.info(
      '[RiwayatTransaksi] 🔍 Mengambil riwayat transaksi untuk pelanggan: $idPelanggan',
    );
    try {
      // Dapatkan state terbaru dari TransaksiOp (AsyncNotifier)
      final notifierState = await ref.watch(transaksiOpProvider.future);

      // Filter transaksi yang dimiliki pelanggan ini
      final semuaTransaksi = notifierState.transaksi
          .where((t) => t.idPelanggan == idPelanggan)
          .toList();
      final totalPoinUser = semuaTransaksi
          .where((t) => t.statusPembayaran == StatusPembayaran.paid)
          .fold<int>(0, (sum, t) => sum + (t.poinDidapat - t.poinDigunakan));
      return (transaksi: semuaTransaksi, totalPoin: totalPoinUser);
    } catch (e, s) {
      Log.error('[RiwayatTransaksi] ❌ ERROR: $e', e: e, s: s);
      rethrow;
    }
  }
}
```

#### File: `lib/fitur/transaksi/operasi/transaksi_op_firebase.dart`
```dart
// path: lib/fitur/transaksi/operasi/transaksi_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class TransaksiOpFirebase extends BaseOpFirebase {
  TransaksiOpFirebase({super.firestore}) {
    Log.info('TransactionOpFirebase diinisialisasi.');
  }
  CollectionReference get _koleksi => firestore.collection(NamaTabel.transaksi);

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    Log.info('Menambahkan transaksi baru: ${transaksi.id}');
    try {
      await sisipkan(NamaTabel.transaksi, transaksi.id, transaksi.toFirebase());
      Log.info('Berhasil menambahkan transaksi: ${transaksi.id}');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menambahkan transaksi: ${transaksi.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui seluruh data transaksi (merge) berdasarkan objek TransaksiModel.
  /// Jika Anda ingin hanya memperbarui beberapa field, gunakan updateTransaksiFields.
  Future<void> perbaruiTransaksi(TransaksiModel transaksi) async {
    Log.info('Memulai update transaksi di Firestore: ${transaksi.id}');
    try {
      final docRef = _koleksi.doc(transaksi.id);
      final data = transaksi.toFirebase();
      // set merge agar tidak menimpa seluruh dokumen jika ada field server-side lain
      data[NamaKolom.diperbaruiPada] = FieldValue.serverTimestamp();
      await docRef.set(data, SetOptions(merge: true));
      Log.info('Update transaksi berhasil: ${transaksi.id}');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal mengupdate transaksi: ${transaksi.id}', e: e, s: s);
      rethrow;
    } on Exception catch (e, s) {
      Log.error(
        'Error umum saat mengupdate transaksi: ${transaksi.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  Future<TransaksiModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mendapatkan transaksi by ID: $id');
    try {
      final doc = await _koleksi.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return TransaksiModel.fromFirebase(doc.id, data);
        }
        return null;
      }
      return null;
    } catch (e, st) {
      Log.error(
        'Error mendapatkan transaksi by ID',
        e: e,
        s: st,
        data: {'transactionId': id},
      );
      return null;
    }
  }

  /// Mengambil semua transaksi yang merupakan aktivasi paket dari Firebase.
  Future<List<TransaksiModel>> ambilBerdasarkanStatusAktivasi() async {
    try {
      Log.info(
        'Mengambil transaksi dengan status aktivasi = true dari Firebase',
      );
      final querySnapshot = await _koleksi
          .where(NamaKolom.statusAktivasi, isEqualTo: true)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      Log.info(
        'Berhasil mengambil ${querySnapshot.docs.length} transaksi aktivasi paket dari Firebase',
      );
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransaksiModel.fromFirebase(doc.id, data);
      }).toList();
    } on FirebaseException catch (e, st) {
      Log.error(
        'Error saat mengambil transaksi aktivasi paket dari Firebase',
        e: e,
        s: st,
      );
      return [];
    } on Exception catch (e, st) {
      Log.error(
        'Error umum saat mengambil transaksi aktivasi paket dari Firebase',
        e: e,
        s: st,
      );
      return [];
    }
  }

  Future<TransaksiModel?> ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info(
        'Mencari transaksi lunas terbaru dari Firebase untuk pengguna ID: $idPelanggan',
      );
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(
            NamaKolom.statusPembayaran,
            isEqualTo: StatusPembayaran.paid.name,
          )
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggalBerakhir, descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Log.warning(
          'Tidak ada transaksi lunas yang aktif dari Firebase untuk pengguna ID: $idPelanggan',
        );
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      Log.info(
        'Transaksi lunas terbaru dari Firebase ditemukan untuk pengguna ID: $idPelanggan',
      );
      return TransaksiModel.fromFirebase(doc.id, data);
    } on Exception catch (e, s) {
      Log.error(
        'Error mengambil transaksi lunas terbaru dari Firebase untuk pengguna ID: $idPelanggan',
        e: e,
        s: s,
      );
      return null;
    }
  }

  Future<List<TransaksiModel>> ambilBelumLunasBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      final querySnapshot = await _koleksi
          .where(
            NamaKolom.statusPembayaran,
            isEqualTo: StatusPembayaran.unpaid.name,
          )
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      // jika query tidak cocok atau daftar kosong kembalikan daftar kosong
      if (querySnapshot.docs.isEmpty) {
        Log.info('Tidak ada paket aktif yang ditemukan untuk: $idPelanggan');
        return [];
      }
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransaksiModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('terjadi error saat pengambilan dftar belum lunas', e: e, s: s);
      return [];
    }
  }

  /// Mengambil semua transaksi untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info('Mengambil semua transaksi untuk: $idPelanggan');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      Log.info('Menemukan ${querySnapshot.docs.length} transaksi.');
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransaksiModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil transaksi: $e', e: e, s: s);
      return [];
    }
  }

  /// Mengambil semua transaksi yang terkait dengan sebuah dompet (baik sebagai sumber maupun tujuan).
  Future<List<TransaksiModel>> ambilBerdasarkanIdDompet(String idDompet) async {
    try {
      Log.info('Mengambil transaksi terkait Wallet ID: $idDompet');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idDompet, isEqualTo: idDompet)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      final querySnapshotTujuan = await _koleksi
          .where(NamaKolom.idDompetTujuan, isEqualTo: idDompet)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      final hasil = <TransaksiModel>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        hasil.add(TransaksiModel.fromFirebase(doc.id, data));
      }
      for (final doc in querySnapshotTujuan.docs) {
        final data = doc.data() as Map<String, dynamic>;
        hasil.add(TransaksiModel.fromFirebase(doc.id, data));
      }
      hasil.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      Log.info(
        'Berhasil mengambil ${hasil.length} transaksi untuk Wallet ID: $idDompet',
      );
      return hasil;
    } on Exception catch (e, s) {
      Log.error(
        'Error mengambil transaksi berdasarkan ID dompet: $idDompet',
        e: e,
        s: s,
      );
      return [];
    }
  }

  Future<int> ambilTotalPoin(String idPelanggan) async {
    try {
      Log.info('Menghitung total poin untuk: $idPelanggan');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .where(
            NamaKolom.statusPembayaran,
            isEqualTo: StatusPembayaran.paid.name,
          )
          .get();
      var totalPoin = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalPoin += (data[NamaKolom.poinDidapat] as int? ?? 0);
        totalPoin -= (data[NamaKolom.poinDigunakan] as int? ?? 0);
      }
      Log.info('Total poin untuk $idPelanggan adalah $totalPoin');
      return totalPoin;
    } on Exception catch (e, s) {
      Log.error('Error menghitung total poin: $e', e: e, s: s);
      return 0;
    }
  }

  /// Melakukan soft delete pada transaksi di Firestore.
  Future<void> softDeleteTransaksi(String id) async {
    Log.info('Memulai soft delete transaksi di Firestore: $id');
    try {
      await softDelete(NamaTabel.transaksi, id);
      Log.info('Soft delete transaksi berhasil: $id');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan soft delete transaksi: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil daftar paket aktif (transaksi yang belum kedaluwarsa)
  /// untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilPaketAktifPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info('Mulai mengambil paket aktif untuk pelanggan: $idPelanggan');
      // Ambil waktu saat ini
      final now = DateTime.now();

      final querySnapshot = await _koleksi
          // 1. Cari transaksi milik pelanggan yang benar
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          // 2. Pastikan transaksi tidak dihapus
          .where(NamaKolom.dihapus, isEqualTo: false)
          // 3. Filter utama: endDate harus lebih besar dari waktu sekarang
          .where(NamaKolom.tanggalBerakhir, isGreaterThan: now)
          .get();

      // Jika tidak ada dokumen yang cocok, kembalikan list kosong
      if (querySnapshot.docs.isEmpty) {
        Log.info('Tidak ada paket aktif yang ditemukan untuk: $idPelanggan');
        return [];
      }

      // Ubah setiap dokumen menjadi objek TransactionModel
      final daftarPaketAktif = querySnapshot.docs.map((doc) {
        return TransaksiModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      Log.info(
        '${daftarPaketAktif.length} paket aktif ditemukan untuk: $idPelanggan',
      );
      return daftarPaketAktif;
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengambil paket aktif untuk pelanggan $idPelanggan: $e',
        e: e,
        s: s,
      );
      // Kembalikan list kosong jika terjadi error agar aplikasi tidak crash
      return [];
    }
  }

  /// Menyisipkan atau memperbarui beberapa transaksi sekaligus (batch) di Firestore.
  ///
  /// [items] adalah daftar [TransaksiModel] yang akan disisipkan atau diperbarui.
  /// Fungsi ini menggunakan batch write untuk efisiensi dan atomisitas.
  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    if (items.isEmpty) {
      Log.info('Batch transaksi: daftar kosong, operasi dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${items.length} transaksi di Firestore',
    );

    try {
      final batch = firestore.batch();
      for (final transaksi in items) {
        final docRef = _koleksi.doc(transaksi.id);
        final data = transaksi.toFirebase();
        data[NamaKolom.diperbaruiPada] = FieldValue.serverTimestamp();
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      Log.info(
        'Batch ${items.length} transaksi berhasil diproses di Firestore',
      );
    } on FirebaseException catch (e, st) {
      Log.error(
        'Gagal memproses batch transaksi di Firestore',
        e: e,
        s: st,
        data: {'jumlahItem': items.length},
      );
      rethrow;
    } on Exception catch (e, st) {
      Log.error(
        'Error umum saat memproses batch transaksi di Firestore',
        e: e,
        s: st,
        data: {'jumlahItem': items.length},
      );
      rethrow;
    }
  }
}
```

#### File: `lib/fitur/transaksi/operasi/transaksi_op_global.dart`
```dart
// path: lib/fitur/transaksi/operasi/transaksi_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/user/providers/user_provider.dart';

class TransaksiOpGlobal {
  final Ref ref;
  TransaksiOpGlobal({required this.ref});

  TransaksiOpSqlite get _transaksiOpSqlite =>
      ref.read(transaksiOpSqliteProvider);
  TransaksiOpFirebase get _transaksiOpFirebase =>
      ref.read(transaksiOpFirebaseProvider);

  void invalidate(String? idDompet) {
    ref.read(dompetProvider.notifier).invalidateDompetProvider(idDompet);
  }

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    Log.info('Menambahkan transaksi baru: ${transaksi.id}');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.tambahTransaksi(transaksi);
    } else {
      await _transaksiOpFirebase.tambahTransaksi(transaksi);
    }
    invalidate(null);
  }

  Future<void> perbaruiTransaksi(
    TransaksiModel transaksi, {
    bool dariServer = false,
  }) async {
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.perbaruiTransaksi(
        transaksi,
        dariServer: dariServer,
      );
    } else {
      await _transaksiOpFirebase.perbaruiTransaksi(transaksi);
    }
    invalidate(null);
  }

  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Menghapus transaksi ID: $id');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.softDelete(id, dariServer: dariServer);
    } else {
      await _transaksiOpFirebase.softDeleteTransaksi(id);
    }
    invalidate(null);
  }

  Future<void> softDeleteAll({bool dariServer = false}) async {
    Log.info('Menghapus semua transaksi');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.softDeleteAll(dariServer: dariServer);
    } else {
      final userId = await ref.read(userIdProvider.future);
      if (userId == null || userId.isEmpty) {
        Log.warning('User ID tidak ditemukan, tidak ada yang dihapus');
        return;
      }
      final transaksi = await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        userId,
      );
      for (final t in transaksi) {
        await _transaksiOpFirebase.softDeleteTransaksi(t.id);
      }
    }
    invalidate(null);
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<TransaksiModel> items, {
    bool dariServer = false,
  }) async {
    if (items.isEmpty) {
      Log.info('Batch transaksi: daftar kosong, operasi dibatalkan.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${items.length} transaksi');
    if (RoleUtil.isAdmin(ref)) {
      await _transaksiOpSqlite.sisipkanAtauPerbaruiBatch(
        items,
        dariServer: dariServer,
      );
    } else {
      await _transaksiOpFirebase.sisipkanAtauPerbaruiBatch(items);
    }
    invalidate(null);
  }

  Future<List<TransaksiModel>> ambilSemua() async {
    Log.info('Mengambil semua transaksi berdasarkan role');
    if (RoleUtil.isAdmin(ref)) {
      Log.info('Mode Admin: Mengambil transaksi dari SQLite');
      return await _transaksiOpSqlite.ambilSemua();
    } else {
      Log.info('Mode User: Mengambil transaksi dari Firebase');
      final userId = await ref.read(userIdProvider.future);
      if (userId == null || userId.isEmpty) {
        Log.warning('User ID tidak ditemukan, mengembalikan list kosong');
        return [];
      }
      return await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(userId);
    }
  }

  Future<TransaksiModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mengambil transaksi berdasarkan ID: $id');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanId(id);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanId(id);
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    Log.info('[TransaksiOpGlobal] ambilBerdasarkanIdPelanggan: $idPelanggan');
    if (RoleUtil.isAdmin(ref)) {
      Log.info('[TransaksiOpGlobal] Admin → SQLite');
      return await _transaksiOpSqlite.ambilBerdasarkanIdPelanggan(idPelanggan);
    } else {
      Log.info('[TransaksiOpGlobal] User → Firebase');
      return await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        idPelanggan,
      );
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanIdDompet(String idDompet) async {
    Log.info('Mengambil transaksi berdasarkan ID dompet: $idDompet');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIdDompet(idDompet);
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanIdDompet(idDompet);
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanStatusAktivasi() async {
    Log.info('Mengambil transaksi dengan status aktivasi = true');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanStatusAktivasi();
    } else {
      return await _transaksiOpFirebase.ambilBerdasarkanStatusAktivasi();
    }
  }

  Future<List<TransaksiModel>> ambilBerdasarkanIds(List<String> ids) async {
    Log.info('Mengambil transaksi berdasarkan ${ids.length} ID');
    if (ids.isEmpty) {
      Log.warning('Daftar ID kosong, mengembalikan list kosong');
      return [];
    }
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilBerdasarkanIds(ids);
    } else {
      final hasil = <TransaksiModel>[];
      for (final id in ids) {
        final transaksi = await _transaksiOpFirebase.ambilBerdasarkanId(id);
        if (transaksi != null) {
          hasil.add(transaksi);
        }
      }
      return hasil;
    }
  }

  Future<List<TransaksiModel>> ambilPaketAktifPelanggan(
    String idPelanggan,
  ) async {
    Log.info('Mengambil paket aktif untuk pelanggan: $idPelanggan');
    if (RoleUtil.isAdmin(ref)) {
      final semuaTransaksi = await _transaksiOpSqlite
          .ambilBerdasarkanIdPelanggan(idPelanggan);
      final sekarang = DateTime.now();
      return semuaTransaksi
          .where(
            (t) =>
                t.tanggalBerakhir != null &&
                t.tanggalBerakhir!.isAfter(sekarang) &&
                t.statusPembayaran.name == 'paid',
          )
          .toList();
    } else {
      return await _transaksiOpFirebase.ambilPaketAktifPelanggan(idPelanggan);
    }
  }

  Future<int> ambilTotalPoin(String idPelanggan) async {
    Log.info('Mengambil total poin untuk pelanggan: $idPelanggan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPoin(idPelanggan);
    } else {
      return await _transaksiOpFirebase.ambilTotalPoin(idPelanggan);
    }
  }

  Future<double> ambilTotalPemasukan() async {
    Log.info('Menghitung total pemasukan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPemasukan();
    } else {
      return 0;
    }
  }

  Future<double> ambilTotalPengeluaran() async {
    Log.info('Menghitung total pengeluaran');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPengeluaran();
    } else {
      return 0;
    }
  }

  Future<double> getNetTotal() async {
    Log.info('Menghitung total bersih');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.getNetTotal();
    } else {
      final income = await ambilTotalPemasukan();
      final expense = await ambilTotalPengeluaran();
      return income - expense;
    }
  }

  Future<double> ambilTotalPendapatanPerbulan() async {
    Log.info('Mengambil total pendapatan bersih per bulan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPendapatanPerbulan();
    } else {
      return 0;
    }
  }

  // Future<List<PaketTerlarisModel>> ambilPaketTerlaris({int limit = 5}) async {
  //   Log.info('Mengambil paket terlaris, limit: $limit');
  //   if (RoleUtil.isAdmin(ref)) {
  //     return await _transaksiOpSqlite.ambilPaketTerlaris(limit: limit);
  //   } else {
  //     return [];
  //   }
  // }

  Future<List<double>> ambilPendapatanHarian() async {
    Log.info('Mengambil pendapatan harian 7 hari terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanHarian();
    } else {
      return [];
    }
  }

  Future<List<double>> ambilPendapatanMingguan() async {
    Log.info('Mengambil pendapatan mingguan 4 minggu terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanMingguan();
    } else {
      return [];
    }
  }

  Future<List<double>> ambilPendapatanBulanan() async {
    Log.info('Mengambil pendapatan bulanan 5 bulan terakhir');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilPendapatanBulanan();
    } else {
      return [];
    }
  }

  Future<int> ambilTotalPoinSemuaPelanggan() async {
    Log.info('Menghitung total poin semua pelanggan');
    if (RoleUtil.isAdmin(ref)) {
      return await _transaksiOpSqlite.ambilTotalPoinSemuaPelanggan();
    } else {
      return 0;
    }
  }
}

final transaksiOpGlobalProvider = Provider<TransaksiOpGlobal>((ref) {
  return TransaksiOpGlobal(ref: ref);
});
```

#### File: `lib/fitur/transaksi/operasi/transaksi_op_sqlite.dart`
```dart
// path: lib/fitur/transaksi/operasi/transaksi_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data transaksi di database lokal.
class TransaksiOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite baseOpSqlite;
  final PaketOpSqlite paketOpsqlite;

  final String _tabelTransaksi = NamaTabel.transaksi;
  DateTime get _nowUtc => DateTime.now().toUtc();

  TransaksiOpSqlite({
    required this.sqliteDb,
    required this.baseOpSqlite,
    required this.paketOpsqlite,
  });

  /// Menghitung ulang saldo dompet berdasarkan semua transaksi terkait dan memperbaruinya.
  /// Operasi ini harus dijalankan di dalam sebuah transaksi database [txn].
  Future<void> _hitungUlangDanPerbaruiSaldoDompet(
    final String idDompet,
    final DatabaseExecutor txn,
  ) async {
    try {
      Log.info('Memulai hitung ulang saldo untuk Wallet ID: $idDompet');
      final hasilTotal = await txn.rawQuery(
        '''
        SELECT
          COALESCE(SUM(
            CASE
              WHEN ${NamaKolom.tipe} = 'income'
                AND ${NamaKolom.idDompet} = ?
              THEN ${NamaKolom.jumlah}

              WHEN ${NamaKolom.tipe} = 'expense'
                AND ${NamaKolom.idDompet} = ?
              THEN -${NamaKolom.jumlah}

              WHEN ${NamaKolom.tipe} = 'transfer'
                AND ${NamaKolom.idDompet} = ?
              THEN -${NamaKolom.jumlah}

              WHEN ${NamaKolom.tipe} = 'transfer'
                AND ${NamaKolom.idDompetTujuan} = ?
              THEN ${NamaKolom.jumlah}

              ELSE 0
            END
          ), 0) as total
        FROM $_tabelTransaksi
        WHERE ${NamaKolom.dihapus} = 0 AND (${NamaKolom.idDompet} = ? OR ${NamaKolom.idDompetTujuan} = ?)
        ''',
        [idDompet, idDompet, idDompet, idDompet, idDompet, idDompet],
      );
      final saldoTotal = (hasilTotal.first['total'] as num?)?.toDouble() ?? 0.0;
      final dompetMaps = await txn.query(
        NamaTabel.dompet,
        where: '${NamaKolom.id} = ?',
        whereArgs: [idDompet],
      );
      if (dompetMaps.isEmpty) {
        Log.warning('Dompet ID: $idDompet tidak ditemukan');
        return;
      }
      final dompetLama = DompetModel.fromSqlite(dompetMaps.first);
      final dompetBaru = dompetLama.copyWith(
        saldo: saldoTotal,
        diperbaruiPada: _nowUtc, // ← Gunakan DateTime
      );
      await txn.update(
        NamaTabel.dompet,
        dompetBaru.toSqlite(),
        where: '${NamaKolom.id} = ?',
        whereArgs: [idDompet],
      );

      Log.info(
        'Berhasil update saldo Wallet ID: $idDompet menjadi $saldoTotal',
      );
    } on Exception catch (e, st) {
      Log.error('Gagal hitung ulang saldo Wallet ID: $idDompet', e: e, s: st);
      rethrow;
    }
  }

  /// Menambahkan transaksi baru ke database dan memperbarui saldo dompet terkait.
  Future<int> tambahTransaksi(
    final TransaksiModel transaction, {
    final bool fromServer = false,
  }) async {
    try {
      final id = await baseOpSqlite.operasiKompleks<int>((txn) async {
        Log.info('Memulai transaksi database untuk addTransaction');
        final data = transaction.copyWith(diperbaruiPada: _nowUtc);

        final newId = await txn.insert(
          _tabelTransaksi,
          data.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        Log.info(
          'Data transaksi berhasil masuk ke tabel dengan row ID: $newId',
        );

        await _hitungUlangDanPerbaruiSaldoDompet(data.idDompet, txn);
        if (data.tipe == TipeTransaksi.transfer &&
            data.idDompetTujuan != null) {
          Log.info(
            'Deteksi transaksi transfer, menghitung saldo wallet tujuan',
          );
          await _hitungUlangDanPerbaruiSaldoDompet(data.idDompetTujuan!, txn);
        }
        return newId;
      }, dariServer: fromServer);
      Log.info('Proses addTransaction ID: ${transaction.id} berhasil');
      return id;
    } on Exception catch (e, st) {
      Log.error('Gagal menambah transaksi ID: ${transaction.id}', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua transaksi yang tidak dihapus dari database.
  Future<List<TransaksiModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    try {
      Log.info('Mengambil data semua transaksi dari SQLite');
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelTransaksi,
        where: query,
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} data transaksi dari SQLite');
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, st) {
      Log.error('Gagal mengambil semua transaksi', e: e, s: st);
      return [];
    }
  }

  /// Memperbarui data transaksi yang ada dan menghitung ulang saldo dompet yang terpengaruh.
  Future<void> perbaruiTransaksi(
    TransaksiModel transaksi, {
    bool dariServer = false,
  }) async {
    try {
      await baseOpSqlite.operasiKompleks<void>((txn) async {
        Log.info('Memulai update transaksi database ID: $transaksi.id');
        final maps = await txn.query(
          _tabelTransaksi,
          where: '${NamaKolom.id} = ?',
          whereArgs: [transaksi.id],
        );

        if (maps.isNotEmpty) {
          final transaksiLama = TransaksiModel.fromSqlite(maps.first);
          final updateData = transaksi.copyWith(diperbaruiPada: _nowUtc);
          await txn.update(
            _tabelTransaksi,
            updateData.toSqlite(),
            where: '${NamaKolom.id} = ?',
            whereArgs: [transaksi.id],
          );
          Log.info('Data transaksi $transaksiLama ke  $updateData diperbarui');
          final dompetTerpengaruh = <String>{};
          dompetTerpengaruh.add(transaksiLama.idDompet);
          dompetTerpengaruh.add(updateData.idDompet);
          if (transaksiLama.idDompetTujuan != null) {
            dompetTerpengaruh.add(transaksiLama.idDompetTujuan!);
          }
          if (updateData.idDompetTujuan != null) {
            dompetTerpengaruh.add(updateData.idDompetTujuan!);
          }

          Log.info(
            'Mengupdate saldo untuk wallet yang terpengaruh: $dompetTerpengaruh',
          );
          for (final idDompet in dompetTerpengaruh) {
            await _hitungUlangDanPerbaruiSaldoDompet(idDompet, txn);
          }
        } else {
          Log.warning(
            'Update gagal: Transaksi ID $transaksi.id tidak ditemukan',
          );
        }
      }, dariServer: dariServer);
      Log.info('Proses updateTransaction ID: $transaksi.id selesai');
    } on Exception catch (e, st) {
      Log.error('Gagal update transaksi ID: $transaksi.id', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil satu transaksi berdasarkan ID-nya.
  Future<TransaksiModel?> ambilBerdasarkanId(String id) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Mencari transaksi berdasarkan ID: $id');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelTransaksi,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        Log.warning('Transaksi dengan ID: $id tidak ditemukan');
        return null;
      }
      Log.info('Transaksi ID: $id ditemukan');
      return TransaksiModel.fromSqlite(maps.first);
    } catch (e, st) {
      Log.error('Gagal mengambil transaksi ID: $id', e: e, s: st);
      return null;
    }
  }

  /// Mengambil semua transaksi untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Mengambil transaksi untuk Customer ID: $idPelanggan');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelTransaksi,
        where: '${NamaKolom.idPelanggan} = ? AND ${NamaKolom.dihapus} = ?',
        whereArgs: [idPelanggan, 0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info(
        'Ditemukan ${maps.length} transaksi untuk Customer ID: $idPelanggan',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, st) {
      Log.error('Error ambil transaksi customer', e: e, s: st);
      return [];
    }
  }

  /// Mengambil semua transaksi yang terkait dengan sebuah dompet (baik sebagai sumber maupun tujuan).
  Future<List<TransaksiModel>> ambilBerdasarkanIdDompet(
    final String idDompet,
  ) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Mengambil transaksi terkait Wallet ID: $idDompet');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelTransaksi,
        where:
            '(${NamaKolom.idDompet} = ? OR ${NamaKolom.idDompetTujuan} = ?) AND ${NamaKolom.dihapus} = ?',
        whereArgs: [idDompet, idDompet, 0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Ditemukan ${maps.length} transaksi untuk Wallet ID: $idDompet');
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error ambil transaksi wallet', e: e, s: st);
      return [];
    }
  }

  /// Mengambil semua transaksi yang merupakan aktivasi paket.
  Future<List<TransaksiModel>> ambilBerdasarkanStatusAktivasi() async {
    try {
      final db = await sqliteDb.database;
      Log.info('Mengambil transaksi dengan status isActivated = 1');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelTransaksi,
        where: '${NamaKolom.statusAktivasi} = ? AND ${NamaKolom.dihapus} = ?',
        whereArgs: [1, 0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} transaksi aktivasi paket');
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error saat mengambil transaksi aktivasi paket', e: e, s: st);
      return [];
    }
  }

  /// Menandai transaksi sebagai dihapus (soft delete) dan menghitung ulang saldo dompet.
  Future<void> softDelete(String id, {bool dariServer = false}) async {
    try {
      await baseOpSqlite.operasiKompleks<void>((txn) async {
        Log.info('Memulai soft delete atomik untuk ID: $id');
        final maps = await txn.query(
          _tabelTransaksi,
          where: '${NamaKolom.id} = ?',
          whereArgs: [id],
        );

        if (maps.isEmpty) {
          Log.warning('Soft delete gagal: Transaksi ID $id tidak ditemukan');
          return;
        }

        final transaksiLama = TransaksiModel.fromSqlite(maps.first);
        final transaksiDiarsip = transaksiLama.copyWith(
          diHapus: true,
          diperbaruiPada: _nowUtc,
          diarsipkanPada: _nowUtc,
        );
        await txn.update(
          _tabelTransaksi,
          transaksiDiarsip.toSqlite(),
          where: '${NamaKolom.id} = ?',
          whereArgs: [id],
        );
        Log.info('Flag isDeleted diatur ke 1 untuk ID: $id');

        await _hitungUlangDanPerbaruiSaldoDompet(transaksiLama.idDompet, txn);
        if (transaksiLama.tipe == TipeTransaksi.transfer &&
            transaksiLama.idDompetTujuan != null) {
          await _hitungUlangDanPerbaruiSaldoDompet(
            transaksiLama.idDompetTujuan!,
            txn,
          );
        }
      }, dariServer: dariServer);
      Log.info('Transaksi ID: $id berhasil diarsipkan secara atomik');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan transaksi ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Menandai semua transaksi sebagai dihapus dan mereset saldo semua dompet menjadi 0.
  Future<int> softDeleteAll({bool dariServer = false}) async {
    try {
      final count = await baseOpSqlite.operasiKompleks<int>((final txn) async {
        Log.warning('Memulai soft delete semua transaksi secara atomik');

        final rowsAffected = await txn.update(
          _tabelTransaksi,
          {
            NamaKolom.dihapus: 1,
            NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
            NamaKolom.diarsipkanPada: _nowUtc.millisecondsSinceEpoch,
          },
          where: '${NamaKolom.dihapus} = ?',
          whereArgs: [0],
        );
        Log.info('$rowsAffected transaksi telah ditandai sebagai dihapus');

        await txn.update(NamaTabel.dompet, {
          NamaKolom.saldo: 0,
          NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
        });
        Log.info('Semua saldo dompet direset ke 0 setelah penghapusan massal');

        return rowsAffected;
      }, dariServer: dariServer);
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal menghapus semua transaksi', e: e, s: st);
      rethrow;
    }
  }

  /// Menghitung total pemasukan (income) dari semua transaksi.
  Future<double> ambilTotalPemasukan() async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung total seluruh pemasukan');
      final result = await db.rawQuery(
        "SELECT SUM(${NamaKolom.jumlah}) as total FROM $_tabelTransaksi WHERE ${NamaKolom.tipe} = 'income' AND ${NamaKolom.dihapus} = 0",
      );
      var total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      Log.info('Total pemasukan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung total pemasukan', e: e, s: st);
      return 0.0;
    }
  }

  /// Menghitung total pengeluaran (expense) dari semua transaksi.
  Future<double> ambilTotalPengeluaran() async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung total seluruh pengeluaran');
      final result = await db.rawQuery(
        "SELECT SUM(${NamaKolom.jumlah}) as total FROM $_tabelTransaksi WHERE ${NamaKolom.tipe} = 'expense' AND ${NamaKolom.dihapus} = 0",
      );
      var total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      Log.info('Total pengeluaran: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung total pengeluaran', e: e, s: st);
      return 0.0;
    }
  }

  /// Menghitung total bersih (pemasukan - pengeluaran).
  Future<double> getNetTotal() async {
    Log.info('Menghitung Net Total (Pemasukan - Pengeluaran)');
    final income = await ambilTotalPemasukan();
    final expense = await ambilTotalPengeluaran();
    final net = income - expense;
    Log.info('Hasil Net Total: $net');
    return net;
  }

  // Future<List<PaketTerlarisModel>> ambilPaketTerlaris({int limit = 5}) async {
  //   Log.info('Mulai menghitung paket terlaris.');
  //   try {
  //     final daftarPaket = await paketOpsqlite.ambilSemua();
  //     final daftartransaksi = await ambilSemua();
  //     if (daftartransaksi.isEmpty) {
  //       Log.warning('Tidak ada transaksi, mengembalikan list paket kosong.');
  //       return [];
  //     }
  //     final jumlahPenjualan = groupBy(
  //       daftartransaksi.where((t) => t.idPaket != null).toList(),
  //       (t) => t.idPaket!,
  //     ).map((key, value) => MapEntry(key, value.length));
  //     final paketTerlaris = daftarPaket.map((paket) {
  //       return PaketTerlarisModel(
  //         paket: paket,
  //         totalTerjual: jumlahPenjualan[paket.id] ?? 0,
  //       );
  //     }).toList();
  //     paketTerlaris.sort((a, b) => b.totalTerjual.compareTo(a.totalTerjual));

  //     final hasil = paketTerlaris.take(limit).toList();
  //     Log.info(
  //       'Berhasil menghitung ${hasil.length} paket terlaris: ${hasil.map((p) => '${p.paket.nama} (${p.totalTerjual})').toList()}',
  //     );

  //     return hasil;
  //   } catch (e, st) {
  //     Log.error('Gagal menghitung paket terlaris.', e: e, s: st);
  //     rethrow;
  //   }
  // }

  /// Mengambil data pendapatan harian dalam 7 hari terakhir
  Future<List<double>> ambilPendapatanHarian() async {
    try {
      final db = await sqliteDb.database;
      final now = DateTime.now();
      final results = <double>[];

      for (var i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final result = await db.rawQuery(
          '''
        SELECT COALESCE(SUM(
          CASE
            WHEN ${NamaKolom.tipe} = 'income' THEN ${NamaKolom.jumlah}
            WHEN ${NamaKolom.tipe} = 'expense' THEN -${NamaKolom.jumlah}
            ELSE 0
          END
        ), 0) as total
        FROM ${NamaTabel.transaksi}
        WHERE ${NamaKolom.tanggal} >= ? 
          AND ${NamaKolom.tanggal} < ?
          AND ${NamaKolom.dihapus} = 0
          AND ${NamaKolom.statusPembayaran} = 'paid'
        ''',
          [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
        );

        final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
        results.add(total / 1000000); // Konversi ke Jutaan
      }

      return results;
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan harian', e: e, s: st);
      return List.filled(7, 0.0);
    }
  }

  /// Mengambil data pendapatan mingguan dalam 4 minggu terakhir
  Future<List<double>> ambilPendapatanMingguan() async {
    try {
      final db = await sqliteDb.database;
      final now = DateTime.now();
      final results = <double>[];

      for (var i = 3; i >= 0; i--) {
        final startOfWeek = now.subtract(
          Duration(days: i * 7 + now.weekday - 1),
        );
        final start = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final end = start.add(const Duration(days: 7));

        final result = await db.rawQuery(
          '''
        SELECT COALESCE(SUM(
          CASE
            WHEN ${NamaKolom.tipe} = 'income' THEN ${NamaKolom.jumlah}
            WHEN ${NamaKolom.tipe} = 'expense' THEN -${NamaKolom.jumlah}
            ELSE 0
          END
        ), 0) as total
        FROM ${NamaTabel.transaksi}
        WHERE ${NamaKolom.tanggal} >= ? 
          AND ${NamaKolom.tanggal} < ?
          AND ${NamaKolom.dihapus} = 0
          AND ${NamaKolom.statusPembayaran} = 'paid'
        ''',
          [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
        );

        final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
        results.add(total / 1000000); // Konversi ke Jutaan
      }

      return results;
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan mingguan', e: e, s: st);
      return List.filled(4, 0.0);
    }
  }

  /// Mengambil data pendapatan bulanan dalam 5 bulan terakhir
  Future<List<double>> ambilPendapatanBulanan() async {
    try {
      final db = await sqliteDb.database;
      final now = DateTime.now();
      final results = <double>[];

      for (var i = 4; i >= 0; i--) {
        final month = now.month - i;
        final year = now.year - (month <= 0 ? 1 : 0);
        final actualMonth = month <= 0 ? month + 12 : month;

        final startOfMonth = DateTime(year, actualMonth);
        final endOfMonth = DateTime(
          actualMonth == 12 ? year + 1 : year,
          actualMonth == 12 ? 1 : actualMonth + 1,
        );

        final result = await db.rawQuery(
          '''
        SELECT COALESCE(SUM(
          CASE
            WHEN ${NamaKolom.tipe} = 'income' THEN ${NamaKolom.jumlah}
            WHEN ${NamaKolom.tipe} = 'expense' THEN -${NamaKolom.jumlah}
            ELSE 0
          END
        ), 0) as total
        FROM ${NamaTabel.transaksi}
        WHERE ${NamaKolom.tanggal} >= ? 
          AND ${NamaKolom.tanggal} < ?
          AND ${NamaKolom.dihapus} = 0
          AND ${NamaKolom.statusPembayaran} = 'paid'
        ''',
          [
            startOfMonth.millisecondsSinceEpoch,
            endOfMonth.millisecondsSinceEpoch,
          ],
        );

        final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
        results.add(total / 1000000); // Konversi ke Jutaan
      }

      return results;
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan bulanan', e: e, s: st);
      return List.filled(5, 0.0);
    }
  }

  /// Menghitung total poin yang diperoleh seorang pelanggan.
  Future<int> ambilPoinDidapat(String idPelanggan) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung poin yang dihasilkan Customer: $idPelanggan');
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.poinDidapat}) as total FROM $_tabelTransaksi WHERE ${NamaKolom.idPelanggan} = ? AND ${NamaKolom.dihapus} = 0 AND ${NamaKolom.statusPembayaran} = ?',
        [idPelanggan, StatusPembayaran.paid.name],
      );
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin dihasilkan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin dihasilkan', e: e, s: st);
      return 0;
    }
  }

  Future<int> ambilPoinDigunakan(String idPelanggan) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung poin yang digunakan Customer: $idPelanggan');
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.poinDigunakan}) as total FROM $_tabelTransaksi WHERE ${NamaKolom.idPelanggan} = ? AND ${NamaKolom.dihapus} = 0 AND ${NamaKolom.statusPembayaran} = ?',
        [idPelanggan, StatusPembayaran.paid.name],
      );
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin digunakan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin digunakan', e: e, s: st);
      return 0;
    }
  }

  Future<int> ambilTotalPoin(String idPelanggan) async {
    Log.info('Menghitung saldo poin akhir Customer: $idPelanggan');
    final hasil = await Future.wait([
      ambilPoinDidapat(idPelanggan),
      ambilPoinDigunakan(idPelanggan),
    ]);
    final poinDidapat = hasil[0];
    final poinDigunakan = hasil[1];
    final total = poinDidapat - poinDigunakan;
    Log.info(
      'Saldo poin akhir Customer $idPelanggan: $total (earned=$poinDidapat, used=$poinDigunakan)',
    );
    return total;
  }

  Future<int> ambilTotalPoinSemuaPelanggan() async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung total poin semua pelanggan');

      final result = await db.rawQuery(
        '''
      SELECT 
        SUM(${NamaKolom.poinDidapat}) as total_poin_didapat,
        SUM(${NamaKolom.poinDigunakan}) as total_poin_digunakan
      FROM $_tabelTransaksi 
      WHERE ${NamaKolom.dihapus} = 0 
        AND ${NamaKolom.statusPembayaran} = ?
      ''',
        [StatusPembayaran.paid.name],
      );

      final poinDidapat = result.first['total_poin_didapat'] as int? ?? 0;
      final poinDigunakan = result.first['total_poin_digunakan'] as int? ?? 0;
      final total = poinDidapat - poinDigunakan;

      Log.info('Total poin semua pelanggan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung total poin semua pelanggan', e: e, s: st);
      return 0;
    }
  }

  /// Memasukkan atau memperbarui beberapa transaksi sekaligus (batch) dan menghitung ulang saldo dompet yang terpengaruh.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<TransaksiModel> transaksi, {
    final bool dariServer = false,
  }) async {
    if (transaksi.isEmpty) {
      Log.warning('Batch dibatalkan karena daftar transaksi kosong');
      return;
    }
    final dompetTerpengaruh = <String>{};

    try {
      await baseOpSqlite.operasiKompleks<void>((final txn) async {
        Log.info(
          'Memulai proses Batch insert/update untuk ${transaksi.length} item',
        );
        final batch = txn.batch();
        for (final item in transaksi) {
          batch.insert(
            _tabelTransaksi,
            item.copyWith(diperbaruiPada: _nowUtc).toSqlite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          dompetTerpengaruh.add(item.idDompet);
          if (item.idDompetTujuan != null) {
            dompetTerpengaruh.add(item.idDompetTujuan!);
          }
        }
        await batch.commit(noResult: true);
        Log.info(
          'Batch commit selesai. Menghitung ulang saldo untuk wallet: $dompetTerpengaruh',
        );

        for (final walletId in dompetTerpengaruh) {
          await _hitungUlangDanPerbaruiSaldoDompet(walletId, txn);
        }
      }, dariServer: dariServer);
      Log.info('Proses Batch transaksi berhasil sepenuhnya');
    } on Exception catch (e, st) {
      Log.error('Gagal menjalankan Batch transaksi', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilTotalPendapatanPerbulan() async {
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> hasil = await db.rawQuery(
        '''
      SELECT SUM(
        CASE
          WHEN ${NamaKolom.tipe} = ? THEN ${NamaKolom.jumlah}
          WHEN ${NamaKolom.tipe} = ? THEN -${NamaKolom.jumlah}
          ELSE 0
        END
      ) as total
      FROM ${NamaTabel.transaksi}
      WHERE ${NamaKolom.dihapus} = 0
        AND ${NamaKolom.statusPembayaran} = ?
      ''',
        [
          TipeTransaksi.income.name,
          TipeTransaksi.expense.name,
          StatusPembayaran.paid.name,
        ],
      );

      final total = (hasil.first['total'] as num?)?.toDouble() ?? 0.0;
      Log.info('Total pendapatan bersih: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan bersih.', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil beberapa transaksi berdasarkan daftar ID.
  Future<List<TransaksiModel>> ambilBerdasarkanIds(
    final List<String> ids,
  ) async {
    if (ids.isEmpty) {
      Log.warning('Pencarian Batch ID dibatalkan karena list ID kosong');
      return [];
    }
    try {
      final db = await sqliteDb.database;
      Log.info('Mengambil transaksi berdasarkan list ID: $ids');
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelTransaksi,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} transaksi dari list ID');
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error saat ambil transaksi by IDs', e: e, s: st);
      return [];
    }
  }
}
```

#### File: `lib/fitur/transaksi/page/detail_transaksi_a.dart`
```dart
// path lib/fitur/transaksi/page/detail_transaksi_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk menampilkan detail dari sebuah transaksi.
class DetailTransaksiA extends ConsumerStatefulWidget {
  /// Model transaksi yang akan ditampilkan.
  final TransaksiModel transaksi;

  /// Konstruktor untuk TransactionDetailPage.
  const DetailTransaksiA({super.key, required this.transaksi});

  @override
  ConsumerState<DetailTransaksiA> createState() => _DetailTransaksiAState();
}

class _DetailTransaksiAState extends ConsumerState<DetailTransaksiA> {
  late final DompetOpSqlite _dompetOpSqlite = ref.watch(dompetOpSqliteProvider);
  late final KategoriOpSqlite _kategoriOpSqlite = ref.watch(
    kategoriOpSqliteProvider,
  );
  late final PelangganOpSqlite _pelangganOpsqlite = ref.watch(
    pelangganOpSqliteProvider,
  );
  late final PaketOpSqlite _paketOpSqlite = ref.watch(paketOpSqliteProvider);
  late final SubKategoriOpSqlite _subKategoriOpSqlite = ref.watch(
    subKategoriOpSqliteProvider,
  );

  late TransaksiModel _currentTransaction;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaksi;
    Log.info('Membuka halaman Detail Transaksi ID: ${_currentTransaction.id}');
  }

  Future<String?> _getName(
    Future<dynamic> Function(String) getModel,
    String id,
    String label,
  ) async {
    if (id.isEmpty) return null;

    try {
      final model = await getModel(id);
      if (model != null) {
        String? name;
        if (model is DompetModel) name = model.nama;
        if (model is KategoriModel) name = model.nama;
        if (model is SubKategoriModel) name = model.nama;
        if (model is PelangganModel) name = model.nama;
        if (model is PaketModel) name = model.nama;
        return name ?? 'Nama tidak tersedia';
      }
      return 'Data tidak ditemukan';
    } on Exception {
      return 'Error Memuat';
    }
  }

  Future<void> _navigasiKeForm() async {
    Log.info(
      'Membuka FormTransaksiPage dari halaman detail untuk mengedit transaksi: ${_currentTransaction.id}',
    );
    await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => FormTransaksi(transaksi: _currentTransaction),
      ),
    );
    try {
      final transaksiOpSqlite = ref.read(transaksiOpGlobalProvider);
      final transaksi = await transaksiOpSqlite.ambilBerdasarkanId(
        _currentTransaction.id,
      );
      if (transaksi != null) {
        Log.info('Berhasil memuat data transaksi terbaru. Memperbarui UI.');
        setState(() {
          _currentTransaction = transaksi;
        });
      } else {
        Log.warning(
          'Gagal memuat ulang transaksi: data tidak ditemukan setelah update.',
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e, s) {
      Log.error('Gagal memuat ulang data transaksi setelah edit.', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data terbaru.');
      }
    }
  }

  Future<void> _softDeleteTransaksi() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (konfirmasi != true) return;
    if (!mounted) return;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menghapus transaksi...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    try {
      await ref
          .read(transaksiOpGlobalProvider)
          .softDelete(_currentTransaction.id);
      unawaited(
        ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
      );
      if (mounted) {
        Navigator.pop(context); // Tutup loading dialog
        ToastUtil.success(context, 'Transaksi berhasil dihapus');
        Navigator.pop(context); // Tutup halaman detail
      }
    } catch (e, st) {
      if (mounted) {
        Navigator.pop(context); // Tutup loading dialog
        ToastUtil.error(context, 'Gagal menghapus transaksi');
        Log.error('Gagal menghapus transaksi', e: e, s: st);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaksi = _currentTransaction;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            onPressed: _softDeleteTransaksi,
            icon: const Icon(TIcons.delete),
          ),
          IconButton(
            icon: const Icon(TIcons.edit),
            onPressed: _navigasiKeForm,
            tooltip: 'Edit Transaksi',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Keterangan', transaksi.deskripsi),
            _buildDetailRow(
              'Tanggal',
              FormatWaktuLengkap.formatSingkat(transaksi.tanggal),
            ),
            _buildDetailRow(
              'Jumlah',
              FormatUang.formatMataUang(transaksi.jumlah),
            ),
            _buildDetailRow('Tipe', transaksi.tipe.displayName),
            _buildFutureDetailRow(
              'Dompet',
              _getName(
                _dompetOpSqlite.ambilBerdasarkanId,
                transaksi.idDompet,
                'Dompet',
              ),
            ),
            if (transaksi.idDompetTujuan != null &&
                transaksi.idDompetTujuan!.isNotEmpty)
              _buildFutureDetailRow(
                'Dompet Tujuan',
                _getName(
                  _dompetOpSqlite.ambilBerdasarkanId,
                  transaksi.idDompetTujuan!,
                  'Dompet Tujuan',
                ),
              ),
            _buildFutureDetailRow(
              'Kategori',
              _getName(
                _kategoriOpSqlite.ambilKategoriBerdasarkanId,
                transaksi.idKategori,
                'Kategori',
              ),
            ),
            if (transaksi.idSubKategori != null &&
                transaksi.idSubKategori!.isNotEmpty)
              _buildFutureDetailRow(
                'Sub Kategori',
                _getName(
                  _subKategoriOpSqlite.getSubCategoryById,
                  transaksi.idSubKategori!,
                  'Sub-Kategori',
                ),
              ),
            if (transaksi.idPelanggan != null &&
                transaksi.idPelanggan!.isNotEmpty)
              _buildFutureDetailRow(
                'Pelanggan',
                _getName(
                  _pelangganOpsqlite.ambilBerdasarkanId,
                  transaksi.idPelanggan!,
                  'Pelanggan',
                ),
              ),
            if (transaksi.idPaket != null && transaksi.idPaket!.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getName(
                  _paketOpSqlite.ambilBerdasarkanId,
                  transaksi.idPaket!,
                  'Paket',
                ),
              ),
            _buildDetailRow(
              'Status Pembayaran',
              transaksi.statusPembayaran.displayName,
            ),
            _buildDetailRow(
              'Poin Dihasilkan',
              transaksi.poinDidapat.toString(),
            ),
            _buildDetailRow(
              'Poin Digunakan',
              transaksi.poinDigunakan.toString(),
            ),
            if (transaksi.tanggalMulai != null)
              _buildDetailRow(
                'Masa Aktif Mulai',
                FormatWaktuLengkap.formatSingkat(transaksi.tanggalMulai!),
              ),
            if (transaksi.tanggalBerakhir != null)
              _buildDetailRow(
                'Masa Aktif Berakhir',
                FormatWaktuLengkap.formatSingkat(transaksi.tanggalBerakhir!),
              ),
            if (transaksi.durasiBonus > 0 && transaksi.tipeDurasiBonus != null)
              _buildDetailRow(
                'Bonus',
                '${transaksi.durasiBonus} ${transaksi.tipeDurasiBonus?.displayName}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          gapH16,
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildFutureDetailRow(String label, Future<String?> future) {
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDetailRow(label, 'Memuat...');
        }
        if (snapshot.hasError) {
          return _buildDetailRow(label, 'Error Data');
        }
        return _buildDetailRow(label, snapshot.data ?? '-');
      },
    );
  }
}
```

#### File: `lib/fitur/transaksi/page/detail_transaksi_u.dart`
```dart
// path: lib/fitur/transaksi/page/detail_transaksi_u.dart

import 'package:flutter/material.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart'; // DIUBAH

class DetailTransaksiU extends StatelessWidget {
  final TransaksiModel transaksi;
  final PaketModel? paket;

  const DetailTransaksiU({super.key, required this.transaksi, this.paket});

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun halaman TransactionDetailPage untuk transaksi ID: ${transaksi.id}',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Tanggal:',
              FormatWaktuLengkap.formatSingkat(transaksi.tanggal),
            ),
            _buildInfoRow('Keterangan:', transaksi.deskripsi),
            _buildInfoRow(
              'Jumlah:',
              FormatUang.formatMataUang(transaksi.jumlah),
            ),
            _buildInfoRow('Tipe:', transaksi.tipe.displayName),
            if (paket != null)
              _buildInfoRow('Paket:', paket!.nama)
            else if (transaksi.idPaket != null)
              _buildInfoRow('Paket:', 'Memuat...'),
            _buildInfoRow(
              'Status Pembayaran:',
              transaksi.statusPembayaran.displayName,
            ),
            if (transaksi.tanggalMulai != null)
              _buildInfoRow(
                'Tanggal Mulai:',
                FormatWaktuLengkap.formatSingkat(transaksi.tanggalMulai!),
              ),
            if (transaksi.tanggalBerakhir != null)
              _buildInfoRow(
                'Tanggal Berakhir:',
                FormatWaktuLengkap.formatSingkat(transaksi.tanggalBerakhir!),
              ),
            _buildInfoRow('Poin didapat:', transaksi.poinDidapat.toString()),
            _buildInfoRow(
              'Poin digunakan:',
              transaksi.poinDigunakan.toString(),
            ),
            if (transaksi.durasiBonus > 0 && transaksi.tipeDurasiBonus != null)
              _buildInfoRow(
                'Bonus',
                '${transaksi.durasiBonus} ${transaksi.tipeDurasiBonus!.displayName}',
              ),
          ],
        ),
      ),
      // DIUBAH
      bottomNavigationBar: const BannerAdsWidget(),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: value is Widget ? value : Text(value.toString())),
        ],
      ),
    );
  }
}
```

#### File: `lib/fitur/transaksi/page/form_transaksi.dart`
```dart
// path: lib/fitur/transaksi/page/form_transaksi.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_rupiah.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';
import 'package:wifi/shared/widget/pemilih_tanggal_waktu_widget.dart';

class FormTransaksi extends ConsumerStatefulWidget {
  final TransaksiModel? transaksi;

  const FormTransaksi({super.key, this.transaksi});

  @override
  ConsumerState<FormTransaksi> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends ConsumerState<FormTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _jumlahFocusNode = FocusNode();
  final _keteranganFocusNode = FocusNode();
  DateTime? _tanggalDipilih;
  TimeOfDay? _jamDipilih;

  KategoriModel? _kategoriDipilih;
  SubKategoriModel? _subKategoriDipilih;
  TipeTransaksi _tipe = TipeTransaksi.income;
  DompetModel? _dompetDipilih;
  DompetModel? _dompetTujuanDipilih;

  late final DompetOpSqlite _dompetOpSlite;
  late final KategoriOpSqlite _kategoriOpSqlite;
  List<KategoriModel> _daftarKategori = [];
  List<DompetModel> _daftarDompet = [];
  List<KategoriModel> _kategoriDifilter = [];

  bool get _modeEdit => widget.transaksi != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Menginisialisasi FormTransaksiPage dalam mode: ${_modeEdit ? "Edit" : "Tambah"}.',
    );
    _dompetOpSlite = ref.read(dompetOpSqliteProvider);
    _kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    Log.info('Memulai pemuatan data awal (dompet & kategori).');
    try {
      final daftarDompet = await _dompetOpSlite.ambilSemua();
      Log.info('Berhasil memuat ${daftarDompet.length} dompet.');
      final daftarKategori = await _kategoriOpSqlite.ambilSemua();
      Log.info('Berhasil memuat ${daftarKategori.length} kategori.');

      if (!mounted) return;

      setState(() {
        _daftarDompet = daftarDompet;
        _daftarKategori = daftarKategori;
      });

      if (_modeEdit) {
        Log.info(
          'Mode Edit: Mempopulasikan form dengan data transaksi ID: ${widget.transaksi!.id}',
        );
        final trx = widget.transaksi!;
        _tipe = trx.tipe;
        _keteranganController.text = trx.deskripsi;
        _jumlahController.text = trx.jumlah.abs().toString();
        _tanggalDipilih = trx.tanggal;
        _jamDipilih = TimeOfDay.fromDateTime(trx.tanggal);
        _dompetDipilih =
            _daftarDompet.firstWhereOrNull((d) => d.id == trx.idDompet) ??
            _daftarDompet.firstOrNull;

        if (trx.tipe == TipeTransaksi.transfer && trx.idDompetTujuan != null) {
          _dompetTujuanDipilih =
              _daftarDompet.firstWhereOrNull(
                (d) => d.id == trx.idDompetTujuan,
              ) ??
              _daftarDompet.firstOrNull;
          if (_dompetTujuanDipilih != null &&
              _dompetDipilih != null &&
              _dompetTujuanDipilih!.id == _dompetDipilih!.id) {
            _dompetTujuanDipilih = null;
            Log.warning(
              'Dompet tujuan sama dengan dompet asal, di-reset ke null.',
            );
          }
        }

        _filterKategoriInternal();

        if (trx.idKategori.isNotEmpty) {
          _kategoriDipilih = _kategoriDifilter.cast<KategoriModel?>().firstWhere(
            (k) => k?.id == trx.idKategori,
            orElse: () {
              Log.warning(
                'Kategori dengan ID ${trx.idKategori} tidak ditemukan setelah filter.',
              );
              return null;
            },
          );

          if (trx.idSubKategori != null && _kategoriDipilih != null) {
            _subKategoriDipilih = _kategoriDipilih!.idSubKategori
                .cast<SubKategoriModel?>()
                .firstWhere(
                  (sk) => sk?.id == trx.idSubKategori,
                  orElse: () {
                    Log.warning(
                      'Sub-kategori dengan ID ${trx.idSubKategori} tidak ditemukan.',
                    );
                    return null;
                  },
                );
          }
        }
        Log.info('Selesai mempopulasikan form untuk mode Edit.');
      } else {
        Log.info(
          'Mode Tambah: Mejalankan filter kategori awal untuk tipe Pemasukan.',
        );
        Log.info('Mode Tambah: Mengisi default tanggal/waktu sekarang.');
        _tanggalDipilih = DateTime.now();
        _jamDipilih = TimeOfDay.fromDateTime(DateTime.now());
        _filterKategoriInternal();
      }
    } on Exception catch (e, s) {
      Log.error('Gagal total saat memuat data awal.', e: e, s: s);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memuat data penting: $e');
    }
  }

  void _filterKategoriInternal() {
    final tipeSebelum = _kategoriDifilter.length;

    if (_tipe == TipeTransaksi.transfer) {
      _kategoriDifilter = [];
      Log.info('Tipe transaksi adalah Transfer, kategori dikosongkan.');
      return;
    }

    final tipeKategoriTarget = _tipe == TipeTransaksi.income
        ? TipeKategori.income
        : TipeKategori.expense;

    _kategoriDifilter = _daftarKategori
        .where((final k) => k.tipe == tipeKategoriTarget)
        .toList();
    Log.info(
      'Kategori difilter untuk tipe: ${_tipe.name}. Jumlah: $tipeSebelum -> ${_kategoriDifilter.length}.',
    );
  }

  void _filterKategori() {
    setState(() {
      Log.info(
        'Tipe transaksi diubah, memfilter ulang kategori dan mereset pilihan kategori.',
      );
      _filterKategoriInternal();
      _kategoriDipilih = null;
      _subKategoriDipilih = null;
    });
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    Log.info('Memilih tanggal, saat ini: $_tanggalDipilih');
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggalDipilih) {
      setState(() => _tanggalDipilih = picked);
      Log.info('Tanggal dipilih: ${FormatTanggal.formatDasar(picked)}');
    }
  }

  Future<void> _pilihJam(BuildContext context) async {
    Log.info('Memilih waktu, saat ini: $_jamDipilih');
    final initial = _jamDipilih ?? TimeOfDay.fromDateTime(DateTime.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && picked != _jamDipilih) {
      setState(() => _jamDipilih = picked);
      Log.info('Waktu dipilih: ${picked.hour}:${picked.minute}');
    }
  }

  Future<void> _simpanForm() async {
    Log.info('Tombol "Simpan" ditekan.');
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _menyimpan = true);
      final combinedDateTime = DateTime(
        _tanggalDipilih!.year,
        _tanggalDipilih!.month,
        _tanggalDipilih!.day,
        _jamDipilih!.hour,
        _jamDipilih!.minute,
      );
      final jumlah = InputRupiah.parse(_jumlahController.text).abs();
      final transaksi = TransaksiModel(
        id: _modeEdit ? widget.transaksi!.id : const Uuid().v4(),
        deskripsi: _keteranganController.text,
        jumlah: jumlah,
        tanggal: combinedDateTime,
        tipe: _tipe,
        idDompet: _dompetDipilih?.id ?? '',
        idDompetTujuan: _tipe == TipeTransaksi.transfer
            ? _dompetTujuanDipilih?.id
            : null,
        idKategori: _kategoriDipilih?.id ?? '',
        tanggalMulai: null,
        tanggalBerakhir: null,
        idPelanggan: null,
        idPaket: null,
        idSubKategori: _subKategoriDipilih?.id,
      );

      Log.info('Model Transaksi yang akan disimpan: ${transaksi.toSqlite()}');
      final transaksiOp = ref.read(transaksiOpProvider.notifier);
      try {
        if (_modeEdit) {
          Log.info(
            'Menjalankan operasi UPDATE untuk transaksi ID: ${transaksi.id}',
          );
          await transaksiOp.perbarui(transaksi);
        } else {
          Log.info('Menjalankan operasi CREATE untuk transaksi baru.');
          await transaksiOp.tambah(transaksi);
        }
        if (!mounted) return;
        Log.info(
          'Penyimpanan berhasil. Menutup form dan kembali dengan hasil true.',
        );
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (mounted) {
          ToastUtil.success(
            context,
            'Transaksi berhasil disimpan dan disinkronkan.',
          );
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } on Exception catch (e, s) {
        Log.error('Gagal menyimpan transaksi ke database.', e: e, s: s);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal menyimpan transaksi: $e');
      }
    } on Exception catch (e) {
      ToastUtil.error(context, 'Gagal menyimpan Transaksi $e');
    } finally {
      setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: TipeTransaksi.values.map((tipe) {
                  final isSelected = _tipe == tipe;
                  Color getColor() {
                    switch (tipe) {
                      case TipeTransaksi.income:
                        return Colors.green;
                      case TipeTransaksi.expense:
                        return Colors.red;
                      case TipeTransaksi.transfer:
                        return Colors.blue;
                    }
                  }

                  return Expanded(
                    child: DecoratedBox(
                      // Memberikan border hanya di bagian bawah
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? getColor()
                                : Colors.grey.shade300,
                            width: isSelected
                                ? 3.0
                                : 1.0, // Border lebih tebal saat terpilih
                          ),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _tipe = tipe;
                            _filterKategori();
                            _dompetTujuanDipilih = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Text(
                          tipe.displayName.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? getColor() : Colors.black45,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              gapH8,
              InputTeks(
                controller: _keteranganController,
                label: 'Keterangan',
                focusNode: _keteranganFocusNode,
                nextFocusNode: _jumlahFocusNode,
              ),
              gapH8,
              InputRupiah(
                controller: _jumlahController,
                focusNode: _jumlahFocusNode,
                textInputAction: TextInputAction.done,
              ),
              gapH24,
              PemilihTanggalWaktuWidget(
                tanggalTerpilih: _tanggalDipilih,
                waktuTerpilih: _jamDipilih,
                onPilihTanggal: () => _pilihTanggal(context),
                onPilihWaktu: () => _pilihJam(context),
              ),
              DropdownButtonFormField<DompetModel>(
                key: ValueKey<String?>(_dompetDipilih?.id ?? 'null'),
                initialValue: _dompetDipilih,
                decoration: const InputDecoration(labelText: 'Dompet'),
                items: _daftarDompet.map((dompet) {
                  return DropdownMenuItem(
                    value: dompet,
                    child: Text(dompet.nama),
                  );
                }).toList(),
                onChanged: (v) {
                  Log.info('Pengguna memilih dompet: ${v?.nama ?? "null"}');
                  setState(() {
                    _dompetDipilih = v;
                    // ✅ Reset dompet tujuan jika nilainya sama dengan dompet asal
                    if (_dompetTujuanDipilih == v ||
                        _dompetTujuanDipilih?.id == v?.id) {
                      _dompetTujuanDipilih = null;
                    }
                  });
                },
                validator: (v) => v == null ? 'Dompet harus dipilih' : null,
              ),
              if (_tipe == TipeTransaksi.transfer)
                DropdownButtonFormField<DompetModel>(
                  key: ValueKey<DompetModel?>(_dompetTujuanDipilih),
                  initialValue: _dompetTujuanDipilih,
                  decoration: const InputDecoration(labelText: 'Dompet Tujuan'),
                  items: _daftarDompet
                      .where((dompet) => dompet.id != _dompetDipilih?.id)
                      .map((dompet) {
                        return DropdownMenuItem(
                          value: dompet,
                          child: Text(dompet.nama),
                        );
                      })
                      .toList(),
                  onChanged: (val) {
                    Log.info(
                      'Pengguna memilih dompet tujuan: ${val?.nama ?? "null"}',
                    );
                    setState(() => _dompetTujuanDipilih = val);
                  },
                  validator: (val) {
                    if (val == null) return 'Dompet tujuan harus dipilih';
                    if (val == _dompetDipilih) {
                      return 'Dompet tidak boleh sama';
                    }
                    return null;
                  },
                ),
              if (_tipe != TipeTransaksi.transfer &&
                  _kategoriDifilter.isNotEmpty)
                DropdownButtonFormField<KategoriModel>(
                  key: ValueKey<KategoriModel?>(_kategoriDipilih),
                  initialValue: _kategoriDipilih,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: _kategoriDifilter.map((kategori) {
                    return DropdownMenuItem(
                      value: kategori,
                      child: Text(kategori.nama),
                    );
                  }).toList(),
                  onChanged: (val) {
                    Log.info(
                      'Pengguna memilih kategori: ${val?.nama ?? "null"}',
                    );
                    setState(() {
                      _kategoriDipilih = val;
                      _subKategoriDipilih = null;
                    });
                  },
                  validator: (val) =>
                      val == null ? 'Kategori harus dipilih' : null,
                ),
              if (_kategoriDipilih != null &&
                  _kategoriDipilih!.idSubKategori.isNotEmpty)
                DropdownButtonFormField<SubKategoriModel>(
                  key: ValueKey<SubKategoriModel?>(_subKategoriDipilih),
                  initialValue: _subKategoriDipilih,
                  decoration: const InputDecoration(labelText: 'Sub Kategori'),
                  items: _kategoriDipilih!.idSubKategori.map((sub) {
                    return DropdownMenuItem(value: sub, child: Text(sub.nama));
                  }).toList(),
                  onChanged: (val) {
                    Log.info(
                      'Pengguna memilih sub-kategori: ${val?.nama ?? "null"}',
                    );
                    setState(() => _subKategoriDipilih = val);
                  },
                  validator: (val) =>
                      val == null ? 'Sub Kategori harus dipilih' : null,
                ),
              gapH20,
              ElevatedButton(
                onPressed: _menyimpan ? null : _simpanForm,
                child: _menyimpan
                    ? const CircularProgressIndicator()
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Log.info(
      'Menjalankan dispose di FormTransaksiPage. Membersihkan controllers.',
    );
    _jumlahController.dispose();
    _keteranganController.dispose();
    _jumlahFocusNode.dispose();
    _keteranganFocusNode.dispose();
    super.dispose();
  }
}
```

#### File: `lib/fitur/transaksi/page/transaksi_a.dart`
```dart
// path lib/fitur/transaksi/page/transaksi_a.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/helper/pengurut_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_a.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider_usang.dart';
import 'package:wifi/fitur/transaksi/widget/daftar_transaksi_widget.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/ringkasan_keuangan_widget.dart';

// ============================================================
// Halaman Utama
// ============================================================
class TransaksiA extends ConsumerWidget {
  const TransaksiA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(transaksiProvider);

    return Scaffold(
      appBar: const _TransactionAppBar(),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) => _TransactionBody(state: state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Log.info('FAB tambah transaksi ditekan.');
          _naviagasiKeForm(context);
        },
        child: const Icon(TIcons.add),
      ),
    );
  }

  Future<void> _naviagasiKeForm(
    BuildContext context, {
    TransaksiModel? transaksi,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => FormTransaksi(transaksi: transaksi),
      ),
    );
  }
}

// ============================================================
// AppBar
// ============================================================
class _TransactionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _TransactionAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSortBy = ref.watch(urutanTransaksiStateProvider);
    return AppBar(
      title: const Text('Transaksi'),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(TIcons.search)),
        IconButton(
          onPressed: () => _tampilkanDialogUrutan(context, ref, currentSortBy),
          icon: const Icon(TIcons.filter),
          tooltip: 'Urutkan',
        ),
        IconButton(
          onPressed: () => _softDeleteAllTransaksi(context, ref),
          icon: const Icon(TIcons.delete),
          tooltip: 'Hapus Semua Transaksi',
        ),
      ],
    );
  }

  Future<void> _tampilkanDialogUrutan(
    BuildContext context,
    WidgetRef ref,
    UrutanTransaksi currentSortBy,
  ) async {
    Log.info('Membuka dialog pengurutan transaksi.');

    final newSort = await showDialog<UrutanTransaksi>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: [
          RadioGroup<UrutanTransaksi>(
            groupValue: currentSortBy,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              children: UrutanTransaksi.values
                  .map(
                    (sortBy) => RadioListTile<UrutanTransaksi>(
                      title: Text(sortBy.teks),
                      value: sortBy,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );

    if (newSort != null) {
      ref.read(urutanTransaksiStateProvider.notifier).ubahUrutan(newSort);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ============================================================
// Dialog Hapus Semua (tidak berubah)
// ============================================================
Future<void> _softDeleteAllTransaksi(
  BuildContext context,
  WidgetRef ref,
) async {
  final konfirmasi = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text(
        'Anda yakin ingin menghapus semua transaksi? Tindakan ini tidak dapat diurungkan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if ((konfirmasi == true) && context.mounted) {
    try {
      await ref.read(operasiProviderProvider.notifier).softDeleteAll();
      if (context.mounted) {
        ToastUtil.success(context, 'Semua transaksi berhasil dihapus.');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus semua transaksi.', e: e, s: s);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal menghapus transaksi: $e');
      }
    }
  }
}

// ============================================================
// Body (dengan sorting)
// ============================================================
class _TransactionBody extends ConsumerWidget {
  final TransaksiState state;
  const _TransactionBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(urutanTransaksiStateProvider);
    final sortedTransactions = state.transaksi.urutkan(sortBy);
    return RefreshIndicator(
      onRefresh: () => ref.read(transaksiProvider.notifier).refresh(),
      child: Column(
        children: [
          RingkasanKeuanganWidget(
            pemasukan: state.totalPemasukan,
            pengeluaran: state.totalPengeluaran,
            total: state.total,
          ),
          Expanded(
            // ✅ Perbaikan 5: Gunakan sortedTransactions
            child: sortedTransactions.isEmpty
                ? const Center(child: Text('Tidak ada transaksi'))
                : _TransactionListView(transaksi: sortedTransactions),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ListView (tidak berubah)
// ============================================================
class _TransactionListView extends ConsumerStatefulWidget {
  final List<TransaksiModel> transaksi;
  const _TransactionListView({required this.transaksi});

  @override
  ConsumerState<_TransactionListView> createState() =>
      _TransactionListViewState();
}

class _TransactionListViewState extends ConsumerState<_TransactionListView> {
  final ScrollController _pengendaliScroll = ScrollController();
  int _jumlahTampil = 20;

  @override
  void initState() {
    super.initState();
    _pengendaliScroll.addListener(_deteksiScroll);
  }

  @override
  void dispose() {
    _pengendaliScroll.removeListener(_deteksiScroll);
    _pengendaliScroll.dispose();
    super.dispose();
  }

  void _deteksiScroll() {
    if (_pengendaliScroll.position.pixels >=
        _pengendaliScroll.position.maxScrollExtent - 200) {
      if (_jumlahTampil < widget.transaksi.length) {
        setState(() {
          _jumlahTampil += 20;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaksiTampil = widget.transaksi.take(_jumlahTampil).toList();
    final grupTransaksi = kelompokkanTransaksiPerTanggal(transaksiTampil);

    return ListView.builder(
      controller: _pengendaliScroll,
      key: const PageStorageKey('transaction_list_key'),
      itemCount:
          grupTransaksi.length +
          (_jumlahTampil < widget.transaksi.length ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == grupTransaksi.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final date = grupTransaksi.keys.elementAt(index);
        final transactionsOnDate = grupTransaksi[date]!;
        final totalHarian = transactionsOnDate.fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.income ? item.jumlah : -item.jumlah),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bangunHeaderBagian(date, totalHarian),
            ...transactionsOnDate.map(
              (transaksi) => bangunItemTransaksi(
                context,
                transaksi,
                onTap: () => _navigasiKeDetailTransaksi(context, transaksi),
                onEdit: () =>
                    _navigasiKeFormTransaksi(context, transaksi: transaksi),
                onDelete: () => ref
                    .read(transaksiOpGlobalProvider)
                    .softDelete(transaksi.id),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigasiKeDetailTransaksi(
    BuildContext context,
    TransaksiModel transaksi,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailTransaksiA(transaksi: transaksi),
      ),
    );
  }

  Future<void> _navigasiKeFormTransaksi(
    BuildContext context, {
    TransaksiModel? transaksi,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => FormTransaksi(transaksi: transaksi),
      ),
    );
  }
}
```

#### File: `lib/fitur/transaksi/page/transaksi_u.dart`
```dart
// path lib/fitur/transaksi/page/transaksi_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider_usang.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/fitur/paket/widget/nama_paket_widget.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/providers/user_provider.dart';

enum SortMode {
  tanggalTerbaru,
  tanggalTerlama,
  tanggalBerakhirTerbaru,
  tanggalBerakhirTerlama,
  lunas,
  belumLunas,
}

class TransaksiU extends ConsumerStatefulWidget {
  const TransaksiU({super.key});

  @override
  ConsumerState<TransaksiU> createState() => _TransaksiUState();
}

class _TransaksiUState extends ConsumerState<TransaksiU> {
  final ScrollController _pengendaliScroll = ScrollController();

  SortMode _modeUrutan = SortMode.tanggalTerbaru;
  int _jumlahTampil = 20;
  bool _sedangMemuatLebih = false;

  @override
  void initState() {
    super.initState();
    _pengendaliScroll.addListener(_deteksiScroll);
  }

  @override
  void dispose() {
    _pengendaliScroll.removeListener(_deteksiScroll);
    _pengendaliScroll.dispose();
    super.dispose();
  }

  List<TransaksiModel> _sortHistory(List<TransaksiModel> history) {
    switch (_modeUrutan) {
      case SortMode.tanggalTerbaru:
        history.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        break;
      case SortMode.tanggalTerlama:
        history.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        break;
      case SortMode.tanggalBerakhirTerbaru:
        history.sort((a, b) {
          if (a.tanggalBerakhir == null && b.tanggalBerakhir == null) return 0;
          if (a.tanggalBerakhir == null) return 1;
          if (b.tanggalBerakhir == null) return -1;
          return b.tanggalBerakhir!.compareTo(a.tanggalBerakhir!);
        });
        break;
      case SortMode.tanggalBerakhirTerlama:
        history.sort((a, b) {
          if (a.tanggalBerakhir == null && b.tanggalBerakhir == null) return 0;
          if (a.tanggalBerakhir == null) return 1;
          if (b.tanggalBerakhir == null) return -1;
          return a.tanggalBerakhir!.compareTo(b.tanggalBerakhir!);
        });
        break;
      case SortMode.lunas:
        history.sort((a, b) {
          final statusA = a.statusPembayaran == StatusPembayaran.paid ? 0 : 1;
          final statusB = b.statusPembayaran == StatusPembayaran.paid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
      case SortMode.belumLunas:
        history.sort((a, b) {
          final statusA = a.statusPembayaran == StatusPembayaran.unpaid ? 0 : 1;
          final statusB = b.statusPembayaran == StatusPembayaran.unpaid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
    }
    return history;
  }

  void _deteksiScroll() {
    final state = ref.read(transaksiProvider).value;
    if (state == null) return;

    final userId = ref.read(userIdProvider).value;
    if (userId == null) return;

    final semua = state.transaksi
        .where((e) => e.idPelanggan == userId)
        .toList();
    final total = semua.length;

    if (_pengendaliScroll.position.pixels >=
        _pengendaliScroll.position.maxScrollExtent - 200) {
      if (!_sedangMemuatLebih && _jumlahTampil < total) {
        _muatLebihBanyak();
      }
    }
  }

  Future<void> _muatLebihBanyak() async {
    setState(() {
      _sedangMemuatLebih = true;
      _jumlahTampil += 20;
      _sedangMemuatLebih = false;
    });
  }

  Future<void> _refreshRiwayat() async {
    setState(() {
      _jumlahTampil = 20; // Reset pagination
    });
    final _ = ref.refresh(transaksip); // Paksa muat ulang data
  }

  Future<void> _navigasiKeDetailTransaksi(
    TransaksiModel tx,
    Future<PaketModel?> paketfuture,
  ) async {
    final paket = await paketfuture;
    await ref.read(interstitialAdServiceProvider).show();
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiU(transaksi: tx, paket: paket),
      ),
    );
    await ref.read(interstitialAdServiceProvider).show();
  }

  @override
  Widget build(BuildContext context) {
    final transaksi = ref.watch(transaksiProvider);
    final paketOpFirebase = ref.read(paketOpFirebaseProvider);
    final userId = ref.watch(userIdProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          PopupMenuButton<SortMode>(
            onSelected: (hasil) {
              setState(() {
                _modeUrutan = hasil;
                _jumlahTampil = 20;
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: SortMode.tanggalTerbaru,
                checked: _modeUrutan == SortMode.tanggalTerbaru,
                child: const TeksIsiSedang('Tanggal (Terbaru)'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.tanggalTerlama,
                checked: _modeUrutan == SortMode.tanggalTerlama,
                child: const TeksIsiSedang('Tanggal (Terlama)'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.tanggalBerakhirTerbaru,
                checked: _modeUrutan == SortMode.tanggalBerakhirTerbaru,
                child: const TeksIsiSedang('Tanggal Berakhir (Terbaru)'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.tanggalBerakhirTerlama,
                checked: _modeUrutan == SortMode.tanggalBerakhirTerlama,
                child: const TeksIsiSedang('Tanggal Berakhir (Terlama)'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.lunas,
                checked: _modeUrutan == SortMode.lunas,
                child: const TeksIsiSedang('Status: Lunas'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.belumLunas,
                checked: _modeUrutan == SortMode.belumLunas,
                child: const TeksIsiSedang('Status: Belum Lunas'),
              ),
            ],
            icon: const Icon(TIcons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: transaksi.when(
              data: (data) {
                if (userId == null || userId.isEmpty) {
                  return const Center(
                    child: Text('Silakan login terlebih dahulu'),
                  );
                }

                final semuaTransaksi = data.transaksi
                    .where((e) => e.idPelanggan == userId)
                    .toList();
                final riwayatUrut = _sortHistory(List.from(semuaTransaksi));
                final transaksiTampil = riwayatUrut
                    .take(_jumlahTampil)
                    .toList();
                final showLoadMore = _jumlahTampil < riwayatUrut.length;

                return RefreshIndicator(
                  onRefresh: _refreshRiwayat,
                  child: ListView.builder(
                    controller: _pengendaliScroll,
                    itemCount: transaksiTampil.length + (showLoadMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == transaksiTampil.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final tx = transaksiTampil[index];
                      final paketFuture = tx.idPaket != null
                          ? paketOpFirebase.ambilBerdasarkanId(tx.idPaket!)
                          : Future<PaketModel?>.value();
                      final teksAktif = tx.tanggalBerakhir != null
                          ? PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
                              tx.tanggalBerakhir!,
                            )
                          : '--';
                      final warnaAktif = tx.tanggalBerakhir != null
                          ? PerhitunganUtil.ambilWarnaSisaMasaAktif(
                              tx.tanggalBerakhir!,
                            )
                          : Colors.grey;

                      return Card(
                        key: ValueKey(tx.id),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(TIcons.receiptLong),
                          title: NamaPaketWidget(idPaket: tx.idPaket ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tx.tanggalBerakhir != null)
                                TeksIsiSedang(
                                  'Berakhir - ${FormatWaktuLengkap.formatSingkat(tx.tanggalBerakhir!)}',
                                ),
                              TeksIsiSedang(
                                'Status: ${tx.statusPembayaran.displayName}',
                                warna:
                                    tx.statusPembayaran == StatusPembayaran.paid
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              TeksIsiSedang(
                                'Masa Aktif: $teksAktif',
                                warna: warnaAktif,
                              ),
                            ],
                          ),
                          trailing: const Icon(TIcons.chevronRight),
                          onTap: () =>
                              _navigasiKeDetailTransaksi(tx, paketFuture),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, stackTrace) => Text('$error $stackTrace'),
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### File: `lib/fitur/transaksi/provider/transaksi_provider_usang.dart`
```dart
// // path: lib/fitur/transaksi/provider/transaksi_provider.dart

// import 'dart:async';

// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
// import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
// import 'package:wifi/shared/debug/log.dart';

// part 'transaksi_provider.freezed.dart';
// part 'transaksi_provider.g.dart';

// @freezed
// abstract class TransaksiState with _$TransaksiState {
//   const factory TransaksiState({
//     @Default([]) List<TransaksiModel> transaksi,
//     @Default(0.0) double totalPemasukan,
//     @Default(0.0) double totalPengeluaran,
//     @Default(0.0) double total,
//     @Default(0) int totalPoinSemuaPelanggan,
//     // required List<PaketTerlarisModel> paketTerlaris,
//     required List<double> pendapatanHarian,
//     required List<double> pendapatanMingguan,
//     required List<double> pendapatanBulanan,
//     required double totalPendapatanPerbulan,
//   }) = _TransaksiState;
// }

// @riverpod
// class Transaksi extends _$Transaksi {
//   TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);
//   @override
//   FutureOr<TransaksiState> build() {
//     return _loadData();
//   }

//   Future<TransaksiState> _loadData() async {
//     final hasil = await Future.wait([
//       _transaksiOp.ambilSemua(), // [0]
//       _transaksiOp.ambilTotalPemasukan(), // [1]
//       _transaksiOp.ambilTotalPengeluaran(), // [2]
//       _transaksiOp.getNetTotal(), // [3]
//       _transaksiOp.ambilTotalPoinSemuaPelanggan(), // [4]
//       // _transaksiOp.ambilPaketTerlaris(), // [5] ✅ TAMBAHKAN
//       _transaksiOp.ambilPendapatanHarian(), // [6]
//       _transaksiOp.ambilPendapatanMingguan(), // [7]
//       _transaksiOp.ambilPendapatanBulanan(), // [8]
//       _transaksiOp.ambilTotalPendapatanPerbulan(), //[9]
//     ]);

//     return TransaksiState(
//       transaksi: hasil[0] as List<TransaksiModel>,
//       totalPemasukan: hasil[1] as double,
//       totalPengeluaran: hasil[2] as double,
//       total: hasil[3] as double,
//       totalPoinSemuaPelanggan: hasil[4] as int,
//       // paketTerlaris: hasil[5] as List<PaketTerlarisModel>,
//       pendapatanHarian: hasil[5] as List<double>,
//       pendapatanMingguan: hasil[6] as List<double>,
//       pendapatanBulanan: hasil[7] as List<double>,
//       totalPendapatanPerbulan: hasil[8] as double,
//     );
//   }

//   Future<int> getTotalPoinPelanggan(String idPelanggan) async {
//     return await _transaksiOp.ambilTotalPoin(idPelanggan);
//   }

//   // ✅ Method untuk ambil poin banyak pelanggan (paralel)
//   Future<Map<String, int>> getTotalPoinBanyakPelanggan(List<String> ids) async {
//     final hasil = <String, int>{};
//     for (final id in ids) {
//       hasil[id] = await _transaksiOp.ambilTotalPoin(id);
//     }
//     return hasil;
//   }

//   Future<List<int>> getTotalPoinBanyakPelangganParallel(
//     List<String> ids,
//   ) async {
//     final futures = ids.map((id) => _transaksiOp.ambilTotalPoin(id)).toList();
//     return await Future.wait(futures);
//   }

//   Future<void> refresh() async {
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(_loadData);
//   }

//   void invalidateProviderTransaksi() {
//     ref.invalidateSelf();
//     ref.invalidate(riwayatTransaksiPelangganProvider);
//   }
// }

// @Riverpod(keepAlive: true)
// Future<({List<TransaksiModel> transaksi, int totalPoin})>
// riwayatTransaksiPelanggan(Ref ref, String idPelanggan) async {
//   Log.info(
//     '[RiwayatTransaksi] 🔍 Mengambil riwayat transaksi untuk pelanggan: $idPelanggan',
//   );
//   try {
//     final transaksiOp = ref.read(transaksiOpGlobalProvider);
//     final results = await Future.wait([
//       transaksiOp.ambilBerdasarkanIdPelanggan(idPelanggan),
//       transaksiOp.ambilTotalPoin(idPelanggan),
//     ]);
//     final semuaTransaksi = results[0] as List<TransaksiModel>;
//     final totalPoinUser = results[1] as int;
//     Log.info('[RiwayatTransaksi] 📊 Total transaksi: ${semuaTransaksi.length}');
//     Log.info('[RiwayatTransaksi] 🎯 Total poin: $totalPoinUser');
//     return (transaksi: semuaTransaksi, totalPoin: totalPoinUser);
//   } catch (e, s) {
//     Log.error('[RiwayatTransaksi] ❌ ERROR: $e', e: e, s: s);
//     rethrow;
//   }
// }

// @riverpod
// Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
//   Ref ref,
//   String idPelanggan,
// ) async {
//   Log.info(
//     '[RiwayatPoin] 🔍 Mengambil riwayat poin untuk pelanggan: $idPelanggan',
//   );
//   try {
//     final transaksiOp = ref.read(transaksiOpGlobalProvider);
//     final semuaTransaksi = await transaksiOp.ambilBerdasarkanIdPelanggan(
//       idPelanggan,
//     );
//     Log.info('[RiwayatPoin] 📊 Total transaksi: ${semuaTransaksi.length}');
//     return semuaTransaksi;
//   } catch (e, s) {
//     Log.error('[RiwayatPoin] ❌ ERROR: $e', e: e, s: s);
//     rethrow;
//   }
// }
```

#### File: `lib/fitur/transaksi/transaksi_provider_usang.dart`
```dart
// // path: lib/fitur/transaksi/provider/transaksi_provider.dart

// import 'dart:async';

// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
// import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
// import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
// import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
// import 'package:wifi/shared/debug/log.dart';

// part 'transaksi_provider.freezed.dart';
// part 'transaksi_provider.g.dart';

// /// Data mentah paket terlaris sebelum di-resolve detailnya.
// class PaketTerlarisMentah {
//   final String id;
//   final int totalTerjual;
//   const PaketTerlarisMentah(this.id, this.totalTerjual);
// }

// @freezed
// abstract class TransaksiState with _$TransaksiState {
//   const factory TransaksiState({
//     @Default([]) List<TransaksiModel> transaksi,
//     @Default(0.0) double totalPemasukan,
//     @Default(0.0) double totalPengeluaran,
//     @Default(0.0) double total,
//     @Default(0) int totalPoinSemuaPelanggan,
//     @Default([]) List<PaketTerlarisMentah> paketTerlaris,
//     @Default([]) List<double> pendapatanHarian,
//     @Default([]) List<double> pendapatanMingguan,
//     @Default([]) List<double> pendapatanBulanan,
//     @Default([]) double pendapatanBulanIni,
//   }) = _TransaksiState;
// }

// @riverpod
// class Transaksi extends _$Transaksi {
//   TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);

//   @override
//   Future<TransaksiState> build() async {
//     final transaksi = await _transaksiOp.ambilSemua();
//     return TransaksiState(transaksi: transaksi);
//   }

//   Future<TransaksiState> _loadData() async {
//     Log.info('[TransaksiProvider] 🔄 Memuat satu data utama via ambilSemua()');

//     // 1. Single Source of Truth: Hanya panggil 1 fungsi async ke database
//     final semuaTransaksi = await _transaksiOp.ambilSemua();
//     final sekarang = DateTime.now();

//     // 2. Kalkulasi statistik pemasukan & pengeluaran secara sinkron di memori HP
//     final totalPemasukan = semuaTransaksi
//         .where(
//           (t) =>
//               t.tipe == TipeTransaksi.income &&
//               t.statusPembayaran == StatusPembayaran.paid,
//         )
//         .fold(0.0, (sum, t) => sum + t.jumlah);
//     final totalPengeluaran = semuaTransaksi
//         .where((t) => t.tipe == TipeTransaksi.expense)
//         .fold(0.0, (sum, t) => sum + t.jumlah);
//     final netTotal = totalPemasukan - totalPengeluaran;
//     final totalPoinSemua = semuaTransaksi.fold(
//       0,
//       (sum, t) => sum + (t.poinDidapat - t.poinDigunakan),
//     );
//     final pendapatanBulanIni = semuaTransaksi
//         .where(
//           (t) =>
//               t.tipe == TipeTransaksi.income &&
//               t.statusPembayaran == StatusPembayaran.paid &&
//               t.tanggal.month == sekarang.month &&
//               t.tanggal.year == sekarang.year,
//         )
//         .fold(0.0, (sum, t) => sum + t.jumlah);
//     return TransaksiState(
//       transaksi: semuaTransaksi,
//       totalPemasukan: totalPemasukan,
//       totalPengeluaran: totalPengeluaran,
//       total: netTotal,
//       totalPoinSemuaPelanggan: totalPoinSemua,
//       pendapatanBulanIni: pendapatanBulanIni,
//       paketTerlaris: _hitungPaketTerlaris(semuaTransaksi),
//       pendapatanHarian: _hitungPendapatanHarian(semuaTransaksi),
//       pendapatanMingguan: _hitungPendapatanMingguan(semuaTransaksi),
//       pendapatanBulanan: _hitungPendapatanBulanan(semuaTransaksi),
//     );
//   }

//   // --- HELPER METODE UNTUK MEMPROSES GRAFIK & STATISTIK ---
//   List<PaketTerlarisMentah> _hitungPaketTerlaris(List<TransaksiModel> list) {
//     final jumlahPerPaket = <String, int>{};

//     for (final t in list) {
//       if (t.idPaket != null && t.statusPembayaran == StatusPembayaran.paid) {
//         jumlahPerPaket[t.idPaket!] = (jumlahPerPaket[t.idPaket!] ?? 0) + 1;
//       }
//     }

//     final sortedEntries = jumlahPerPaket.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     return sortedEntries
//         .take(5)
//         .map((e) => PaketTerlarisMentah(e.key, e.value))
//         .toList();
//   }

//   List<double> _hitungPendapatanHarian(List<TransaksiModel> list) {
//     final hasil = List<double>.filled(7, 0.0);
//     final sekarang = DateTime.now();

//     for (var i = 0; i < 7; i++) {
//       final targetTanggal = sekarang.subtract(Duration(days: i));

//       final totalHariItu = list
//           .where(
//             (t) =>
//                 t.tipe == TipeTransaksi.income &&
//                 t.statusPembayaran == StatusPembayaran.paid &&
//                 t.tanggal.day == targetTanggal.day &&
//                 t.tanggal.month == targetTanggal.month &&
//                 t.tanggal.year == targetTanggal.year,
//           )
//           .fold(0.0, (sum, t) => sum + t.jumlah);

//       hasil[6 - i] = totalHariItu; // Mengurutkan dari hari terlama ke hari ini
//     }
//     return hasil;
//   }

//   List<double> _hitungPendapatanMingguan(List<TransaksiModel> list) {
//     final hasil = List<double>.filled(4, 0.0);
//     final sekarang = DateTime.now();

//     for (var i = 0; i < 4; i++) {
//       final batasBawah = sekarang.subtract(Duration(days: (i + 1) * 7));
//       final batasAtas = sekarang.subtract(Duration(days: i * 7));

//       final totalMingguItu = list
//           .where((t) {
//             if (t.tipe != TipeTransaksi.income ||
//                 t.statusPembayaran != StatusPembayaran.paid) {
//               return false;
//             }
//             return t.tanggal.isAfter(batasBawah) &&
//                 t.tanggal.isBefore(batasAtas.add(const Duration(days: 1)));
//           })
//           .fold(0.0, (sum, t) => sum + t.jumlah);

//       hasil[3 - i] =
//           totalMingguItu; // Mengurutkan dari 4 minggu lalu ke minggu ini
//     }
//     return hasil;
//   }

//   List<double> _hitungPendapatanBulanan(List<TransaksiModel> list) {
//     final hasil = List<double>.filled(5, 0.0);
//     final sekarang = DateTime.now();

//     for (var i = 0; i < 5; i++) {
//       var targetBulan = sekarang.month - i;
//       var targetTahun = sekarang.year;

//       while (targetBulan <= 0) {
//         targetBulan += 12;
//         targetTahun -= 1;
//       }

//       final totalBulanItu = list
//           .where(
//             (t) =>
//                 t.tipe == TipeTransaksi.income &&
//                 t.statusPembayaran == StatusPembayaran.paid &&
//                 t.tanggal.month == targetBulan &&
//                 t.tanggal.year == targetTahun,
//           )
//           .fold(0.0, (sum, t) => sum + t.jumlah);

//       hasil[4 - i] =
//           totalBulanItu; // Mengurutkan dari 5 bulan lalu ke bulan ini
//     }
//     return hasil;
//   }

//   Future<void> tambah(TransaksiModel transaksi) async {
//     try {
//       await _transaksiOp.tambahTransaksi(transaksi);
//     } on Exception catch (e, s) {
//       Log.error('Error ditambah: $e', e: e, s: s);
//       rethrow;
//     }
//   }

//   Future<void> refresh() async {
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(_loadData);
//   }

//   void invalidateProviderTransaksi() {
//     ref.invalidateSelf();
//     ref.invalidate(riwayatTransaksiPelangganProvider);
//   }
// }

// @Riverpod(keepAlive: true)
// Future<({List<TransaksiModel> transaksi, int totalPoin})>
// riwayatTransaksiPelanggan(Ref ref, String idPelanggan) async {
//   Log.info(
//     '[RiwayatTransaksi] 🔍 Mengambil riwayat transaksi untuk pelanggan: $idPelanggan',
//   );
//   try {
//     final transaksiOp = ref.read(transaksiOpGlobalProvider);
//     final results = await Future.wait([
//       transaksiOp.ambilBerdasarkanIdPelanggan(idPelanggan),
//       transaksiOp.ambilTotalPoin(idPelanggan),
//     ]);
//     final semuaTransaksi = results[0] as List<TransaksiModel>;
//     final totalPoinUser = results[1] as int;
//     Log.info('[RiwayatTransaksi] 📊 Total transaksi: ${semuaTransaksi.length}');
//     Log.info('[RiwayatTransaksi] 🎯 Total poin: $totalPoinUser');
//     return (transaksi: semuaTransaksi, totalPoin: totalPoinUser);
//   } catch (e, s) {
//     Log.error('[RiwayatTransaksi] ❌ ERROR: $e', e: e, s: s);
//     rethrow;
//   }
// }

// @riverpod
// Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
//   Ref ref,
//   String idPelanggan,
// ) async {
//   Log.info(
//     '[RiwayatPoin] 🔍 Mengambil riwayat poin untuk pelanggan: $idPelanggan',
//   );
//   try {
//     final transaksiOp = ref.read(transaksiOpGlobalProvider);
//     final semuaTransaksi = await transaksiOp.ambilBerdasarkanIdPelanggan(
//       idPelanggan,
//     );
//     Log.info('[RiwayatPoin] 📊 Total transaksi: ${semuaTransaksi.length}');
//     return semuaTransaksi;
//   } catch (e, s) {
//     Log.error('[RiwayatPoin] ❌ ERROR: $e', e: e, s: s);
//     rethrow;
//   }
// }
```

#### File: `lib/fitur/transaksi/widget/daftar_transaksi_widget.dart`
```dart
// path lib/fitur/transaksi/widget/daftar_transaksi_widget.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Mengelompokkan daftar transaksi berdasarkan tanggal (tanpa jam).
Map<DateTime, List<TransaksiModel>> kelompokkanTransaksiPerTanggal(
  final List<TransaksiModel> transaksi,
) {
  final kelompok = <DateTime, List<TransaksiModel>>{};
  for (final transaksi in transaksi) {
    final tanggal = DateTime(
      transaksi.tanggal.year,
      transaksi.tanggal.month,
      transaksi.tanggal.day,
    );
    kelompok[tanggal] ??= [];
    kelompok[tanggal]!.add(transaksi);
  }
  return kelompok;
}

/// Membangun widget header untuk sebuah seksi transaksi berdasarkan tanggal.
Widget bangunHeaderBagian(DateTime tanggal, double total) {
  return Builder(
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FormatTanggal.formatSingkat(tanggal),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              FormatUang.formatMataUang(total),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: total >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Widget tile untuk menampilkan satu transaksi dalam daftar.
class TileTransaksi extends ConsumerStatefulWidget {
  final TransaksiModel transaksi;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TileTransaksi({
    super.key,
    required this.transaksi,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  ConsumerState<TileTransaksi> createState() => _StateTileTransaksi();
}

class _StateTileTransaksi extends ConsumerState<TileTransaksi> {
  late final KategoriOpSqlite _kategoriOpSqlite;
  late final DompetOpSqlite _dompetOpSqlite;

  @override
  void initState() {
    super.initState();
    _kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    _dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    Log.info('TransactionTile initState for ID: ${widget.transaksi.id}');
  }

  @override
  void dispose() {
    Log.info('TransactionTile dispose for ID: ${widget.transaksi.id}');
    super.dispose();
  }

  Future<String> ambilNamaKategori() async {
    if (widget.transaksi.idKategori.isEmpty) {
      return 'Tanpa Kategori';
    }
    try {
      final kategori = await _kategoriOpSqlite.ambilKategoriBerdasarkanId(
        widget.transaksi.idKategori,
      );
      return kategori.nama;
    } catch (e, st) {
      Log.error(
        'Gagal mendapatkan nama kategori untuk ID: ${widget.transaksi.idKategori}',
        e: e,
        s: st,
      );
      return 'Error Kategori';
    }
  }

  Future<String> _ambilNamaDompet() async {
    if (widget.transaksi.idDompet.isEmpty) {
      return 'Tanpa Dompet';
    }
    try {
      final dompet = await _dompetOpSqlite.ambilBerdasarkanId(
        widget.transaksi.idDompet,
      );
      return dompet?.nama ?? 'Dompet Dihapus';
    } catch (e, st) {
      Log.error(
        'Gagal mendapatkan nama dompet untuk ID: ${widget.transaksi.idDompet}',
        e: e,
        s: st,
      );
      return 'Error Dompet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final IconData ikon;
    final Color warnaIkon;
    if (widget.transaksi.tipe == TipeTransaksi.income) {
      ikon = Icons.arrow_downward;
      warnaIkon = Colors.green;
    } else {
      ikon = Icons.arrow_upward;
      warnaIkon = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        key: ValueKey(widget.transaksi.id),
        onTap: widget.onTap,
        onLongPress: () {
          if (widget.onEdit == null && widget.onDelete == null) return;
          unawaited(
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Opsi'),
                content: const Text(
                  'Apa yang ingin Anda lakukan dengan transaksi ini?',
                ),
                actions: [
                  if (widget.onEdit != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEdit!();
                      },
                      child: const Text('Edit'),
                    ),
                  if (widget.onDelete != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete!();
                      },
                      child: const Text('Hapus'),
                    ),
                ],
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: warnaIkon.withAlpha(25),
          child: Icon(ikon, color: warnaIkon),
        ),
        title: Text(widget.transaksi.deskripsi),
        subtitle: FutureBuilder<List<String>>(
          future: Future.wait([ambilNamaKategori(), _ambilNamaDompet()]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Memuat...');
            }
            if (snapshot.hasError) {
              Log.error(
                'Error di FutureBuilder TransactionTile untuk ID: ${widget.transaksi.id}',
                e: snapshot.error,
                s: snapshot.stackTrace,
              );
              return Text(
                'Error memuat data',
                style: textTheme.bodyMedium?.copyWith(color: Colors.red),
              );
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
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: warnaIkon,
              ),
            ),
            gapH4,
            Text(
              FormatJam.formatJamMenit(widget.transaksi.tanggal),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Membangun widget [TileTransaksi] dengan parameter yang diberikan.
Widget bangunItemTransaksi(
  final BuildContext context,
  final TransaksiModel transaksi, {
  final VoidCallback? onTap,
  final VoidCallback? onEdit,
  final VoidCallback? onDelete,
}) {
  return TileTransaksi(
    transaksi: transaksi,
    onTap: onTap,
    onEdit: onEdit,
    onDelete: onDelete,
  );
}
```


