// path: lib/shared/utils/sync_manager.dart

import 'package:wifi/shared/data/services/preferensi_service.dart';
import 'package:wifi/shared/debug/log.dart';

class SyncManager {
  Future<DateTime> getTerakhirUnduh() async {
    Log.info('Meminta timestamp terakhir unduh dari PreferensiService');
    final result = await PreferensiService.getTerakhirUnduh();
    // diubah: jika null, kembalikan Epoch 0 sebagai default
    final a = result ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unduh yang digunakan: $a');
    return a;
  }

  Future<void> setTerakhirUnduh(DateTime time) async {
    Log.info('Menyimpan timestamp terakhir unduh: $time');
    await PreferensiService.setTerakhirUnduh(time);
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  Future<DateTime> getTerakhirUnggah() async {
    Log.info('Meminta timestamp terakhir unggah dari PreferensiService');
    final result = await PreferensiService.getTerakhirUnggah();
    // diubah: jika null, kembalikan Epoch 0 sebagai default
    final a = result ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unggah yang digunakan: $a');
    return a;
  }

  Future<void> setTerakhirUnggah(DateTime time) async {
    Log.info('Menyimpan timestamp terakhir unggah: $time');
    await PreferensiService.setTerakhirUnggah(time);
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }
}
