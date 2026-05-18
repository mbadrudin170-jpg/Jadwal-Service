# Dokumentasi: `lib/shared/operasi/apk_version_operation.dart`

`ApkVersionOperation` adalah kelas yang mengelola informasi tentang versi aplikasi (APK) yang disimpan di database lokal. Tujuannya adalah untuk memungkinkan mekanisme pemeriksaan pembaruan aplikasi secara mandiri, baik untuk aplikasi admin maupun aplikasi klien.

---

## Konsep dan Tujuan

Dalam sistem ini, admin memiliki kemampuan untuk mengunggah file APK versi baru dan mencatat informasinya di Firestore. Informasi ini kemudian disinkronkan ke semua perangkat (termasuk perangkat admin lain dan perangkat klien) dan disimpan di database SQLite lokal menggunakan `ApkVersionOperation`.

Dengan data ini, aplikasi bisa:

1.  **Memeriksa Pembaruan**: Saat aplikasi dimulai, ia dapat membandingkan versi yang sedang berjalan dengan `latestVersion` yang tercatat di database lokal.
2.  **Menampilkan Notifikasi Update**: Jika versi yang berjalan lebih rendah dari versi terbaru, aplikasi dapat menampilkan dialog atau notifikasi yang mengajak pengguna untuk memperbarui aplikasi.
3.  **Menyediakan Link Unduhan**: Informasi versi ini juga mencakup URL unduhan untuk arsitektur yang berbeda (misalnya, `arm64-v8a`, `armeabi-v7a`), memungkinkan aplikasi untuk menyediakan link unduhan yang tepat untuk perangkat pengguna.

---

## Metode Utama

### Operasi Tulis (Write)

-   `addApkVersion(apkVersion, {fromServer})`: Menambahkan informasi versi APK baru ke database lokal. Biasanya dipanggil saat sinkronisasi data dari Firestore.

-   `updateApkVersion(apkVersion, {fromServer})`: Memperbarui informasi versi APK yang sudah ada.

-   `archiveApkVersion(id, {fromServer})`: Melakukan *soft delete* pada informasi versi APK. Ini berguna untuk menyembunyikan versi lama atau yang bermasalah dari daftar tanpa menghapusnya secara permanen.

-   `insertOrUpdateBatch(modelList, {fromServer})`: Menyisipkan atau memperbarui beberapa informasi versi APK sekaligus secara efisien. Ini adalah metode utama yang digunakan saat sinkronisasi dari server.

### Operasi Baca (Read)

-   `getAllApkVersions()`: Mengambil semua data versi APK dari database, termasuk yang sudah diarsipkan. Berguna untuk halaman manajemen versi di aplikasi admin.

-   `getAllActiveApkVersions()`: Mengambil semua versi APK yang masih aktif (tidak diarsipkan). Versi-versi inilah yang akan dianggap sebagai kandidat untuk pembaruan.

-   `getLatestApkVersion()`: **Metode paling penting untuk klien**. Metode ini mengambil satu versi APK aktif yang paling baru (berdasarkan `updatedAt`). Aplikasi klien akan menggunakan data dari metode ini untuk memeriksa apakah ada pembaruan yang tersedia.

-   `getApkVersionById(id)`: Mengambil informasi versi APK tertentu berdasarkan ID-nya.

---

## Interaksi dengan `BaseOperation`

Sama seperti kelas operasi lainnya, semua metode yang mengubah data (tambah, perbarui, arsipkan) memanfaatkan `BaseOperation`. Ini memastikan bahwa setiap perubahan yang dilakukan secara lokal (misalnya, oleh admin melalui panel admin) akan ditandai untuk diunggah ke Firestore, sehingga semua perangkat lain pada akhirnya akan menerima informasi versi APK yang sama.
