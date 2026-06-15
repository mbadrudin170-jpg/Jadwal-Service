// path: lib/fitur/akun/provider/akun_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'akun_provider.g.dart';
part 'akun_provider.freezed.dart';

@freezed
abstract class AkunState with _$AkunState {
  const factory AkunState({
    PelangganModel? akunSaatIni,
    @Default([]) List<PelangganModel> daftarAkunTersimpan,
  }) = _AkunState;
}

@Riverpod(keepAlive: true)
class PengelolaAkun extends _$PengelolaAkun {
  @override
  Future<AkunState> build() {
    return _initAwal(ref);
  }

  Future<AkunState> _initAwal(Ref ref) async {
    final penyimpananLokal =
        await ref.watch(layananPenyimpananLokalProvider.future);
    final akunSaatIni = await penyimpananLokal.ambilAkunLogin();
    final daftarAkun = await penyimpananLokal.ambilDaftarAkun();
    return AkunState(akunSaatIni: akunSaatIni, daftarAkunTersimpan: daftarAkun);
  }

  // 1. Login / simpan akun
  Future<void> login(PelangganModel akun) async {
    final penyimpananLokal =
        await ref.read(layananPenyimpananLokalProvider.future);

    await penyimpananLokal.simpanAkunSaatIni(akun);
    final daftarAkun = await penyimpananLokal.ambilDaftarAkun();
    state = AsyncValue.data(AkunState(
      akunSaatIni: akun,
      daftarAkunTersimpan: daftarAkun,
    ));
  }

  // 2. Logout (hapus akun saat ini)
  Future<void> logout() async {
    final penyimpananLokal =
        await ref.read(layananPenyimpananLokalProvider.future);

    await penyimpananLokal.hapusAkunSaatIni();
    final akunSaatIni = await penyimpananLokal.ambilAkunLogin();
    final daftarAkun = await penyimpananLokal.ambilDaftarAkun();
    state = AsyncValue.data(AkunState(
      akunSaatIni: akunSaatIni,
      daftarAkunTersimpan: daftarAkun,
    ));
  }

  // 3. Hapus akun tertentu dari daftar
  Future<void> hapusAkun(String id) async {
    final penyimpananLokal =
        await ref.read(layananPenyimpananLokalProvider.future);

    final keadaanSaatIni = state.value;
    if (keadaanSaatIni == null) return;

    await penyimpananLokal.hapusAkun(id);
    final daftarBaru =
        keadaanSaatIni.daftarAkunTersimpan.where((a) => a.id != id).toList();
    final akunBaru = keadaanSaatIni.akunSaatIni?.id == id
        ? null
        : keadaanSaatIni.akunSaatIni;
    state = AsyncValue.data(AkunState(
      akunSaatIni: akunBaru,
      daftarAkunTersimpan: daftarBaru,
    ));
  }

  Future<void> hapusTokenLogin() async {
    final penyimpananLokal =
        await ref.read(layananPenyimpananLokalProvider.future);
    await penyimpananLokal.hapusTokenLogin();

    final keadaanSaatIni = state.value;
    final akunSaatIni = await penyimpananLokal.ambilAkunLogin();
    final daftarAkun = keadaanSaatIni?.daftarAkunTersimpan ??
        await penyimpananLokal.ambilDaftarAkun();
    state = AsyncValue.data(AkunState(
      akunSaatIni: akunSaatIni,
      daftarAkunTersimpan: daftarAkun,
    ));
  }

  // 4. Segarkan manual (jika diperlukan)
  Future<void> refresh() async {
    final penyimpananLokal =
        await ref.read(layananPenyimpananLokalProvider.future);
    final akunSaatIni = await penyimpananLokal.ambilAkunLogin();
    final daftarAkun = await penyimpananLokal.ambilDaftarAkun();
    state = AsyncValue.data(AkunState(
      akunSaatIni: akunSaatIni,
      daftarAkunTersimpan: daftarAkun,
    ));
  }
}
