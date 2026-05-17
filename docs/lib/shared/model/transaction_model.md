
# Dokumentasi: TransactionModel

## Lokasi File
`lib/shared/model/transaction_model.dart`

## Ringkasan
`TransactionModel` adalah model data paling kompleks dan sentral dalam aplikasi ini. Model ini merepresentasikan setiap catatan pergerakan keuangan, baik itu pemasukan, pengeluaran, transfer antar dompet, maupun transaksi yang lebih spesifik seperti pembelian paket langganan (subscription).

Karena kompleksitasnya, model ini memiliki banyak field yang bersifat opsional dan hanya digunakan untuk tipe transaksi tertentu. Contohnya, `destinationWalletId` hanya relevan untuk transaksi tipe `transfer`, sementara `packageId`, `startDate`, dan `endDate` hanya relevan untuk transaksi tipe `subscription`.

Model ini didesain untuk bisa disimpan baik di **SQLite** pada perangkat admin maupun di **Firebase** untuk sinkronisasi dan pencatatan terpusat.

## Penggunaan
-   `TransactionOperation`: Mengelola operasi CRUD (Create, Read, Update, Delete) untuk data transaksi di database lokal SQLite.
-   `TransactionOpFirebase`: Mengelola sinkronisasi data transaksi ke Firebase.
-   `TransactionForm`: Form utama di aplikasi admin untuk mencatat transaksi baru (pemasukan, pengeluaran, pembelian paket).
-   `TransactionHistoryPage`: Menampilkan daftar riwayat semua transaksi, baik di aplikasi admin maupun user.
-   `ActiveCustomerModel`: Dibuat atau diperbarui berdasarkan transaksi pembelian paket (`subscription`).
-   Berbagai laporan keuangan (harian, bulanan, per kategori) dihasilkan dari agregasi data `TransactionModel`.

## Detail Kolom
| Nama Kolom | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | ID unik untuk setiap transaksi. | Dihasilkan otomatis menggunakan `Uuid().v4()`. |
| `date` | `DateTime` | Tanggal dan waktu transaksi dicatat. | Wajib diisi. |
| `description` | `String` | Deskripsi atau catatan tambahan mengenai transaksi. | Wajib diisi. |
| `amount` | `double` | Jumlah nominal uang dari transaksi. | Wajib diisi. |
| `type` | `TransactionType` | Jenis transaksi: `income`, `expense`, `transfer`, `subscription`. | Enum, wajib diisi. |
| `walletId` | `String` | ID dari `WalletModel` (dompet) yang menjadi sumber dana. | Wajib diisi. |
| `categoryId` | `String` | ID dari `CategoryModel` yang mengklasifikasikan transaksi ini. | Wajib diisi. |
| `destinationWalletId` | `String?` | ID `WalletModel` tujuan, **hanya** untuk `type` = `transfer`. | Opsional. |
| `customerId` | `String?` | ID `CustomerModel` yang terkait dengan transaksi ini (misal: pembeli paket). | Opsional. |
| `packageId` | `String?` | ID `PackageModel`, **hanya** untuk `type` = `subscription`. | Opsional. |
| `subCategoryId` | `String?` | ID `SubCategoryModel` untuk klasifikasi yang lebih detail. | Opsional. |
| `paymentStatus` | `PaymentStatus` | Status pembayaran: `paid`, `unpaid`, `pending`. | Enum, default `unpaid`. |
| `earnedPoints` | `int` | Poin yang didapat dari transaksi ini. | Default `0`. |
| `usedPoints` | `int` | Poin yang digunakan/ditukar dalam transaksi ini. | Default `0`. |
| `packageDuration` | `int?` | Durasi paket yang dibeli (misal: 30). | Opsional, untuk `subscription`. |
| `durationType` | `DurationType?` | Tipe durasi paket (`days`, `months`, dll). | Opsional, untuk `subscription`. |
| `startDate` | `DateTime?` | Tanggal mulai periode aktif paket. | Opsional, untuk `subscription`. |
| `endDate` | `DateTime?` | Tanggal berakhir periode aktif paket. | Opsional, untuk `subscription`. |
| `isActivated` | `bool` | Menandakan apakah transaksi ini adalah aktivasi paket baru. | Default `false`. |
| `isDeleted` | `bool` | Status hapus sementara (soft delete). | Default `false`. |
| `updatedAt` | `DateTime?` | Waktu terakhir data diperbarui. | |
| `archivedAt` | `DateTime?` | Waktu data diarsipkan. | |

## Metode Utama

### `TransactionModel.fromSqlite(Map<String, dynamic> map)`
Factory constructor untuk membangun objek `TransactionModel` dari data `Map` yang dibaca dari SQLite. Termasuk logika parsing untuk enum dan tipe data lainnya.

### `Map<String, dynamic> toSqlite()`
Mengonversi objek `TransactionModel` menjadi `Map` yang siap untuk dimasukkan ke dalam tabel SQLite.

### `TransactionModel.fromFirebase(String id, Map<String, dynamic> data)`
Factory constructor untuk membangun objek dari dokumen Firestore. `id` dokumen digunakan sebagai `id` model.

### `Map<String, dynamic> toFirebase()`
Mengonversi objek `TransactionModel` menjadi `Map` untuk disimpan di Firestore. `DateTime` dikonversi menjadi `Timestamp`.

### `copyWith({...})`
Metode standar untuk membuat salinan objek dengan beberapa perubahan, sangat berguna dalam state management untuk menjaga imutabilitas.

## Contoh Penggunaan
```dart
// Admin mencatat pembelian paket oleh pelanggan
final subscriptionTx = TransactionModel(
  date: DateTime.now(),
  description: 'Pembelian Paket Internet 1 Bulan oleh Budi',
  amount: 150000,
  type: TransactionType.subscription,
  walletId: 'wallet-kas-id',
  categoryId: 'cat-penjualan-id',
  customerId: 'cust-budi-id',
  packageId: 'pkg-1-bulan-id',
  paymentStatus: PaymentStatus.paid,
  earnedPoints: 100,
  packageDuration: 30,
  durationType: DurationType.days,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(const Duration(days: 30)),
  isActivated: true,
);

// Menyimpan ke SQLite dan Firebase
final sqliteMap = subscriptionTx.toSqlite();
// await TransactionOperation.instance.insert(subscriptionTx, sqliteMap);

final firebaseMap = subscriptionTx.toFirebase();
// await TransactionOpFirebase.instance.add(subscriptionTx, firebaseMap);

// Setelah transaksi ini, sebuah ActiveCustomerModel akan dibuat/diperbarui untuk Budi.
```

Dokumentasi ini memberikan gambaran menyeluruh tentang struktur `TransactionModel` dan perannya yang krusial sebagai fondasi pencatatan aktivitas keuangan dan langganan di seluruh aplikasi.
