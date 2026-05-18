# Dokumentasi: `lib/shared/services/internet_connection_check.dart`

`InternetConnectionService` adalah kelas layanan penting yang menyediakan fungsionalitas tunggal namun krusial: memeriksa apakah perangkat pengguna saat ini terhubung ke internet. Layanan ini mengabstraksi plugin `connectivity_plus` dan menambahkan logging yang kuat serta kemampuan untuk diuji (testability).

---

## Tujuan dan Peran dalam Aplikasi

Dalam aplikasi yang bergantung pada sinkronisasi data dengan server, mengetahui status koneksi internet sebelum mencoba operasi jaringan adalah fundamental. Mengabaikan pemeriksaan ini dapat menyebabkan:

-   **Error yang Tidak Terduga**: Mencoba melakukan panggilan HTTP saat offline akan menghasilkan `Exception` yang mungkin tidak ditangani dengan baik.
-   **Pengalaman Pengguna yang Buruk**: Pengguna mungkin melihat indikator *loading* tanpa akhir atau pesan error yang tidak jelas, karena aplikasi tidak tahu bahwa masalahnya adalah koneksi yang terputus.

Layanan ini digunakan di seluruh aplikasi, terutama oleh `SyncManager` dan proses unggah/unduh data, untuk memastikan operasi jaringan hanya dicoba ketika ada kemungkinan berhasil.

---

## Desain dan Arsitektur

Versi kode ini menunjukkan evolusi dari implementasi sederhana menjadi kelas yang lebih matang dan kuat, berkat beberapa keputusan desain kunci:

-   **Injeksi Ketergantungan (Dependency Injection)**: Konstruktor `InternetConnectionService({final Connectivity? connectivity})` memungkinkan `Connectivity` (kelas inti dari plugin) untuk diinjeksi. Ini adalah praktik terbaik yang memberikan keuntungan besar:
    -   **Untuk Pengujian**: Dalam pengujian unit, kita dapat membuat `InternetConnectionService` dengan *mock* `Connectivity`. Ini memungkinkan kita untuk mensimulasikan berbagai kondisi jaringan (online via WiFi, online via Mobile, offline, atau bahkan error dari plugin itu sendiri) secara deterministik tanpa memerlukan koneksi jaringan yang sebenarnya.
    -   **Fleksibilitas**: Meskipun tidak digunakan saat ini, ini memungkinkan konfigurasi `Connectivity` di masa depan jika diperlukan.

-   **Logging yang Sangat Detail**: Metode `checkConnection` dilengkapi dengan log di setiap langkahnya. Ini sangat berharga untuk debugging:
    -   `[Koneksi] Memulai pemeriksaan...`
    -   `[Koneksi] Memanggil _connectivity.checkConnectivity().`
    -   `[Koneksi] Hasil mentah diterima: ...`
    -   Log spesifik untuk hasil (sukses, gagal, atau peringatan).
    -   `[Koneksi] Pemeriksaan selesai, mengembalikan nilai: ...`

    Dengan log ini, saat meninjau log aplikasi, kita bisa melihat dengan tepat bagaimana layanan ini sampai pada kesimpulan "online" atau "offline", yang sangat membantu dalam mendiagnosis masalah terkait jaringan yang dilaporkan oleh pengguna.

-   **Penanganan Error yang Aman (Robust Error Handling)**: Panggilan ke `_connectivity.checkConnectivity()` dibungkus dalam `try-catch`. Jika plugin `connectivity_plus` itu sendiri mengalami error internal, layanan ini tidak akan menyebabkan crash pada aplikasi. Sebaliknya, ia akan mencatat error fatal dengan `Log.error()` dan mengembalikan `false`. Ini adalah perilaku *fail-safe* yang benar: jika status koneksi tidak dapat dipastikan, lebih aman untuk mengasumsikan perangkat sedang offline.

---

## Logika Inti: `checkConnection()`

Logika untuk menentukan status "online" sangat spesifik dan disengaja:

```dart
final isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
    connectivityResult.contains(ConnectivityResult.wifi);
```

Aplikasi ini mendefinisikan "online" secara ketat sebagai terhubung ke **WiFi** atau **Mobile Data**. Hasil `connectivityResult` lain seperti `bluetooth` atau `ethernet` (yang mungkin terjadi pada perangkat tertentu) akan dianggap "offline" oleh logika ini. Ini adalah keputusan bisnis yang disengaja untuk menyederhanakan logika dan fokus pada dua metode koneksi yang paling umum. Log peringatan akan dicatat dalam kasus ini, yang memungkinkan untuk peninjauan di masa depan jika dukungan untuk jenis koneksi lain diperlukan.

---

## Kesimpulan

`InternetConnectionService` adalah contoh yang sangat baik dari sebuah layanan utilitas yang dirancang dengan baik. Ia mengambil satu fungsionalitas inti, membuatnya dapat diandalkan melalui penanganan error yang kuat, membuatnya transparan melalui logging yang detail, dan membuatnya dapat diverifikasi melalui desain yang dapat diuji. Ini adalah komponen fondasi yang penting untuk stabilitas fitur-fitur jaringan aplikasi.
