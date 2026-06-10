// path: lib/fitur/akun/provider/akun_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'akun_provider.g.dart';
part 'akun_provider.freezed.dart';

@freezed
abstract class AkunState with _$AkunState {
  const factory AkunState({
    CustomerModel? akunSaatIni,
    @Default([]) List<CustomerModel> daftarAkunTersimpan,
  }) = _AkunState;
}

@Riverpod(keepAlive: true)
class PengelolaAkun extends _$PengelolaAkun {
  @override
  Future<AkunState> build() async {
    final penyimpanan = await ref.watch(localStorageServiceProvider.future);
    final akunSaatIni = await penyimpanan.ambilAkunLogin();
    final daftarAkun = await penyimpanan.ambilDaftarAkun();
    return AkunState(akunSaatIni: akunSaatIni, daftarAkunTersimpan: daftarAkun);
  }

  // 1. Login / simpan akun
  Future<void> login(CustomerModel akun) async {
    final penyimpanan = await ref.read(localStorageServiceProvider.future);

    await penyimpanan.simpanAkunSaatIni(akun);
    final daftarAkun = await penyimpanan.ambilDaftarAkun();
    if (!ref.mounted) return;
    state = AsyncValue.data(AkunState(
      akunSaatIni: akun,
      daftarAkunTersimpan: daftarAkun,
    ));
  }

  // 2. Logout (hapus akun saat ini)
  Future<void> logout() async {
    final penyimpanan = await ref.read(localStorageServiceProvider.future);

    await penyimpanan.hapusAkunSaatIni();
    final akunSaatIni = await penyimpanan.ambilAkunLogin();
    final daftarAkun = await penyimpanan.ambilDaftarAkun();
    if (!ref.mounted) return;
    state = AsyncValue.data(AkunState(
      akunSaatIni: akunSaatIni,
      daftarAkunTersimpan: daftarAkun,
    ));
  }

  // 3. Hapus akun tertentu dari daftar
  Future<void> hapusAkun(String idAkun) async {
    final penyimpanan = await ref.read(localStorageServiceProvider.future);

    final keadaanSaatIni = state.value;
    if (keadaanSaatIni == null) return;

    await penyimpanan.hapusAkun(idAkun);
    final daftarBaru = keadaanSaatIni.daftarAkunTersimpan
        .where((a) => a.id != idAkun)
        .toList();
    final akunBaru = keadaanSaatIni.akunSaatIni?.id == idAkun
        ? null
        : keadaanSaatIni.akunSaatIni;
    if (!ref.mounted) return;
    state = AsyncValue.data(AkunState(
      akunSaatIni: akunBaru,
      daftarAkunTersimpan: daftarBaru,
    ));
  }

  Future<void> hapusTokenLogin() async {
    final penyimpanan = await ref.read(localStorageServiceProvider.future);
    await penyimpanan.hapusTokenLogin();
    final akunSaatIni = await penyimpanan.ambilAkunLogin();
    if (!ref.mounted) return; // Pindah ke sini, setelah await terakhir
    state = AsyncValue.data(AkunState(
      akunSaatIni: akunSaatIni,
    ));
  }

  // 4. Segarkan manual (jika diperlukan)
  Future<void> refresh() async {
    final penyimpanan = await ref.read(localStorageServiceProvider.future);

    final akunSaatIni = await penyimpanan.ambilAkunLogin();
    final daftarAkun = await penyimpanan.ambilDaftarAkun();
    if (!ref.mounted) return;
    state = AsyncValue.data(AkunState(
      akunSaatIni: akunSaatIni,
      daftarAkunTersimpan: daftarAkun,
    ));
  }
}
