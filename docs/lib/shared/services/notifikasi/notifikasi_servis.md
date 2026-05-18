# Dokumentasi: `lib/shared/services/notifikasi/notifikasi_servis.dart`

`NotifikasiServis` adalah kelas layanan pembungkus (wrapper) yang kuat untuk plugin `flutter_local_notifications`. Tujuannya adalah untuk menyediakan API tingkat tinggi yang disederhanakan dan aman untuk menangani semua kebutuhan notifikasi lokal aplikasi. Ini mencakup inisialisasi, permintaan izin, penayangan notifikasi langsung, penjadwalan, pembaruan, dan pembatalan.

---

## Arsitektur dan Desain

Layanan ini menunjukkan beberapa praktik terbaik dalam rekayasa perangkat lunak mobile:

1.  **Inisialisasi Zona Waktu yang Tangguh**: Penjadwalan notifikasi sangat bergantung pada zona waktu yang benar. Metode `_inisialisasiZonaWaktu` menangani kompleksitas ini dengan sangat baik:
    -   Ia menggunakan `flutter_timezone` untuk mendapatkan zona waktu perangkat secara dinamis.
    -   Ia menggunakan pustaka `timezone` untuk memuat data zona waktu dan mengatur lokasi lokal.
    -   **Penanganan Error**: Jika karena alasan tertentu zona waktu yang terdeteksi tidak ditemukan di database (kasus langka), ia secara aman menggunakan `UTC` sebagai *fallback*, mencegah aplikasi dari crash.
    -   **Efisiensi**: Ia menggunakan bendera statis `_zonaWaktuTelahDiinisialisasi` untuk memastikan proses yang agak berat ini hanya berjalan **satu kali** selama siklus hidup aplikasi.

2.  **Manajemen Channel Android**: Untuk Android 8.0+, notifikasi harus ditempatkan dalam sebuah "Channel". Layanan ini secara otomatis membuat channel `'notifikasi_penting_wifi_app'` dengan `Importance.max`. Ini memastikan bahwa notifikasi dari aplikasi ini akan mendapatkan prioritas tertinggi (misalnya, muncul sebagai *heads-up notification*).

3.  **Callback Terpisah untuk Latar Depan dan Latar Belakang**: Layanan ini dengan benar mengonfigurasi dua *handler* berbeda:
    -   `onDidReceiveNotificationResponse`: Untuk notifikasi yang diketuk saat aplikasi berada di latar depan (*foreground*).
    -   `onDidReceiveBackgroundNotificationResponse`: Untuk notifikasi yang diketuk saat aplikasi berada di latar belakang (*background*). Ini didefinisikan sebagai fungsi level atas (`@pragma('vm:entry-point')`) sesuai dengan persyaratan plugin untuk eksekusi di *isolate* terpisah.

4.  **Kemampuan Pengujian (Testability)**: Meskipun konstruktor utama tidak memerlukan parameter, ia menyediakan konstruktor internal `NotifikasiServis.internal(this.plugin)` yang ditandai dengan `@visibleForTesting`. Ini memungkinkan kita untuk menyuntikkan instance `FlutterLocalNotificationsPlugin` palsu (*mock*) selama pengujian unit untuk memverifikasi bahwa metode seperti `show`, `zonedSchedule`, dan `cancel` dipanggil dengan parameter yang benar tanpa benar-benar berinteraksi dengan OS.

5.  **Penggunaan ID Acak untuk Notifikasi Langsung**: Metode `tampilkanNotifikasiLangsung` menggunakan `_random.nextInt(...)` untuk menghasilkan ID notifikasi. Ini adalah pendekatan yang baik untuk notifikasi instan yang tidak perlu direferensikan lagi di masa depan, memastikan setiap notifikasi adalah unik dan tidak akan menimpa notifikasi lain secara tidak sengaja.

---

## Metode Utama dan Alur Kerja

-   **`inisialisasi()`**: Ini adalah titik masuk utama. Harus dipanggil sekali saat aplikasi dimulai (misalnya, di `main()`). Ini mengorkestrasi inisialisasi zona waktu, pembuatan channel, dan inisialisasi plugin itu sendiri.

-   **`requestPermissions()`**: Pada Android 13+, aplikasi harus secara eksplisit meminta izin untuk menampilkan notifikasi. Metode ini membungkus logika tersebut, membuatnya mudah untuk dipanggil pada saat yang tepat dalam alur pengguna (misalnya, setelah halaman *onboarding*).

-   **`getDetailPeluncuranNotifikasi()`**: Berguna untuk menangani kasus di mana aplikasi **ditutup sepenuhnya** dan kemudian dibuka oleh pengguna yang mengetuk notifikasi. Ini memungkinkan aplikasi untuk memulai dan langsung menavigasi ke konten yang relevan.

-   **`tampilkanNotifikasiLangsung()`**: Untuk menampilkan notifikasi secara instan. Berguna untuk umpan balik langsung, seperti "Pengunggahan data selesai".

-   **`jadwalNotifikasi()`**: Inti dari fitur pengingat. Metode ini mengambil `DateTime` dan menjadwalkan notifikasi untuk ditampilkan pada waktu yang tepat di masa depan, bahkan jika aplikasi ditutup. Ia menggunakan `AndroidScheduleMode.exactAllowWhileIdle` untuk memastikan pengiriman yang tepat waktu.

-   **`perbaruiJadwalNotifikasi()`**: Menyediakan cara yang nyaman untuk mengubah notifikasi yang sudah ada. Implementasinya cerdas: ia hanya membatalkan notifikasi lama berdasarkan ID-nya dan kemudian membuat jadwal baru dengan informasi yang diperbarui.

-   **`batalNotifikasi(id)` dan `batalSemuaNotifikasi()`**: Menyediakan kontrol granular untuk menghapus notifikasi yang tidak lagi relevan.

---

## Kesimpulan

`NotifikasiServis` adalah abstraksi yang sangat baik. Ia mengambil API yang kuat namun kompleks dari `flutter_local_notifications` dan menyajikannya sebagai serangkaian metode yang logis, aman, dan mudah digunakan yang disesuaikan dengan kebutuhan spesifik aplikasi. Dengan penanganan zona waktu yang kuat, manajemen channel yang benar, dan arsitektur yang dapat diuji, ini adalah komponen fundamental untuk setiap fitur yang bergantung pada penjadwalan dan pemberitahuan pengguna.
