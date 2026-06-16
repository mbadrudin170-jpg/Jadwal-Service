// path: lib/shared/data/services/layanan_preferensi.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';

class LayananPreferensi {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static const String _kunciTerakhirUnduh = 'terakhir_unduh';
  static const String _kunciTerakhirUnggah = 'terakhir_unggah';

  static Future<DateTime?> ambilWaktuTerakhirUnduh() async {
    Log.info(
      'Mengambil timestamp terakhir unduh dengan key: $_kunciTerakhirUnduh',
    );
    final result = await _ambilTimestamp(_kunciTerakhirUnduh, 'Unduh');
    Log.info('Timestamp terakhir unduh: ${result ?? "null"}');
    return result;
  }

  static Future<void> simpanWaktuTerakhirUnduh(DateTime waktu) async {
    Log.info(
      'Menyiapkan penyimpanan timestamp terakhir unduh: $waktu $_kunciTerakhirUnduh',
    );
    await _simpanTimestamp(_kunciTerakhirUnduh, waktu, 'Unduh');
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  static Future<DateTime?> ambilWaktuTerakhirUnggah() async {
    Log.info(
      'Mengambil timestamp terakhir unggah dengan key: $_kunciTerakhirUnggah',
    );
    final result = await _ambilTimestamp(_kunciTerakhirUnggah, 'Unggah');
    Log.info('Timestamp terakhir unggah: ${result ?? "null"}');
    return result;
  }

  static Future<void> simpanWaktuTerakhirUnggah(DateTime waktu) async {
    Log.info(
      'Menyiapkan penyimpanan timestamp terakhir unggah: $waktu $_kunciTerakhirUnggah',
    );
    await _simpanTimestamp(_kunciTerakhirUnggah, waktu, 'Unggah');
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  static Future<DateTime?> _ambilTimestamp(String key, String label) async {
    Log.info('Membaca timestamp $label dari SharedPreferences | Key: $key');
    final prefs = await _prefs;
    final timestamp = prefs.getInt(key);

    if (timestamp == null || timestamp == 0) {
      Log.info(
        'Timestamp $label kosong atau belum di-set. Mengembalikan null.',
      );
      return null;
    }

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    Log.info('Timestamp $label berhasil dibaca: $date');
    return date;
  }

  static Future<void> _simpanTimestamp(
    final String key,
    final DateTime waktu,
    final String label,
  ) async {
    Log.info(
      'Menyimpan timestamp $label ke SharedPreferences | Value: $waktu | Key: $key',
    );
    try {
      final prefs = await _prefs;
      final int tanggal = waktu.toUtc().millisecondsSinceEpoch;
      await prefs.setInt(key, tanggal);
      Log.info('✨ Timestamp $label berhasil disimpan | UTC: $waktu');
    } on Exception catch (e, s) {
      Log.error('Error saat menyimpan timestamp $label: $e', e: e, s: s);
    }
  }

  static Future<void> resetWaktuSinkronisasi() async {
    final prefs = await _prefs;
    Log.warning('Menghapus timestamp terakhir unduh ($_kunciTerakhirUnduh)');
    await prefs.remove(_kunciTerakhirUnduh);
    Log.warning('Menghapus timestamp terakhir unggah ($_kunciTerakhirUnggah)');
    await prefs.remove(_kunciTerakhirUnggah);
    Log.info('Semua timestamp sinkronisasi telah di-reset.');
  }
}
