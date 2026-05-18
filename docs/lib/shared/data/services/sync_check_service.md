# Dokumentasi: `lib/shared/data/services/sync_check_service.dart`

`SyncCheckService` adalah layanan tingkat tinggi yang berfungsi sebagai **orkestrator utama** untuk seluruh proses sinkronisasi data aplikasi. Perannya bukan untuk melakukan detail teknis unggah atau unduh, melainkan untuk mengelola alur kerja (workflow) sinkronisasi secara keseluruhan, memutuskan apa yang harus dijalankan dan dalam urutan apa.

Bisa dianggap sebagai "manajer proyek" untuk sinkronisasi data.

---

## Arsitektur dan Desain

-   **Pola Fasad (Facade Pattern)**: `SyncCheckService` bertindak sebagai fasad untuk subsistem sinkronisasi yang lebih kompleks. Ia menyembunyikan detail interaksi antara `NewDataCheckService`, `UploadDataService`, dan `DownloadDataService` di balik satu metode publik yang sederhana: `runSyncCheck()`.

-   **Injeksi Ketergantungan**: Seperti layanan lainnya, kelas ini menggunakan injeksi ketergantungan. Ini sangat penting untuk sebuah orkestrator, karena dalam pengujian unit, kita dapat menyuntikkan versi *mock* dari layanan-layanan yang lebih rendah untuk memverifikasi bahwa `SyncCheckService` memanggil layanan yang benar dalam urutan yang benar dalam berbagai skenario (misalnya, memverifikasi bahwa `_uploadService.uploadAllData()` dipanggil ketika `_newDataCheck.hasNewSqliteData()` mengembalikan `true`).

---

## Logika Orkestrasi Inti: `runSyncCheck()`

Metode ini mengimplementasikan logika bisnis yang sangat spesifik dan penting untuk sinkronisasi:

**Prinsip: Unggah-Dulu (Upload-First)**

Alur kerjanya adalah sebagai berikut:

1.  **Cek & Unggah**: Pertama, ia memeriksa apakah ada data lokal yang perlu diunggah (`_checkAndRunUpload`).
    -   Jika ya, ia akan menjalankan proses unggah penuh, memperbarui timestamp unggah, dan mereset bendera `need_upload`.

2.  **Perbarui Status Global (Jika Perlu)**: **Ini adalah langkah yang paling krusial.** Jika langkah 1 menghasilkan unggahan data, layanan akan segera memanggil `_updateGlobalStatus()`. Metode ini "menyentuh" sebuah dokumen global di Firestore (`status_global/globalStatusId`) dengan memperbarui `FieldValue.serverTimestamp()`. 
    -   **Mengapa ini penting?** Tindakan ini adalah sinyal bagi **semua perangkat lain** yang menggunakan aplikasi ini. Ketika perangkat lain menjalankan pemeriksaan sinkronisasi mereka, `NewDataCheckService` mereka akan mendeteksi bahwa timestamp global ini lebih baru daripada timestamp unduhan terakhir mereka, dan itu akan memicu proses unduhan pada perangkat-perangkat tersebut. Ini adalah mekanisme inti yang membuat data tetap sinkron di seluruh ekosistem.

3.  **Cek & Unduh**: Terakhir, layanan memeriksa apakah ada data baru di server untuk diunduh (`_checkAndRunDownload`).
    -   Jika perangkat ini baru saja mengunggah data, pemeriksaan ini mungkin akan langsung `false` untuk dirinya sendiri (karena `setLastUpload` dan `setLastDownload` akan berdekatan), tetapi itu tidak masalah. Tujuan utamanya adalah untuk menarik perubahan yang mungkin dibuat oleh perangkat lain **sejak terakhir kali aplikasi ini melakukan sinkronisasi**.

Logika "Unggah-Dulu" ini membantu mengurangi kemungkinan konflik. Dengan mengirimkan perubahan lokal Anda terlebih dahulu sebelum menarik perubahan dari orang lain, Anda memastikan bahwa pekerjaan Anda disimpan di server.

---

## Penanganan Kegagalan (Error Handling)

Setiap langkah utama (unggah dan unduh) dibungkus dalam blok `try-catch` sendiri. Ini adalah desain yang tangguh:

-   Jika proses unggah gagal (misalnya, karena tidak ada koneksi internet), `Exception` akan dicatat, dan metode `_checkAndRunUpload` akan mengembalikan `false`. Namun, ini **tidak akan menghentikan** eksekusi. Program akan tetap melanjutkan untuk mencoba `_checkAndRunDownload`. 
-   Ini memungkinkan aplikasi untuk tetap menerima pembaruan dari server meskipun sedang tidak dapat mengirim pembaruan.

---

## Kesimpulan

`SyncCheckService` adalah jantung dari kecerdasan sinkronisasi aplikasi. Ia menggabungkan layanan-layanan yang lebih kecil menjadi sebuah alur kerja yang koheren, andal, dan efisien. Dengan menerapkan logika "Unggah-Dulu" dan mekanisme pemberitahuan via timestamp global, ia memastikan bahwa data dapat mengalir secara konsisten di antara banyak perangkat dengan cara yang dapat diprediksi dan dapat di-debug.
