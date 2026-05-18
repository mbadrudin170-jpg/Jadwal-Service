# Dokumentasi: `lib/shared/services/info_perangkat_service.dart`

`InfoPerangkatService` adalah kelas layanan yang berfungsi sebagai pembungkus (wrapper) dan fasad (facade) untuk plugin `device_info_plus`. Tujuannya adalah untuk mengabstraksi dan menyederhanakan proses pengambilan informasi perangkat keras (hardware) yang spesifik untuk setiap platform, terutama arsitektur CPU.

---

## Tujuan dan Pentingnya

Mengetahui arsitektur CPU perangkat sangat penting untuk beberapa skenario, terutama dalam konteks aplikasi Android. Aplikasi Android modern sering kali didistribusikan dalam beberapa versi APK yang berbeda, masing-masing dioptimalkan untuk arsitektur CPU yang berbeda (misalnya, `arm64-v8a`, `armeabi-v7a`, `x86_64`).

Layanan ini menyediakan cara yang andal bagi aplikasi untuk:
1.  Mengidentifikasi arsitektur perangkat yang sedang berjalan.
2.  Membuat keputusan cerdas berdasarkan informasi tersebut, seperti merekomendasikan atau mengunduh versi APK yang paling sesuai saat ada pembaruan.

---

## Desain dan Arsitektur

Kelas ini menerapkan beberapa praktik desain yang sangat baik:

-   **Pola Injeksi Ketergantungan (Dependency Injection - DI)**: Ini adalah fitur desain yang paling menonjol. Konstruktor `InfoPerangkatService(this.deviceInfo)` mengharuskan `DeviceInfoPlugin` untuk "disuntikkan" dari luar saat kelas ini dibuat. Ini sangat krusial untuk **pengujian (testing)**. Dalam pengujian unit, kita dapat membuat instance `InfoPerangkatService` dengan `DeviceInfoPlugin` palsu (mock), yang memungkinkan kita untuk mensimulasikan berbagai skenario (misalnya, perangkat Android dengan arsitektur ARM, perangkat iOS, atau bahkan kondisi error) tanpa memerlukan perangkat fisik.

-   **Penanganan Spesifik Platform**: Metode `dapatkanArsitekturPerangkat` secara eksplisit memeriksa platform target (`defaultTargetPlatform`) dan menjalankan kode yang sesuai untuk Android atau iOS. Ini mengisolasi logika yang berbeda untuk setiap platform di dalam satu tempat.

-   **Penanganan Kasus Web dan Platform Lain**: Kelas ini dengan benar mengidentifikasi bahwa fungsionalitas ini tidak relevan untuk web (`kIsWeb`) dan platform lain yang tidak didukung, lalu mengembalikan pesan error yang jelas.

-   **Penanganan Error yang Kuat**: Seluruh logika panggilan ke *native code* dibungkus dalam blok `try-catch`. Jika `deviceInfo` gagal mendapatkan informasi karena alasan apa pun, layanan ini tidak akan menyebabkan aplikasi *crash*. Sebaliknya, ia akan menangkap `Exception` dan mengembalikan `Map` yang berisi pesan error yang deskriptif.

---

## Metode Utama: `dapatkanArsitekturPerangkat()`

-   **Tanggung Jawab**: Satu-satunya tugas metode ini adalah mengambil informasi perangkat keras dan mengembalikannya dalam format `Map<String, dynamic>` yang terstruktur.
-   **Struktur Kembalian (Return Value)**:
    -   **Pada Android**: Mengembalikan `supportedAbis` (daftar arsitektur yang didukung, contoh: `['arm64-v8a', 'armeabi-v7a', 'armeabi']`) dan `isPhysicalDevice`. Informasi `supportedAbis` adalah yang paling penting di sini.
    -   **Pada iOS**: Mengembalikan `utsname.machine` (pengenal model internal, contoh: `'iPhone13,2'`) dan `isPhysicalDevice`.
    -   **Pada Error/Platform Tidak Didukung**: Mengembalikan `Map` dengan satu kunci, `'error'`, yang berisi string penjelasan masalah.

---

## Contoh Penggunaan

Layanan ini dapat diintegrasikan dengan fitur pemeriksa pembaruan aplikasi. Alurnya akan seperti ini:

1.  Aplikasi memanggil `InfoPerangkatService.dapatkanArsitekturPerangkat()`.
2.  Aplikasi memeriksa `supportedAbis` dari hasil yang dikembalikan. Biasanya, arsitektur pertama dalam daftar (`supportedAbis[0]`) adalah yang paling optimal.
3.  Saat meminta informasi versi APK terbaru dari server, aplikasi menyertakan arsitektur yang terdeteksi (misalnya, `arm64-v8a`).
4.  Server kemudian merespons dengan URL unduhan untuk file APK yang benar, memastikan pengguna mendapatkan versi yang paling efisien untuk perangkat mereka.

Dengan membungkus fungsionalitas ini dalam sebuah layanan, kode yang memerlukan informasi perangkat menjadi lebih bersih, lebih mudah diuji, dan tidak terikat langsung pada detail implementasi dari plugin `device_info_plus`.
