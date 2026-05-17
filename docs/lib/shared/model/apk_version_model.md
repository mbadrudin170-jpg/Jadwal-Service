
# Dokumentasi: ApkVersionModel

## Lokasi File
`lib/shared/model/apk_version_model.dart`

## Ringkasan
`ApkVersionModel` adalah model data yang bertanggung jawab untuk menyimpan dan mengelola informasi terkait versi aplikasi. Model ini krusial untuk fitur pemeriksaan pembaruan (update) di dalam aplikasi, baik untuk admin maupun pengguna. Informasi yang dikelola mencakup nomor versi terbaru, catatan rilis (changelog), tautan unduhan untuk berbagai arsitektur CPU, dan penanda apakah pembaruan bersifat wajib.

Model ini didesain untuk sinkronisasi antara database lokal (SQLite) dan cloud (Firebase), memastikan bahwa informasi versi yang ditampilkan kepada pengguna selalu konsisten dan terpusat.

## Penggunaan
Model ini terutama digunakan oleh:
-   `ApkVersionOperation`: Untuk melakukan operasi CRUD pada data versi aplikasi di database lokal.
-   `InfoApkPageUser`: Halaman di aplikasi user yang menampilkan informasi versi saat ini dan pilihan untuk memperbarui.
-   `ApkVersionForm`: Form di aplikasi admin untuk membuat atau mengedit entri versi aplikasi baru.
-   `KontrolAplikasiService`: Servis yang memeriksa apakah ada pembaruan baru yang tersedia saat aplikasi dimulai.

## Detail Kolom
| Nama Kolom | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | ID unik untuk setiap entri versi. | Dihasilkan otomatis menggunakan `Uuid().v4()`. |
| `releaseNotes` | `String` | Catatan rilis atau changelog untuk versi ini. | Berisi penjelasan tentang perubahan dan fitur baru. |
| `latestBuildNumber`| `Map<ApkArchitectureEnum, int>` | Peta yang menyimpan nomor build terbaru untuk setiap arsitektur APK (misal: `arm64-v8a`, `armeabi-v7a`). | Kunci adalah enum `ApkArchitectureEnum`, nilai adalah `int`. |
| `downloadLinks` | `Map<ApkArchitectureEnum, String>`| Peta yang menyimpan tautan unduhan APK untuk setiap arsitektur. | Kunci adalah enum `ApkArchitectureEnum`, nilai adalah URL unduhan. |
| `latestVersion` | `String` | Nomor versi yang ditampilkan kepada pengguna (contoh: "1.0.2"). | |
| `isUpdateRequired` | `bool` | Penanda apakah pembaruan ke versi ini wajib. | Jika `true`, pengguna akan dipaksa untuk memperbarui. |
| `youtubeTutorial` | `String` | Tautan ke video tutorial YouTube yang relevan dengan versi ini. | Opsional. |
| `isDeleted` | `bool` | Status hapus sementara (soft delete). | `true` jika dianggap terhapus. Default `false`. |
| `archivedAt` | `DateTime?` | Waktu data ini diarsipkan. | |
| `updatedAt` | `DateTime?` | Waktu terakhir data ini diperbarui. | |

## Metode Utama

### `ApkVersionModel.fromSqlite(Map<String, dynamic> map)`
Factory constructor untuk membuat instance dari data `Map` SQLite. Metode ini secara khusus menangani deserialisasi data `Map` yang disimpan sebagai JSON string di dalam kolom SQLite (untuk `latestBuildNumber` dan `downloadLinks`).

### `Map<String, dynamic> toSqlite()`
Mengonversi model menjadi `Map` untuk penyimpanan SQLite. Data `Map` (`latestBuildNumber` dan `downloadLinks`) di-encode menjadi JSON string sebelum disimpan ke dalam database.

### `ApkVersionModel.fromFirebase(String id, Map<String, dynamic> map)`
Factory constructor untuk membuat instance dari data `Map` Firestore. Metode ini melakukan parsing `Timestamp` menjadi `DateTime` dan memetakan struktur data `Map` dari Firebase.

### `Map<String, dynamic> toFirebase()`
Mengonversi model menjadi `Map` untuk penyimpanan di Firestore. Metode ini secara langsung memetakan `Map` Dart ke `Map` Firestore tanpa perlu serialisasi JSON.

### `copyWith({...})`
Membuat salinan dari objek `ApkVersionModel` dengan kemampuan untuk menimpa nilai field tertentu. Ini berguna untuk menjaga imutabilitas saat memperbarui state.

## Contoh Penggunaan
```dart
// Membuat entri versi baru dari panel admin
final newVersion = ApkVersionModel(
  latestVersion: '2.1.0',
  releaseNotes: 'Perbaikan bug dan peningkatan performa.',
  isUpdateRequired: false,
  latestBuildNumber: {
    ApkArchitectureEnum.arm64v8a: 15,
    ApkArchitectureEnum.armeabiv7a: 15,
  },
  downloadLinks: {
    ApkArchitectureEnum.arm64v8a: 'http://example.com/app-arm64.apk',
    ApkArchitectureEnum.armeabiv7a: 'http://example.com/app-armeabi.apk',
  },
  youtubeTutorial: 'https://youtube.com/watch?v=tutorial',
);

// Menyimpan ke Firebase
final firebaseMap = newVersion.toFirebase();
// await firestore.collection('apk_versions').doc(newVersion.id).set(firebaseMap);

// Membaca dari SQLite dan memeriksa pembaruan
// final modelFromDb = ApkVersionModel.fromSqlite(sqliteMap);
// if (localBuildNumber < modelFromDb.latestBuildNumber[userArchitecture]) {
//   // Tampilkan dialog pembaruan
// }
```

Dokumentasi ini membantu developer memahami bagaimana informasi versi dikelola dan disinkronkan, serta bagaimana cara berinteraksi dengan model ini untuk fitur-fitur terkait pembaruan aplikasi.
