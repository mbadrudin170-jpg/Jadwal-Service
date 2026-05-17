# Dokumentasi: `lib/shared/utils/format_util.dart`

File ini adalah pusat utilitas untuk semua kebutuhan pemformatan data seperti tanggal, waktu, dan mata uang. Tujuannya adalah untuk memastikan konsistensi format di seluruh aplikasi dan memisahkan logika pemformatan dari logika bisnis.

---

## Kelas `FormatUtil`

Kelas ini khusus menangani pemformatan yang berhubungan dengan **tanggal**. Semua metode di dalamnya bersifat statis.

### `FormatUtil.formatDateBasic(DateTime date)`

Mengubah objek `DateTime` menjadi string tanggal dengan format `d MMM yyyy`.

- **Parameter:**
  - `date` (DateTime): Objek tanggal yang akan diformat.
- **Hasil:** String (contoh: "17 Agu 2024").
- **Contoh Penggunaan:**
  '''dart
  String tanggal = FormatUtil.formatDateBasic(DateTime.now());
  // tanggal -> "17 Agu 2024" (jika hari ini 17 Agustus 2024)
  '''

### `FormatUtil.formatDateAndTime(DateTime date)`

Mengubah objek `DateTime` menjadi string tanggal dan waktu dengan format `d MMM yyyy, HH:mm`.

- **Parameter:**
  - `date` (DateTime): Objek tanggal yang akan diformat.
- **Hasil:** String (contoh: "17 Agu 2024, 10:30").
- **Contoh Penggunaan:**
  '''dart
  String tanggalWaktu = FormatUtil.formatDateAndTime(DateTime.now());
  // tanggalWaktu -> "17 Agu 2024, 10:30"
  '''

### `FormatUtil.formatDateCompact(DateTime date)`

Mengubah objek `DateTime` menjadi string tanggal ringkas dengan format `E, d MMM yy`.

- **Parameter:**
  - `date` (DateTime): Objek tanggal yang akan diformat.
- **Hasil:** String (contoh: "Sel, 17 Agu 24").
- **Contoh Penggunaan:**
  '''dart
  String tanggalRingkas = FormatUtil.formatDateCompact(DateTime.now());
  // tanggalRingkas -> "Sel, 17 Agu 24"
  '''

---

## Kelas `TimeFormat`

Kelas ini khusus menangani pemformatan yang berhubungan dengan **waktu/jam**.

### `TimeFormat.formatHourMinute(DateTime time)`

Mengubah objek `DateTime` menjadi string waktu dengan format `HH:mm`.

- **Parameter:**
  - `time` (DateTime): Objek tanggal-waktu yang jamnya akan diformat.
- **Hasil:** String (contoh: "23:59").
- **Contoh Penggunaan:**
  '''dart
  String jam = TimeFormat.formatHourMinute(DateTime.now());
  // jam -> "23:59"
  '''

### `TimeFormat.formatFullTime(DateTime time)`

Mengubah objek `DateTime` menjadi string waktu lengkap dengan format `HH:mm:ss`.

- **Parameter:**
  - `time` (DateTime): Objek tanggal-waktu yang jamnya akan diformat.
- **Hasil:** String (contoh: "10:30:55").
- **Contoh Penggunaan:**
  '''dart
  String waktuLengkap = TimeFormat.formatFullTime(DateTime.now());
  // waktuLengkap -> "10:30:55"
  '''

### `TimeFormat.formatTextToHour(String timeText)`

Mengonversi string waktu berformat ISO 8601 menjadi format jam `HH:mm`.

- **Parameter:**
  - `timeText` (String): Teks waktu dalam format yang bisa di-parse oleh `DateTime.parse()`.
- **Hasil:** String (contoh: "14:45"). Jika input tidak valid, akan mengembalikan `"--:--"`.
- **Contoh Penggunaan:**
  '''dart
  String jamDariTeks = TimeFormat.formatTextToHour("2024-08-17T14:45:00Z");
  // jamDariTeks -> "14:45"
  '''

---

## Kelas `CurrencyFormat`

Kelas ini khusus menangani pemformatan **mata uang Rupiah**.

### `CurrencyFormat.formatCurrency(double amount)`

Memformat angka (double) menjadi string mata uang Rupiah.

- **Parameter:**
  - `amount` (double): Jumlah uang yang akan diformat.
- **Hasil:** String (contoh: "Rp 150.000").
- **Contoh Penggunaan:**
  '''dart
  String harga = CurrencyFormat.formatCurrency(150000);
  // harga -> "Rp 150.000"
  '''
