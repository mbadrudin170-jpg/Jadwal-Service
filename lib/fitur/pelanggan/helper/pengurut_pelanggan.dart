// path lib/fitur/pelanggan/helper/pengurut_pelanggan.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';

part 'pengurut_pelanggan.g.dart';

enum UrutanPelanggan {
  namaAZ('Nama A-Z'),
  namaZa('Nama Z-A'),
  terakhirOnline('Aktivitas Terakhir (Terbaru)'),
  terbaruOnline('Aktivitas Terakhir (Terlama)'),
  poinTerbanyak('Poin (Tertinggi)'),
  poinTerkecil('Poin (Terendah)');

  const UrutanPelanggan(this.teks);
  final String teks;
}

@riverpod
class UrutanPelangganState extends _$UrutanPelangganState {
  @override
  UrutanPelanggan build() => UrutanPelanggan.namaAZ;
  void ubahUrutan(UrutanPelanggan urutanBaru) => state = urutanBaru;
}

/// Menghubungkan data pelanggan dengan perolehan total poinnya secara paralel
@riverpod
Future<List<(PelangganModel, int)>> pelangganDenganPoin(Ref ref) async {
  final pelangganState = await ref.watch(pelangganProvider.future);
  final transaksiNotifier = ref.watch(transaksiProvider.notifier);
  final daftarPelanggan = pelangganState.daftarPelanggan;
  final semuaPoin = await transaksiNotifier.getTotalPoinBanyakPelangganParallel(
    daftarPelanggan.map((p) => p.id).toList(),
  );
  return List.generate(
    daftarPelanggan.length,
    (i) => (daftarPelanggan[i], semuaPoin[i]),
  );
}

@riverpod
Future<List<(PelangganModel, int)>> filteredCustomers(Ref ref) async {
  final pelangganWithPoints = await ref.watch(
    pelangganDenganPoinProvider.future,
  );
  final searchQuery = ref.watch(searchQueryPelangganProvider).toLowerCase();
  final sortOption = ref.watch(urutanPelangganStateProvider);
  final filtered = pelangganWithPoints
      .where((tuple) => tuple.$1.nama.toLowerCase().contains(searchQuery))
      .toList();
  if (filtered.isNotEmpty) {
    switch (sortOption) {
      case UrutanPelanggan.namaAZ:
        filtered.sort(
          (a, b) => a.$1.nama.toLowerCase().compareTo(b.$1.nama.toLowerCase()),
        );
        break;
      case UrutanPelanggan.namaZa:
        filtered.sort(
          (a, b) => b.$1.nama.toLowerCase().compareTo(a.$1.nama.toLowerCase()),
        );
        break;
      case UrutanPelanggan.terakhirOnline:
        filtered.sort((a, b) {
          if (a.$1.terkahirAktif == null) return 1;
          if (b.$1.terkahirAktif == null) return -1;
          return b.$1.terkahirAktif!.compareTo(a.$1.terkahirAktif!);
        });
        break;
      case UrutanPelanggan.terbaruOnline:
        filtered.sort((a, b) {
          if (a.$1.terkahirAktif == null) return -1;
          if (b.$1.terkahirAktif == null) return 1;
          return a.$1.terkahirAktif!.compareTo(b.$1.terkahirAktif!);
        });
        break;
      case UrutanPelanggan.poinTerbanyak:
        filtered.sort((a, b) => b.$2.compareTo(a.$2));
        break;
      case UrutanPelanggan.poinTerkecil:
        filtered.sort((a, b) => a.$2.compareTo(b.$2));
        break;
    }
  }
  return filtered;
}
