# Dokumentasi: `lib/shared/services/kontrol_aplikasi_service.dart`

`KontrolAplikasiService` adalah sebuah layanan terpusat yang berfungsi sebagai "saklar remot" untuk aplikasi. Dengan menggunakan Cloud Firestore sebagai backend, layanan ini memungkinkan administrator untuk mengaktifkan atau menonaktifkan mode pemeliharaan (maintenance) untuk semua pengguna secara *real-time* tanpa perlu merilis pembaruan aplikasi.

---

## Tujuan dan Arsitektur

-   **Tujuan Utama**: Memberikan kemampuan untuk menonaktifkan fungsionalitas aplikasi utama dari jarak jauh, biasanya untuk keperluan pemeliharaan database, pembaruan server, atau saat terjadi masalah kritis yang perlu segera diisolasi.
-   **Backend**: Menggunakan Cloud Firestore, yang merupakan pilihan tepat karena kemampuannya mengirimkan perubahan data secara real-time ke semua klien yang terhubung.
-   **Struktur Data Firestore**: Layanan ini berinteraksi dengan struktur data yang spesifik:
    -   **Koleksi**: `pengaturan`
    -   **Dokumen**: `status_aplikasi`
    -   **Field**: `sedang_maintenance` (bertipe `boolean`). Jika `true`, aplikasi masuk mode pemeliharaan.

---

## Desain dan Pola Kunci

Layanan ini menunjukkan beberapa keputusan desain yang cerdas dan aman:

1.  **Pola *Fail-Safe* (Aman dari Kegagalan) pada Pembacaan**: Metode `dapatkanStatusMaintenance()` dirancang untuk menjadi sangat tangguh. Ia mengembalikan `false` (artinya, aplikasi **tidak** dalam mode pemeliharaan) dalam beberapa skenario:
    -   Jika dokumen `status_aplikasi` belum pernah ada di Firestore.
    -   Jika dokumennya ada, tetapi field `sedang_maintenance` tidak ada di dalamnya.
    -   Jika terjadi `Exception` saat mencoba berkomunikasi dengan Firestore (misalnya, tidak ada koneksi internet).

    Ini adalah keputusan desain yang sangat penting untuk keamanan. Ini memastikan bahwa pengguna **tidak akan pernah terkunci** dari aplikasi secara tidak sengaja. Aplikasi hanya akan masuk ke mode pemeliharaan jika status `true` secara eksplisit dan berhasil dibaca dari Firestore.

2.  **`rethrow` pada Penulisan**: Sebaliknya, metode `aturStatusMaintenance(bool status)` menggunakan `rethrow` di dalam blok `catch`-nya. Ini juga merupakan keputusan yang disengaja dan tepat.
    -   Saat seorang admin mencoba mengubah status pemeliharaan, itu adalah operasi yang kritis. Jika operasi ini gagal (misalnya, karena aturan keamanan Firestore atau masalah jaringan), kegagalan tersebut **tidak boleh disembunyikan**. 
    -   Dengan `rethrow`, error tersebut akan dilempar kembali ke pemanggil (misalnya, UI di panel admin). Ini memungkinkan UI untuk bereaksi, seperti dengan menampilkan pesan error ("Gagal mengubah status, coba lagi") dan memastikan admin tahu bahwa perubahan yang mereka inginkan tidak terjadi.

3.  **Penggunaan `SetOptions(merge: true)`**: Saat menulis data, `set` dipanggil dengan opsi `merge: true`. Ini adalah praktik yang baik karena mencegah penimpaan data lain yang mungkin ada di dalam dokumen `status_aplikasi`. Ini membuat sistem lebih fleksibel jika di masa depan ada field konfigurasi lain yang ditambahkan ke dokumen yang sama.

4.  **Audit Timestamp**: Metode `aturStatusMaintenance` juga memperbarui field `diperbarui` dengan `FieldValue.serverTimestamp()`. Ini mencatat kapan terakhir kali status diubah, yang berguna untuk keperluan audit dan pelacakan.

---

## Alur Penggunaan

Layanan ini biasanya digunakan dalam dua konteks yang berbeda:

-   **Di Aplikasi Pengguna**: 
    1.  Saat aplikasi dimulai (misalnya, di `main.dart` atau di *splash screen*).
    2.  Aplikasi memanggil `await KontrolAplikasiService().dapatkanStatusMaintenance()`.
    3.  Jika hasilnya `true`, aplikasi akan langsung menavigasi pengguna ke halaman khusus "Sedang Maintenance" dan memblokir akses ke seluruh fitur lainnya.

-   **Di Aplikasi Admin (atau Panel Kontrol)**:
    1.  Terdapat sebuah tombol atau *switch* dengan label "Aktifkan Mode Maintenance".
    2.  Saat admin mengaktifkannya, UI memanggil `await KontrolAplikasiService().aturStatusMaintenance(true)` di dalam blok `try-catch`.
    3.  Jika berhasil, UI menunjukkan konfirmasi. Jika gagal, `catch` akan menangkap error dan menampilkan pesan kegagalan kepada admin.

---

## Kesimpulan

`KontrolAplikasiService` adalah contoh bagus dari pemisahan antara konfigurasi operasional dan kode aplikasi. Ini memberikan fleksibilitas dan kontrol yang sangat dibutuhkan untuk mengelola aplikasi yang sudah berjalan di lapangan, meningkatkan kemampuan tim untuk merespons insiden dan melakukan pemeliharaan terjadwal dengan lebih anggun.
