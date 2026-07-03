# Dokumentasi Fitur: poin

## Daftar file

- [lib/fitur/poin/operasi/firebase_points_data_source.dart](../../lib/fitur/poin/operasi/firebase_points_data_source.dart)
- [lib/fitur/poin/operasi/sqlite_points_data_source.dart](../../lib/fitur/poin/operasi/sqlite_points_data_source.dart)
- [lib/fitur/poin/page/halaman_poin.dart](../../lib/fitur/poin/page/halaman_poin.dart)
- [lib/fitur/poin/poin.dart](../../lib/fitur/poin/poin.dart)
- [lib/fitur/poin/provider/points_page_data_source.dart](../../lib/fitur/poin/provider/points_page_data_source.dart)
- [lib/fitur/poin/service/poin_transaction_service.dart](../../lib/fitur/poin/service/poin_transaction_service.dart)
- [lib/fitur/poin/widget/kartu_total_poin.dart](../../lib/fitur/poin/widget/kartu_total_poin.dart)
- [lib/fitur/poin/widget/ui_halaman_poin.dart](../../lib/fitur/poin/widget/ui_halaman_poin.dart)

## Isi file

### File: `lib/fitur/poin/operasi/firebase_points_data_source.dart`
```dart
// path: lib/fitur/poin/poin/firebase_points_data_source.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_firebase.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

/// Implementasi [PointsPageDataSource] untuk mengambil data dari Firebase.
class FirebasePointsDataSource implements PointsPageDataSource {
  final TransaksiOpFirebase _transactionOpFirebase;
  final PaketOpFirebase _packageOpFirebase;

  FirebasePointsDataSource({
    required TransaksiOpFirebase transactionOpFirebase,
    required PaketOpFirebase packageOpFirebase,
  }) : _transactionOpFirebase = transactionOpFirebase,
       _packageOpFirebase = packageOpFirebase;

  @override
  Future<int> ambilTotalPoin(String customerId) {
    return _transactionOpFirebase.ambilTotalPoin(customerId);
  }

  @override
  Future<List<PaketModel>> getPublicPackages() {
    return _packageOpFirebase.ambilPaketPublik();
  }

  @override
  Future<List<TransaksiModel>> getPointsTransactions(String customerId) async {
    final history = await _transactionOpFirebase.ambilBerdasarkanIdPelanggan(
      customerId,
    );
    return history
        .where((t) => t.poinDidapat > 0 || t.poinDigunakan > 0)
        .toList();
  }

  @override
  Future<PaketModel?> getPaketByid(String packageId) {
    return _packageOpFirebase.ambilBerdasarkanId(packageId);
  }

  @override
  bool get isFirebase => true;
}

final firebasePointsDataSourceProvider = Provider<FirebasePointsDataSource>((
  ref,
) {
  return FirebasePointsDataSource(
    transactionOpFirebase: ref.watch(transaksiOpFirebaseProvider),
    packageOpFirebase: ref.watch(paketOpFirebaseProvider),
  );
});
```

### File: `lib/fitur/poin/operasi/sqlite_points_data_source.dart`
```dart
// path: lib/fitur/poin/operasi/sqlite_points_data_source.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

class SQLitePointsDataSource implements PointsPageDataSource {
  final TransaksiOpSqlite _transaksiOpSqlite;
  final PaketOpSqlite _paketOpSqlite;

  SQLitePointsDataSource({
    required TransaksiOpSqlite transaksiOpSqlite,
    required PaketOpSqlite paketOpSqlite,
  }) : _transaksiOpSqlite = transaksiOpSqlite,
       _paketOpSqlite = paketOpSqlite;

  @override
  Future<int> ambilTotalPoin(String customerId) {
    return _transaksiOpSqlite.ambilTotalPoin(customerId);
  }

  @override
  Future<List<PaketModel>> getPublicPackages() {
    return _paketOpSqlite.ambilPaketPublik();
  }

  @override
  Future<List<TransaksiModel>> getPointsTransactions(
    final String customerId,
  ) async {
    final history = await _transaksiOpSqlite.ambilBerdasarkanIdPelanggan(
      customerId,
    );
    return history
        .where((t) => t.poinDidapat > 0 || t.poinDigunakan > 0)
        .toList();
  }

  @override
  Future<PaketModel?> getPaketByid(String packageId) {
    return _paketOpSqlite.ambilBerdasarkanId(packageId);
  }

  @override
  bool get isFirebase => false;
}

final sqlitePointsDataSourceProvider = Provider<SQLitePointsDataSource>((ref) {
  return SQLitePointsDataSource(
    transaksiOpSqlite: ref.watch(transaksiOpSqliteProvider),
    paketOpSqlite: ref.watch(paketOpSqliteProvider),
  );
});
```

### File: `lib/fitur/poin/page/halaman_poin.dart`
```dart
// path lib/fitur/poin/page/halaman_poin.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/order/provider/order_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/poin/poin.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_a.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';
import 'package:wifi/user/providers/user_provider.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';
import 'package:wifi/user/widget/ads/interstitial/layanan_iklan_interstisial.dart';

class HalamanPoin extends ConsumerStatefulWidget {
  final String idPelanggan;

  const HalamanPoin({super.key, required this.idPelanggan});

  @override
  ConsumerState<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends ConsumerState<HalamanPoin> {
  late final LayananIklanInterstisial _layananIklanInterstisial;
  OpsiMenuPoin _menuAktif = OpsiMenuPoin.penukaran;
  late final Widget _judulAppBar;
  bool _sedangTukarPoin = false;
  String? _idRewardYangDiproses;
  @override
  void initState() {
    super.initState();
    _layananIklanInterstisial = LayananIklanInterstisial();
    _judulAppBar = Row(
      children: [
        Expanded(child: NamaPelangganWidget(idPelanggan: widget.idPelanggan)),
      ],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await ref.read(userIdProvider.future);
      if (userId != null && userId.isNotEmpty) {
        Log.info('Preloading interstitial ad for PointsPage.');
        unawaited(
          _layananIklanInterstisial.preloadAd().catchError((Object e) {
            Log.warning('Failed to preload interstitial ad: $e');
          }),
        );
      }
    });
  }

  Future<void> _tukarPoin(PaketModel hadiah, int poinSaatIni) async {
    if (_sedangTukarPoin) return;

    setState(() {
      _sedangTukarPoin = true;
      _idRewardYangDiproses = hadiah.id;
    });

    try {
      if (ref.isAdmin) {
        Log.warning('Admin mencoba menukar poin, operasi diblokir.');
        ToastUtil.error(
          context,
          'Admin tidak dapat menukar poin dari antarmuka ini.',
        );
        return;
      }

      final isOnline = await ref
          .read(koneksiInternetServiceProvider)
          .cekInternet();
      if (!mounted) return;
      if (!isOnline) {
        ToastUtil.warning(context, 'Cek koneksi internet Anda');
        return;
      }

      // 3. Validasi Poin
      final poinCukup = poinSaatIni >= hadiah.poinPenukaran;
      if (!kDebugMode && !poinCukup) {
        ToastUtil.warning(
          context,
          'Poin Anda tidak mencukupi untuk menukar hadiah ini.',
        );
        return;
      }

      // 4. Konfirmasi User
      final dikonfirmasi = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Penukaran'),
          content: Text('Anda yakin ingin menukar poin dengan ${hadiah.nama}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Tukar'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (!(dikonfirmasi == true)) {
        Log.info('Penukaran dibatalkan oleh user');
        return;
      }
      Log.info('Pengguna mengonfirmasi penukaran untuk: ${hadiah.nama}');
      if (mounted) {
        unawaited(
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const SizedBox(
              width: 25,
              height: 25,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      }
      try {
        Log.info('Lanjut ke penukaran poin');
        final transactionService = ref.read(poinTransactionServiceProvider);
        await transactionService.tukarPoin(
          idPelanggan: widget.idPelanggan,
          paket: hadiah,
          poinSaatIni: poinSaatIni,
        );
        _invalidateProviderTerkait(null, widget.idPelanggan);
        if (mounted) {
          ToastUtil.success(
            context,
            'Order sudah terkirim menunggu konfirmasi Admin',
          );
        }
      } catch (e, st) {
        Log.error(
          'Gagal menukar poin',
          e: e,
          s: st,
          data: {'customerId': widget.idPelanggan, 'packageId': hadiah.id},
        );
        if (mounted) {
          ToastUtil.error(
            context,
            'Terjadi kesalahan saat menukar poin: ${e.toString()}',
          );
        }
      } finally {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangTukarPoin = false;
          _idRewardYangDiproses = null;
        });
      }
    }
  }

  Future<void> _navigasiKeDetailTransaksi(TransaksiModel transaksi) async {
    if (!mounted) return;
    Log.info('Navigating to transaction detail for ID: ${transaksi.id}');
    PaketModel? paket;
    if (transaksi.idPaket != null && transaksi.idPaket!.isNotEmpty) {
      try {
        final paketOp = ref.read(paketOpGlobalProvider);
        paket = await paketOp.ambilBerdasarkanId(transaksi.idPaket!);
      } on Exception catch (e, st) {
        Log.error(
          'Failed to get package ${transaksi.idPaket}: $e',
          e: e,
          s: st,
        );
      }
    }

    if (!mounted) return;
    if (ref.isUser) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailTransaksiU(transaksi: transaksi, paket: paket),
        ),
      );
    } else {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTransaksiA(transaksi: transaksi),
        ),
      );
    }
  }

  void _invalidateProviderTerkait(String? idDompet, String? idPelanggan) {
    ref.read(transaksiOpGlobalProvider).invalidate(idDompet);
    ref.read(orderProvider.notifier).invalidate();
    if (ref.isAdmin) {
      ref.read(pelangganAktifProvider.notifier).invalidatePelangganAktif();
    }
    ref.read(pelangganProvider.notifier).invalidateDetailPelanggan(idPelanggan);
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Building PointsPage UI, selected menu: $_menuAktif');
    final dataAsync = ref.watch(
      riwayatTransaksiPelangganProvider(widget.idPelanggan),
    );
    final daftarHadiah = ref.watch(paketProvider);
    return dataAsync.when(
      skipLoadingOnReload: true,
      loading: () => Scaffold(
        appBar: AppBar(title: _judulAppBar),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: _judulAppBar),
        body: Center(child: Text('Error: $e')),
      ),
      data: (dataHalaman) {
        return UiHalamanPoin(
          appBarTitle: _judulAppBar,
          totalPoin: dataHalaman.totalPoin,
          menuPilihan: _menuAktif,
          onSelectionChanged: (newSelection) async {
            final selection = newSelection.first;
            Log.info('Points menu changed to: $selection');
            setState(() => _menuAktif = selection);

            if (selection == OpsiMenuPoin.riwayat && ref.isUser) {
              await _layananIklanInterstisial.show();
            }
          },
          contentView: _menuAktif == OpsiMenuPoin.penukaran
              ? daftarHadiah.when(
                  skipLoadingOnReload: true,
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (state) => _buildDaftarHadiah(
                    state.daftarPaketPublik,
                    dataHalaman.totalPoin,
                  ),
                )
              : _buildRiwayatPoin(),
          bottomWidget: ref.isUser ? const BannerAdsWidget() : null,
        );
      },
    );
  }

  Widget _buildDaftarHadiah(List<PaketModel?> daftarHadiah, int totalPoin) {
    Log.info('Building reward list.');
    if (daftarHadiah.isEmpty) {
      return const Center(child: Text('Belum ada hadiah yang tersedia'));
    }
    return ListView.builder(
      itemCount: daftarHadiah.length,
      itemBuilder: (context, index) {
        final hadiah = daftarHadiah[index];
        final poinCukup = totalPoin >= hadiah!.poinPenukaran;
        final progress = hadiah.poinPenukaran > 0
            ? (totalPoin / hadiah.poinPenukaran).clamp(0.0, 1.0)
            : 1.0;
        final selisihPoin = totalPoin - hadiah.poinPenukaran;
        final sedangMemprosesRewardIni =
            _sedangTukarPoin && _idRewardYangDiproses == hadiah.id;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(hadiah.nama),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${hadiah.poinPenukaran} Poin'),
                    ElevatedButton(
                      onPressed: sedangMemprosesRewardIni
                          ? null
                          : () => _tukarPoin(hadiah, totalPoin),
                      child: const Text('Tukar'),
                    ),
                  ],
                ),
                gapH4,
                LinearProgressIndicator(value: progress, minHeight: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Poin: $totalPoin / ${hadiah.poinPenukaran}',
                      style: TextStyle(
                        fontSize: 12,
                        color: poinCukup ? Colors.green : Colors.grey,
                      ),
                    ),
                    Text(
                      '$selisihPoin',
                      style: TextStyle(
                        color: poinCukup ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
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

  Widget _buildRiwayatPoin() {
    Log.info('Building points history.');
    final riwayatAsync = ref.watch(
      riwayatTransaksiPelangganProvider(widget.idPelanggan),
    );
    return riwayatAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
        final semuaTransaksi = data.transaksi;
        final riwayatPoin = semuaTransaksi
            .where((t) => t.poinDidapat > 0 || t.poinDigunakan > 0)
            .toList();
        if (riwayatPoin.isEmpty) {
          return const Center(child: Text('Belum ada riwayat poin'));
        }
        return ListView.builder(
          itemCount: riwayatPoin.length,
          itemBuilder: (context, index) {
            final transaksi = riwayatPoin[index];
            final apakahPenambahan = transaksi.poinDidapat > 0;
            final nilaiPoin = apakahPenambahan
                ? transaksi.poinDidapat
                : transaksi.poinDigunakan;
            final teksPoin = apakahPenambahan ? '+$nilaiPoin' : '-$nilaiPoin';
            final apakahBelumBayar =
                transaksi.statusPembayaran == StatusPembayaran.unpaid;
            final Color warnaPoin = apakahBelumBayar
                ? Colors.grey
                : apakahPenambahan
                ? Colors.green
                : Colors.red;
            return InkWell(
              onTap: () => _navigasiKeDetailTransaksi(transaksi),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    apakahBelumBayar
                        ? TIcons.hourglass
                        : apakahPenambahan
                        ? TIcons.arrowUp
                        : TIcons.arrowDown,
                    color: warnaPoin,
                  ),
                  title: Text(transaksi.deskripsi),
                  subtitle: Text(FormatTanggal.formatDasar(transaksi.tanggal)),
                  trailing: Text(
                    teksPoin,
                    style: TextStyle(
                      color: warnaPoin,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
```

### File: `lib/fitur/poin/poin.dart`
```dart
// path: lib/fitur/poin/poin.dart

export 'package:wifi/fitur/poin/operasi/firebase_points_data_source.dart';
export 'package:wifi/fitur/poin/operasi/sqlite_points_data_source.dart';
export 'package:wifi/fitur/poin/page/halaman_poin.dart';
export 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
export 'package:wifi/fitur/poin/service/poin_transaction_service.dart';
export 'package:wifi/fitur/poin/widget/kartu_total_poin.dart';
export 'package:wifi/fitur/poin/widget/ui_halaman_poin.dart';
```

### File: `lib/fitur/poin/provider/points_page_data_source.dart`
```dart
// path: lib/fitur/poin/provider/points_page_data_source.dart

import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';

abstract class PointsPageDataSource {
  Future<int> ambilTotalPoin(String customerId);

  Future<List<PaketModel>> getPublicPackages();

  Future<List<TransaksiModel>> getPointsTransactions(String customerId);

  Future<PaketModel?> getPaketByid(String packageId);

  bool get isFirebase;
}
```

### File: `lib/fitur/poin/service/poin_transaction_service.dart`
```dart
// path: lib/fitur/poin/service/poin_transaction_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/notifikasi/enum/tipe_notifikasi_enum.dart';
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/fitur/order/enum/status_order_enum.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';

/// Service untuk menangani transaksi penukaran poin dengan Firestore Transaction.
class PoinTransactionService {
  final BaseOpFirebase _baseOpFirebase;
  PoinTransactionService({required BaseOpFirebase baseOpFirebase})
    : _baseOpFirebase = baseOpFirebase {
    Log.info('PoinTransactionService diinisialisasi.');
  }

  /// Menukar poin dengan paket menggunakan Firestore Transaction
  ///
  /// Menggunakan BaseOpFirebase.runComplexOperation untuk konsistensi
  /// dengan pattern yang sudah ada di seluruh aplikasi.
  Future<void> tukarPoin({
    required String idPelanggan,
    required PaketModel paket,
    required int poinSaatIni,
  }) async {
    Log.info('Memulai transaksi penukaran poin', {
      'customerId': idPelanggan,
      'packageId': paket.id,
      'packageName': paket.nama,
      'pointsNeeded': paket.poinPenukaran,
      'currentPoints': poinSaatIni,
    });

    // Validasi awal sebelum transaction
    if (!kDebugMode && poinSaatIni < paket.poinPenukaran) {
      Log.warning('Poin tidak mencukupi untuk penukaran', {
        'customerId': idPelanggan,
        'currentPoints': poinSaatIni,
        'neededPoints': paket.poinPenukaran,
      });
      throw Exception('Poin tidak mencukupi');
    }

    try {
      // Gunakan BaseOpFirebase.runComplexOperation
      await _baseOpFirebase.operasiKompleks((txn) async {
        Log.info('Transaksi Firestore dimulai melalui BaseOpFirebase');

        // 1. BACA DATA PELANGGAN
        final pelangganRef = _baseOpFirebase.firestore
            .collection(NamaTabel.pelanggan)
            .doc(idPelanggan);
        final pelangganDoc = await txn.get(pelangganRef);

        if (!pelangganDoc.exists) {
          Log.error(
            'Pelanggan tidak ditemukan',
            data: {'customerId': idPelanggan},
          );
          throw Exception('Pelanggan tidak ditemukan');
        }

        // 2. HITUNG ULANG POIN DARI TRANSAKSI
        // PERBAIKAN: Gunakan firestore langsung untuk query, bukan txn.get()
        final transaksiSnapshot = await _baseOpFirebase.firestore
            .collection(NamaTabel.transaksi)
            .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
            .where(NamaKolom.dihapus, isEqualTo: false)
            .where(
              NamaKolom.statusPembayaran,
              isEqualTo: StatusPembayaran.paid.name,
            )
            .get();

        var totalPoin = 0;
        for (final doc in transaksiSnapshot.docs) {
          final data = doc.data();
          totalPoin += (data[NamaKolom.poinDidapat] as int? ?? 0);
          totalPoin -= (data[NamaKolom.poinDigunakan] as int? ?? 0);
        }

        Log.info('Total poin dihitung ulang', {
          'customerId': idPelanggan,
          'totalPoints': totalPoin,
        });

        // 3. VALIDASI POIN
        if (!kDebugMode && totalPoin < paket.poinPenukaran) {
          Log.warning('Poin tidak mencukupi setelah perhitungan ulang', {
            'customerId': idPelanggan,
            'totalPoints': totalPoin,
            'neededPoints': paket.poinPenukaran,
          });
          throw Exception(
            'Poin tidak mencukupi (total: $totalPoin, dibutuhkan: ${paket.poinPenukaran})',
          );
        }

        // 4. BUAT DATA YANG DIPERLUKAN
        final now = DateTime.now();
        final idTransaksi = const Uuid().v4();
        final idOrder = const Uuid().v4();
        final idPelangganAktif = const Uuid().v4();

        // Gunakan PerhitunganUtil yang sudah ada
        final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
          now,
          paket,
        );

        // 4a. Transaksi
        final transaksiBaru = TransaksiModel(
          id: idTransaksi,
          tanggal: now,
          deskripsi: 'Tukar Poin: ${paket.nama}',
          jumlah: 0,
          tipe: TipeTransaksi.expense,
          idDompet: '',
          idKategori: '',
          idPaket: paket.id,
          idPelanggan: idPelanggan,
          poinDigunakan: paket.poinPenukaran,
          tanggalMulai: now,
          tanggalBerakhir: tanggalBerakhir,
          statusAktivasi: true,
          diperbaruiPada: now.toUtc(),
        );

        // 4b. Pelanggan Aktif
        final pelangganAktifBaru = PelangganAktifModel(
          id: idPelangganAktif,
          idPelanggan: idPelanggan,
          idPaket: paket.id,
          idTransaksi: idTransaksi,
          tanggalMulai: now,
          tanggalBerakhir: tanggalBerakhir,
          status: StatusPembayaran.paid,
          diperbaruiPada: now.toUtc(),
        );

        // 4c. Order
        final orderBaru = OrderModel(
          id: idOrder,
          idPelanggan: idPelanggan,
          idPaket: paket.id,
          tanggal: now,
          status: StatusOrderEnum.baru,
          diperbaruiPada: now.toUtc(),
        );

        // 4d. Notifikasi untuk admin
        final notifikasiBaru = NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: now,
          tanggalBerakhir: now,
          tanggalTampil: now,
          judul: 'Order Paket',
          deskripsi: 'Pelanggan menukar poin untuk paket ${paket.nama}',
          tipe: TipeNotifikasiEnum.order,
          diperbaruiPada: now.toUtc(),
          idTujuan: idOrder,
          userId: idPelanggan,
          targetRole: AppRole.admin,
        );

        // 5. SIMPAN SEMUA DATA DALAM SATU TRANSACTION
        Log.info('Menyimpan semua data dalam transaction...', {
          'transactionId': idTransaksi,
          'orderId': idOrder,
          'activeCustomerId': idPelangganAktif,
        });

        // Simpan transaksi
        txn.set(
          _baseOpFirebase.firestore
              .collection(NamaTabel.transaksi)
              .doc(idTransaksi),
          transaksiBaru.toFirebase(),
        );

        // Simpan pelanggan aktif
        txn.set(
          _baseOpFirebase.firestore
              .collection(NamaTabel.pelangganAktif)
              .doc(idPelangganAktif),
          pelangganAktifBaru.toFirebase(),
        );

        // Simpan order
        txn.set(
          _baseOpFirebase.firestore
              .collection(NamaTabel.pesananPelanggan)
              .doc(idOrder),
          orderBaru.toFirebase(),
        );

        // Simpan notifikasi
        txn.set(
          _baseOpFirebase.firestore
              .collection(NamaTabel.notifikasi)
              .doc(notifikasiBaru.id),
          notifikasiBaru.toFirebase(),
        );

        Log.info('Semua data berhasil disimpan dalam transaction');
      });

      Log.info('Transaksi penukaran poin BERHASIL', {
        'customerId': idPelanggan,
        'packageId': paket.id,
        'pointsUsed': paket.poinPenukaran,
      });
    } catch (e, st) {
      Log.error(
        'Transaksi penukaran poin GAGAL',
        e: e,
        s: st,
        data: {'customerId': idPelanggan, 'packageId': paket.id},
      );
      rethrow;
    }
  }
}

/// Provider untuk PoinTransactionService
final poinTransactionServiceProvider = Provider<PoinTransactionService>((ref) {
  final baseOpFirebase = ref.watch(baseOpFirebaseProvider);
  return PoinTransactionService(baseOpFirebase: baseOpFirebase);
});
```

### File: `lib/fitur/poin/widget/kartu_total_poin.dart`
```dart
// path lib/fitur/poin/widget/kartu_total_poin.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class KartuTotalPoin extends StatelessWidget {
  final int poin;
  final IconData icon;
  final Color warna;
  final VoidCallback? onTap;

  const KartuTotalPoin({
    super.key,
    required this.poin,
    this.icon = TIcons.points,
    this.warna = TColors.pointColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [warna, Color.lerp(warna, Colors.black, 0.25)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: warna.withAlpha(77),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withAlpha(26),
            highlightColor: Colors.white.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withAlpha(26),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  gapW20,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Poin',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white.withAlpha(204),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      gapH4,
                      Text(
                        FormatNomor.formatRibuan(poin),
                        style: textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/poin/widget/ui_halaman_poin.dart`
```dart
// path lib/fitur/poin/widget/ui_halaman_poin.dart

import 'package:flutter/material.dart';
import 'package:wifi/fitur/poin/widget/kartu_total_poin.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';

/// Menu yang tersedia di halaman poin.
enum OpsiMenuPoin {
  /// Menu penukaran hadiah.
  penukaran,

  /// Menu riwayat poin.
  riwayat,
}

/// UI halaman poin yang dapat digunakan kembali.
class UiHalamanPoin extends StatelessWidget {
  final Widget appBarTitle;
  final int totalPoin;
  final OpsiMenuPoin menuPilihan;
  final ValueChanged<Set<OpsiMenuPoin>> onSelectionChanged;
  final Widget contentView;
  final Widget? bottomWidget;

  const UiHalamanPoin({
    super.key,
    required this.appBarTitle,
    required this.totalPoin,
    required this.menuPilihan,
    required this.onSelectionChanged,
    required this.contentView,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: appBarTitle, elevation: 1),
      body: Column(
        children: [
          _buildInfoPoinHeader(context),
          _buildSegmentedControl(context),
          Expanded(child: contentView),
        ],
      ),
      // DIUBAH: Widget sekarang ditempatkan di sini.
      bottomNavigationBar: bottomWidget,
    );
  }

  Widget _buildInfoPoinHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Theme.of(context).primaryColor.withAlpha(15),
      child: Center(child: KartuTotalPoin(poin: totalPoin)),
    );
  }

  Widget _buildSegmentedControl(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    Widget buildSegment(
      final OpsiMenuPoin menu,
      final String label,
      final IconData icon,
    ) {
      final isSelected = menuPilihan == menu;
      return Expanded(
        child: InkWell(
          onTap: () => onSelectionChanged({menu}),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          splashColor: primaryColor.withAlpha(26),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
                gapH8,
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(102),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: menuPilihan == OpsiMenuPoin.penukaran
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withAlpha(204)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              buildSegment(OpsiMenuPoin.penukaran, 'Tukar Hadiah', TIcons.gift),
              buildSegment(
                OpsiMenuPoin.riwayat,
                'Riwayat Poin',
                TIcons.history,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

