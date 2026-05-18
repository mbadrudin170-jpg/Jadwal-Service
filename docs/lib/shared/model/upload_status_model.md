# Dokumentasi: `lib/shared/model/upload_status_model.dart`

`UploadStatusModel` adalah model data yang berfungsi sebagai "bendera" (*flag*) sederhana di dalam database lokal (SQLite). Tujuannya adalah untuk menandakan apakah ada perubahan data lokal yang perlu diunggah (disinkronkan) ke server (Firestore).

---

## Konsep Utama

-   **Satu Baris Status**: Dalam tabel `upload_status`, hanya ada satu baris yang relevan untuk mekanisme ini, yaitu baris dengan `id` = `'need_upload'`.
-   **Bendera Boolean**: Properti `needUpload` (disimpan di kolom `value` sebagai '1' atau '0') adalah inti dari model ini. Jika `true` ('1'), artinya ada data lokal yang menunggu untuk diunggah. Jika `false` ('0'), artinya semua data lokal sudah sinkron dengan server.

---

## Properti

-   `id` (String): Kunci unik untuk baris status. Untuk keperluan sinkronisasi, nilai yang digunakan adalah `UploadStatusModel.idNeedUpload` (`'need_upload'`).
-   `needUpload` (bool): Nilai bendera yang menandakan perlu atau tidaknya proses unggah.
-   `updatedAt` (DateTime?): Waktu terakhir kali status `needUpload` diubah.

---

## Metode

### `fromSqlite(Map<String, dynamic> map)`
*Factory constructor* untuk membuat instance `UploadStatusModel` dari data yang dibaca dari SQLite. Metode ini secara spesifik mengonversi nilai dari kolom `value` ('1' atau '0') menjadi `bool`.

### `toSqlite()`
Mengonversi instance `UploadStatusModel` menjadi `Map` yang siap disimpan ke SQLite. Properti `needUpload` (boolean) dikonversi menjadi string '1' atau '0' untuk disimpan di kolom `value`.

### `copyWith()`
Membuat salinan dari instance `UploadStatusModel` dengan beberapa nilai yang dapat diubah.

---

## Alur Kerja Sinkronisasi Unggah

1.  **Perubahan Data Lokal**:
    -   Ketika pengguna (biasanya admin) melakukan perubahan data saat sedang *offline* (tidak ada koneksi internet), atau saat terjadi error koneksi saat mencoba menyimpan ke Firestore, data tersebut akan disimpan di *local queue* (misalnya, di tabel SQLite lain).
    -   Setelah data berhasil disimpan secara lokal, aplikasi akan memperbarui status `need_upload` menjadi `true` di tabel `upload_status` menggunakan `UploadStatusModel`.

2.  **Pengecekan Status Unggah**:
    -   Sebuah layanan di latar belakang (`SyncCheckService`) secara berkala memeriksa nilai dari bendera `need_upload`.
    -   Pengecekan juga bisa dipicu saat aplikasi mendeteksi kembali adanya koneksi internet.

3.  **Proses Unggah**:
    -   Jika `need_upload` bernilai `true`, `SyncManager` atau komponen serupa akan memulai proses `UploadData`.
    -   Proses ini akan membaca data dari *local queue* dan mengirimkannya ke Firestore.

4.  **Pembaruan Status**:
    -   Setelah semua data dalam antrian berhasil diunggah ke Firestore, proses `UploadData` akan memperbarui status `need_upload` kembali menjadi `false`.

Dengan alur ini, `UploadStatusModel` menjadi mekanisme yang ringan dan efisien untuk memastikan bahwa tidak ada data lokal yang tertinggal dan semua perubahan pada akhirnya tersinkronisasi ke server.
