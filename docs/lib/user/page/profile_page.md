# Dokumentasi: `lib/user/page/profile_page.dart`

`ProfilePage` adalah halaman yang berfungsi sebagai dasbor utama bagi pengguna aplikasi. Halaman ini menampilkan informasi personal pengguna, ringkasan poin, dan detail paket langganan yang sedang aktif.

---

## Fungsionalitas Utama

1.  **Menampilkan Data Pengguna**: Mengambil dan menampilkan data pengguna yang sedang login, seperti nama lengkap.
2.  **Ringkasan Poin**: Menghitung dan menampilkan total poin yang dimiliki pengguna berdasarkan riwayat transaksi.
3.  **Informasi Langganan**: Menampilkan detail paket yang sedang aktif, termasuk sisa masa aktif dan status pembayaran.
4.  **Navigasi**: Memungkinkan pengguna untuk menavigasi ke halaman detail profil dan halaman poin.
5.  **Muat Ulang Data**: Mendukung fitur *pull-to-refresh* untuk memperbarui semua data yang ditampilkan.
6.  **Iklan**: Menampilkan banner iklan di bagian bawah halaman.

---

## Struktur dan Komponen

### `ProfilePage` (StatefulWidget)

-   **Parameter:**
    -   `userId` (String): ID unik dari Firestore Authentication untuk pengguna yang sedang login.
    -   `localStorageService` (LocalStorageService): Service untuk mengakses penyimpanan lokal (saat ini belum banyak digunakan di halaman ini).

### `_ProfilePageState` (State)

Kelas ini mengelola state dan logika untuk `ProfilePage`.

#### Properti State:

-   `_futureCustomer`: `Future<CustomerModel?>` untuk mengambil data pelanggan.
-   `_subscriptionHistoryFuture`: `Future<List<TransactionModel>>` untuk mengambil riwayat transaksi (digunakan untuk menghitung poin dan mencari langganan aktif).
-   `_futurePackageName`: `Future<String>` untuk mengambil nama paket berdasarkan `packageId`.

#### Metode Utama:

-   `_initializeData()`: Dipanggil di `initState` untuk memulai proses pengambilan data awal dari Firestore.
-   `_reloadData()`: Dipicu oleh `RefreshIndicator` untuk mengambil ulang semua data dari server.
-   `_navigateToDetail(String userId)`: Menavigasi ke halaman `UserCustomerDetailPage` untuk melihat atau mengedit detail profil.
-   `_navigateToPointsPage(String customerId)`: **(Baru Ditambahkan)** Menavigasi ke halaman `UserPointsPage` saat pengguna mengetuk item "Poin".
-   `build()`: Merender UI utama menggunakan `FutureBuilder` untuk menangani state *loading*, *error*, dan *success* saat mengambil data pelanggan.

#### Komponen UI (Helper Widgets):

-   `_buildInfoCard()`: Membuat widget `Card` yang terstruktur untuk menampilkan grup informasi (seperti "Informasi Pribadi").
-   `_buildInfoItem()`: Membuat baris informasi individual yang berisi ikon, label, dan nilai. Widget ini mendukung parameter `onTap` untuk aksi navigasi.

## Alur Pengambilan Data

1.  `initState` memanggil `_initializeData`.
2.  `_customerOp.getCustomerOnce(userId)` dipanggil untuk mendapatkan data pelanggan.
3.  Setelah data pelanggan didapat, `_transactionOp.getSubscriptionHistory(customerId)` dipanggil untuk mendapatkan semua riwayat transaksi.
4.  `FutureBuilder` utama (`_futureCustomer`) akan merender UI setelah data pelanggan siap.
5.  Di dalam UI, `FutureBuilder` sekunder (`_subscriptionHistoryFuture`) digunakan untuk:
    -   Menghitung total poin dengan menjumlahkan `earnedPoints` dan mengurangi `usedPoints`.
    -   Mencari paket langganan yang masih aktif.
    -   Menampilkan informasi terkait langganan seperti sisa masa aktif.

## Perubahan Terbaru

-   **Navigasi Poin**: Menambahkan fungsi `onTap` pada item "Poin". Saat diketuk, aplikasi akan menavigasi pengguna ke `UserPointsPage` untuk melihat detail poin dan riwayatnya. Ini diimplementasikan dengan menambahkan metode `_navigateToPointsPage` dan memanggilnya dari `_buildInfoItem`.
