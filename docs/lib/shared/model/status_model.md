# Dokumentasi: `lib/shared/model/status_model.dart`

`StatusModel` adalah model data sederhana yang tujuan utamanya adalah untuk merekam waktu (timestamp) dari sebuah pembaruan atau kejadian. Seperti `SettingsModel`, model ini juga dirancang sebagai *singleton* dengan ID global `'global_status'`.

---

## Properti

-   `id` (String): ID unik untuk dokumen status, yang selalu diatur ke `globalStatusId` (`'global_status'`).
-   `updatedAt` (DateTime?): Waktu (timestamp) kapan status terakhir kali diperbarui.

---

## Metode

### `copyWith()`
Membuat salinan dari instance `StatusModel` dengan nilai `updatedAt` yang bisa diubah.

### `fromSqlite(Map<String, dynamic> map)`
*Factory constructor* untuk membuat instance `StatusModel` dari data SQLite.

### `toSqlite()`
Mengonversi instance `StatusModel` menjadi `Map` untuk disimpan ke SQLite.

### `fromFirebase(Map<String, dynamic> data)`
*Factory constructor* untuk membuat instance `StatusModel` dari data Firestore.

### `toFirebase()`
Mengonversi instance `StatusModel` menjadi `Map` untuk disimpan ke Firestore.

---

## Konsep dan Penggunaan

Model ini berfungsi sebagai mekanisme "penanda" atau *trigger* untuk sinkronisasi data.

### Alur Kerja Sinkronisasi:

1.  **Di Sisi Admin (Pembaruan)**:
    -   Setiap kali admin melakukan perubahan data yang signifikan (misalnya, menambah pelanggan baru, mengubah harga paket), aplikasi admin akan memperbarui dokumen `global_status` di Firestore dengan `updatedAt` yang baru (waktu saat ini).

2.  **Di Sisi Klien (Pengecekan)**:
    -   Aplikasi klien (bisa aplikasi admin lain atau aplikasi pengguna) secara berkala (misalnya, saat aplikasi dibuka atau setiap beberapa jam) akan memeriksa dokumen `global_status` di Firestore.
    -   Aplikasi klien membandingkan nilai `updatedAt` dari Firestore dengan nilai `updatedAt` yang disimpannya secara lokal (di SQLite).
    -   Jika `updatedAt` di Firestore **lebih baru** daripada yang disimpan secara lokal, itu berarti ada data baru di server yang perlu diunduh.
    -   Aplikasi klien kemudian akan memicu proses sinkronisasi (mengunduh data baru) dan setelah selesai, memperbarui timestamp `updatedAt` lokalnya agar sesuai dengan yang ada di server.

Dengan cara ini, `StatusModel` menjadi cara yang efisien untuk memberitahu semua klien bahwa ada pembaruan data di server tanpa harus memeriksa setiap tabel atau koleksi satu per satu.
