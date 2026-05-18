# Dokumentasi: `lib/shared/data/services/new_data_check_service.dart`

`NewDataCheckService` adalah kelas layanan yang bertindak sebagai "pusat intelijen" untuk sistem sinkronisasi data aplikasi. Tanggung jawab utamanya adalah untuk menjawab dua pertanyaan penting secara efisien:

1.  Apakah ada data baru di database lokal (SQLite) yang perlu diunggah ke server (Firebase)?
2.  Apakah ada data baru di server (Firebase) yang perlu diunduh ke aplikasi?

Layanan ini tidak melakukan sinkronisasi itu sendiri, melainkan hanya menyediakan status, memungkinkan komponen lain seperti `SyncManager` untuk memutuskan *apakah* dan *kapan* harus memulai proses unggah atau unduh.

---

## Arsitektur dan Desain

Kelas ini dirancang dengan mempertimbangkan efisiensi, ketahanan, dan kemampuan pengujian.

-   **Injeksi Ketergantungan (Dependency Injection)**: Konstruktor `NewDataCheckService(...)` memungkinkan injeksi dependensi kritis seperti `FirebaseFirestore`, `SyncManager`, dan `UploadStatusOperation`. Ini adalah praktik desain yang sangat baik karena memungkinkan pengujian unit yang andal. Dalam pengujian, kita dapat mengganti dependensi nyata dengan *mock* (palsu) untuk mensimulasikan berbagai skenario (misalnya, ada data baru, tidak ada data baru, server tidak terjangkau) tanpa memerlukan koneksi jaringan atau database nyata.

-   **Pola Pemeriksaan yang Efisien**: Daripada memindai seluruh tabel untuk mencari perubahan, layanan ini menggunakan dua pola yang sangat efisien untuk pemeriksaan data.

---

## Mekanisme Pemeriksaan Data Lokal: Pola "Bendera Kotor" (Dirty Flag)

Metode `hasNewSqliteData()` bertanggung jawab untuk memeriksa perubahan lokal. Cara kerjanya sangat cerdas:

1.  **Tidak Memindai Semua Tabel**: Memeriksa setiap baris di setiap tabel untuk melihat apa yang telah berubah akan sangat lambat dan boros baterai.
2.  **Menggunakan Bendera Terpusat**: Sebaliknya, aplikasi ini menggunakan mekanisme "bendera kotor". Ada sebuah tabel atau entri khusus di SQLite (dikelola oleh `UploadStatusOperation`) yang menyimpan satu nilai boolean: `need_upload`.
3.  **Cara Kerja**: Setiap kali ada operasi tulis, ubah, atau hapus di tempat lain dalam aplikasi (misalnya, membuat transaksi baru, mengedit detail pelanggan), operasi tersebut juga akan memanggil `UploadStatusOperation` untuk menyetel bendera `need_upload` menjadi `true`.
4.  **Pemeriksaan Cepat**: `NewDataCheckService.hasNewSqliteData()` hanya perlu membaca satu nilai boolean ini. Jika `true`, ia tahu ada pekerjaan yang harus dilakukan. Jika `false`, tidak ada.

Ini adalah pola yang sangat efisien dan skalabel. Sebagai pelengkap, metode `resetNeedUpload()` dipanggil setelah proses pengunggahan data berhasil, menyetel kembali bendera menjadi `false`, menandakan bahwa "pekerjaan telah selesai".

---

## Mekanisme Pemeriksaan Data Server: Pola "Perbandingan Timestamp"

Metode `hasNewFirebaseData()` bertanggung jawab untuk memeriksa pembaruan di server. Ia juga menggunakan pola yang efisien untuk menghindari pengunduhan data yang tidak perlu.

1.  **Tidak Mengunduh Seluruh Data**: Mengunduh semua data dari server hanya untuk membandingkannya dengan data lokal akan memakan banyak kuota dan waktu.
2.  **Menggunakan Timestamp Terpusat**: Sebaliknya, ada sebuah dokumen khusus di Firestore (misalnya, di `pengaturan/status_sinkronisasi`) yang berisi satu field `Timestamp` bernama `diperbarui`.
3.  **Cara Kerja**:
    -   Setiap kali ada perubahan data penting di sisi server (misalnya, admin mengubah daftar paket dari panel admin), proses tersebut juga akan memperbarui field `diperbarui` di dokumen status ini dengan waktu server saat itu.
    -   `NewDataCheckService` kemudian melakukan perbandingan sederhana:
        a.  Mengambil timestamp **unduhan terakhir yang berhasil** dari penyimpanan lokal (melalui `SyncManager.getLastDownload()`).
        b.  Mengambil timestamp `diperbarui` dari dokumen status di Firestore. Pentingnya, ini dilakukan dengan `source: Source.server` untuk memastikan data yang didapat adalah yang terbaru dan bukan dari cache.
        c.  Membandingkan keduanya: `serverTime.isAfter(localTime)`.
4.  **Keputusan Cepat**: Jika timestamp server lebih baru, metode mengembalikan `true`, menandakan bahwa pengunduhan diperlukan. Jika tidak, ia mengembalikan `false`.

---

## Desain *Fail-Safe* (Aman dari Kegagalan)

Kedua metode pemeriksaan ini dirancang untuk menjadi "aman". Jika terjadi kesalahan apa pun selama proses pemeriksaan (misalnya, tidak ada koneksi internet, dokumen status di Firestore tidak ada, atau terjadi error pada database lokal), metode-metode ini akan menangkap `Exception` dan **selalu mengembalikan `false`**. Ini adalah perilaku yang diinginkan untuk mencegah aplikasi mencoba melakukan sinkronisasi yang gagal, yang dapat menguras baterai dan membingungkan pengguna.

---

## Kesimpulan

`NewDataCheckService` adalah contoh rekayasa perangkat lunak yang solid. Ia memecahkan masalah kompleks (pemeriksaan sinkronisasi) dengan solusi yang sederhana, efisien, andal, dan dapat diuji. Logging yang sangat detail di seluruh metodenya juga menjadikannya komponen yang transparan dan mudah di-debug.
