
# Dokumentasi: InfoPerangkatService

## Lokasi File
`lib/shared/services/info_perangkat_service.dart`

## Ringkasan
`InfoPerangkatService` adalah kelas layanan sederhana yang bertujuan untuk mengambil informasi spesifik dari perangkat keras tempat aplikasi dijalankan. Layanan ini merupakan pembungkus (*wrapper*) untuk plugin `device_info_plus`, yang mengabstraksi cara mendapatkan detail perangkat di berbagai platform seperti Android dan iOS.

Tujuan utama dari layanan ini dalam konteks aplikasi adalah untuk mengidentifikasi arsitektur CPU perangkat (misalnya, `arm64-v8a`, `armeabi-v7a`, `x86_64`). Informasi ini krusial untuk fitur pemeriksaan versi dan pembaruan aplikasi (`ApkVersionModel`), di mana aplikasi perlu mengunduh file APK yang tepat sesuai dengan arsitektur perangkat pengguna.

## Arsitektur dan Ketergantungan
-   **device_info_plus**: Ketergantungan utama. Plugin ini menyediakan akses ke API tingkat sistem operasi untuk informasi perangkat.
-   **Dependency Injection**: Desain kelas ini menggunakan *constructor injection*. `DeviceInfoPlugin` di-pass melalui konstruktor, bukan dibuat di dalam kelas. Ini adalah praktik terbaik yang memungkinkan `InfoPerangkatService` untuk diuji secara terpisah (*unit test*) dengan menyuntikkan *mock* `DeviceInfoPlugin`.
-   **Platform Specific Code**: Layanan ini berisi kode yang spesifik untuk platform (Android dan iOS) dan juga menangani kasus untuk web (di mana informasi arsitektur tidak relevan atau tidak tersedia).

## Metode Utama

### `Future<Map<String, dynamic>> dapatkanArsitekturPerangkat()`
Ini adalah metode inti dari layanan ini. Ketika dipanggil, ia akan:
1.  Memeriksa apakah aplikasi berjalan di web. Jika ya, ia akan langsung mengembalikan pesan error karena informasi arsitektur tidak relevan.
2.  Memeriksa platform (`defaultTargetPlatform`).
    -   **Jika Android**: Ia akan memanggil `deviceInfo.androidInfo` untuk mendapatkan `AndroidDeviceInfo`. Dari sini, ia akan mengekstrak daftar `supportedAbis` (contoh: `['arm64-v8a', 'armeabi-v7a', 'armeabi']`).
    -   **Jika iOS**: Ia akan memanggil `deviceInfo.iosInfo` dan mengekstrak `utsname.machine` (contoh: `iPhone13,2`).
3.  Mengembalikan informasi yang relevan dalam bentuk `Map<String, dynamic>`.
4.  Jika terjadi kesalahan saat mengambil informasi, ia akan menangkap `Exception` dan mengembalikan `Map` yang berisi pesan error.

## Tujuan Desain
-   **Abstraksi**: Menyembunyikan kompleksitas penggunaan plugin `device_info_plus` di balik metode yang sederhana dan fokus pada tujuan (`dapatkanArsitekturPerangkat`).
-   **Dapat Diuji (Testable)**: Pola *dependency injection* yang digunakan membuat kelas ini sangat mudah untuk diuji.
-   **Modular**: Mengisolasi fungsionalitas terkait informasi perangkat ke dalam satu kelas, sehingga mudah ditemukan, dikelola, dan diganti jika diperlukan.
-   **Aman dari Kegagalan (Fail-safe)**: Menggunakan `try-catch` untuk memastikan bahwa kegagalan dalam mengambil info perangkat tidak akan menyebabkan aplikasi crash, melainkan mengembalikan pesan error yang dapat ditangani.

## Contoh Pemanggilan
```dart
// Inisialisasi service, idealnya melalui dependency injection framework
final deviceInfoPlugin = DeviceInfoPlugin();
final infoService = InfoPerangkatService(deviceInfoPlugin);

// Panggil metode untuk mendapatkan informasi
final deviceInfoMap = await infoService.dapatkanArsitekturPerangkat();

if (deviceInfoMap.containsKey('error')) {
  Log.error('Gagal mendapatkan info arsitektur: ${deviceInfoMap['error']}');
} else {
  // Contoh untuk Android
  final supportedAbis = deviceInfoMap['supportedAbis'] as List<String>?;
  if (supportedAbis != null && supportedAbis.isNotEmpty) {
    final primaryAbi = supportedAbis.first; // e.g., 'arm64-v8a'
    Log.info('Arsitektur utama perangkat adalah: $primaryAbi');

    // Logika selanjutnya, misalnya membandingkan dengan ApkVersionModel
    // untuk menemukan URL unduhan APK yang benar.
  }
}
```

Dokumentasi ini menjelaskan peran `InfoPerangkatService` sebagai jembatan yang aman dan teruji antara aplikasi dan informasi perangkat keras, yang sangat penting untuk fungsionalitas pembaruan aplikasi yang andal.
