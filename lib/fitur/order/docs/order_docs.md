// path: lib/fitur/order/docs/order_docs.md

# Dokumentasi Fitur Order

Berikut adalah dokumentasi untuk semua fungsionalitas yang terkait dengan fitur order.

## Struktur Direktori

```
lib/fitur/order/
├── docs/
│   └── order_docs.md
├── model/
│   ├── order_model.dart
│   └── order_model.freezed.dart
├── operasi/
│   └── order_op_firebase.dart
├── provider/
│   ├── order_provider_gabungan.dart
│   └── order_provider_gabungan.g.dart
└── ui/
    └── order_page.dart
```

---

## Fungsionalitas Utama

### 1. Menampilkan Daftar Order (`Daftar Order`)

-   **Tujuan**: Menampilkan semua order yang belum dihapus (`isDeleted == 0`).
-   **Peran Admin**: Mengambil dan menampilkan seluruh data order dari database.
-   **Peran User**: Hanya mengambil dan menampilkan order yang `userId`-nya cocok dengan `userId` pengguna yang sedang login (didapat dari `userIdProvider`).

### 2. Menyortir Daftar (`Tombol Sortir`)

-   **Tujuan**: Memfilter dan mengurutkan daftar order berdasarkan `status` (misalnya: 'pending', 'completed', 'cancelled').

### 3. Mengubah Status Order (`Dialog Ubah Status`)

-   **Akses**: Fitur ini **hanya untuk Admin**.
-   **Pemicu**: Muncul ketika Admin melakukan `onLongPress` (tekan lama) pada salah satu item order.
-   **Alur**:
    1.  Setelah `onLongPress`, sebuah dialog opsi (`Dialog Opsi Ubah Status`) akan tampil.
    2.  Dialog ini berisi pilihan status baru untuk order tersebut.
    3.  Ketika Admin memilih salah satu status, nilai `status` pada data order di database akan diperbarui.
    4.  Sebuah dialog konfirmasi akan muncul untuk memastikan perubahan.
    5.  Setelah dikonfirmasi, semua dialog akan tertutup.
    6.  Daftar order pada UI akan otomatis diperbarui untuk menampilkan data terbaru.

### 4. Menghapus Order (`Fitur Hapus`)

-   **Tujuan**: Melakukan *soft delete* pada sebuah data order.
-   **Alur**:
    1.  Pengguna menekan tombol hapus.
    2.  Sebuah dialog konfirmasi akan muncul.
    3.  Jika dikonfirmasi, nilai `isDeleted` pada data order di database akan diubah menjadi `1`.

### 5. Pembaruan Data Real-time (`Update Otomatis`)

-   **Tujuan**: Memastikan UI selalu menampilkan data yang sinkron dengan database.
-   **Mekanisme**: Memberi notifikasi ke UI setiap kali ada perubahan data (data baru, data diubah, atau data dihapus). UI kemudian akan *rebuild* komponen yang relevan untuk mencerminkan perubahan tersebut, tanpa perlu me-rebuild seluruh halaman.

