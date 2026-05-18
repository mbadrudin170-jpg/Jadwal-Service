# Dokumentasi: `lib/shared/model/wallet_model.dart`

`WalletModel` adalah model data yang merepresentasikan entitas "dompet" atau sumber dana di dalam aplikasi. Dompet ini digunakan untuk mencatat dari mana dana untuk sebuah transaksi berasal.

---

## Konsep

Dalam konteks aplikasi ini, "dompet" tidak selalu berarti dompet digital atau akun bank. Ini adalah representasi abstrak dari sumber dana. Contohnya bisa berupa:

-   `Tunai`
-   `Transfer Bank`
-   `Dompet Digital A`
-   `Kas Toko`

Admin dapat membuat dan mengelola berbagai jenis dompet ini. Ketika sebuah transaksi pembayaran dicatat, admin akan memilih dari dompet mana pembayaran tersebut diterima. Ini memungkinkan pelacakan pendapatan berdasarkan sumbernya.

---

## Properti

-   `id` (String): ID unik untuk setiap dompet, dihasilkan otomatis jika tidak disediakan.
-   `name` (String): Nama yang diberikan oleh pengguna untuk dompet ini (misalnya, "Tunai Kantor", "Bank BCA").
-   `balance` (double): Saldo saat ini dari dompet tersebut. Properti ini dapat digunakan untuk melacak jumlah uang yang ada di setiap sumber dana.
-   `updatedAt` (DateTime?): Waktu terakhir data dompet diperbarui.
-   `isDeleted` (bool): Penanda untuk *soft delete*. Jika `true`, dompet dianggap telah dihapus.
-   `archivedAt` (DateTime?): Waktu saat dompet diarsipkan.

---

## Metode

### `copyWith()`
Membuat salinan dari instance `WalletModel` dengan beberapa nilai yang dapat diubah.

### `fromSqlite(Map<String, dynamic> map)`
*Factory constructor* untuk membuat instance `WalletModel` dari data SQLite.

### `toSqlite()`
Mengonversi instance `WalletModel` menjadi `Map` untuk disimpan ke SQLite.

### `fromFirebase(String id, Map<String, dynamic> data)`
*Factory constructor* untuk membuat instance `WalletModel` dari data Firestore.

### `toFirebase()`
Mengonversi instance `WalletModel` menjadi `Map` untuk disimpan ke Firestore.

---

## Penggunaan

-   **Pencatatan Transaksi**: Saat admin mencatat pembayaran dari pelanggan, mereka akan memilih `WalletModel` yang sesuai untuk menerima dana tersebut. ID dompet ini kemudian disimpan di dalam `TransactionModel`.
-   **Laporan Keuangan**: Dengan data yang tercatat, aplikasi dapat menghasilkan laporan yang menunjukkan berapa banyak pendapatan yang masuk ke setiap dompet, memberikan gambaran yang lebih jelas tentang aliran kas.
-   **Manajemen Dana**: Admin dapat melihat saldo di setiap dompet, membantu mereka mengelola sumber daya keuangan.
