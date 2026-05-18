# Dokumentasi: `lib/shared/operasi/settings_operation.dart`

`SettingsOperation` adalah kelas khusus yang bertanggung jawab untuk mengelola data `SettingsModel` di database lokal. Berbeda dengan kelas operasi lain yang mengelola banyak entri data (seperti banyak pelanggan atau banyak transaksi), `SettingsOperation` hanya berurusan dengan **satu baris data tunggal** di dalam tabel `settings`. Baris ini merepresentasikan konfigurasi global yang berlaku untuk seluruh aplikasi.

---

## Konsep: Single Source of Truth untuk Konfigurasi

-   **ID Global**: Semua operasi di kelas ini menggunakan `globalSettingsId` (sebuah konstanta, biasanya bernilai `1`) untuk memastikan bahwa mereka selalu membaca dan menulis pada baris data yang sama. Ini menjadikan tabel `settings` sebagai *single source of truth* untuk semua parameter konfigurasi.

-   **Pengaturan Default**: Jika aplikasi dijalankan untuk pertama kalinya dan tabel `settings` masih kosong, metode `getSettings()` secara otomatis akan membuat `SettingsModel` dengan nilai-nilai default dan menyimpannya ke database. Ini memastikan bahwa aplikasi selalu memiliki konfigurasi yang valid untuk dijalankan.

-   **Konfigurasi yang Dikelola**: `SettingsModel` berisi berbagai macam pengaturan, seperti:
    -   Nama dan detail bisnis (nama WiFi, alamat, kontak).
    -   Pengaturan pajak dan biaya layanan.
    -   Pengaturan periode penagihan.
    -   Batas waktu pembersihan data arsip (`dataRetentionDays`).
    -   Pesan atau pengumuman yang ingin ditampilkan kepada pelanggan.
    -   Dan lain-lain.

---

## Metode Utama

### Operasi Baca (Read)

-   `getSettings()`: **Metode paling penting di kelas ini**. Metode ini mencoba mengambil data pengaturan dari database. Jika berhasil, ia mengembalikan `SettingsModel` yang ada. Jika tidak ada data (misalnya, instalasi baru), ia akan membuat, menyimpan, dan mengembalikan pengaturan default.

### Operasi Tulis (Write)

-   `saveOrUpdateSettings(settings, {fromServer})`: Metode utama untuk menyimpan seluruh objek `SettingsModel`. Metode ini menggunakan `_baseOperation.insert` yang secara internal berfungsi sebagai `INSERT OR REPLACE` (UPSERT), sehingga admin tidak perlu khawatir apakah sedang membuat atau memperbarui.

-   `updateSettings(data, {fromServer})`: Metode yang lebih efisien untuk memperbarui hanya beberapa field tertentu tanpa perlu mengirim seluruh objek `SettingsModel`. Misalnya, jika admin hanya mengubah nama WiFi, hanya field nama WiFi yang akan dikirim dan diperbarui. `data` adalah sebuah `Map<String, dynamic>` yang berisi key (nama kolom) dan value baru.

-   `saveOrUpdateSettingsWithBatch(settings, {fromServer})`: Varian dari `saveOrUpdateSettings` yang menggunakan operasi batch. Meskipun untuk satu item seperti settings ini tidak memberikan keuntungan performa yang signifikan, penggunaannya memastikan konsistensi dengan pola operasi data lain di aplikasi.

---

## Interaksi dengan `BaseOperation`

Setiap kali pengaturan diubah melalui `saveOrUpdateSettings` atau `updateSettings`, perubahan tersebut akan diteruskan ke `BaseOperation`. Ini memastikan bahwa setiap modifikasi pada konfigurasi global oleh admin akan secara otomatis ditandai untuk diunggah ke Firestore, sehingga semua perangkat lain (termasuk perangkat admin lain) akan menerima dan menerapkan pengaturan terbaru setelah sinkronisasi.
