# Dokumentasi: `lib/shared/data/services/preference_service.dart`

`PreferenceService` adalah kelas utilitas statis yang berfungsi sebagai lapisan abstraksi (abstraction layer) yang aman dan terpusat untuk mengelola data preferensi persisten menggunakan plugin `shared_preferences`. Fokus utamanya adalah pada penyimpanan dan pengambilan timestamp yang krusial untuk logika sinkronisasi data (unggah dan unduh).

---

## Tujuan dan Arsitektur

**Masalah**: `shared_preferences` adalah API level rendah yang menyimpan pasangan kunci-nilai (key-value). Menggunakan kunci string secara langsung di seluruh basis kode dapat menyebabkan masalah:
1.  **Kesalahan Ketik (Typos)**: Mudah sekali salah mengetik kunci, seperti `'terakhir_unduh'` menjadi `'terakhir_undah'`, yang akan menyebabkan bug yang sulit dilacak.
2.  **Kurangnya Keamanan Tipe (Type Safety)**: API dasarnya memungkinkan Anda mencoba membaca sebuah `int` sebagai `String`, yang akan menyebabkan error saat runtime.
3.  **Logika Tersebar**: Logika untuk mengubah `DateTime` menjadi `int` (untuk penyimpanan) dan sebaliknya tersebar di banyak tempat.

**Solusi**: `PreferenceService` memecahkan semua masalah ini dengan:

-   **Mendefinisikan Kunci di Satu Tempat**: Kunci seperti `_keyLastDownload` didefinisikan sebagai konstanta privat di dalam kelas. Kode lain tidak perlu tahu (dan tidak bisa salah mengetik) nama kunci yang sebenarnya.
-   **Menyediakan API Berbasis Tipe (Typed API)**: Metode seperti `getLastDownload()` mengembalikan `Future<DateTime?>` dan `setLastDownload(DateTime time)` menerima `DateTime`. Ini memindahkan tanggung jawab konversi tipe data ke dalam layanan, menyembunyikan detail implementasi (bahwa `DateTime` disimpan sebagai `int` dari *milliseconds since epoch*).
-   **Mempusatkan Logika**: Semua logika untuk mendapatkan instance `SharedPreferences`, membaca, menulis, dan mengonversi nilai, berada di dalam satu kelas ini.

---

## Desain dan Pola Kunci

-   **Kelas Statis**: Semua metode adalah `static`. Ini menjadikannya utilitas global yang mudah digunakan tanpa perlu membuat instance (`PreferenceService.getLastDownload()`). Ini cocok untuk layanan yang state-nya (dalam hal ini, data SharedPreferences itu sendiri) bersifat global untuk aplikasi.

-   **Instance `_prefs` Privat**: `Future<SharedPreferences> _prefs` diinisialisasi sekali dan digunakan kembali. Ini adalah pola yang efisien untuk menghindari pemanggilan `SharedPreferences.getInstance()` berulang kali.

-   **Penanganan Nilai Null yang Aman**: Metode `_getTimestamp` secara eksplisit memeriksa `timestamp == null` atau `timestamp == 0`. Ini membuatnya tangguh terhadap kasus di mana preferensi belum pernah disetel, dan mengembalikan `null` secara konsisten, yang dapat ditangani oleh pemanggil.

-   **Penggunaan UTC**: Saat menyimpan `DateTime`, metode `_setTimestamp` secara eksplisit mengubahnya ke UTC (`time.toUtc()`). Ini adalah praktik terbaik yang sangat penting. Ini memastikan bahwa timestamp tidak terpengaruh oleh zona waktu perangkat pengguna, yang bisa berubah. Dengan menyimpan semua waktu dalam UTC, perbandingan waktu (misalnya, antara waktu lokal dan waktu server) menjadi andal dan konsisten di mana pun pengguna berada.

-   **Logging yang Komprehensif**: Setiap operasi baca, tulis, atau hapus dicatat dengan `Log`. Ini sangat berharga untuk debugging, terutama untuk masalah sinkronisasi. Anda dapat melihat dengan tepat timestamp apa yang dibaca dan ditulis oleh aplikasi.

-   **Metode `resetSyncTime`**: Menyediakan fungsi "tombol panik" atau reset. Ini sangat berguna selama pengembangan dan pengujian untuk memaksa aplikasi melakukan sinkronisasi penuh dari awal dengan menghapus semua catatan waktu sebelumnya.

---

## Alur Penggunaan

Layanan ini adalah komponen pendukung penting untuk `NewDataCheckService` dan `SyncManager`.

-   **Saat Pemeriksaan Unduh**: `NewDataCheckService` akan memanggil `PreferenceService.getLastDownload()` untuk mendapatkan titik waktu terakhir data berhasil diunduh.
-   **Setelah Unduh Berhasil**: `SyncManager` akan memanggil `PreferenceService.setLastDownload(DateTime.now())` untuk mencatat bahwa sinkronisasi baru saja selesai.
-   **Setelah Unggah Berhasil**: `SyncManager` akan memanggil `PreferenceService.setLastUpload(DateTime.now())` untuk mencatat keberhasilan unggahan.

---

## Kesimpulan

`PreferenceService` adalah contoh textbook tentang cara membuat pembungkus (wrapper) yang baik untuk layanan pihak ketiga seperti `shared_preferences`. Ia meningkatkan keamanan, mengurangi kemungkinan error, memusatkan logika, dan meningkatkan kemampuan untuk di-debug, semuanya sambil menyembunyikan kompleksitas yang tidak perlu dari seluruh aplikasi.
