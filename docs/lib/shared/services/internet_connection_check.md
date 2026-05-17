
# Dokumentasi: InternetConnectionService

## Lokasi File
`lib/shared/services/internet_connection_check.dart`

## Ringkasan
`InternetConnectionService` adalah sebuah kelas layanan utilitas yang menyediakan fungsionalitas terpusat untuk memeriksa status konektivitas internet perangkat. Kelas ini bertindak sebagai pembungkus (*wrapper*) untuk plugin `connectivity_plus`, mengabstraksi detail implementasi dan menyediakan metode sederhana yang mengembalikan nilai boolean (`true` jika online, `false` jika offline).

Layanan ini sangat penting untuk fitur-fitur yang memerlukan koneksi internet, seperti sinkronisasi data dengan Firebase (`SyncManager`), pengunduhan pembaruan aplikasi, atau pengiriman data ke server.

## Arsitektur dan Ketergantungan
-   **connectivity_plus**: Ketergantungan eksternal utama. Plugin ini mendeteksi status konektivitas jaringan (WiFi, Mobile Data, Ethernet, dll.).
-   **Dependency Injection**: Kelas ini dirancang untuk dapat diuji (*testable*) dengan menggunakan *constructor injection*. Ia menerima instance `Connectivity` secara opsional. Jika tidak ada yang diberikan, ia akan membuat instancenya sendiri. Ini memungkinkan pengembang untuk menyuntikkan *mock* `Connectivity` selama *unit testing*.
-   **Logging**: Layanan ini dilengkapi dengan `Log` yang sangat detail untuk setiap langkahnya. Ini membantu dalam proses *debugging* untuk melacak status pemeriksaan koneksi, mulai dari pemanggilan plugin hingga hasil akhir.

## Metode Utama

### `Future<bool> checkConnection()`
Ini adalah satu-satunya metode publik di dalam kelas. Saat dipanggil, metode ini akan melakukan langkah-langkah berikut secara asinkron:
1.  **Memulai Pemeriksaan**: Mencatat bahwa proses pemeriksaan koneksi telah dimulai.
2.  **Memanggil Plugin**: Memanggil `_connectivity.checkConnectivity()` untuk mendapatkan daftar hasil konektivitas saat ini (bisa berupa `[ConnectivityResult.wifi]`, `[ConnectivityResult.mobile]`, `[ConnectivityResult.none]`, dll).
3.  **Menganalisis Hasil**: Memeriksa apakah daftar hasil mengandung `ConnectivityResult.wifi` atau `ConnectivityResult.mobile`.
    -   Jika ya, variabel `isOnline` akan menjadi `true`.
    -   Jika tidak (misal, hasilnya adalah `none`, `bluetooth`, atau `ethernet`), `isOnline` akan menjadi `false`.
4.  **Logging Hasil**: Mencatat apakah perangkat dianggap online atau offline berdasarkan analisis.
5.  **Mengembalikan Nilai**: Mengembalikan nilai boolean `isOnline`.
6.  **Penanganan Error**: Jika terjadi `Exception` saat memanggil plugin (misalnya, karena masalah pada implementasi platform plugin), kesalahan tersebut akan ditangkap dan dicatat. Dalam kasus ini, metode akan mengembalikan `false` sebagai nilai *fallback* yang aman.

## Tujuan Desain
-   **Terpusat (Single Source of Truth)**: Menyediakan satu cara yang konsisten di seluruh aplikasi untuk memeriksa konektivitas internet. Ini mencegah duplikasi kode dan inkonsistensi.
-   **Dapat Diuji (Testable)**: Pola *dependency injection* memungkinkan pengujian logika layanan ini tanpa benar-benar bergantung pada status koneksi perangkat keras yang sebenarnya.
-   **Informatif (Debuggable)**: Penggunaan log yang ekstensif memudahkan untuk mendiagnosis masalah konektivitas saat aplikasi berjalan di perangkat pengguna.
-   **Aman (Fail-Safe)**: Dengan menangani error dan mengembalikan `false` secara default saat terjadi masalah, layanan ini mencegah *crash* dan memastikan bahwa logika aplikasi yang bergantung padanya akan berperilaku seolah-olah sedang offline, yang biasanya merupakan skenario yang lebih aman.

## Contoh Pemanggilan
```dart
// Inisialisasi service
final connectionService = InternetConnectionService();

// Sebelum melakukan sinkronisasi data
if (await connectionService.checkConnection()) {
  // Ada koneksi, lanjutkan dengan sinkronisasi
  Log.info('Memulai sinkronisasi data ke Firebase...');
  // await syncManager.startSync();
} else {
  // Tidak ada koneksi, tampilkan pesan ke pengguna atau batalkan operasi
  Log.warning('Sinkronisasi dibatalkan karena tidak ada koneksi internet.');
  // SnackBarUtil.showWarning(message: 'Tidak ada koneksi internet.');
}
```

Dokumentasi ini menjelaskan bagaimana `InternetConnectionService` berfungsi sebagai komponen infrastruktur inti untuk membangun aplikasi yang sadar-jaringan (*network-aware*) dan andal.
