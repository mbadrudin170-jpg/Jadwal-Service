// path: lib/shared/data/services/preferensi_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';

/// Layanan untuk mengelola preferensi aplikasi via SharedPreferences.
///
/// Menyediakan akses ke timestamp sinkronisasi (unduh/unggah)
/// dan fungsi untuk meresetnya.
class PreferensiService {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static const String _keyTerakhirUnduh = 'terakhir_unduh';
  static const String _keyTerakhirUnggah = 'terakhir_unggah';

  /// Mengambil timestamp terakhir unduh.
  ///
  /// Mengembalikan [DateTime] atau `null` jika belum pernah disimpan.
  static Future<DateTime?> getTerakhirUnduh() async {
    Log.info(
      'Mengambil timestamp terakhir unduh dengan key: $_keyTerakhirUnduh',
    );
    final result = await _getTimestamp(_keyTerakhirUnduh, 'Unduh');
    Log.info('Timestamp terakhir unduh: ${result ?? "null"}');
    return result;
  }

  /// Menyimpan timestamp terakhir unduh.
  static Future<void> setTerakhirUnduh(final DateTime waktu) async {
    Log.info(
      'Menyiapkan penyimpanan timestamp terakhir unduh: $waktu $_keyTerakhirUnduh',
    );
    await _setTimestamp(_keyTerakhirUnduh, waktu, 'Unduh');
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  /// Mengambil timestamp terakhir unggah.
  ///
  /// Mengembalikan [DateTime] atau `null` jika belum pernah disimpan.
  static Future<DateTime?> getTerakhirUnggah() async {
    Log.info(
      'Mengambil timestamp terakhir unggah dengan key: $_keyTerakhirUnggah',
    );
    final result = await _getTimestamp(_keyTerakhirUnggah, 'Unggah');
    Log.info('Timestamp terakhir unggah: ${result ?? "null"}');
    return result;
  }

  /// Menyimpan timestamp terakhir unggah.
  static Future<void> setTerakhirUnggah(final DateTime waktu) async {
    Log.info(
      'Menyiapkan penyimpanan timestamp terakhir unggah: $waktu $_keyTerakhirUnggah',
    );
    await _setTimestamp(_keyTerakhirUnggah, waktu, 'Unggah');
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  static Future<DateTime?> _getTimestamp(final String key, final String label) async {
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

  static Future<void> _setTimestamp(
    final String key,
    final DateTime time,
    final String label,
  ) async {
    Log.info(
      'Menyimpan timestamp $label ke SharedPreferences | Value: $time | Key: $key',
    );
    try {
      final prefs = await _prefs;
      final int millis = time.toUtc().millisecondsSinceEpoch;
      await prefs.setInt(key, millis);
      Log.info('✨ Timestamp $label berhasil disimpan | UTC: $time');
    } on Exception catch (e, s) {
      Log.error('Error saat menyimpan timestamp $label: $e', e: e, st: s);
    }
  }

  /// Mereset semua timestamp sinkronisasi (unduh dan unggah).
  static Future<void> resetWaktuSinkronisasi() async {
    final prefs = await _prefs;
    Log.warning('Menghapus timestamp terakhir unduh ($_keyTerakhirUnduh)');
    await prefs.remove(_keyTerakhirUnduh);
    Log.warning('Menghapus timestamp terakhir unggah ($_keyTerakhirUnggah)');
    await prefs.remove(_keyTerakhirUnggah);
    Log.info('Semua timestamp sinkronisasi telah di-reset.');
  }
}
