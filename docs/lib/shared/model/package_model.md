
# Dokumentasi: PackageModel

## Lokasi File
`lib/shared/model/package_model.dart`

## Ringkasan
`PackageModel` adalah model data yang merepresentasikan produk atau layanan yang ditawarkan kepada pelanggan dalam bentuk paket. Setiap paket memiliki atribut seperti nama, harga, durasi, dan tipe durasi (misalnya, jam, hari, bulan). Selain itu, model ini juga mendukung fitur loyalitas dengan menyertakan poin hadiah (`rewardPoints`) yang didapat pelanggan saat membeli paket dan poin yang dibutuhkan untuk menukarkan (`redemptionPoints`) paket.

Model ini dirancang untuk dapat disimpan dan diambil dari **SQLite** (lokal di aplikasi admin) dan **Firebase** (untuk ditampilkan di aplikasi user dan disinkronkan).

## Penggunaan
-   `PackageOperation`: Mengelola operasi CRUD untuk data paket di database lokal.
-   `PackageOpFirebase`: Mengelola sinkronisasi data paket ke Firebase.
-   `PackageForm`: Form di aplikasi admin untuk membuat atau mengedit paket layanan.
-   `PackageSelectionPage` (Aplikasi User): Halaman di mana pengguna dapat melihat dan memilih paket yang ingin mereka beli.
-   `TransactionForm`: Saat membuat transaksi penjualan, admin akan memilih paket dari daftar yang tersedia, yang datanya berasal dari `PackageModel`.
-   `PointRedemptionPage` (Aplikasi User): Menampilkan paket yang dapat ditukarkan dengan poin.

## Detail Kolom
| Nama Kolom | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | ID unik untuk setiap paket. | Dihasilkan otomatis menggunakan `Uuid().v4()`. |
| `name` | `String` | Nama paket (contoh: "Paket Hemat 1 Bulan"). | Wajib diisi. |
| `price` | `int` | Harga paket dalam mata uang Rupiah. | Wajib diisi. |
| `duration` | `int` | Nilai durasi paket (misal: 30, jika `type` adalah `days`). | Wajib diisi. |
| `type` | `DurationType`| Tipe dari durasi, seperti `hours`, `days`, `months`. | Menggunakan enum `DurationType`. |
| `rewardPoints` | `int` | Jumlah poin yang diberikan kepada pelanggan setelah membeli paket ini. | Default `0`. |
| `redemptionPoints`| `int` | Jumlah poin yang dibutuhkan untuk menukarkan (mendapatkan) paket ini secara gratis. | Default `0`. |
| `isPublic` | `bool` | Status apakah paket ini akan ditampilkan secara publik kepada semua pengguna. | Default `true`. |
| `updatedAt` | `DateTime?` | Waktu terakhir data ini diperbarui. | |
| `isDeleted` | `bool` | Status hapus sementara (soft delete). | Default `false`. |
| `archivedAt` | `DateTime?` | Waktu data ini diarsipkan. | |

## Metode Utama

### `PackageModel.fromSqlite(Map<String, dynamic> map)`
Factory constructor untuk membuat instance `PackageModel` dari data `Map` SQLite.

### `Map<String, dynamic> toSqlite()`
Mengonversi `PackageModel` menjadi `Map` untuk disimpan di database SQLite.

### `PackageModel.fromFirebase(String id, Map<String, dynamic> data)`
Factory constructor untuk membuat instance `PackageModel` dari data `Map` Firestore.

### `Map<String, dynamic> toFirebase()`
Mengonversi `PackageModel` menjadi `Map` yang siap disimpan atau diperbarui di Firestore.

### `copyWith({...})`
Membuat salinan dari objek `PackageModel` dengan beberapa field yang diperbarui, untuk menjaga imutabilitas.

## Contoh Penggunaan
```dart
// Admin membuat paket baru
final monthlyPackage = PackageModel(
  name: 'Internet Super Cepat 1 Bulan',
  price: 150000,
  duration: 1,
  type: DurationType.months,
  rewardPoints: 100,
  redemptionPoints: 10000,
  isPublic: true,
);

// Menyimpan ke Firebase
final firebaseMap = monthlyPackage.toFirebase();
// await firestore.collection('packages').doc(monthlyPackage.id).set(firebaseMap);

// User melihat paket di aplikasi
// final doc = await firestore.collection('packages').doc('some-id').get();
// final package = PackageModel.fromFirebase(doc.id, doc.data()!);
// print('Beli ${package.name} dengan harga Rp${package.price} dan dapatkan ${package.rewardPoints} poin!');
```

Dokumentasi ini menguraikan bagaimana produk/layanan aplikasi distrukturkan, dihargai, dan dikelola, yang merupakan inti dari model bisnis aplikasi ini.
