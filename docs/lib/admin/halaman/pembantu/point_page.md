# Dokumentasi: `lib/admin/halaman/pembantu/point_page.dart`

`AdminPointsPage` adalah halaman di sisi admin yang berfungsi untuk melihat rincian poin dari seorang pelanggan spesifik. Halaman ini memiliki fungsionalitas yang identik dengan `UserPointsPage` tetapi dirancang untuk digunakan dalam konteks panel admin, biasanya diakses melalui halaman detail pelanggan.

---

## Fungsionalitas Utama

1.  **Menampilkan Total Poin**: Mengambil dan menampilkan jumlah total poin yang dimiliki pelanggan yang dipilih.
2.  **Daftar Penukaran Hadiah**: Menampilkan daftar hadiah yang dapat ditukarkan dengan poin.
3.  **Riwayat Poin**: Menampilkan riwayat transaksi yang melibatkan perolehan atau penggunaan poin untuk pelanggan tersebut.

---

## Struktur dan Komponen

### `AdminPointsPage` (StatefulWidget)

-   **Parameter:**
    -   `customerId` (String): ID unik pelanggan yang poinnya ingin dilihat oleh admin.

### `_AdminPointsPageState` (State)

Kelas ini mengelola pengambilan dan penampilan data poin untuk pelanggan yang dipilih.

#### Metode Utama:

-   `_loadPointsData()`: Mengambil data total poin dan daftar hadiah.
-   `_loadTransactionHistory()`: Mengambil riwayat transaksi poin pelanggan.
-   `build()`: Menggunakan widget `PoinPageUi` untuk merender tampilan utama, yang memastikan konsistensi visual dengan halaman poin di sisi pengguna.

#### Komponen UI (Helper Widgets):

-   `_buildRewardList()`: Membangun daftar hadiah yang tersedia untuk penukaran.
-   `_buildPointsHistory()`: Membangun daftar riwayat perolehan dan penggunaan poin.

## Pembaruan Terkini

-   **Sentralisasi Ikon**: Sejalan dengan pembaruan pada `UserPointsPage`, halaman ini juga telah diperbarui untuk menggunakan ikon terpusat dari `AppIcons`.
    -   `AppIcons.pointsAdd` digunakan untuk transaksi penambahan poin.
    -   `AppIcons.pointsRemove` digunakan untuk transaksi penggunaan poin.

    Perubahan ini menghilangkan dependensi langsung ke `Icons` dan memastikan konsistensi serta kemudahan pemeliharaan ikon di seluruh aplikasi.
