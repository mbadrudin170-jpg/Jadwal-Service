# Dokumentasi: `lib/shared/model/settings_model.dart`

`SettingsModel` adalah model data yang merepresentasikan pengaturan (konfigurasi) global aplikasi. Model ini dirancang sebagai *singleton* dalam database, artinya hanya ada satu dokumen atau baris data untuk pengaturan di seluruh aplikasi, yang diidentifikasi dengan ID unik `global_config`.

---

## Properti

-   `id` (String): ID unik untuk dokumen pengaturan, selalu diatur ke `globalSettingsId` (`'global_config'`).
-   `autoSyncInterval` (int): Interval (dalam jam) untuk sinkronisasi otomatis. Nilai defaultnya adalah 24 jam.
-   `autoDeleteArchiveDays` (int): Jumlah hari sebelum data yang diarsipkan dihapus secara otomatis. Nilai defaultnya adalah 30 hari.
-   `maintenanceMode` (bool): Penanda untuk mengaktifkan atau menonaktifkan mode pemeliharaan (maintenance) aplikasi. Jika `true`, aplikasi mungkin akan membatasi fungsionalitas tertentu. Nilai defaultnya adalah `false`.
-   `maintenanceInfo` (String): Pesan atau informasi yang akan ditampilkan kepada pengguna saat aplikasi berada dalam mode pemeliharaan.
-   `updatedAt` (DateTime?): Waktu terakhir data pengaturan diperbarui.

---

## Metode

### `copyWith()`
Membuat salinan dari instance `SettingsModel` dengan beberapa nilai yang dapat diubah. Berguna untuk pembaruan state yang *immutable*.

### `fromSqlite(Map<String, dynamic> map)`
*Factory constructor* untuk membuat instance `SettingsModel` dari data yang berasal dari database SQLite. Mengonversi nilai integer `0` atau `1` dari database menjadi `bool` untuk `maintenanceMode`.

### `toSqlite()`
Mengonversi instance `SettingsModel` menjadi `Map<String, dynamic>` untuk disimpan ke SQLite. Mengonversi `maintenanceMode` (bool) menjadi `integer` (0 atau 1).

### `fromFirebase(Map<String, dynamic> data)`
*Factory constructor* untuk membuat instance `SettingsModel` dari data yang diambil dari Firestore.

### `toFirebase()`
Mengonversi instance `SettingsModel` menjadi `Map<String, dynamic>` untuk disimpan ke Firestore. `DateTime` dikonversi menjadi `Timestamp`.

---

## Konsep dan Penggunaan

`SettingsModel` memungkinkan admin untuk mengontrol perilaku aplikasi dari jarak jauh tanpa perlu merilis pembaruan aplikasi. Contohnya:

-   **Mode Pemeliharaan**: Admin dapat mengaktifkan `maintenanceMode` melalui Firebase. Aplikasi klien (baik admin maupun user) akan membaca pengaturan ini dan menampilkan layar pemeliharaan, mencegah pengguna mengakses aplikasi saat ada perbaikan atau pembaruan sistem di sisi server.
-   **Konfigurasi Sinkronisasi**: Mengubah `autoSyncInterval` dapat menyesuaikan seberapa sering aplikasi di perangkat klien melakukan sinkronisasi data dengan server.

Karena bersifat global, operasi pada model ini biasanya melibatkan pengambilan atau pembaruan satu dokumen tunggal di Firestore atau satu baris data di SQLite.
