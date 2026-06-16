// path: lib/fitur/alarm/penjadwal_alarm.dart

abstract class PenjadwalAlarm {
  Future<bool> jadwalkanSekali(
    DateTime waktu,
    int id,
    void Function() panggilBalik, {
    bool bangunkan,
    bool tepatWaktu,
  });

  Future<bool> jadwalkanPeriodik(
    Duration durasi,
    int id,
    void Function() panggilBalik, {
    DateTime? mulaiPada,
    bool tepatWaktu,
    bool bangunkan,
    bool jadwalkanUlangSaatBoot,
  });

  Future<bool> jadwalkanSekaliPada(
    DateTime waktu,
    int id,
    void Function() panggilBalik, {
    bool tepatWaktu = false,
    bool bangunkan = false,
    bool jadwalkanUlangSaatBoot = false,
  });

  Future<bool> batalkan(int id);
}
