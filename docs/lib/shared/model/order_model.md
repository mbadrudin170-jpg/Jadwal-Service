# Dokumentasi: `lib/shared/model/order_model.dart`

`OrderModel` adalah model data yang merepresentasikan pesanan (order) yang dibuat oleh pelanggan. Ini digunakan untuk mencatat pesanan paket sebelum dikonversi menjadi transaksi aktif.

---

## Properti

-   `id` (String): ID unik untuk setiap pesanan, dihasilkan otomatis menggunakan UUID jika tidak disediakan.
-   `customerId` (String): ID pelanggan yang membuat pesanan.
-   `packageId` (String): ID paket yang dipesan.
-   `date` (DateTime): Tanggal dan waktu saat pesanan dibuat.
-   `status` (String): Status pesanan saat ini (misalnya, "new", "processing", "completed").
-   `updatedAt` (DateTime?): Waktu terakhir data pesanan diperbarui.
-   `isDeleted` (bool): Penanda untuk *soft delete*. Jika `true`, pesanan dianggap telah dihapus.
-   `archivedAt` (DateTime?): Waktu saat pesanan diarsipkan.

---

## Metode

### `copyWith()`
Membuat salinan dari instance `OrderModel` dengan beberapa nilai yang dapat diubah. Berguna untuk membuat objek baru berdasarkan yang sudah ada tanpa mengubah objek aslinya.

### `fromSqlite(Map<String, dynamic> map)`
*Factory constructor* untuk membuat instance `OrderModel` dari data yang berasal dari database SQLite. Metode ini mencakup logika untuk mengurai tipe data seperti `DateTime` dan `bool`.

### `toSqlite()`
Mengonversi instance `OrderModel` menjadi `Map<String, dynamic>` yang siap untuk disimpan ke dalam database SQLite. `DateTime` dikonversi menjadi *milliseconds since epoch* dan `bool` menjadi `integer` (1 atau 0).

### `fromFirebase(String id, Map<String, dynamic> data)`
*Factory constructor* untuk membuat instance `OrderModel` dari data yang berasal dari Firestore. ID dokumen dan datanya dipetakan ke properti model.

### `toFirebase()`
Mengonversi instance `OrderModel` menjadi `Map<String, dynamic>` untuk disimpan ke Firestore. `DateTime` dikonversi menjadi `Timestamp` Firestore.

---

## Penggunaan

Model ini sangat penting dalam alur pemesanan di aplikasi. Ketika seorang admin membuat "pesanan" untuk pelanggan, sebuah `OrderModel` akan dibuat. Pesanan ini kemudian dapat diproses, yang pada akhirnya dapat menghasilkan sebuah `TransactionModel` baru dan mengaktifkan langganan.
